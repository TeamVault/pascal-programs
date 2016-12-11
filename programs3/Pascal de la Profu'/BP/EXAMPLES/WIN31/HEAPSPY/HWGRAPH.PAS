{$A-,B-,E-,F-,G+,I-,K-,N-,O-,P-,Q-,R-,S-,T+,V-,W-,X+}
{**********************************************}
{                                              }
{   HeapSpy - HWGraph Module                   }
{   Copyright (c) 1992  Borland International  }
{                                              }
{**********************************************}

unit HWGraph;

{$C MOVEABLE DEMANDLOAD DISCARDABLE}

interface

uses Wintypes, WinProcs, OWindows, Strings, Toolhelp, HWGlobal;

type
  PBarGraphWin = ^TBarGraphWin;
  TBarGraphWin = object(TWindow)
    GBrush, RBrush, YBrush, BBrush: hBrush;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    destructor Done; virtual;
    function GetClassName: PChar; virtual;
    procedure GetWindowClass(var WndClass: TWndClass); virtual;
    procedure Paint(PaintDC: hDC; var PaintStruct: TPaintStruct); virtual;
    procedure WMKeyDown(var Msg: TMessage);
      virtual wm_First + wm_KeyDown;
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;
    procedure RebuildGraph(var Msg: TMessage);
      virtual cm_First + cm_Rebuild;
  end;

implementation

constructor TBarGraphWin.Init;
begin
  inherited Init(AParent, ATitle);
  GBrush := CreateSolidBrush($00008000);
  BBrush := CreateSolidBrush($00800000);
  RBrush := CreateSolidBrush($00000080);
  YBrush := CreateSolidBrush($0000FFFF);
end;

destructor TBarGraphWin.Done;
begin
  DeleteObject(RBrush);
  DeleteObject(GBrush);
  DeleteObject(YBrush);
  DeleteObject(BBrush);
  inherited Done;
end;

procedure TBarGraphWin.WMKeyDown;
var
  CtrlPress: Boolean;
begin
  CtrlPress := GetKeyState(vk_Control) < 0;
  if Scroller <> nil then
  with Scroller^ do
    case Msg.wParam of
      vk_Up:    ScrollBy(0, -1);
      vk_Down:  ScrollBy(0, 1);
      vk_Left:  ScrollBy(-1 ,0);
      vk_Right: ScrollBy(1, 0);
      vk_Home:
        if not CtrlPress then
          ScrollTo(0, Ypos)
        else
          ScrollTo(0, 0);
      vk_End:
        if not CtrlPress then
          ScrollTo(XRange, YPos)
        else
          ScrollTo(XRange, YRange);
      vk_Prior: ScrollBy(0, -YPage);
      vk_Next:  ScrollBy(0, YPage);
    end;
end;

procedure TBarGraphWin.WMSize;
begin
  inherited WMSize(Msg);
end;

type
  THeapSizes = record
    hsCode: LongInt;
    hsCodeLocked: LongInt;
    hsData: LongInt;
    hsDataLocked: LongInt;
    hsOther: LongInt;
    hsOtherLocked: LongInt;
    hsFree: LongInt;
    hsTotal: LongInt;
  end;

procedure ComputeHeapSizes(var HS :THeapSizes);
var
  G: TGlobalEntry;
  TotalHeap: LongInt;
  MM: TMemManInfo;
begin
  FillChar(HS,Sizeof(HS),0);
  TotalHeap := 0;
  G.dwSize := Sizeof(TGlobalEntry);
  GlobalFirst(@G,GLOBAL_ALL);
  repeat
    Inc(TotalHeap,G.dwBlockSize);
    with G do
      case wType of
        gt_Code:
          if wcPageLock = 0 then
            Inc(HS.hsCode, dwBlockSize)
          else
            Inc(HS.hsCodeLocked, dwBlockSize);
        gt_Data,gt_DGroup,gt_Unknown:
           if wcPageLock = 0 then
             Inc(HS.hsData, dwBlockSize)
           else
             Inc(HS.hsDataLocked, dwBlockSize);
        gt_Free:
           Inc(HS.hsFree, dwBlockSize);
      else
        if wcPageLock = 0 then
          Inc(HS.hsOther, dwBlockSize)
        else
          Inc(HS.hsOtherLocked, dwBlockSize);
      end;
  until not GlobalNext(@G, global_All);
  with HS do
  begin
    hsTotal := TotalHeap div 1024;
    hsCode := hsCode div 1024;
    hsCodeLocked := hsCodeLocked div 1024;
    hsData := hsData div 1024;
    hsDataLocked := hsDataLocked div 1024;
    hsOther :=  hsOther div 1024;
    hsOtherLocked := hsOtherLocked div 1024;
    hsFree := hsFree div 1024;
  end;
