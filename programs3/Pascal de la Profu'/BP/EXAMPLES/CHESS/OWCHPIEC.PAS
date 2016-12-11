{************************************************}
{                                                }
{   ObjectWindows Chess Demo                     }
{   Chess Pieces unit                            }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit OWChPiec;

interface

uses WinProcs, WinTypes, OWindows, OWPieces, Chessdll, OWConst;

type

  PChessPiece = ^TChessPiece;
  TChessPiece = object (TGamePiece)
    Piece: TPiece;
    Color: TColor;
    LastValidSquare: TLocation;
    SquareIsValid: Boolean;
    InJeopardy: Boolean;
    ValidMoves: array [0..27] of TMove;  { 28 = max moves per piece (Queen)}
    NeedPawnPromote: Boolean;
    constructor Init(AParent: PWindowsObject;
                     ASquare: TSquare;
                     Loc: TLocation);
    procedure GetSquare(var Sq: TLocation);
    procedure SetSquare(Sq: TLocation);
    procedure Paint(DC: HDC); virtual;
    function  GetCursor: HCursor; virtual;
    function  CanDrag: Boolean; virtual;
    procedure DragBegin(DC: HDC; Mouse: TPoint); virtual;
    procedure DragContinue(DC: HDC; Mouse: TPoint; Sq: TLocation); virtual;
    function  DragEnd(DC: HDC; Mouse: TPoint;
                      Sq: TLocation; var Move): Boolean; virtual;
    procedure ResetValidMoves(var MoveArray: array of TMove);
    procedure CheckJeopardy(var MoveArray: array of TMove);
    function  ValidSquare(Sq: TLocation): Boolean;
  end;


implementation

constructor TChessPiece.Init(AParent: PWindowsObject;
                             ASquare: TSquare;
                             Loc: TLocation);
begin
  Piece := ASquare.Piece;
  Color := ASquare.Color;
  inherited Init(AParent,
    PChar(bmChessPiecesBaseID + Ord(Piece) + Ord(High(Piece))*Ord(Color)),
    PChar(bmChessPiecesBaseID + Ord(Piece) + Ord(High(Piece))*2), Loc);
  FillChar(ValidMoves, SizeOf(ValidMoves), 0);
  Word(LastValidSquare) := 0;
  SquareIsValid := True;
  InJeopardy := False;
  NeedPawnPromote := False;
end;

procedure TChessPiece.GetSquare(var Sq: TLocation);
begin
  Sq := Square;
end;

procedure TChessPiece.SetSquare(Sq: TLocation);
begin
  Square := Sq;
end;

function TChessPiece.GetCursor: HCursor;
begin
  if Dragging then
    if SquareIsValid then
      GetCursor := LoadCursor(HInstance, PChar(curInvisible))
    else
      GetCursor := LoadCursor(HInstance, PChar(curNo))
  else
    GetCursor := LoadCursor(HInstance, PChar(curGrabHandOpen));
end;

procedure TChessPiece.Paint(DC: HDC);
var
  OldBrush: HBrush;
  OldPen: HPen;
  OldRop: Integer;
  R: TRect;
begin
  inherited Paint(DC);
  if InJeopardy and not DragHidden then
  begin
    R := Rect;
    OldBrush := SelectObject(DC, GetStockObject(Null_Brush));
    OldPen := SelectObject(DC, GetStockObject(White_Pen));
    OldRop := SetRop2(DC, R2_XORPEN);
    InflateRect(R, -1, -1);
    Rectangle(DC, R.Left, R.Top, R.Right, R.Bottom);
    InflateRect(R, -2, -2);
    Rectangle(DC, R.Left, R.Top, R.Right, R.Bottom);
    SelectObject(DC, OldPen);
    SelectObject(DC, OldBrush);
    SetRop2(DC, OldRop);
  end;      
end;

function  TChessPiece.CanDrag: Boolean;
begin
  CanDrag := ValidMoves[0].Change.Piece <> pEmpty;
end;

procedure TChessPiece.DragBegin(DC: HDC; Mouse: TPoint);
begin
  SquareIsValid := True;
  inherited DragBegin(DC, Mouse);
  Word(LastValidSquare) := 0;   
end;

procedure TChessPiece.DragContinue(DC: HDC; Mouse: TPoint; Sq: TLocation);
begin
  SquareIsValid :=(Word(Sq) = Word(Square)) or
                  (Word(Sq) = Word(LastValidSquare)) or
                   ValidSquare(TLocation(Sq));
  inherited DragContinue(DC, Mouse, Sq);
end;

function  TChessPiece.DragEnd(   DC: HDC;
                              Mouse: TPoint;
                                 Sq: TLocation;
                           var Move        ): Boolean;
begin
  DragEnd := inherited DragEnd(DC, Mouse, Sq, Move)
             and ValidSquare(Sq);
  with TChange(Move) do
  begin
    Piece := Self.Piece;
    Source:= Square;
    Dest  := Sq;
  end;
end;

{ ResetValidMoves takes the valid move list of the current player
  and copies moves for this piece into a local array.  The valid moves
  are used in setting the cursor to indicate whether a piece is
  draggable or whether the dragging piece can move to the current square. }
procedure TChessPiece.ResetValidMoves(var MoveArray: array of TMove);
var
  X: Integer;
  Y: Integer;
begin
  X := 0;
  Y := 0;
  ValidMoves[X].Change.Piece := pEmpty;
  while (X <= High(ValidMoves)) and
        (Y <= High(MoveArray))  and
        (MoveArray[Y].Change.Piece <> pEmpty) do
  begin
    if Word(MoveArray[Y].Change.Source) = Word(Square) then
    begin
      Move(MoveArray[Y], ValidMoves[X], SizeOf(TMove));
      Inc(X);
      ValidMoves[X].Change.Piece := pEmpty;
    end;
    Inc(Y);
  end;
end;

{ CheckJeopardy takes the valid move list of the opponent and looks
  for any move that will capture this piece. }
procedure TChessPiece.CheckJeopardy(var MoveArray: array of TMove);
var
  X: Integer;
  OldState: Boolean;
begin
  OldState := InJeopardy;
  InJeopardy := False;
  X := 0;
  while (not InJeopardy) and
        (X <= High(MoveArray)) and
        (MoveArray[X].Change.Piece <> pEmpty) do
  begin
    InJeopardy := (Word(MoveArray[X].Change.Dest) = Word(Square));
    Inc(X);
  end;
  if OldState xor InJeopardy then  { If state has changed, redraw }
    RequestRedraw;
end;

function  TChessPiece.ValidSquare(Sq: TLocation): Boolean;
var
  X: Integer;
begin
  ValidSquare := False;
  X := 0;
  while (X <= High(ValidMoves)) and
        (ValidMoves[X].Change.Piece <> pEmpty) and
        (Word(ValidMoves[X].Change.Dest) <> Word(Sq)) do
    Inc(X);
  if (X <= High(ValidMoves)) and
     (ValidMoves[X].Change.Piece <> pEmpty) and
     (Word(ValidMoves[X].Change.Dest) = Word(Sq)) then
  begin
    ValidSquare := True;
    LastValidSquare := Sq;
    NeedPawnPromote := (Piece = pPawn) and
                       (ValidMoves[X].Change.Piece <> Piece);
  end
end;

end.