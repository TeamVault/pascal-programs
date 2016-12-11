{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ Create a collection of graphical objects: Points, Circles,
  and Rectangles. Use the ForEach iterator to display each
  object in the collection. }

program Collect4;

uses Objects, WinTypes, WinProcs, OWindows;

const
  NumToDraw = 10;

{ ********************************** }
{ ******  Graphical Objects  ******* }
{ ********************************** }

type
  PGraphObject = ^TGraphObject;
  TGraphObject = object(TObject)
    Rect: TRect;
    constructor Init(Bounds: TRect);
    procedure Draw(DC: HDC); virtual;
  end;

  PGraphEllipse = ^TGraphEllipse;
  TGraphEllipse = object(TGraphObject)
    procedure Draw(DC: HDC); virtual;
  end;

  PGraphRect = ^TGraphRect;
  TGraphRect = object(TGraphObject)
    procedure Draw(DC: HDC); virtual;
  end;

  PGraphPie = ^TGraphPie;
  TGraphPie = object(TGraphObject)
    ArcStart, ArcEnd: TPoint;
    constructor Init(Bounds: TRect);
    procedure Draw(DC: HDC); virtual;
  end;

{ TGraphObject }
constructor TGraphObject.Init(Bounds: TRect);
var
  Height, Width: Word;
begin
  inherited Init;
  with Bounds do
  begin
    Height := Random(Bottom - Top) div 2 + 10;
    Width := Random(Right - Left) div 3 + 15;
  end;
  with Rect do
  begin
    Left := Random(Bounds.Right - Bounds.Left - Width);
    Right := Left + Width;
    Top := Random(Bounds.Bottom - Bounds.Top - Height);
    Bottom := Top + Height;
  end;
end;

procedure TGraphObject.Draw(DC: HDC);
begin
  Abstract;
end;

{ TGraphEllipse }
procedure TGraphEllipse.Draw(DC: HDC);
begin
  with Rect do
    Ellipse(DC, Left, Top, Right, Bottom);
end;

{ TGraphRect }
procedure TGraphRect.Draw(DC: HDC);
begin
  with Rect do
    Rectangle(DC, Left, Top, Right, Bottom);
end;

{ TGraphPie }
constructor TGraphPie.Init(Bounds: TRect);
var Height, Width: Word;
begin
  inherited Init(Bounds);
  with Bounds do
  begin
    Height := Random(Bottom - Top);
    Width := Random(Right - Left);

    ArcStart.X := Random(Right - Left - Width);
    ArcEnd.X := ArcStart.X + Width;
    ArcStart.Y := Random(Bottom - Top - Height);
    ArcEnd.Y := ArcStart.Y + Height;
  end;
end;

procedure TGraphPie.Draw;
begin
  with Rect do
    Pie(DC, Left, Top, Right, Bottom, ArcStart.X, ArcStart.Y, ArcEnd.X, ArcEnd.Y);
end;

{ ********************************** }
{ *********  Graph Window  ********* }
{ ********************************** }
type
  { Define a TApplication descendant }
  TGraphApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

  PGraphWindow = ^TGraphWindow;
  TGraphWindow = object(TWindow)
    GraphicsList: PCollection;
    destructor Done; virtual;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure SetupWindow; virtual;
  end;


{ TGraphApp }
procedure TGraphApp.InitMainWindow;
begin
  MainWindow := New(PGraphWindow,
    Init(nil, 'Collection of Graphical Objects'));
end;

{ TGraphWindow }
procedure TGraphWindow.SetupWindow;
var
  Bounds: TRect;
  I: Integer;
  P: PGraphObject;
begin
  TWindow.SetupWindow;
  GetClientRect(HWindow, Bounds);

  { Instantiate a collection of objects }

  { Initialize collection to hold 10 elements first, then grow by 5's }
  GraphicsList := New(PCollection, Init(10, 5));

  for I := 1 to NumToDraw do
  begin
    case I mod 3 of                      { Create it }
      0: P := New(PGraphRect, Init(Bounds));
      1: P := New(PGraphEllipse, Init(Bounds));
      0..2: P := New(PGraphPie, Init(Bounds));
    end;
    GraphicsList^.Insert(P);                     { Add it to collection }
  end;
end;

destructor TGraphWindow.Done;
begin
  Dispose(GraphicsList, Done);         { Delete collection }
  inherited Done;
end;

procedure TGraphWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);

{ Nest the iterator method inside Paint so it can access the DC }
procedure DrawAll(C: PCollection); far;

{ Nested, far procedure. Receives one
  collection element--a GraphObject, and
  calls that elements Draw method.
}

procedure CallDraw(P : PGraphObject); far;
begin
  P^.Draw(PaintDC);                            { Call Draw method }
end;

begin { DrawAll }
  C^.ForEach(@CallDraw);              { Draw each object }
end;

begin
  if GraphicsList <> nil then DrawAll(GraphicsList);
end;


{ ********************************** }
{ **********  Main Program ********* }
{ ********************************** }

{ Declare a variable of type TGraphApp }
var
  GraphApp: TGraphApp;

{ Run the GraphApp }
begin
  GraphApp.Init('GraphApp');
  GraphApp.Run;
  GraphApp.Done;
end.

