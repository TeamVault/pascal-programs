{************************************************}
{                                                }
{   Paradox Engine demo program                  }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ Note: This demo requires version 3.0 of the Paradox Engine. }

program PXDemo;

{$R PXDEMO.RES}
{$N+}

uses WinTypes, WinProcs, Strings, Objects, OWindows, OStdDlgs, 
  PXEngWin, PXMsg, PXAccess;

const
  BKColor   = $00FFFF00;
  ForeColor = $00000000;

const
  cm_FileClose = 100;

const
  MenuID      = 100;
  IconID      = 100;

type
  TParadoxDemo = object(TApplication)
    destructor Done; virtual;
    procedure InitMainWindow; virtual;
    procedure Error(errorCode: Integer); virtual;
  end;

  PParadoxTableWindow = ^TParadoxTableWindow;
  TParadoxTableWindow = object(TWindow)
    CharWidth: Integer;
    CharHeight: Integer;
    TableWidth: Integer;
    FixedFont: HFont;
    Table: PPXTable;
    FieldStarts: PWordArray;
    TitleBar: HBitmap;
    ColumnBar: HBitmap;
    constructor Init(AParent: PWindowsObject; TableName: PChar);
    destructor Done; virtual;
    procedure CloseTable;
    function GetClassName: PChar; virtual;
    procedure GetFixedFont(DC: HDC);
    procedure GetWindowClass(var WndClass: TWndClass); virtual;
    procedure Paint(DC: HDC; var PS: TPaintStruct); virtual;
    procedure SetupWindow; virtual;
    procedure CMFileClose(var Message: TMessage);
      virtual cm_First + cm_FileClose;
    procedure CMFileOpen(var Message: TMessage);
      virtual cm_First + cm_FileOpen;
    procedure WMKeyDown(var Msg: TMessage);
      virtual wm_First + wm_KeyDown;
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;
  end;

{ TParadoxDemo }

destructor TParadoxDemo.Done;
begin
  TApplication.Done;
  PXExit;
end;

procedure TParadoxDemo.InitMainWindow;
begin
  Status := PXWinInit('PXDemo', PXExclusive);
  if Status = PXSuccess then
    MainWindow := New(PParadoxTableWindow, Init(nil, 'Paradox Table Viewer'))
  else MessageBox(0, PXErrMsg(Status), 'PXDemo', mb_OK)
end;

procedure TParadoxDemo.Error(ErrorCode: Integer);
begin
  if Status < 0 then TApplication.Error(ErrorCode)
  else MessageBox(GetFocus, PXErrMsg(Status), 'WinTable', MB_OK);
end;

{ TParadoxTableWindow }

constructor TParadoxTableWindow.Init(AParent: PWindowsObject;
  TableName: PChar);
begin
  TWindow.Init(AParent, TableName);
  with Attr do
  begin
    Menu := LoadMenu(HInstance, MakeIntResource(MenuID));
    Style := Style or ws_VScroll or ws_HScroll;
    X := 25;
    Y := 40;
    W := 500;
    H := 350;
  end;
  Scroller := New(PScroller, Init(@Self, 1, 1, 0, 0));
  Scroller^.TrackMode := False;
  Scroller^.AutoOrg := False;
  Table := nil;
  FieldStarts := nil;
  TitleBar := 0;
  ColumnBar := 0;
end;

destructor TParadoxTableWindow.Done;
begin
  CloseTable;
  TWindow.Done;
end;

procedure TParadoxTableWindow.CloseTable;
begin
  if Table <> nil then
  begin
    FreeMem(FieldStarts, SizeOf(Word) * (Table^.NumFields + 2));
    FieldStarts := nil;
    Dispose(Table, Done);
    Table := nil;
    DeleteObject(TitleBar);
    InvalidateRect(HWindow, nil, True);
  end;
end;

procedure TParadoxTableWindow.CMFileClose(var Message: TMessage);
begin
  CloseTable;
end;

procedure TParadoxTableWindow.CMFileOpen(var Message: TMessage);
var
  Filename: array[0..128] of Char;
  I: Integer;
  DC, MemDC: HDC;
  OldBrush: HBrush;
  OldPen: HPen;
  R: TRect;
  SepX, SepY, TitleWidth: Integer;
  FieldStart, FieldEnd: Integer;

function Min(X,Y: Integer): Integer;
begin
  if X < Y then Min := X else Min := Y;
end;

