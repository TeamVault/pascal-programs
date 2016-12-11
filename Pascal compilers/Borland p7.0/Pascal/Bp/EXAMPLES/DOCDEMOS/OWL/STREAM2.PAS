{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ Load and display a collection of graphical objects from a stream:
  ellipses, rectangles and pie slices. This collection was created
  and put on a stream by another program (STREAM1.PAS). }

program Stream2;

uses
  Objects, WinTypes, WinProcs, Strings, OWindows;

const
  em_Stream = 100;

{ ********************************** }
{ ******  Graphical Objects  ******* }
{ ********************************** }

type
  PGraphObject = ^TGraphObject;
  TGraphObject = object(TObject)
    Rect: TRect;
    constructor Init(Bounds: TRect);
    constructor Load(var S: TStream);
    procedure Draw(DC: HDC); virtual;
    procedure Store(var S: TStream); virtual;
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
    constructor Load(var S: TStream);
    procedure Draw(DC: HDC); virtual;
    procedure Store(var S: TStream); virtual;
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

constructor TGraphObject.Load(var S: TStream);
begin
  S.Read(Rect, SizeOf(Rect));
end;

procedure TGraphObject.Draw(DC: HDC);
begin
  Abstract;
end;

procedure TGraphObject.Store(var S: TStream);
begin
  S.Write(Rect, SizeOf(Rect));
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

constructor TGraphPie.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(ArcStart, SizeOf(ArcStart));
  S.Read(ArcEnd, SizeOf(ArcEnd));
end;

procedure TGraphPie.Draw;
begin
  with Rect do
    Pie(DC, Left, Top, Right, Bottom,
      ArcStart.X, ArcStart.Y, ArcEnd.X, ArcEnd.Y);
end;

procedure TGraphPie.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(ArcStart, SizeOf(ArcStart));
  S.Write(ArcEnd, SizeOf(ArcEnd));
end;


{ ********************************** }
{ **  Stream Registration Records ** }
{ ********************************** }

const
  RGraphEllipse: TStreamRec = (
    ObjType: 150;
    VmtLink: Ofs(TypeOf(TGraphEllipse)^);
    Load: @TGraphEllipse.Load;
    Store: @TGraphEllipse.Store);

  RGraphRect: TStreamRec = (
    ObjType: 151;
    VmtLink: Ofs(TypeOf(TGraphRect)^);
    Load: @TGraphRect.Load;
    Store: @TGraphRect.Store);

  RGraphPie: TStreamRec = (
    ObjType: 152;
    VmtLink: Ofs(TypeOf(TGraphPie)^);
    Load: @TGraphPie.Load;
    Store: @TGraphPie.Store);

procedure StreamRegistration;
begin
  RegisterType(RCollection);
  RegisterType(RGraphEllipse);
  RegisterType(RGraphRect);
  RegisterType(RGraphPie);
end;

{ ********************************** }
{ *********  Graph Window  ********* }
{ ********************************** }
type
  { Define a TApplication descendant }
  TGraphApp = object(TApplication)
    procedure InitMainWindow; virtual;
    procedure Error(ErrorCode: Integer); virtual;
  end;

  PGraphWindow = ^TGraphWindow;
  TGraphWindow = object(TWindow)
    GraphicsList: PCollection;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
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
constructor TGraphWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  inherited Init(AParent, ATitle);
  GraphicsList := nil;
end;

procedure TGraphWindow.SetupWindow;
var
  Bounds: TRect;
  I: Integer;
  P: PGraphObject;
  GraphicsStream: TBufStream;
begin
  inherited SetupWindow;
  StreamRegistration;                        { Register all streams }

  { Load collection from stream }
  GraphicsStream.Init('GRAPH.STM', stOpen, 1024);         { Open stream }
  GraphicsList := PCollection(GraphicsStream.Get);        { Load collection }
  if GraphicsStream.Status <> 0 then
    Status := em_Stream;
  GraphicsStream.Done;                                    { Shut down stream }
end;

destructor TGraphWindow.Done;
begin
  if GraphicsList <> nil then
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
  DrawAll(GraphicsList)
end;

procedure TGraphApp.Error(ErrorCode: Integer);
var
  ErrorString: array[0..25] of Char;
begin
  case ErrorCode of
    em_Stream:
      MessageBox(0, 'Error loading GRAPHICS.STM (run STREAM1.PAS first).',
        'Application Error', mb_Ok);
  else
    WVSPrintF(ErrorString, 'Error code = %d', ErrorCode);
    MessageBox(0, ErrorString, 'Application Error', mb_Ok);
  end;
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
