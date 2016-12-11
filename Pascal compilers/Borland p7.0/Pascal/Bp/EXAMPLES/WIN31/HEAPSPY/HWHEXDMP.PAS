{$A-,B-,E-,F-,G+,I-,K-,N-,O-,P-,Q-,R-,S-,T+,V-,W-,X+}

{**********************************************}
{                                              }
{   HeapSpy - HWHexDump Module                 }
{   Copyright (c) 1992  Borland International  }
{                                              }
{**********************************************}

unit HWHexDmp;

{$C MOVEABLE DEMANDLOAD DISCARDABLE}

interface

uses Wintypes, WinProcs, Objects, ODialogs, OWindows, Strings, HWGlobal;

type
  PHexDmpWin = ^THexDmpWin;
  THexDmpWin = object(TBasicHexWin)
    hMem: Word;
    StartOfs: LongInt;
    BlockSize: LongInt;
    procedure SetupWindow; virtual;
    constructor Init(AParent: PWindowsObject; AhMem: Word; AStartOfs: Word;
      ABlockSize: LongInt);
    procedure GetWindowClass(var WndClass: TWndClass); virtual;
    procedure WMKeyDown(var Msg: TMessage); virtual wm_first+wm_KeyDown;
    procedure Paint(PaintDC: hDC; var PaintStruct: TPaintStruct); virtual;
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;
    procedure WMSetFont(var Msg: TMessage);
      virtual wm_First + wm_SetFont;
  end;

implementation

type
  LongRemap = record
    case integer of
      0: (O,S: Word);
      1: (P: Pchar);
      2: (L: LongInt);
    end;

constructor THexDmpWin.Init;
var
  Temp: array[0..127] of Char;
  DC: hDc;
  TM: TTextMetric;
  PrevFont: THandle;
  ParRect: TRect;
begin
  hMem := (AhMem and $FFF8) or (CSeg and 7);
  if not IsValidSelector(hMem) then Fail;
  StartOfs := AStartOfs;
  BlockSize := ABlockSize;
  Inc(BlockSize,StartOFs);
  WVSPrintF(TEMP,'Block Dump - %#4X',hMem);
  inherited Init(AParent,Temp);
  DC := GetDC(0);
  PrevFont := SelectObject(DC,HexDumpFont);
  GetTextMetrics(DC,TM);
  SelectObject(DC,PrevFont);
  ReleaseDC(0,DC);
  with Attr do
  begin
    Style := Style or ws_vscroll or WS_HScroll ;
    w := tm.tmAveCharWidth*81;
    GetClientRect(Parent^.hWindow,ParRect);
    if w > ParRect.right then w := ParRect.right;
  end;
  Scroller := New(PScroller,Init(@Self,8,15,76,BlockSize div 16));
  Scroller^.XUnit := tm.tmAveCharWidth;
  Scroller^.YUnit := tm.tmHeight;
  { AutoOrg MUST be false so that the scrolling action can handle
    a block with more than 32K lines }
  Scroller^.AutoOrg := False;
end;

procedure THexDmpWin.WMSetFont;
var
  DC: hDc;
  TM: TTextMetric;
  PrevFont: THandle;
begin
  DC := GetDC(0);
  PrevFont := SelectObject(DC, Msg.wParam);
  GetTextMetrics(DC, TM);
  SelectObject(DC, PrevFont);
  ReleaseDC(0, DC);
  Scroller^.XUnit := tm.tmAveCharWidth;
  Scroller^.YUnit := tm.tmHeight;
  InvalidateRect(hWindow, nil, true);
end;

procedure THexDmpWin.SetupWindow;
begin
  inherited SetupWindow;
  Scroller^.SetPageSize;
end;

procedure THexDmpWin.GetWindowClass;
begin
  inherited GetWindowClass(WndClass);
  WndClass.hIcon := LoadIcon(hInstance, PChar(ico_hexdmp));
end;

procedure THexDmpWin.WMKeyDown;
var
  CtrlPress: boolean;
