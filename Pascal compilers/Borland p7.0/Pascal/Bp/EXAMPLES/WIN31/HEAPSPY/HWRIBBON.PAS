{$A-,B-,E-,F-,G+,I-,K-,N-,O-,P-,Q-,R-,S-,T+,V-,W-,X+}

{**********************************************}
{                                              }
{   HeapSpy - HWRibbon Module                  }
{   Copyright (c) 1992  Borland International  }
{                                              }
{**********************************************}

unit HWRibbon;

{$C MOVEABLE PRELOAD PERMANENT}

interface

uses WinTypes, WinProcs, OWindows, ODialogs, Strings, HWGlobal;

type
  PRibbonWindow = ^TRibbonWindow;
  TRibbonWindow = object(TWindow)
    GrayBrush: HBrush;
    GrayPen, WhitePen: HPen;
    Height: Integer;
    HintText: array[0..80] of Char;
    Font: HFont;
    IsStockFont: Boolean;
    DefaultText: PChar;
    constructor Init(AParent: PWindowsObject);
    destructor Done; virtual;
    function GetClassName: PChar; virtual;
    procedure GetWindowClass(var WndClass: TWndClass); virtual;
    procedure Paint(PaintDC: hDC; var PS: TPaintStruct); virtual;
    procedure SetHelpText(Txt: PChar);
    procedure WMSetText(var Msg: TMessage);
      virtual wm_First + wm_SetText;
  end;

  PSpeedButton = ^TSpeedButton;
  TSpeedButton = object(TButton)
    BMP: hBitmap;
    Width,Height: word;
    constructor Init(AParent: PWindowsObject; AnID: Integer; x,y: Integer;
      ABitMap: PChar);
    destructor Done; virtual;
    function GetClassName: PChar; virtual;
    procedure GetWindowClass(var WndClass: TWndClass); virtual;
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMLButtonUp(var Msg: TMessage);
      virtual wm_First + wm_LButtonUp;
  end;

  PSpeedBar = ^TSpeedBar;
  TSpeedBar = object(TWindow)
    StatusLine: PWindowsObject;
    constructor Init(AParent: PWindowsObject; AStatusLine: PWindowsObject);
    function GetClassName: PChar; virtual;
    procedure GetWindowClass(var WndClass: TWndClass); virtual;
    procedure AddATool(AnID: Word; ABitMap: PChar);
    procedure WMDrawItem(var Msg: TMessage);
      virtual wm_First + wm_DrawItem;
    procedure WMSetFocus(var Msg: TMessage);
      virtual wm_First + wm_SetFocus;
    procedure WMCommand(var Msg: TMessage);
      virtual wm_First + wm_Command;
  end;

implementation

constructor TRibbonWindow.Init(AParent: PWindowsObject);
var
  DC: hDC;
  OldFont: HFont;
  TM: TTExtMetric;
  LogFont: TLogFont;
const
  WVSRec: record
    MajorV,
    MinorV,
    RevChar: Word;
    Copr: PChar;
  end = (
    MajorV:0;
    MinorV:0;
    RevChar:0;
    Copr:'Copyright © 1992 Borland International');
