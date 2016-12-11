{***************************************************}
{                                                   }
{   Windows 3.1 Common Dialogs Demo Program         }
{                                                   }
{   Copyright (c) 1992 by Borland International     }
{                                                   }
{***************************************************}


program CommDlgs;

{$T-}

{ This program demonstrates the use of several new Windows 3.1
  features: The Common Dialogs (for Font and Color selection),
  True Type, and Playing sounds.
}

uses WinCrt, WinDos, Strings, WinTypes, WinProcs, OWindows, ODialogs,
  CommDlg, MMSystem, BWCC;

{$R CommDlgs}

const

{ Resource IDs }

  id_Menu    = 100;
  id_About   = 100;
  id_Icon    = 100;

{ Menu command IDs }

  cm_FileOpen = 101;
  cm_Color    = 103;
  cm_Font     = 104;
  cm_Help     = 105;
  cm_HelpAbout= 106;

{ Other Constants }

  HelpName    = 'CommDlgs.hlp';
  FlagWidth   = 251;
  FlagHeight  = 180;

type

{ Filename string }

  TFilename = array [0..255] of Char;

{ Application main window }

  PCommDlgsWindow = ^TCommDlgsWindow;
  TCommDlgsWindow = Object(TWindow)
    FlagMap  : HBitMap;
    TheFont  : HFont;
    ALogFont : TLogFont;
    ColorRef : LongInt;
    FileName : TFileName;

    constructor Init(AParent: PWindowsObject; AName: PChar);
    destructor  Done; virtual;

    procedure MakeDefaultFont(var AFont: HFont);
    procedure SetupWindow; virtual;

    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;

    procedure CMColor(var Msg: TMessage);
      virtual cm_First + cm_Color;
    procedure CMFileOpen(var Msg: TMessage);
      virtual cm_First + cm_FileOpen;
    procedure CMFonts(var Msg: TMessage);
      virtual cm_First + cm_Font;
    procedure CMHelp(var Msg: TMessage);
      virtual cm_First + cm_Help;
    procedure CMHelpAbout(var Msg: TMessage);
      virtual cm_First + cm_HelpAbout;
  end;

{ Application object }

  PCommDlgApp = ^TCommDlgApp;
  TCommDlgApp = Object(TApplication)
    procedure InitMainWindow; virtual;
  end;

{ Initialized globals }

const
  DemoTitle: PChar = 'Common Dialogs Demo';

{ Global variables }

var
  App: TCommDlgApp;


{ TCommDlgsWindow Methods }

{ Constructs an instance of TCommDlgsWindow.  Loads the menu and
  initialize the wave file's "FileName" and the text's initial RGB
  color value.
}
constructor TCommDlgsWindow.Init(AParent: PWindowsObject; AName: PChar);
begin
  TWindow.Init(AParent, AName);
  Attr.Menu:= LoadMenu(HInstance, PChar(id_Menu));

  StrCopy(FileName, '');
  ColorRef := RGB(0, 0, 255);
  FlagMap  := 0;
  TheFont  := 0;
end;

{ Destroys an instance of the TCommDlgsWindow by disposing of its
  "FlagMap" image and Font.  Then calls on ancestral destructor to
  complete the shutdown.
}
destructor TCommDlgsWindow.Done;
begin
  if FlagMap <> 0 then
    DeleteObject(FlagMap);
  if TheFont <> 0 then
    DeleteObject(TheFont);
  TWindow.Done;
end;

