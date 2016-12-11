{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program Stretch;

{$R STRETCH.RES}

uses
  WinTypes, WinProcs, WinDos, Strings, OWindows, ODialogs, OMemory,
    OStdDlgs;

const
  idm_Load    = 100;
  idm_Fixed   = 101;
  idm_Stretch = 102;
  idm_About   = 103;

type
  TApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

  PStretchWindow = ^TStretchWindow;
  TStretchWindow = object(TWindow)
    BitMapHandle: HBitmap;
    IconizedBits: HBitmap;
    IconImageValid: Boolean;
    Stretch: Boolean;
    Width, Height: LongInt;
    constructor Init(AParent: PWindowsObject; Title: PChar);
    destructor Done; virtual;
    procedure About(var Message: TMessage); Virtual cm_first + idm_About;
    procedure Fixed(var Message: TMessage); Virtual cm_first + idm_Fixed;
    procedure GetBitmapData(var TheFile: File; BitsHandle: THandle;
      BitsByteSize: Longint);
    procedure GetWindowClass(var WndClass: TWndClass); virtual;
    function LoadBitmapFile(Name: PChar): Boolean;
    procedure LoadImage(var Message: TMessage); virtual cm_first + idm_Load;
    function OpenDIB(var TheFile: File): Boolean;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure SetUpWindow; virtual;
    procedure SetWindowSize;
    procedure StretchOption(var Message: TMessage); virtual
      cm_first + idm_Stretch;
    procedure WMSize(var Message: TMessage); virtual wm_Size;
  end;

{ __ahIncr, ordinal 114, is a 'magic' function. Defining this
  function causes Windows to patch the value into the passed
  reference.  This makes it a type of global variable. To use
  the value of AHIncr, use Ofs(AHIncr). }
procedure AHIncr; far; external 'KERNEL' index 114;

{ TStretchWindow }

constructor TStretchWindow.Init(AParent: PWindowsObject; Title: PChar);
var
  DC: HDC;
begin
  TWindow.Init(AParent, Title);
  BitMapHandle := 0;
  DC := GetDC(GetFocus);
  IconizedBits := CreateCompatibleBitmap(DC, 64, 64);
  ReleaseDC(GetFocus, DC);
  IconImageValid := False;
  Stretch := True;
end;

destructor TStretchWindow.Done;
begin
  if BitMapHandle <> 0 then DeleteObject(BitMapHandle);
  DeleteObject(IconizedBits);
  TWindow.Done;
end;

procedure TStretchWindow.About(var Message: TMessage);
var
  Dialog: TDialog;
begin
  Dialog.Init(@Self, 'About');
  Dialog.Execute;
  Dialog.Done;
end;

procedure TStretchWindow.Fixed(var Message: TMessage);
begin
  CheckMenuItem(GetMenu(HWindow), idm_Fixed, mf_Checked or mf_ByCommand);
  CheckMenuItem(GetMenu(HWindow), idm_Stretch, mf_UnChecked or mf_ByCommand);
  Stretch := False;
  SetWindowSize;
  InvalidateRect(HWindow, nil, False);
end;

{ Copys the bitmap bit data from the file into memory. Since
  copying cannot cross a segment (64K) boundary, we are forced
  to do segment arithmetic to compute the next segment.  Created
  a LongType type to simplify the process. }
procedure TStretchWindow.GetBitmapData(var TheFile: File;
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

procedure TStretchWindow.GetWindowClass(var WndClass: TWndClass);
begin
  TWindow.GetWindowClass(WndClass);

 { With a 0 as hIcon the program can write to the Icon in the paint method }
  WndClass.HIcon := 0;
  WndClass.lpszMenuName := 'Menu';
end;

{ Test if the passed file is a Windows 3.0 DI bitmap and if so read it.
  Report errors if unable to do so. Adjust the Scroller to the new
  bitmap dimensions. }
function TStretchWindow.LoadBitmapFile(Name: PChar): Boolean;
var
  TheFile: File;
  TestWin30Bitmap: Longint;
begin
  LoadBitmapFile := False;
  Assign(TheFile, Name);
  Reset(TheFile, 1);
  Seek(TheFile, 14);
  BlockRead(TheFile, TestWin30Bitmap, SizeOf(TestWin30Bitmap));
  if TestWin30Bitmap = 40 then
    if OpenDIB(TheFile) then
    begin
      LoadBitmapFile := True;
      IconImageValid := False;
    end
    else
      MessageBox(HWindow, 'Unable to create Windows 3.0 bitmap from file.',
	Name, mb_Ok)
  else
      MessageBox(HWindow, 'Not a Windows 3.0 bitmap file.  Convert using Paintbrush.', Name, mb_Ok);
  Close(TheFile);
end;

procedure TStretchWindow.LoadImage(var Message: TMessage);
var
  FileName: array[0..200] of Char;
begin
  if Application^.ExecDialog(New(PFileDialog,
    Init(@Self, PChar(sd_FileOpen),
    StrCopy(FileName, '*.bmp')))) = id_Ok then
    if LoadBitmapFile(FileName) then
      SetWindowSize;
  InvalidateRect(HWindow, nil, False);
end;

{ Attempt to open a Windows 3.0 device independent bitmap. }
function TStretchWindow.OpenDIB(var TheFile: File): Boolean;
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
      Width := NewPixelWidth;
      Height := NewPixelHeight;
    end
    else
      OpenDIB := False;
  end
  else
    OpenDIB := False;
end;

procedure TStretchWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  MemDC: HDC;
  OldBitmap: HBitmap;
  R: TRect;
begin
  if BitMapHandle <> 0 then
  begin
    MemDC := CreateCompatibleDC(PaintDC);
    if IsIconic(HWindow) and IconImageValid then
    begin
      OldBitmap := SelectObject(MemDC, IconizedBits);
      BitBlt(PaintDC, 0, 0, Width, Height, MemDC, 0, 0, SRCCopy);
    end
    else
    begin
      SelectObject(MemDC, BitMapHandle);
      if Stretch then
      begin
	GetClientRect(HWindow, R);
	SetCursor(LoadCursor(0, idc_Wait));
	StretchBlt(PaintDC, 0, 0, R.Right, R.Bottom, MemDC, 0, 0,
	  Width, Height, SRCCopy);
	SetCursor(LoadCursor(0, idc_Arrow));
      end
      else
	BitBlt(PaintDC, 0, 0, Width, Height, MemDC, 0, 0, SRCCopy);
    end;
    DeleteDC(MemDC);
  end;
end;

procedure TStretchWindow.SetUpWindow;
begin
  TWindow.SetUpWindow;
  Stretch := True;
end;

procedure TStretchWindow.SetWindowSize;
const
   MinWindowWidth = 200;
var
  WindowHeight, WindowWidth: LongInt;
begin
  WindowWidth := Width + 2 * GetSystemMetrics(sm_CXFrame);
  if WindowWidth < MinWindowWidth then WindowWidth := MinWindowWidth;
  WindowHeight := Height + 2 * GetSystemMetrics(sm_CYFrame) +
    GetSystemMetrics(sm_CYCaption) + GetSystemMetrics(sm_CYMenu);
  SetWindowPos(HWindow, 0, 0, 0, WindowWidth, WindowHeight, swp_NoMove);
end;

procedure TStretchWindow.StretchOption(var Message: TMessage);
begin
  CheckMenuItem(GetMenu(HWindow), idm_Stretch, mf_Checked or mf_ByCommand);
  CheckMenuItem(GetMenu(HWindow), idm_Fixed, mf_UnChecked or mf_ByCommand);
  Stretch := True;
  InvalidateRect(HWindow, nil, False);
end;

procedure TStretchWindow.WMSize(var Message: TMessage);
var
  DC, MemDC1, MemDC2: HDC;
  OldBitmap1, OldBitmap2: HBitmap;
  OldCursor: HCursor;
begin
  if not IconImageValid and (Message.wParam = sizeIconic) and
    (BitmapHandle <> 0) then
  begin
    DC := GetDC(HWindow);
    MemDC1 := CreateCompatibleDC(DC);
    MemDC2 := CreateCompatibleDC(DC);
    ReleaseDC(HWindow, DC);
    OldBitmap1 := SelectObject(MemDC1, IconizedBits);
    OldBitmap2 := SelectObject(MemDC2, BitmapHandle);
    OldCursor := SetCursor(LoadCursor(0, idc_Wait));
    StretchBlt(MemDC1, 0, 0, Message.lParamLo, Message.lParamHi, MemDC2,
      0, 0, Width, Height, SrcCopy);
    SetCursor(OldCursor);
    SelectObject(MemDC1, OldBitmap1);
    SelectObject(MemDC2, OldBitmap2);
    DeleteDC(MemDC1);
    DeleteDC(MemDC2);
    IconImageValid := True;
  end;
  InvalidateRect(HWindow, nil, False);
end;

{ TApp }

procedure TApp.InitMainWindow;
begin
  MainWindow := New(PStretchWindow, Init(nil, 'Stretch'));
end;

var
  App: TApp;
begin
  App.Init('Stretch');
  App.Run;
  App.Done;
end.
