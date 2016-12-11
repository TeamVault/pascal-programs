{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{$R-} { Turn off range check because Windows message parameters
        don't distinguish between Integer and Word. }

unit GrafLine;

interface

uses WinTypes, Objects, OWindows, Pen;

type
  PLinePoint = ^TLinePoint;
  TLinePoint = object(TObject)
    X, Y: Integer;
    constructor Init(AX, AY: Integer);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
  end;

  PLine = ^TLine;
  TLine = object(TObject)
    Points: PCollection;
    LinePen: PPen;
    constructor Init(APen: PPen);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure AddPoint(AX, AY: Word);
    procedure Draw(ADC: HDC);
    procedure Store(var S: TStream);
  end;

const
  RLinePoint: TStreamRec = (
    ObjType: 200;
    VmtLink: Ofs(TypeOf(TLinePoint)^);
    Load: @TLinePoint.Load;
    Store: @TLinePoint.Store);

  RLine: TStreamRec = (
    ObjType: 201;
    VmtLink: Ofs(TypeOf(TLine)^);
    Load: @TLine.Load;
    Store: @TLine.Store);

implementation

uses WinProcs, OMemory;

{--------------------------------------------------}
{ TDPoints's method implementations:               }
{--------------------------------------------------}

constructor TLinePoint.Init(AX, AY: Integer);
begin
  X := AX;
  Y := AY;
end;

constructor TLinePoint.Load(var S: TStream);
begin
  S.Read(X, SizeOf(X));
  S.Read(Y, SizeOf(Y));
end;

procedure TLinePoint.Store(var S: TStream);
begin
  S.Write(X, SizeOf(X));
  S.Write(Y, SizeOf(Y));
end;

constructor TLine.Init(APen: PPen);
begin
  inherited Init;
  Points := New(PCollection, Init(50, 50));
  LinePen := New(PPen, InitLike(APen));
end;

constructor TLine.Load(var S: TStream);
begin
  Points := PCollection(S.Get);
  LinePen := PPen(S.Get);
end;

destructor TLine.Done;
begin
  Dispose(LinePen, Done);
  Dispose(Points, Done);
  inherited Done;
end;

procedure TLine.AddPoint(AX, AY: Word);
begin
  Points^.Insert(New(PLinePoint, Init(AX, AY)));
end;

procedure TLine.Draw(ADC: HDC);
type
  PtArray = array[0..0] of TPoint;
var
  Pts: ^PtArray;
  PtCount: Integer;

  procedure DrawTheLine(P: PLinePoint); far;
  begin
    Pts^[PtCount].X := P^.X;
    Pts^[PtCount].Y := P^.Y;
    Inc(PtCount);
  end;

begin
  LinePen^.Select(ADC);
  Pts := MemAlloc(Points^.Count * SizeOf(TPoint));
  PtCount := 0;
  Points^.ForEach(@DrawTheLine);
  Polyline(ADC, Pts^, Points^.Count);
  FreeMem(Pts, Points^.Count * SizeOf(TPoint)); 
  LinePen^.Delete;
end;

procedure TLine.Store(var S: TStream);
begin
  S.Put(Points);
  S.Put(LinePen);
end;

begin
  RegisterType(RLinePoint);
  RegisterType(RLine);
end.