begin
  { basic initialization for a non-MDI Window in an MDI Frame }
  Inherited Init(AParent, '');      { create the window normally }
  HintText[0] := #0;
  SetFlags(wb_MDIChild, False);     { turn off the MDI flag that TWindow set }
  DefaultProc := @DefWindowProc;    { and redirect the DefaultProc back }
  Attr.Style := ws_Border or ws_Child or ws_Visible;

  { establish Font for use in this window }
  Font := GetStockObject(ANSI_VAR_FONT);
  GetObject(Font,Sizeof(TLogFont), @LogFont);
  LogFont.lfWeight := 700;
  Font :=CreateFontIndirect(LogFont);
  IsStockFont := false;

  { Determine the height of this window }
  DC := GetDC(0);
  OldFont := SelectObject(DC, Font);
  GetTextMetrics(DC, TM);
  Height := TM.tmHeight + 8;
  SelectObject(DC, OldFont);
  ReleaseDC(0, DC);

  { Make the pens and brushes used to draw the status line }
  GrayPen := CreatePen(PS_SOLID,1,$00808080);
  WhitePen := CreatePen(PS_Solid,1,$00FFFFFF);
  GrayBrush := CreateSolidBrush($00C0C0C0);

  { Set up the text displayed in the hint line when there's nothing
    of greater importance to display }
   WVSrec.MajorV := MajorVersion;
   WVSRec.MinorV := MinorVersion;
   WVSRec.RevChar := Byte(RevisionChar);
   WVSPrintf(HintText,'HeapSpy v%i.%#02i%c %s',WVSRec);
   DefaultText := StrNew(HintText);
   HintText[0] := #0;
end;

destructor TRibbonWindow.Done;
begin
  DeleteObject(GrayPen);
  DeleteObject(WhitePen);
  StrDispose(DefaultText);
  { -- this object is still part of the class, so don't delete!!
  DeleteObject(GrayBrush);
  }
  if not IsStockFont then DeleteObject(Font);
  inherited Done;
end;

function TRibbonWindow.GetClassName;
begin
  GetClassName := 'StatusWindow';
end;

procedure TRibbonWindow.GetWindowClass(var WndClass: TWndClass);
begin
  inherited GetWindowClass(WndClass);
  WndClass.hbrBackGround := GrayBrush;
end;

procedure TRibbonWindow.Paint;
var
  OldFont: HFont;
  OldPen : hPen;
  R: TRect;
begin
  GetClientRect(hWindow,R);
  with R do
  begin
    Inc(Left,4); Inc(top,2); Dec(Right,4);
    Dec(Bottom,3);
    SetBKMode(PaintDC, Transparent);
    OldPen := SelectObject(PaintDC, GrayPen);
    MoveTo(PaintDC, left,bottom);
    LineTo(PaintDC, left,top);
    LineTo(PaintDC, right,top);
    SelectObject(PaintDC, WhitePen);
    LineTo(PaintDC, right,bottom);
    LineTo(PaintDC, left,bottom);
  end;
  SelectObject(PaintDC, OldPen);
  SetTextColor(PaintDC, 0);
  OldFont := SelectObject(PaintDC, Font);
  with R do
    IntersectClipRect(PaintDC, left, top, right-2, bottom);
  if HintText[0] <> #0 then
    TextOut(PaintDC, 8, 3, HintText, StrLen(HintText))
  else
    TextOut(PaintDC, 8, 3, DefaultText, StrLen(DefaultText));
  SelectObject(PaintDC,OldFont);
end;

procedure TRibbonWindow.SetHelpText;
begin
  if Txt = nil then
    HintText[0] := #0
  else
    StrLCopy(HintText, Txt, 80);
  if hWindow <> 0 then
    InvalidateRect(hWindow, nil, True);
end;

procedure TRibbonWindow.WMSetText;
begin
  SetHelpText(PChar(Msg.lPAram));
end;

constructor TSpeedButton.Init(AParent: PWindowsObject; AnID: Integer;
  x,y: Integer; ABitMap: PChar);
var
  B: TBitMap;
begin
  BMP := LoadBitMap(hInstance,ABitMap);
  if BMP = 0 then Fail;
  GetObject(BMP,Sizeof(B), @B);
  Width := B.bmWidth;
  Height := B.bmHeight;
  inherited Init(AParent, AnID, '', x, y, Width, Height, False);
  Attr.Style := Attr.Style or bs_OwnerDraw;
end;

destructor TSpeedButton.Done;
begin
  inherited Done;
  if BMP <> 0 then DeleteObject(BMP);
end;

function TSpeedButton.GetClassName: PChar;
begin
  GetClassName := 'Button';
end;

