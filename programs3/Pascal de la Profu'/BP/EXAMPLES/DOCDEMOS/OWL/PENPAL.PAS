{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit PenPal;

interface

uses WinTypes, Objects, OWindows, ODialogs, Pen;

{$R PENPAL.RES}

const
  id_Add = 201;
  id_Del = 202;
  id_Lines = 6000;
  MaxPens = 9;

type
  PBitButton = ^TBitButton;
  TBitButton = object(TButton)
    procedure Disable;
    procedure Enable;
  end;

  PPenPic = ^TPenPic;
  TPenPic = object(TWindow)
    PenSet: PCollection;
    SelectedPen: Integer;
    UpPic, DownPic: HBitmap;
    constructor Init(AParent: PWindowsObject);
    destructor Done; virtual;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure AddPen(APen: PPen);
    procedure DeletePen;
    procedure SetupWindow; virtual;
    procedure WMLButtonDown(var Msg: TMessage); virtual wm_First + wm_LButtonDown;
  end;

  PPenPalette = ^TPenPalette;
  TPenPalette = object(TWindow)
    AddBtn, DelBtn: PBitButton;
    Pens: PPenPic;
    CurrentPen: PPen;
    constructor Init(AParent: PWindowsObject; ATitle: PChar; APen: PPen);
    destructor Done; virtual;
    function CanClose: Boolean; virtual;
    function GetClassName: PChar; virtual;
    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
    procedure Grow;
    procedure SetupWindow; virtual;
    procedure Shrink;
    procedure IDAdd(var Msg: TMessage); virtual id_First + id_Add;
    procedure IDDel(var Msg: TMessage); virtual id_First + id_Del;
    procedure WMNCActivate(var Msg: TMessage); virtual wm_First + wm_NCActivate;
  end;

implementation

uses WinProcs;


procedure TBitButton.Disable;
begin
  if HWindow <> 0 then EnableWindow(HWindow, False);
end;

procedure TBitButton.Enable;
begin
  if HWindow <> 0 then EnableWindow(HWindow, True);
end;

constructor TPenPalette.Init(AParent: PWindowsObject; ATitle: PChar; APen: PPen);
begin
  TWindow.Init(AParent, ATitle);
  with Attr do
  begin
    Style := Style or ws_PopupWindow or ws_Caption or ws_SysMenu;
    x := 0;
    Y := 0;
    W := 132;
    H := GetSystemMetrics(sm_CYCaption) + 42;
  end;
  AddBtn := New(PBitButton, Init(@Self, id_Add, '&Add pen', 0, 0, 65, 41, True));
  DelBtn := New(PBitButton, Init(@Self, id_Del, '&Del pen', 65, 0, 65, 41, False));
  CurrentPen := APen;
  Pens := New(PPenPic, Init(@Self));
end;

destructor TPenPalette.Done;
begin
  Dispose(Pens, Done);
  TWindow.Done;
end;

function TPenPalette.CanClose: Boolean;
begin
  Show(sw_Hide);
  CanClose := False;
end;

function TPenPalette.GetClassName: PChar;
begin
  GetClassName := 'PenPalette';
end;

procedure TPenPalette.GetWindowClass(var AWndClass: TWndClass);
begin
  TWindow.GetWindowClass(AWndClass);
  AWndClass.hbrBackground := GetStockObject(LtGray_Brush);
end;

procedure TPenPalette.Grow;
var
  WindowRect: TRect;
begin
  GetWindowRect(HWindow, WindowRect);
  with WindowRect do
    MoveWindow(HWindow, left, top, right - left, bottom - top + 40, True);
end;

procedure TPenPalette.SetupWindow;
begin
  TWindow.SetupWindow;
  DelBtn^.Disable;
end;

procedure TPenPalette.Shrink;
var
  WindowRect: TRect;
begin
  GetWindowRect(HWindow, WindowRect);
  with WindowRect do
    MoveWindow(HWindow, left, top, right - left, bottom - top - 40, True);
end;

procedure TPenPalette.IDAdd(var Msg: TMessage);
begin
  Pens^.AddPen(CurrentPen);
end;

procedure TPenPalette.IDDel(var Msg: TMessage);
begin
  Pens^.DeletePen;
end;

procedure TPenPalette.WMNCActivate(var Msg: TMessage);
begin
  Msg.wParam := 1;
  DefWndProc(Msg);
end;

constructor TPenPic.Init(AParent: PWindowsObject);
begin
  TWindow.Init(AParent, nil);
  Attr.Style := ws_Child or ws_Visible;
  PenSet := New(PCollection, Init(MaxPens, 0));
  SelectedPen := -1;
  UpPic := LoadBitmap(HInstance, 'PAL_UP');
  DownPic := LoadBitmap(HInstance, 'PAL_DOWN');
end;

destructor TPenPic.Done;
begin
  DeleteObject(UpPic);
  DeleteObject(DownPic);
  Dispose(PenSet, Done);
  TWindow.Done;
end;

procedure TPenPic.AddPen(APen: PPen);
begin
  SelectedPen := PenSet^.Count;
  PenSet^.Insert(New(PPen, InitLike(APen)));
  with PPenPalette(Parent)^ do
  begin
    DelBtn^.Enable;
    if PenSet^.Count >= MaxPens then
      AddBtn^.Disable;
    Grow;
  end;
end;

procedure TPenPic.DeletePen;
begin
  if SelectedPen > -1 then
  begin
    PenSet^.AtFree(SelectedPen);
    PenSet^.Pack;
    SelectedPen := -1;
    with PPenPalette(Parent)^ do
    begin
      AddBtn^.Enable;
      DelBtn^.Disable;
      Shrink;
    end;
  end;
end;

procedure TPenPic.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  PenCount: Integer;
  MemDC: HDC;
  TheBitmap, OrigBitmap: HBitmap;

  procedure ShowPen(P: PPen); far;
  begin
    Inc(PenCount);
    if PenCount = SelectedPen then
      TheBitmap := DownPic
    else TheBitmap := UpPic;
    SelectObject(MemDC, GetStockObject(LtGray_Brush));
    SelectObject(MemDC, TheBitmap);
    BitBlt(PaintDC, 0, PenCount * 40, 128, 40, MemDC, 0, 0, SrcCopy);

    P^.Select(PaintDC);
    MoveTo(PaintDC, 15, PenCount * 40 + 20);
    LineTo(PaintDC, 115, PenCount * 40 + 20);
    P^.Delete;
  end;

begin
  MemDC := CreateMemoryDC;
  OrigBitmap := SelectObject(MemDC, UpPic);
  PenCount := -1;
  PenSet^.ForEach(@ShowPen);
  SelectObject(MemDC, OrigBitmap);
  DeleteDC(MemDC);
end;

procedure TPenPic.SetupWindow;
var
  ClientRect: TRect;
begin
  TWindow.SetupWindow;
  GetClientRect(Parent^.HWindow, ClientRect);
  with ClientRect do
    MoveWindow(HWindow, 1, bottom - top + 1, 128,
      40 * MaxPens, False);
end;

procedure TPenPic.WMLButtonDown(var Msg: TMessage);
begin
  SelectedPen := Msg.LParamHi div 40;
  with PPen(PenSet^.At(SelectedPen))^ do
    PPenPalette(Parent)^.CurrentPen^.SetAttributes(Style, Width, Color);
  PPenPalette(Parent)^.DelBtn^.Enable;
  InvalidateRect(HWindow, nil, False);
end;

end.
