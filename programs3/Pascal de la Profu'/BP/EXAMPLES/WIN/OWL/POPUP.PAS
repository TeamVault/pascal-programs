{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program Popup;

uses WinTypes, WinProcs, Strings, OWindows;

{$R POPUP}

const

  cm_Window = 100;

type

  TSubWinType = (sw_Child, sw_PopParent, sw_PopNoParent);

  PSubWindow = ^TSubWindow;
  TSubWindow = object(TWindow)
    SubWinType: TSubWinType;
    constructor Init(AParent: PWindowsObject; ASubWinType: TSubWinType);
    destructor Done; virtual;
    procedure Paint(PaintDC: HDC; var PaintStruct: TPaintStruct); virtual;
  end;

  PMainWindow = ^TMainWindow;
  TMainWindow = object(TWindow)
    constructor Init(ATitle: PChar);
    procedure ShowSubWindow(AParent: PWindowsObject;
      ASubWinType: TSubWinType);
    procedure WMInitMenu(var Msg: TMessage);
      virtual wm_First + wm_InitMenu;
    procedure CMChild(var Msg: TMessage);
      virtual cm_First + cm_Window + Ord(sw_Child);
    procedure CMPopParent(var Msg: TMessage);
      virtual cm_First + cm_Window + Ord(sw_PopParent);
    procedure CMPopNoParent(var Msg: TMessage);
      virtual cm_First + cm_Window + Ord(sw_PopNoParent);
  end;

  TPopupApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

const

  SubWinPtr: array[TSubWinType] of PSubWindow = (nil, nil, nil);

  SubWinTitle: array[TSubWinType] of PChar = (
    'Child Window', 'Popup with Parent', 'Popup without Parent');

  SubWinStyle: array[TSubWinType] of Longint = (
    ws_Child or ws_OverlappedWindow or ws_Visible,
    ws_Popup or ws_OverlappedWindow or ws_Visible,
    ws_Popup or ws_OverlappedWindow or ws_Visible);

  SubWinPos: array[TSubWinType] of TPoint = (
    (X: 10; Y: 10), (X: 34; Y: 72), (X: 54; Y: 92));

  SubWinText: array[TSubWinType] of PChar = (
    'Child windows cannot be moved outside their parent window.  When ' +
      'minimized, a child window''s icon resides within the parent ' +
      'window.',
    'Popup windows can be moved outside their parent window.  A popup ' +
      'with a parent is always displayed in front of the parent, ' +
      'even when the parent is focused.  To test this, click on the ' +
      'parent window.  When minimized, popup icons reside on the desktop.',
    'Popup windows can be moved outside their parent window.  A popup ' +
      'without a parent allows the parent to be brought to the front ' +
      'when focused. To test this, click on the parent window.  When ' +
      'minimized, popup icons reside on the desktop.');

var

  PopupApp: TPopupApp;

{ TSubWindow }

constructor TSubWindow.Init(AParent: PWindowsObject;
  ASubWinType: TSubWinType);
begin
  TWindow.Init(AParent, SubWinTitle[ASubWinType]);
  Attr.Style := SubWinStyle[ASubWinType];
  Attr.X := SubWinPos[ASubWinType].X;
  Attr.Y := SubWinPos[ASubWinType].Y;
  Attr.W := 300;
  Attr.H := 150;
  SubWinType := ASubWinType;
end;

destructor TSubWindow.Done;
begin
  TWindow.Done;
  SubWinPtr[SubWinType] := nil;
end;

procedure TSubWindow.Paint(PaintDC: HDC; var PaintStruct: TPaintStruct);
var
  S: PChar;
  R: TRect;
begin
  GetClientRect(HWindow, R);
  InflateRect(R, -2, 0);
  S := SubWinText[SubWinType];
  DrawText(PaintDC, S, StrLen(S), R, dt_WordBreak);
end;

{ TMainWindow }

constructor TMainWindow.Init(ATitle: PChar);
begin
  TWindow.Init(nil, ATitle);
  Attr.X := 0;
  Attr.Y := 0;
  Attr.W := 400;
  Attr.H := 215;
  Attr.Menu := LoadMenu(HInstance, 'Menu');
end;

procedure TMainWindow.ShowSubWindow(AParent: PWindowsObject;
  ASubWinType: TSubWinType);
begin
  if SubWinPtr[ASubWinType] = nil then
    SubWinPtr[ASubWinType] := PSubWindow(Application^.MakeWindow(
      New(PSubWindow, Init(AParent, ASubWinType))))
  else
    SetFocus(SubWinPtr[ASubWinType]^.HWindow);
end;

procedure TMainWindow.WMInitMenu(var Msg: TMessage);
var
  Index: TSubWinType;
  MenuState: Word;
begin
  for Index := sw_Child to sw_PopNoParent do
  begin
    if SubWinPtr[Index] = nil then
      MenuState := mf_Unchecked else
      MenuState := mf_Checked;
    CheckMenuItem(Attr.Menu, cm_Window + Ord(Index), MenuState);
  end;
end;

procedure TMainWindow.CMChild(var Msg: TMessage);
begin
  ShowSubWindow(@Self, sw_Child);
end;

procedure TMainWindow.CMPopParent(var Msg: TMessage);
begin
  ShowSubWindow(@Self, sw_PopParent);
end;

procedure TMainWindow.CMPopNoParent(var Msg: TMessage);
begin
  ShowSubWindow(nil, sw_PopNoParent);
end;

{ TPopupApp }

procedure TPopupApp.InitMainWindow;
begin
  MainWindow := New(PMainWindow, Init('Parent Window'));
end;

{ Main program }

begin
  PopupApp.Init('Popup');
  PopupApp.Run;
  PopupApp.Done;
end.