procedure TSpeedButton.GetWindowClass(var WndClass: TWndClass);
begin
  inherited GetWindowClass(WndClass);
end;

procedure TSpeedButton.WMLButtonDown;
var
  HelpText: array[0..80] of Char;
begin
  if PSpeedBar(Parent)^.StatusLine <> nil then
  begin
    HelpText[0] := #0;
    LoadString(hInstance,Attr.ID,HelpText,80);
    SendMessage(PSpeedBar(Parent)^.StatusLine^.hWindow,
      wm_SetText, 0, LongInt(@HelpText));
  end;
  DefWndProc(Msg);
end;

procedure TSpeedButton.WMLButtonUp;
begin
   if PSpeedBar(Parent)^.StatusLine <> nil then
     SendMessage(PSpeedBar(Parent)^.StatusLine^.hWindow,
       wm_SetText, 0, 0);
   DefWndProc(Msg);
end;

{ Speedbar Methods }

constructor TSpeedBar.Init;
var
  i: Integer;
begin
  inherited Init(AParent,'');
  StatusLine := AStatusLine;
  Flags := Flags and (not wb_MDIChild);
  DefaultProc := @DefWindowProc;
  Attr.X := 0;
  Attr.Y := 0;
  Attr.W := 2;
  Attr.H := 0;
  Attr.Style := ws_Visible or ws_Child or ws_Border;
end;

function TSpeedBar.GetClassName: PChar;
begin
  GetClassName := 'SpeedBar';
end;

procedure TSpeedBar.GetWindowClass(var WndClass: TWndClass);
begin
  inherited GetWindowClass(WndClass);
  with WndClass do
    hbrBackGround := GetStockObject(LtGray_Brush);
end;

procedure TSpeedBar.AddATool(AnID: Word; ABitMap: PChar);
var
  Tool: PSpeedButton;
  NewWidth,i,x,y,Col: Integer;
begin
  x := Attr.W;
  y := 2;
  Tool := New(PSpeedButton,Init(@Self,AnID,x,y,ABitMap));
  if Tool = nil then exit;
  Inc(Attr.W,(Tool^.Width+2));
  if Attr.H < (Tool^.Height+6) then
    Attr.H := Tool^.Height+6;
end;

procedure TSpeedBar.WMDrawItem(var Msg: TMessage);
var
  Tool: PSpeedButton;
  MemDC: hDC;
  OldBMP: hBitmap;
  x,y: Integer;
begin
  with PDrawItemStruct(Msg.lParam)^ do
  begin
    Tool := PSpeedButton(ChildWithID(CtlID));
    MemDC := CreateCompatibleDC(hDC);
    OldBMP := SelectObject(MemDC,Tool^.BMP);
    if (ItemState and ODS_Selected) <> 0 then
    begin
      x := 1;
      y := 1;
    end
    else
    begin
      x := 0;
      y := 0;
    end;
    BitBlt(hDC, x, y, Tool^.Width - x * 2, Tool^.Height - y * 2, MemDC,
      0, 0, SrcCopy);
    SelectObject(MemDC,OldBMP);
    DeleteDC(MemDC);
  end;
end;

procedure TSpeedBar.WMSetFocus;
begin
  SetFocus(Msg.wParam);
end;

procedure TSpeedBar.WMCommand(var Msg: TMessage);
var
  MDIChild,MDIClient: hWnd;
begin
  if DescendantOf(TypeOf(TMDIWindow),TypeOf(Application^.MainWindow^)) then
  begin
    MDIClient := PMDIWindow(Application^.MainWindow)^.ClientWnd^.hWindow;
    MDIChild := SendMessage(MDIClient,WM_MDIGetActive,0,0);
    if MDIChild = 0 then MDIChild := MDIClient;
  end
  else
     MDIChild := Application^.MainWindow^.hWindow;
  SendMessage(MDIChild,WM_COMMAND,Msg.wParam,0);
end;

end.
