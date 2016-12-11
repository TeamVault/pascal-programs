{$A-,B-,E-,F-,G+,I-,K-,N-,O-,P-,Q-,R-,S-,T+,V-,W-,X+}

{**********************************************}
{                                              }
{   HeapSpy - HWBitmap Module                  }
{   Copyright (c) 1992  Borland International  }
{                                              }
{**********************************************}

unit HWBitmap;

{$C MOVEABLE DEMANDLOAD DISCARDABLE}

interface

uses Wintypes, WinProcs, Objects, ODialogs, OWindows, Strings, HWGlobal;

type
  PBitmapWin = ^TBitMapWin;
  TBitmapWin = object(TWindow)
    RefObj: PWindowsObject;
    BitmapHandle: Word;
    PixelWidth,
    PixelHeight: Word;
    constructor Init(AParent: PWindowsObject; ARefObj: PWindowsObject;
      hMem: Word);
    destructor Done; virtual;
    procedure Paint(PaintDC: HDC; var PaintStruct: TPaintStruct); virtual;
    procedure WMKeyDown(var Msg: TMessage);
      virtual wm_First + wm_KeyDown;
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;
    procedure WMSetFocus(var Msg: TMessage);
      virtual wm_First + wm_SetFocus;
  end;

implementation

constructor TBitmapWin.Init;
var
  Temp: array[0..127] of char;
  BMP: PBitmapInfo;
  BI: TBitMap;
  BitsPtr: Pointer;
  DC: hDC;
  sz,bc: Word;
begin
  if not Odd(hMem) then Dec(hMem);
  BMP := Ptr(hMem,0);
  bc :=  BMP^.bmiHeader.biBitCount;
  sz := BMP^.bmiHeader.biSize;
  if sz = 12 then
    sz := sz + ((1 shl bc) * SizeOf(TRGBTriple))
  else
    sz := sz + ((1 shl bc) * SizeOf(TRGBQuad));
  RefObj := ARefObj;
  BitsPtr := Ptr(hMem, sz);
  DC := CreateDC('DISPLAY', nil, nil, nil);
  BitmapHandle := CreateDIBitmap(DC, BMP^.bmiheader, cbm_init, BitsPtr,
    BMP^, 0);
  DeleteDC(DC);
  if GetObject(BitmapHandle, SizeOf(TBitmap), @BI) = 0 then Fail;
  PixelWidth := BI.bmWidth;
  PixelHeight := BI.bmHeight;
  WVSPrintF(TEMP, 'Bitmap - %#4X', BitmapHandle);
  inherited Init(AParent,Temp);
  with Attr do
    Style := ws_vscroll or WS_HScroll;
  Scroller := New(PScroller, Init(@Self, 1, 1, PixelHeight, PixelWidth));
end;

destructor TBitmapWin.Done;
begin
  inherited Done;
  DeleteObject(BitmapHandle);
end;

procedure TBitmapWin.WMSetFocus;
begin
  DefWndProc(Msg);
  SetWindowPos(RefObj^.HWindow, HWindow, 0, 0, 0, 0, swp_NoMove or
    swp_NoSize or swp_NoActivate);
end;

procedure TBitmapWin.WMKeyDown;
var
  CtrlPress: Boolean;
begin
  CtrlPress := GetKeyState(vk_Control) < 0;
  if Scroller <> nil then
  with Scroller^ do
  case Msg.wParam of
    vk_Up:    ScrollBy(0,-1);
    vk_Down:  ScrollBy(0,1);
    vk_Left:  ScrollBy(-1,0);
    vk_Right: ScrollBy(1,0);
    vk_Home:
      if not CtrlPress then
        ScrollTo(0,Ypos)
      else
        ScrollTo(0,0);
    vk_End:
      if not CtrlPress then
        ScrollTo(XRange,YPos)
      else
        ScrollTo(XRange,YRange);
    vk_Prior: ScrollBy(0,-YPage);
    vk_Next:  ScrollBy(0,YPage);
    end;
end;

procedure TBitmapWin.WMSize;
begin
  inherited WMSize(Msg);
end;

procedure TBitMapWin.Paint(PaintDC: HDC; var PaintStruct: TPaintStruct);
var
  MemoryDC: HDC;
  OldBitmapHandle: THandle;
  ClientRect: TRect;
begin
  if BitmapHandle <> 0 then
  begin
    MemoryDC := CreateCompatibleDC(PaintDC);
    OldBitmapHandle := SelectObject(MemoryDC, BitmapHandle);
    BitBlt(PaintDC, 0, 0, PixelWidth, PixelHeight, MemoryDC, 0, 0,
      SrcCopy);
    SelectObject(MemoryDC, OldBitmapHandle);
    DeleteDC(MemoryDC);
  end;
end;


end.
