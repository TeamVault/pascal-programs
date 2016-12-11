{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ Create and display a collection of graphical objects:
  ellipses, rectangles and pie slices. Then put them on a stream
  to be read by another program (STREAM2.PAS). }

program Stream1;

uses
  Objects, WinTypes, WinProcs, Strings, OWindows;

const
  NumToDraw = 10;
  em_Stream = 100;

{ ********************************** }
{ ******  Graphical Objects  ******* }
{ ********************************** }

type
  PGraphObject = ^TGraphObject;
  TGraphObject = object(TObject)
    Rect: TRect;
    constructor Init(Bounds: TRect);
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
    Load: nil;                             { No load method yet }
    Store: @TGraphEllipse.Store);

  RGraphRect: TStreamRec = (
    ObjType: 151;
    VmtLink: Ofs(TypeOf(TGraphRect)^);
    Load: nil;                             { No load method yet }
    Store: @TGraphRect.Store);

  RGraphPie: TStreamRec = (
    ObjType: 152;
    VmtLink: Ofs(TypeOf(TGraphPie)^);
    Load: nil;                             { No load method yet }
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

procedure TGraphApp.Error(ErrorCode: Integer);
var
  ErrorString: array[0..25] of Char;
begin
  case ErrorCode of
    em_Stream:
      MessageBox(0, 'Error creating GRAPHICS.STM.',
        'Application Error', mb_Ok);
  else
    WVSPrintF(ErrorString, 'Error code = %d', ErrorCode);
    MessageBox(0, ErrorString, 'Application Error', mb_Ok);
  end;
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

  { Put the collection in a stream on disk }
  StreamRegistration;                   { Register all streamed objects }
  GraphicsStream.Init('GRAPH.STM', stCreate, 1024);
  GraphicsStream.Put(GraphicsList);     { Output collection }
  if GraphicsStream.Status <> 0 then
    Status := em_Stream;
  GraphicsStream.Done;                  { Shut down stream }
end;

destructor TGraphWindow.Done;
begin
  Dispose(GraphicsList, Done);         { Delete collection }
  inherited Done;
end;

procedure TGraphWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
const
  Msg: PChar = 'Figures stored. Run STREAM2.PAS to load and see them.';
var
  Bounds: TRect;
begin
  GetClientRect(HWindow, Bounds);
  DrawText(PaintDC, Msg, StrLen(Msg), Bounds, DT_WordBreak);
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

