{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program PaletteTest;

{$R-}

uses WinTypes, WinProcs, OWindows;

const
  NumColors = 8;
  RedVals : array[0..NumColors - 1] of Byte =
    (0, 0, 0, 0, $FF, $FF, $FF, $FF);
  GreenVals : array[0..NumColors - 1] of Byte =
    (0, 0, $FF, $FF, 0, 0, $FF, $FF);
  BlueVals : array[0..NumColors - 1] of Byte =
    (0, $FF, 0, $FF, 0, $FF, 0, $FF);

type 
  PaletteApplication = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

  PTestWindow = ^TestWindow;
  TestWindow = object(TWindow)
    MyLogPalette: PLogPalette;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    destructor Done; virtual;
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMRButtonDown(var Msg: TMessage);
      virtual wm_First + wm_RButtonDown;
  end;

{  Helpful function for dealing with palette-index TColorRefs }
       
function PaletteIndex(W: Word): TColorRef;
begin
  PaletteIndex := $01000000 or W;
end;
   
{--------------------------------------------------}
{ TestWindow method implementations:               }
{--------------------------------------------------}

constructor TestWindow.Init(AParent: PWindowsObject; ATitle: PChar);
var
  i: Integer;
begin
  inherited Init(AParent, ATitle);
  GetMem(MyLogPalette, SizeOf(TLogPalette) + SizeOf(TPaletteEntry) * NumColors);
  MyLogPalette^.palVersion := $300;
  MyLogPalette^.palNumEntries := NumColors;
  for i := 0 to NumColors - 1 do
  begin
    MyLogPalette^.palPalEntry[i].peRed := RedVals[i];
    MyLogPalette^.palPalEntry[i].peGreen := GreenVals[i];
    MyLogPalette^.palPalEntry[i].peBlue := BlueVals[i];
    MyLogPalette^.palPalEntry[i].peFlags := pc_Reserved;
  end;
end;

destructor TestWindow.Done;
begin
  FreeMem(MyLogPalette, (sizeof(TLogPalette) + sizeof(TPaletteEntry) * NumColors ));
  inherited Done;
end;

procedure TestWindow.WMLButtonDown(var Msg: TMessage);
var
  i: Integer;
  ABrush, OldBrush: HBrush;
  OldPalette: HPalette;
  ThePalette: HPalette;
  TheDC: HDC;
begin
  ThePalette := CreatePalette(MyLogPalette^);
  TheDC := GetDC(HWindow);
  OldPalette := SelectPalette(TheDC, ThePalette, False);
  RealizePalette(TheDC);
  for i := 0 to NumColors - 1 do
  begin
    ABrush := CreateSolidBrush(PaletteIndex(i));
    OldBrush := SelectObject(TheDC, ABrush);
    Rectangle(TheDC, i * 25, i * 25, i * 25 + 20, i * 25 + 20);
    SelectObject(TheDC, OldBrush);
    DeleteObject(ABrush);
  end;
  SelectPalette(TheDC, OldPalette, False);
  ReleaseDC(HWindow, TheDC);
  DeleteObject(ThePalette);
end;

procedure TestWindow.WMRButtonDown(var Msg: TMessage);
var
  i: Integer;
  APaletteEntry : TPaletteEntry;
begin
  APaletteEntry := MyLogPalette^.palPalEntry[0];
  for i := 0 to NumColors - 2 do
    MyLogPalette^.palPalEntry[i] := MyLogPalette^.palPalEntry[i + 1] ;
  i := NumColors - 1;
  MyLogPalette^.palPalEntry[i] := APaletteEntry;
end;

{--------------------------------------------------}
{ PaletteApplication method implementations:       }
{--------------------------------------------------}

procedure PaletteApplication.InitMainWindow;
begin
  MainWindow := New(PTestWindow, Init(nil, 'Test Palettes'));
end;

{--------------------------------------------------}
{ Main program:                                    }
{--------------------------------------------------}
var
   PalApp: PaletteApplication;
begin
  PalApp.Init('PaletteApp');
  PalApp.Run;
  PalApp.Done;
end.
