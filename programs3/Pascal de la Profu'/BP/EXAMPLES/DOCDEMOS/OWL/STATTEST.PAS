{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program StatTest;

uses WinTypes, WinProcs, OWindows, ODialogs;

const
  id_ST1 = 101;
  id_ST2 = 102;
  id_ST3 = 103;
  id_ST4 = 104;
  id_ST5 = 105;
  id_ST6 = 106;
  id_ST7 = 107;
  id_ST8 = 108;
  id_ST9 = 109;
  id_ST10 = 110;
  id_ST11 = 111;
  id_ST12 = 112;
  id_ST13 = 113;
  id_ST14 = 114;
  id_ST15 = 115;
  id_ST16 = 116;
  id_ST17 = 117;
  id_ST18 = 118;
  id_ST19 = 119;
  id_ST20 = 120;

type

  TestApplication = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

  PTestWindow = ^TestWindow;
  TestWindow = object(TWindow)
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
  end;

{--------------------------------------------------}
{ TestWindow's method implementations:             }
{--------------------------------------------------} 

constructor TestWindow.Init(AParent: PWindowsObject; ATitle: PChar);
var
  AStat : PStatic;
begin
  inherited Init(AParent, ATitle);
  AStat := New(PStatic, Init(@Self, id_ST1, 'Default Static', 20, 20, 150, 24, 0));
  AStat := New(PStatic, Init(@Self, id_ST2, 'SS_SIMPLE', 20, 50, 150, 24, 0));
  AStat := New(PStatic, Init(@Self, id_ST3, 'SS_LEFT', 20, 80, 150, 24, 0));
  AStat := New(PStatic, Init(@Self, id_ST4, 'SS_CENTER', 20, 110, 150, 24, 0));
  AStat := New(PStatic, Init(@Self, id_ST5, 'SS_RIGHT', 20, 140, 150, 24, 0));
  AStat := New(PStatic, Init(@Self, id_ST6, 'SS_BLACKFRAME', 20, 170, 150, 24, 0));
  AStat := New(PStatic, Init(@Self, id_ST7, 'SS_BLACKRECT', 20, 200, 150, 24, 0));
  AStat := New(PStatic, Init(@Self, id_ST8, 'SS_GRAYFRAME', 20, 230, 150, 24, 0));
  AStat := New(PStatic, Init(@Self, id_ST9, 'SS_GRAYRECT', 20, 260, 150, 24, 0));
  AStat := New(PStatic, Init(@Self, id_ST10, 'SS_NOPREFIX', 20, 290, 150, 24, 0));
  AStat := New(PStatic, Init(@Self, id_ST11, 'Sample &Text', 170, 20, 200, 24, 0));
  AStat := New(PStatic, Init(@Self, id_ST12, 'Sample &Text', 170, 50, 200, 24, 0));
  AStat^.Attr.Style := AStat^.Attr.Style and not SS_LEFT or SS_SIMPLE;
  AStat := New(PStatic, Init(@Self, id_ST13, 'Sample &Text', 170, 80, 200, 24, 0));
  AStat := New(PStatic, Init(@Self, id_ST14, 'Sample &Text', 170, 110, 200, 24, 0));
  AStat^.Attr.Style := AStat^.Attr.Style and not SS_LEFT or SS_CENTER;
  AStat := New(PStatic, Init(@Self, id_ST15, 'Sample &Text', 170, 140, 200, 24, 0));
  AStat^.Attr.Style := AStat^.Attr.Style and not SS_LEFT or SS_RIGHT;
  AStat := New(PStatic, Init(@Self, id_ST16, 'Sample &Text', 170, 170, 200, 24, 0));
  AStat^.Attr.Style := AStat^.Attr.Style and not SS_LEFT or SS_BLACKFRAME;
  AStat := New(PStatic, Init(@Self, id_ST17, 'Sample &Text', 170, 200, 200, 24, 0));
  AStat^.Attr.Style := AStat^.Attr.Style and not SS_LEFT or SS_BLACKRECT;
  AStat := New(PStatic, Init(@Self, id_ST18, 'Sample &Text', 170, 230, 200, 24, 0));
  AStat^.Attr.Style := AStat^.Attr.Style and not SS_LEFT or SS_GRAYFRAME;
  AStat := New(PStatic, Init(@Self, id_ST19, 'Sample &Text', 170, 260, 200, 24, 0));
  AStat^.Attr.Style := AStat^.Attr.Style and not SS_LEFT or SS_GRAYRECT;
  AStat := New(PStatic, Init(@Self, id_ST20, 'Sample &Text', 170, 290, 200, 24, 0));
  AStat^.Attr.Style := AStat^.Attr.Style and not SS_LEFT or SS_NOPREFIX or SS_RIGHT;
end;

{--------------------------------------------------}
{ TestApplication's method implementations:        }
{--------------------------------------------------} 

procedure TestApplication.InitMainWindow;
begin
  MainWindow := New(PTestWindow, Init(nil, 'Static Control Tester'));
end;

{--------------------------------------------------}
{ Main program:                                    }
{--------------------------------------------------} 

var
  TestApp : TestApplication;
begin
  TestApp.Init('StatTest');
  TestApp.Run;
  TestApp.Done;
end.

