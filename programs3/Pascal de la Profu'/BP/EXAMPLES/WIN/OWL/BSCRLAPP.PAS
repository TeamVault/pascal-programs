{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program BScrlApp;

{$R BSCRLAPP.RES}

uses WinTypes, WinProcs, WinDos, OWindows, OMemory, OStdDlgs, Strings;

const
  bsa_Name =  'BitmapScroll';

type

{ TBitScrollApp, a TApplication descendant }

  TBitScrollApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

{ TBitScrollWindow, a TWindow descendant }

  PScrollWindow = ^TBitScrollWindow;
  TBitScrollWindow = object(TWindow)
    FileName: array[0..fsPathName] of Char;
    BitmapHandle: HBitmap;
    IconizedBits: HBitmap;
    IconImageValid: Boolean;
    PixelHeight, PixelWidth: Word;
    Mode: Longint;
    constructor Init(ATitle: PChar);
    destructor Done; virtual;
    function GetClassName : PChar; virtual;
    procedure GetWindowClass(var WndClass: TWndClass); virtual;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure CMFileOpen(var Msg: TMessage); virtual cm_First + cm_FileOpen;
    procedure WMSize(var Msg: TMessage); virtual wm_First + wm_Size;
    procedure AdjustScroller;
    function LoadBitmapFile(Name: PChar): Boolean;
    function OpenDIB(var TheFile: File): Boolean;
    procedure GetBitmapData(var TheFile: File;
      BitsHandle: THandle; BitsByteSize: Longint);
  end;

{ __ahIncr, ordinal 114, is a 'magic' function. Defining this
  function causes Windows to patch the value into the passed
  reference.  This makes it a type of global variable. To use
  the value of AHIncr, use Ofs(AHIncr). }

procedure AHIncr; far; external 'KERNEL' index 114;

{ Construct the TBitScrollApp's MainWindow of type TBitScrollWindow }

procedure TBitScrollApp.InitMainWindow;
begin
  MainWindow := New(PScrollWindow, Init(bsa_name));
end;

{ Constructor for a TBitScrollWindow, sets scroll styles and constructs
  the Scroller object.  Also sets the Mode based on whether the display
  is monochrome (two-color) or polychrome. }

constructor TBitScrollWindow.Init(ATitle: PChar);
var
  DCHandle: HDC;
begin
  TWindow.Init(nil, ATitle);
  Attr.Style := Attr.Style or ws_VScroll or ws_HScroll;
  Attr.Menu := LoadMenu(HInstance, bsa_Name);
  BitmapHandle := 0;
  IconImageValid := False;
  Scroller := New(PScroller, Init(@Self, 1, 1, 200, 200));
  DCHandle := CreateDC('Display', nil, nil, nil);
  IconizedBits := CreateCompatibleBitmap(DCHandle, 64, 64);
  if GetDeviceCaps(DCHandle, numColors) < 3 then Mode := notSrcCopy
  else Mode := srcCopy;
  DeleteDC(DCHandle);
end;

{ Change the class name to the application name. }

function TBitScrollWindow.GetClassName : PChar;
begin
  GetClassName := bsa_Name;
end;

{ Allow the iconic picture to be drawn from the client area. }

procedure TBitScrollWindow.GetWindowClass(var WndClass: TWndClass);
begin
  TWindow.GetWindowClass(WndClass);
  WndClass.hIcon := 0; { Client area will be painted by the app. }
end;

destructor TBitScrollWindow.Done;
begin
  if BitmapHandle <> 0 then DeleteObject(BitmapHandle);
  DeleteObject(IconizedBits);
  TWindow.Done;
end;

{ If the the 'Open...' menu item is selected, then, using
  the current TFileDlgRec we prompt the user for a new bitmap
  file.  If the user selects one and it is one that we can
  read, we display it in the window and change the window's
  caption to reflect the new bitmap file.  It should be noted
  that we save the old TFileDlgRec just in case we are unable
  to display the bitmap.  This allows us to restore the old
  search criteria. }

procedure TBitScrollWindow.CMFileOpen(var Msg: TMessage);
var
  TempName: array[0..fsPathName] of Char;
  CaptionBuffer: array [0..fsPathName+12{bsa_Name} +2{': '} +1{#0}] of Char;
begin
  if Application^.ExecDialog(New(PFileDialog,
    Init(@Self, PChar(sd_FileOpen), StrCopy(TempName, '*.bmp')))) = id_Ok then
    if LoadBitmapFile(TempName) then
    begin
      StrCopy(FileName, TempName);
      StrCopy(CaptionBuffer, bsa_Name);
      StrCat(CaptionBuffer, ': ');
      StrCat(CaptionBuffer, AnsiLower(FileName));
      SetWindowText(HWindow, CaptionBuffer);
    end;
end;

{ Adjust the Scroller range so that the the origin is the
  upper-most scrollable point and the corner is the
  bottom-most. }

procedure TBitScrollWindow.AdjustScroller;
var
  ClientRect: TRect;
begin
  GetClientRect(HWindow, ClientRect);
  with ClientRect do
    Scroller^.SetRange(PixelWidth - (right - left),
      PixelHeight - (bottom - top));
  Scroller^.ScrollTo(0, 0);
  InvalidateRect(HWindow, nil, True);
end;

{ Reset scroller range. }

procedure TBitScrollWindow.WMSize(var Msg: TMessage);
var
  DC, MemDC1, MemDC2: HDC;
  OldBitmap1, OldBitmap2: HBitmap;
  OldCursor: HCursor;
begin
  TWindow.WMSize(Msg);
  Scroller^.AutoOrg := not (Msg.wParam = sizeIconic);
  if not (Msg.WParam = sizeIconic) then AdjustScroller
  else if not IconImageValid and (BitmapHandle <> 0) then
  begin
    DC := GetDC(HWindow);
    MemDC1 := CreateCompatibleDC(DC);
    MemDC2 := CreateCompatibleDC(DC);
    ReleaseDC(HWindow, DC);
    OldBitmap1 := SelectObject(MemDC1, IconizedBits);
    OldBitmap2 := SelectObject(MemDC2, BitmapHandle);
    OldCursor := SetCursor(LoadCursor(0, idc_Wait));
    StretchBlt(MemDC1, 0, 0, Msg.lParamLo, Msg.lParamHi, MemDC2,
      0, 0, PixelWidth, PixelHeight, SrcCopy);
    SetCursor(OldCursor);
    SelectObject(MemDC1, OldBitmap1);
    SelectObject(MemDC2, OldBitmap2);
    DeleteDC(MemDC1);
    DeleteDC(MemDC2);
    IconImageValid := True;
  end;
end;

{ Copys the bitmap bit data from the file into memory. Since
  copying cannot cross a segment (64K) boundary, we are forced
  to do segment arithmetic to compute the next segment.  Created
  a LongType type to simplify the process. }

procedure TBitScrollWindow.GetBitmapData(var TheFile: File;
  BitsHandle: THandle; BitsByteSize: Longint);
type
  LongType = record
    case Word of
      0: (Ptr: Pointer);
      1: (Long: Longint);
      2: (Lo: Word;
	  Hi: Word);
  end;
var
  Count: Longint;
  Start, ToAddr, Bits: LongType;
begin
  Start.Long := 0;
  Bits.Ptr := GlobalLock(BitsHandle);
  Count := BitsByteSize - Start.Long;
  while Count > 0 do
  begin
    ToAddr.Hi := Bits.Hi + (Start.Hi * Ofs(AHIncr));
    ToAddr.Lo := Start.Lo;
    if Count > $4000 then Count := $4000;
    BlockRead(TheFile, ToAddr.Ptr^, Count);
    Start.Long := Start.Long + Count;
    Count := BitsByteSize - Start.Long;
  end;
  GlobalUnlock(BitsHandle);
end;

{ Attempt to open a Windows 3.0 device independent bitmap. }

function TBitScrollWindow.OpenDIB(var TheFile: File): Boolean;
var
  bitCount: Word;
  size: Word;
  longWidth: Longint;
  DCHandle: HDC;
  BitsPtr: Pointer;
  BitmapInfo: PBitmapInfo;
  BitsHandle, NewBitmapHandle: THandle;
  NewPixelWidth, NewPixelHeight: Word;
begin
  OpenDIB := True;
  Seek(TheFile, 28);
  BlockRead(TheFile, bitCount, SizeOf(bitCount));
  if bitCount <= 8 then
  begin
    size := SizeOf(TBitmapInfoHeader) + ((1 shl bitCount) * SizeOf(TRGBQuad));
    BitmapInfo := MemAlloc(size);
    Seek(TheFile, SizeOf(TBitmapFileHeader));
    BlockRead(TheFile, BitmapInfo^, size);
    NewPixelWidth := BitmapInfo^.bmiHeader.biWidth;
    NewPixelHeight := BitmapInfo^.bmiHeader.biHeight;
    longWidth := (((NewPixelWidth * bitCount) + 31) div 32) * 4;
    BitmapInfo^.bmiHeader.biSizeImage := longWidth * NewPixelHeight;
    GlobalCompact(-1);
    BitsHandle := GlobalAlloc(gmem_Moveable or gmem_Zeroinit,
      BitmapInfo^.bmiHeader.biSizeImage);
    GetBitmapData(TheFile, BitsHandle, BitmapInfo^.bmiHeader.biSizeImage);
    DCHandle := CreateDC('Display', nil, nil, nil);
    BitsPtr := GlobalLock(BitsHandle);
    NewBitmapHandle :=
      CreateDIBitmap(DCHandle, BitmapInfo^.bmiHeader, cbm_Init, BitsPtr,
      BitmapInfo^, 0);
    DeleteDC(DCHandle);
    GlobalUnlock(BitsHandle);
    GlobalFree(BitsHandle);
    FreeMem(BitmapInfo, size);
    if NewBitmapHandle <> 0 then
    begin
      if BitmapHandle <> 0 then DeleteObject(BitmapHandle);
      BitmapHandle := NewBitmapHandle;
      PixelWidth := NewPixelWidth;
      PixelHeight := NewPixelHeight;
    end
    else
      OpenDIB := False;
  end
  else
    OpenDIB := False;
end;

{ Test if the passed file is a Windows 3.0 DI bitmap and if so read it.
  Report errors if unable to do so. Adjust the Scroller to the new
  bitmap dimensions. }

function TBitScrollWindow.LoadBitmapFile(Name: PChar): Boolean;
var
  TheFile: File;
  TestWin30Bitmap: Longint;
  ErrorMsg: PChar;
  OldCursor: HCursor;
begin
  ErrorMsg := nil;
  OldCursor := SetCursor(LoadCursor(0, idc_Wait));
  Assign(TheFile, Name);
  {$I-}
  Reset(TheFile, 1);
  {$I+}
  if IOResult = 0 then
  begin
    Seek(TheFile, 14);
    BlockRead(TheFile, TestWin30Bitmap, SizeOf(TestWin30Bitmap));
    if TestWin30Bitmap = 40 then
      if OpenDIB(TheFile) then
      begin
	AdjustScroller;
	IconImageValid := False;
      end
      else ErrorMsg := 'Unable to create Windows 3.0 bitmap from file'
    else
      ErrorMsg := 'Not a Windows 3.0 bitmap file';
    Close(TheFile);
  end
  else
    ErrorMsg := 'Cannot open bitmap file';
  SetCursor(OldCursor);
  if ErrorMsg = nil then LoadBitmapFile := True else
  begin
    MessageBox(HWindow, ErrorMsg, bsa_Name, mb_Ok);
    LoadBitmapFile := False;
  end;
end;

{ Responds to an incoming "paint" message by redrawing the bitmap.  (The
  Scroller's BeginView method, which sets the viewport origin relative
  to the present scroll position, has already been called. )  }

procedure TBitScrollWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  MemoryDC: HDC;
  OldBitmapHandle: THandle;
begin
  if BitmapHandle <> 0 then
  begin
    MemoryDC := CreateCompatibleDC(PaintDC);
    if IsIconic(HWindow) then
      OldBitmapHandle := SelectObject(MemoryDC, IconizedBits)
    else
    begin
      OldBitmapHandle := SelectObject(MemoryDC, BitmapHandle);
      if Mode = srcCopy then
      begin
	SetBkColor(PaintDC, GetNearestColor(PaintDC, $800000));
	SetTextColor(PaintDC, $FFFFFF);
      end;
    end;
    BitBlt(PaintDC, 0, 0, PixelWidth, PixelHeight, MemoryDC, 0, 0,
      Mode);
    SelectObject(MemoryDC, OldBitmapHandle);
    DeleteDC(MemoryDC);
  end;
end;

{ Declare a variable of type TBitScrollApp }

var
  ScrollApp: TBitScrollApp;

{ Run the BitScrollApp }

begin
  ScrollApp.Init(bsa_Name);
  ScrollApp.Run;
  ScrollApp.Done;
end.