begin
  if Application^.ExecDialog(New(PFileDialog, Init(@Self, PChar(sd_FileOpen),
    StrCopy(FileName, '*.db')))) = idOK then
  begin
    CloseTable;
    Table := New(PPXTable, Init(FileName));
    if Table^.Status <> 0 then
    begin
      Dispose(Table, Done);
      Table := nil;
    end
    else
    begin
      { Record Field starts }
      GetMem(FieldStarts, SizeOf(Word) * (Table^.NumFields + 2));
      FieldStarts^[1] := 0;
      for I := 2 to Table^.NumFields + 1 do
        FieldStarts^[I] := Table^.FieldWidth(I - 1) + FieldStarts^[I - 1] + 1;
      TableWidth := FieldStarts^[I];
      GetClientRect(HWindow, R);
      Scroller^.SetRange(TableWidth - R.right div CharWidth,
        Table^.NumRecords - R.bottom div CharHeight);

      { Create the title bar bitmap }
      DC := GetDC(HWindow);
      MemDC := CreateCompatibleDC(DC);
      ReleaseDC(HWindow, DC);
      TitleWidth := TableWidth * CharWidth;
      TitleBar := CreateCompatibleBitmap(DC, TitleWidth, CharHeight);
      SelectObject(MemDC, TitleBar);
      SelectObject(MemDC, FixedFont);
      SetTextColor(MemDC, ForeColor);
      SetBkColor(MemDC, BKColor);
      OldBrush := SelectObject(MemDC, CreateSolidBrush(BKColor));
      PatBlt(MemDC, 0, 0, TitleWidth, CharHeight, PatCopy);
      DeleteObject(SelectObject(MemDC, OldBrush));

      { Draw double lines }
      OldPen := SelectObject(MemDC, CreatePen(ps_Solid, 2, ForeColor));
      SepX := CharWidth div 3;
      SepY := CharHeight div 3;
      {   Top line }
      MoveTo(MemDC, SepX, SepY);
      LineTo(MemDC, TitleWidth - SepX, SepY);
      LineTo(MemDC, TitleWidth - SepX, CharHeight + 1);
      {   Bottom lines and titles}
      Inc(SepY, SepY);
      for I := 1 to  Table^.NumFields do
      begin
        FieldStart := FieldStarts^[I] * CharWidth;
        FieldEnd := FieldStart + Table^.FieldWidth(I) * CharWidth;
        MoveTo(MemDC, FieldStart - SepX, CharHeight);
        LineTo(MemDC, FieldStart - SepX, SepY);
        LineTo(MemDC, FieldEnd + SepX, SepY);
        LineTo(MemDC, FieldEnd + SepX, CharHeight + 1);
        TextOut(MemDC, FieldStart, 0, Table^.FieldName(I),
          Min(StrLen(Table^.FieldName(I)), Table^.FieldWidth(I)));
      end;
      DeleteObject(SelectObject(MemDC, OldPen));
      DeleteDC(MemDC);
      InvalidateRect(HWindow, nil, True);
    end;
  end;
end;

function TParadoxTableWindow.GetClassName: PChar;
begin
  GetClassName := 'TurboTableView';
end;

function EnumerateFont(LogFont: PLogFont; TextMetric: PTextMetric;
  FontType: Integer; Data: Pointer): Bool; export;
begin
  PLogFont(Data)^ := LogFont^;
  EnumerateFont := (TextMetric^.tmPitchAndFamily and 1) = 1;
end;

procedure TParadoxTableWindow.GetFixedFont(DC: HDC);
var
  LogFont: TLogFont;
  FontFunc: TFarProc;
begin
  FontFunc := MakeProcInstance(@EnumerateFont, HInstance);
  EnumFonts(DC, 'SYSTEM', FontFunc, @LogFont);
  FixedFont := CreateFontIndirect(LogFont);
  FreeProcInstance(FontFunc);
end;

procedure TParadoxTableWindow.GetWindowClass(var WndClass: TWndClass);
var
  LogBrush: TLogBrush;
begin
  TWindow.GetWindowClass(WndClass);
  LogBrush.lbStyle := bs_Solid;
  LogBrush.lbColor := BKColor;
  WndClass.hbrBackground := CreateBrushIndirect(LogBrush);
  WndClass.hIcon := LoadIcon(HInstance, MakeIntResource(IconID));
end;

procedure TParadoxTableWindow.Paint(DC: HDC; var PS: TPaintStruct);
var
  OldFont: HFont;
  OldCursor: HCursor;
  HRgn1, HRgn2: HRgn;
  MemDC: HDC;
  StartX, StopX: Integer;
  FirstField, LastField, FirstRec, LastRec: Integer;
  I, J: Integer;
  R: TRect;

procedure DrawField(X, Y, Width: Integer; FieldText: PChar);
var
  Temp: array[0..255] of Char;
  XPos, YPos, Len: Integer;
  R: TRect;
begin
  XPos := (X - Scroller^.XPos) * CharWidth;
  YPos := (Y - Scroller^.YPos) * CharHeight;
  Len := StrLen(FieldText);
  TextOut(DC, XPos, YPos, FieldText, Len);
  if Width > Len then
  begin
    FillChar(Temp, SizeOf(Temp), ' ');
    TextOut(DC, XPos + Len * CharWidth, YPos, Temp, Width - Len);
  end;
end;

