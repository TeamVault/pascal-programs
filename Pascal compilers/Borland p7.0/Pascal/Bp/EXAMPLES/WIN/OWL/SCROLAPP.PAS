{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program Scroll;

uses WinTypes, WinProcs, Strings, OWindows;

type

  { Declare TScrollApp, a TApplication descendant }
  TScrollApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

  { Declare TScrollWindow, a TWindow descendant }
  PScrollWindow = ^TScrollWindow;
  TScrollWindow = object(TWindow)
    constructor Init(ATitle: PChar);
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
  end;

{ Construct the TScrollApp's MainWindow of type TScrollWindow }
procedure TScrollApp.InitMainWindow;
begin
  MainWindow := New(PScrollWindow, Init('Boxes'));
end;

{ Constructor for a TScrollWindow, sets scroll styles and constructs
  the Scroller object. }
constructor TScrollWindow.Init(ATitle: PChar);
begin
  TWindow.Init(nil, ATitle);
  Attr.Style := Attr.Style or ws_VScroll or ws_HScroll;
  Scroller := New(PScroller, Init(@Self, 8, 15, 80, 60));
end;

{ Responds to an incoming "paint" message by redrawing boxes.  Note
  that the Scroller's BeginView method, which sets the viewport origin
  relative to the present scroll position, has already been called. }
procedure TScrollWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  X1, Y1, I: Integer;
begin 
  for I := 0 to 49 do
  begin
    X1 := 10 + I * 8;
    Y1 := 30 + I * 5;
    Rectangle(PaintDC, X1, Y1, X1 + X1, X1 + Y1 * 2);
  end;
end;

{ Declare a variable of type TScrollApp } 
var
  ScrollApp: TScrollApp;

{ Run the ScrollApp }
begin
  ScrollApp.Init('ScrollApp');
  ScrollApp.Run;
  ScrollApp.Done;
end.
