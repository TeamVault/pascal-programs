{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Step02;

uses Strings, WinTypes, WinProcs, OWindows;

type
  PStepWindow = ^TStepWIndow;
  TStepWindow = object(TWindow)
    DragDC: HDC;
    HasChanged: Boolean;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    function CanClose: Boolean; virtual;
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMRButtonDown(var Msg: TMessage);
      virtual wm_First + wm_RButtonDown;
  end;
  TMyApplication = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

constructor TStepWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  inherited Init(AParent, ATitle);
  HasChanged := False;
end;

function TStepWindow.CanClose: Boolean;
var
  Reply: Integer;
begin
  CanClose := True;
  if HasChanged then
  begin
    Reply := MessageBox(HWindow, 'Do you want to save?',
      'Drawing has changed', mb_YesNo or mb_IconQuestion);
    if Reply = id_Yes then CanClose := False;
  end;
end;

procedure TStepWindow.WMLButtonDown(var Msg: TMessage);
var
  S: array[0..9] of Char;
begin
  wvsprintf(S, '(%d,%d)', Msg.LParam);
  DragDC := GetDC(HWindow);
  TextOut(DragDC, Msg.LParamLo, Msg.LParamHi, S, StrLen(S));
  ReleaseDC(HWindow, DragDC);
end;

procedure TStepWindow.WMRButtonDown(var Msg: TMessage);
begin
  InvalidateRect(HWindow, nil, True);
end;

procedure TMyApplication.InitMainWindow;
begin
  MainWindow := New(PStepWindow, Init(nil, 'Steps'));
end;

var
  MyApp: TMyApplication;

begin
  MyApp.Init('Steps');
  MyApp.Run;
  MyApp.Done;
end.