end;

procedure TBarGraphWin.Paint(PaintDC: HDC; var PaintStruct: TPaintStruct);
var
  Rect: TRect;
  HeapSizes: THeapSizes;
  OldBrush: hBrush;
  OldPen,DashPen  : hPen;
  OldAlign: Word;
  YInc,YPos,i: Integer;
  Temp: array[0..11] of char;
const
  yOfs: Integer = 2000;
begin
  ComputeHeapSizes(HeapSizes);
  GetClientRect(hWindow, Rect);
  SetMapMode(PaintDC, mm_Anisotropic);
  YOfs := HeapSizes.hsTotal div 10;
  SetWindowExt(PaintDC, 19000, (yOfs * 2) + HeapSizes.hsTotal);
  SetViewPortExt(PaintDC, Rect.Right, -Rect.Bottom);
  SetViewPortOrg(PaintDC, 0, Rect.Bottom);
  SetBKMode(PaintDC, Transparent);
  with HEapSizes do
  begin

    {- Draw Bounding Rectangle}
    OldBrush := SelectObject(PaintDC, GetStockObject(ltGray_Brush));
    Rectangle(PaintDC, 1000, Yofs, 18000, yOfs + HeapSizes.hsTotal);

    {- Draw % lines }
    YInc := HeapSizes.hsTotal div 10;
    DashPen := CreatePen(ps_Dot, 1, 0);
    OldPen := SelectObject(PaintDC, DashPen);
    YPos := YOfs + YInc;
    for i := 1 to 9 do
    begin
      MoveTo(PaintDC,1000,YPos);
      LineTo(PaintDC,18000,YPos);
      Inc(YPos,YInc);
    end;
    SelectObject(PaintDC,OldPen);
    DeleteObject(DashPen);

    {- Draw bars of graph }
    SelectObject(PaintDc, BBRush);
    Rectangle(PaintDC, 1000, yOfs, 3000, yOfs + hsCode);
    Rectangle(PaintDC, 3000, yOfs, 5000, yOfs + hsCodeLocked);
    SelectObject(PaintDC, RBrush);
    Rectangle(PaintDC, 6000, yOfs, 8000, yOfs + hsData);
    Rectangle(PaintDC, 8000, yOfs, 10000, yOfs + hsDataLocked);
    SelectObject(PaintDC, GBrush);
    Rectangle(PaintDC, 11000, yOfs, 13000, yOfs + hsOther);
    Rectangle(PaintDC, 13000, yOfs, 15000, yOfs + hsOtherLocked);
    SelectObject(PaintDC, YBrush);
    Rectangle(PaintDC, 16000, yOfs, 18000, yOfs + hsFree);
    SelectObject(PaintDC, OldBrush);
    TextOut(PaintDC, 1000, yOfs, 'Code', 4);
    TExtOut(PaintDC, 6000, yOfs, 'Data', 4);
    TextOut(PaintDC, 11000, yOfs, 'Other', 5);
    TextOut(PaintDC, 16000, yOfs, 'Free', 4);
    SetTextAlign(PaintDC, ta_Bottom);
    Str(hsCode, Temp);
    TextOut(PaintDC, 1000, yOfs + hsCode, Temp, StrLen(Temp));
    Str(hsData, Temp);
    TExtOut(PaintDC, 6000, yOfs + hsData, Temp, StrLen(Temp));
    Str(hsOther, Temp);
    TextOut(PaintDC, 11000, yOfs + hsOther, Temp, StrLen(Temp));
    Str(hsFree, Temp);
    TextOut(PaintDC, 16000, yOfs + hsFree, Temp, StrLen(Temp));
  end;
end;

procedure TBarGraphWin.RebuildGraph;
begin
  InvalidateRect(hWindow,nil,false);
end;

procedure TBarGraphWin.GetWindowClass(var WndClass: TWndClass);
begin
  inherited GetWindowClass(WndClass);
  WndClass.hIcon := LoadIcon(hInstance, PChar(ico_Graph));
end;

function TBarGraphWin.GetClassName: PChar;
begin
  GetClassName := 'HWBarGraph';
end;

end.