{ Sets up an Italic, Times New Roman, font handle used as the default
  Font by TCommDlgsWindow in its Paint method.
}
procedure TCommDlgsWindow.MakeDefaultFont(var AFont: HFont);
begin
  FillChar(ALogFont, SizeOf(TLogFont), #0);
  with ALogFont do
  begin
    lfHeight        := 96;     {Make a large font                 }
    lfWeight        := 700;    {Indicate a Bold attribute         }
    lfItalic        := 1;      {Non-zero value indicates italic   }
    lfUnderline     := 1;      {Non-zero value indicates underline}
    lfOutPrecision  := Out_Stroke_Precis;
    lfClipPrecision := Clip_Stroke_Precis;
    lfQuality       := Default_Quality;
    lfPitchAndFamily:= Variable_Pitch;
    StrCopy(lfFaceName, 'Times New Roman');
  end;
  TheFont := CreateFontIndirect(ALogFont);
end;

{ Establishes the font and the "FlagMap" bitmap image used in
  TCommDlgsWindow's Paint method.  The FlagMap is held as an instance
  variable until the window is closed.
}
procedure TCommDlgsWindow.SetUpWindow;
begin
  TWindow.SetupWindow;
  MakeDefaultFont(TheFont);
  FlagMap := LoadBitmap(HInstance, 'bitmap_2');
end;

{ Displays the bitmap held in "FlagMap".  Then surrounds this flag map
  with the string 'TP Win 3.1' in the selected font and text color.
}
procedure TCommDlgsWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  S        : array [0..100] of Char;
  aDC      : HDC;
  OldBitMap: HBitMap;
  Dims     : LongInt;
begin
  aDC := CreateCompatibleDC(PaintDC);
  OldBitMap := SelectObject(aDC, FlagMap);

  StrCopy(S, 'TP ');
  SelectObject(PaintDC, TheFont);
  SetTextColor(PaintDC, ColorRef);
  TextOut(PaintDC, 0, 0, S, StrLen(S));

  Dims := GetTextExtent(PaintDC, S, StrLen(S));
  StretchBlt(PaintDC, LoWord(Dims), 0, LoWord(Dims), HiWord(Dims),
             aDC, 0, 0, FlagWidth, FlagHeight, SrcCopy);
  StrCopy(S, ' Win 3.1');
  TextOut(PaintDC, (LoWord(Dims) * 2), 0, S, StrLen(S));

  SelectObject(aDC, OldBitMap);
  DeleteDC(aDC);
end;

{ Displays the "Open File Dialog" from Common dialogs and permit the user
  to select from among the available Wave files.  Then play the sound
  found in the file using "SndPlaySound".
}
procedure TCommDlgsWindow.CMFileOpen(var Msg: TMessage);
const
  DefExt = 'wav';
var
  OpenFN      : TOpenFileName;
  Filter      : array [0..100] of Char;
  FullFileName: TFilename;
  WinDir      : array [0..145] of Char;
begin
  GetWindowsDirectory(WinDir, SizeOf(WinDir));
  SetCurDir(WinDir);
  StrCopy(FullFileName, '');

{ Set up a filter buffer to look for Wave files only.  Recall that filter
  buffer is a set of string pairs, with the last one terminated by a
  double-null.
}
  FillChar(Filter, SizeOf(Filter), #0);  { Set up for double null at end }
  StrCopy(Filter, 'Wave Files');
  StrCopy(@Filter[StrLen(Filter)+1], '*.wav');

  FillChar(OpenFN, SizeOf(TOpenFileName), #0);
  with OpenFN do
  begin
    hInstance     := HInstance;
    hwndOwner     := HWindow;
    lpstrDefExt   := DefExt;
    lpstrFile     := FullFileName;
    lpstrFilter   := Filter;
    lpstrFileTitle:= FileName;
    flags         := ofn_FileMustExist;
    lStructSize   := sizeof(TOpenFileName);
    nFilterIndex  := 1;       {Index into Filter String in lpstrFilter}
    nMaxFile      := SizeOf(FullFileName);
  end;
  if GetOpenFileName(OpenFN) then
    SndPlaySound(FileName, 1);   {Second parameter must be 1}
end;

{ Displays the "Choose Color" dialog from the common dialogs unit.
  Permits an initial value to be inserted and custom colors to be
  developed. Note, custom colors are not used by the "ChooseFont"
  dialog from common dialogs.
}
procedure TCommDlgsWindow.CMColor(var Msg: TMessage);
type
  TLongAry = array [0..15] of Longint;
const
  { Establishes a set of custom colors in 15 shades of blue }
  CustColors: TLongAry = (
    $000000, $100000, $200000, $300000,
    $400000, $500000, $600000, $700000,
    $800000, $900000, $A00000, $B00000,
    $C00000, $D00000, $E00000, $F00000);
var
  ChooseClr: TChooseColor;
  i        : Integer;
begin
  with ChooseClr do
  begin
    HWndOwner   := HWindow;
    lStructSize := Sizeof(TChooseColor);
    rgbResult   := ColorRef;
    lpCustColors:= @CustColors;
    Flags       := cc_FullOpen or cc_RGBInit;
      {Allow custom colors and the initialization through rgbResult}
  end;
  if not ChooseColor(ChooseClr) then
    Exit;
  ColorRef := ChooseClr.RGBResult;
  InvalidateRect(HWindow, nil, True);
end;

{ Displays the ChooseFont dialog to permit the selection of a font which
  is returned as a TLogFont.  Then a font handle is created from this
  logical font information.
}
procedure TCommDlgsWindow.CMFonts(var Msg: TMessage);
var
  ChooseRec: TChooseFont;
  Colors   : LongInt;
  Style    : array [0..100] of Char;
  TempFont : TLogFont;
begin
  FillChar(ChooseRec, SizeOf(ChooseRec), #0);
  with ChooseRec do
  begin
    lStructSize:= SizeOf(TChooseFont);
    hwndOwner  := HWindow;
    lpLogFont  := @ALogFont;
    Flags      := cf_ScreenFonts or cf_Effects or cf_InitToLogFontStruct;
    rgbColors  := ColorRef;
    lpszStyle  := Style;
  end;
  if not ChooseFont(ChooseRec) then
    Exit;

{ Update the Font and Color data fields, then cause the window to be
  repainted.
}
  if TheFont <> 0 then
    DeleteObject(TheFont);
  ColorRef:= ChooseRec.rgbColors;
  TheFont := CreateFontIndirect(ALogFont);
  InvalidateRect(HWindow, nil, True);
end;

{ Displays the help index for the Demo Help File.
}
procedure TCommDlgsWindow.CMHelp(var Msg: TMessage);
begin
  WinHelp(HWindow, HelpName, Help_Index, 0);
end;

{ Displays the program's About Box dialog.
}
procedure TCommDlgsWindow.CMHelpAbout(var Msg: TMessage);
begin
  Application^.ExecDialog(New(PDialog, Init(@Self, PChar(id_About))));
end;


{ TCommDlgApp Methods }

procedure TCommDlgApp.InitMainWindow;
begin
  MainWindow := New(PCommDlgsWindow, Init(nil, Application^.Name));
end;


{ Main program }

begin
  App.Init(DemoTitle);
  App.Run;
  App.Done;
end.