begin
  CtrlPress := GetKeyState(VK_CONTROL) < 0;
  if Scroller <> nil then
  with Scroller^ do
    case Msg.wParam of
      vk_Up: ScrollBy(0,-1);
      vk_Down: ScrollBy(0,1);
      vk_Left: ScrollBy(-1,0);
      vk_Right: ScrollBy(1,0);
      vk_Home: ScrollTo(0,Ypos);
      vk_End: ScrollTo(XRange,YPos);
      vk_Prior:
        if not CtrlPress then
          ScrollBy(0,-YPage)
        else
          ScrollTo(0,0);
      vk_Next:
        if not CtrlPress then
          ScrollBy(0,YPage)
        else
          ScrollTo(XRange,YRange);
    end;
end;

procedure THexDmpWin.WMSize;
const
  InProc: boolean = False;
var
  cx,cy: integer;
  R: TRect;
begin
  inherited WMSize(MSg);
  if hWindow <> 0 then
    if Scroller <> nil then
       with Scroller^ do
         SetRange(76-XPage,(BlockSize div 16)-Ypage);
end;

procedure HexByte(var Dest; chv: Char); assembler;
asm
	CLD
	LES	DI,Dest
	MOV	AL,chv
	MOV	AH,AL
	MOV	CX,4
	SHR	AL,CL
	OR	AL,$30
	CMP	AL,$39
	JBE	@1
	ADD	AL,7
@1:	STOSB
	SHR	AX,CL
	SHR	AL,CL
	OR 	AL,$30
	CMP	AL,$39
	JBE	@2
	ADD	AL,7
@2:	STOSB
end;

procedure THexDmpWin.Paint;
Var
  Mem: PChar;
  Temp: array[0..80] of Char;
  j,ti: Word;
  PrevFont: HFont;
  i,X1,Y1,Y2: LongInt;
  OldBKColor,
  OldTxtColor: Word;
  LO: LongRemap;
  Ch: Char;
begin
  FillChar(Temp,81,' ');
  PrevFont := SelectObject(PaintDC, HexDumpFont);
  OldBkColor := SetBkColor(PaintDC, GetSysColor(color_Window));
  OldTxtColor := SetTextColor(PaintDC, GetSysColor(color_WindowText));
  with Scroller^ do
  begin
    X1 := YPos;
    Y1 := X1+(PaintStruct.rcPaint.Top div YUnit);
    Y2 := X1+(PaintStruct.rcPaint.Bottom div YUnit);
    LO.L := (StartOfs and $FFF0)+(Y1*16);
    Mem := Ptr((LO.S shl 3)+hMem,0); {!!! WIN3.x dependent }
    for i := Y1 to y2 do
      if LO.L < BlockSize then
      begin
        HexPtr(Temp,@Mem[LO.O]);
        StrCat(Temp,'  ');
        ti := 11;
        for j := 0 to 15 do
        begin
          if (StartOfs > (LO.L+j)) or ((LO.L+j) >= BlockSize) then
          begin
            Ch := ' ';
            FillChar(Temp[ti],3,' ');
          end
          else
          begin
            Ch := Mem[LO.O+j];
            HexByte(Temp[ti],Ch);
          end;
          if Ch >= #32 then
            Temp[60+j] := Ch
          else
            Temp[60+j] := '.';
          Inc(ti,3);
        end;
        Temp[34] := '-';
        Temp[76] := #00;
        TextOut(PaintDC,(0-Xpos)*XUnit,(i-x1)*YUnit,Temp,76);
        if LO.O >= $FFF0 then
        begin
          Inc(LO.L,16);
          Mem := Ptr((LO.S shl 3)+hMem,0);  {!!! Win3.x dependant }
        end
        else
           Inc(LO.O,16);
      end;
  end;
  SelectObject(PaintDC,PrevFont);
  SetTextColor(PaintDC,OldTxtColor);
  SetBkColor(PaintDC,OldBkColor);
end;

end.