begin
  if Table <> nil then
  begin
    SetTextColor(DC, ForeColor);
    SetBkColor(DC, BKColor);
    OldFont := SelectObject(DC, FixedFont);
    StartX := (PS.rcPaint.left div CharWidth) + Scroller^.XPos;
    StopX := (PS.rcPaint.right div CharWidth + 1) + Scroller^.XPos;
    FirstField := 1;
    while FieldStarts^[FirstField+1] <= StartX do Inc(FirstField);
    LastField := Table^.NumFields;
    while FieldStarts^[LastField] >= StopX do Dec(LastField);
    FirstRec := (PS.rcPaint.top div CharHeight) + Scroller^.YPos;
    LastRec := (PS.rcPaint.bottom div CharHeight + 1) + Scroller^.YPos + 1;
    MemDC := CreateCompatibleDC(DC);
    SelectObject(MemDC, ColumnBar);
    for I := FirstField to LastField do
    begin
      J := (FieldStarts^[I + 1] - Scroller^.XPos - 1) * CharWidth;
      BitBlt(DC, J, PS.rcPaint.top, J + CharWidth, PS.rcPaint.bottom,
        MemDC, 0, 0, SrcCopy);
    end;
    DeleteDC(MemDC);
    OldCursor := SetCursor(LoadCursor(0, idc_Wait));

    for I := FirstRec to LastRec do
      if I = 0 then
      begin
        MemDC := CreateCompatibleDC(DC);
        SelectObject(MemDC, TitleBar);
        BitBlt(DC, 0, 0, (TableWidth - Scroller^.XPos) * CharWidth,
          CharHeight, MemDC, Scroller^.XPos * CharWidth, 0, SrcCopy);
        DeleteDC(MemDC);
      end
      else
        for J := FirstField to LastField do
          DrawField(FieldStarts^[J], I, Table^.FieldWidth(J),
            Table^.GetField(I, J));
    SetCursor(OldCursor);
    SelectObject(DC, OldFont);
    if Table^.Status <> 0 then CloseTable;
  end;
end;

procedure TParadoxTableWindow.SetupWindow;
var
  TextMetric: TTextMetric;
  DC: HDC;
  OldFont: THandle;
begin
  TWindow.SetupWindow;
  DC := GetDC(HWindow);
  GetFixedFont(DC);
  OldFont := SelectObject(DC, FixedFont);
  GetTextMetrics(DC, TextMetric);
  CharWidth := TextMetric.tmAveCharWidth;
  CharHeight := TextMetric.tmHeight;
  Scroller^.SetUnits(CharWidth, CharHeight);
  SelectObject(DC, OldFont);
  ReleaseDC(HWindow, DC);
  Scroller^.SetSBarRange;
end;

procedure TParadoxTableWindow.WMKeyDown(var Msg: TMessage);
begin
  with Scroller^ do
    case Msg.wParam of
      vk_Left:
        if GetKeyState(vk_Control) and $8000 <> 0 then
          HScroll(sb_PageUp, 0)
        else
          HScroll(sb_LineUp, 0);
      vk_Right:
        if GetKeyState(vk_Control) and $8000 <> 0 then
          HScroll(sb_PageDown, 0)
        else
          HScroll(sb_LineDown, 0);
      vk_Up: VScroll(sb_LineUp, 0);
      vk_Down: VScroll(sb_LineDown, 0);
      vk_Next: VScroll(sb_PageDown, 0);
      vk_Prior: VScroll(sb_PageUp, 0);
      vk_Home: ScrollTo(XPos, 0);
      vk_End: ScrollTo(XPos, Table^.NumRecords);
    end;
end;

procedure TParadoxTableWindow.WMSize(var Msg: TMessage);
var
  R: TRect;
  DC, MemDC: HDC;
  OldBrush: HBrush;
  OldPen: HPen;
  SepX: Integer;
begin
  TWindow.WMSize(Msg);
  if Table <> nil then
  begin
    GetClientRect(HWindow, R);
    Scroller^.SetRange(TableWidth - R.right div CharWidth,
      Table^.NumRecords - R.bottom div CharHeight + 1);
    { Call GetClientRect again because SetRange can change the size of
      the client area if a scrollbar disappears }
    GetClientRect(HWindow, R);
    if ColumnBar <> 0 then DeleteObject(ColumnBar);
    DC := GetDC(HWindow);
    MemDC := CreateCompatibleDC(DC);
    ReleaseDC(HWindow, DC);
    ColumnBar := CreateCompatibleBitmap(DC, CharWidth,
      R.bottom * CharHeight);
    SelectObject(MemDC, ColumnBar);
    SetTextColor(MemDC, ForeColor);
    SetBKColor(MemDC, BKColor);
    OldBrush := SelectObject(MemDC, CreateSolidBrush(BKColor));
    PatBlt(MemDC, 0, 0, CharWidth, R.bottom * CharHeight, PatCopy);
    DeleteObject(SelectObject(MemDC, OldBrush));
    OldPen := SelectObject(MemDC, CreatePen(ps_Solid, 2, ForeColor));
    SepX := CharWidth div 3;
    MoveTo(MemDC, SepX, 0);
    LineTo(MemDC, SepX, R.bottom);
    MoveTo(MemDC, CharWidth - SepX, 0);
    LineTo(MemDC, CharWidth - SepX, R.bottom);
    DeleteObject(SelectObject(MemDC, OldPen));
    DeleteDC(MemDC);
  end;
end;

var
  ParadoxDemo: TParadoxDemo;
begin
  ParadoxDemo.Init('ParadoxDemo');
  ParadoxDemo.Run;
  ParadoxDemo.Done;
end.
