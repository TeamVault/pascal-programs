{************************************************}
{                                                }
{   Chess - Shared DLL Example                   }
{   CHESS.DLL Board managment                    }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit LBoard;

{$R-,Q-,S-,W-}

interface

uses GameRec;

function EqMove(var A, B: MoveType): Boolean;
function Min(A, B: Integer): Integer;
function Max(A, B: Integer): Integer;
procedure InitBoard;
procedure CalcPieceTab;
procedure GenCastSquare(New1: SquareType; var CastSquare,
  CornerSquare: SquareType);
procedure Perform(Move: MoveType; ResetMove: Boolean);
procedure MovePiece(New1,Old: SquareType);
procedure DeletePiece(InSquare: SquareType);
procedure InsertPiece(InPiece: PieceType; InColor: ColorType;
  InSquare: SquareType);
procedure ChangeType(NewType: PieceType; InSquare: SquareType);

{ To make Perform's ResetMove parameter easier to read: }
const
  DoIt = False;
  UndoIt = True;

implementation

uses Strings;

{ Compares two moves }
function EqMove(var A, B: MoveType): Boolean;
begin
   EqMove := False;
   if A.MovPiece = B.MovPiece then
     if A.New1 = B.New1 then
       if A.Old = B.Old then
         if A.Content = B.Content then
           if A.Spe = B.Spe then
             EqMove := True;
end; { EqMove }

function Min(A, B: Integer): Integer;
begin
  if A < B then
    Min := A
  else
    Min := B;
end; { Min }

function Max(A, B: Integer): Integer;
begin
  if A > B then
    Max := A
  else
    Max := B;
end; { Max }

{ Calculates PieceTab from scratch }
procedure CalcPieceTab;
var
  Square: SquareType;
  Piece1: PieceType;

  { Clears indexes in Board and PieceTab }
  procedure ClearIndex;
  var
    Square: SquareType;
    Col: ColorType;
    Index: IndexType;
  begin
    with CC do
    begin
      for Square := 0 to $77 do
        Board[Square].Index := 16;
      for Col := White to Black do
        for Index := 0 to 15 do
          PieceTab[Col,Index].IPiece := Empty;
      PawnNo[White] := -1;
      PawnNo[Black] := -1;
      OfficerNo := PawnNo;
    end;
  end;

begin
  ClearIndex;

  { Insert all the Pieces of the type }
  for Piece1 := King to Pawn do
  with CC do
  begin

    { Save Number of officers }
    if Piece1 = Pawn then
      OfficerNo := PawnNo;

    Square := 0;
    repeat
      with Board[Square] do
        if Piece = Piece1 then
        begin

          { Count Pieces }
          Inc(PawnNo[Color]);

          { Insert Piece }
          with PieceTab[Color,PawnNo[Color]] do
          begin
            IPiece := Piece1;
            ISquare := Square;
            Index := PawnNo[Color];
          end;
        end;

        { Generate all squares from border to center }
        Square := Square xor $77;
        if (Square and 4) = 0 then
          if Square >= $70 then
            Square := (Square + $11) and $73
          else
            Square := Square + $10;
    until Square = 0;
  end;
end; { CalcPieceTab }

{ Calculates the squares for the Rook Move in A castling }
procedure GenCastSquare(New1: SquareType; var CastSquare,
  CornerSquare: SquareType);
begin
   { Short }
   if (New1 and 7) >= 4 then
   begin
     CastSquare := New1 - 1;
     CornerSquare := New1 + 1;
   end
   else

   { Long }
   begin
    CastSquare := New1 + 1;
    CornerSquare := New1 - 2;
   end;
end; { GenCastSquare }


{ Utility functions for Perform: }

{ Is used to Move a Piece }
procedure MovePiece(New1,Old: SquareType);
var
  B: BoardType;
begin
  with CC do
  begin
    B := Board[New1];
    Board[New1] := Board[Old];
    Board[Old] := B;
    with Board[New1] do
      PieceTab[Color,Index].ISquare := New1;
  end;
end; { MovePiece }

{ Is used in captures. The Square must not be Empty }
procedure DeletePiece(InSquare: SquareType);
begin
  with CC, Board[InSquare] do
  begin
    Piece := Empty;
    PieceTab[Color,Index].IPiece := Empty;
  end;
end; { DeletePiece }

{ Is used to take Back captures }
procedure InsertPiece(InPiece: PieceType; InColor: ColorType;
  InSquare: SquareType);
begin
  with CC, Board[InSquare],PieceTab[InColor,Index] do
  begin
    Piece := InPiece;
    Color := InColor;
    IPiece := InPiece;
    ISquare := InSquare;
  end;
end; { InsertPiece }

{ Is used for Pawn promotion }
procedure ChangeType(NewType: PieceType; InSquare: SquareType);
begin
  with CC, Board[InSquare] do
  begin
    Piece := NewType;
    PieceTab[Color,Index].IPiece := NewType;
    if OfficerNo[Color] < Index then
      OfficerNo[Color] := Index;
  end;
end; { ChangeType }


{ Clears the Board and initializes the Board-module }
procedure InitBoard;
var
  i: 0..7;
begin
  with CC do
  begin
    FillChar(Board, sizeof(Board), 0);

    { Setup Start position }
    for i := 0 to 7 do
    begin
      InsertPiece(Pieces[i],White, i);
      InsertPiece(Pawn,White, i + $10);
      InsertPiece(Pawn,Black, i + $60);
      InsertPiece(Pieces[i],Black, i + $70);
    end;
  end;

  { init the PieceTable, closely coupled with the board }
  CalcPieceTab;
end; { InitBoard }



{ Performs or takes Back Move (takes Back if ResetMove if True),
  and performs the updating of Board and PieceTab. Player must
  contain the Color of the moving Player, Opponent the Color
  of the Opponent.

  MovePiece, DeletePiece, InsertPiece and ChangeType
  are used to Update the Board module }
procedure Perform(Move: MoveType; ResetMove: Boolean);
var
  New1,CastSquare,CornerSquare,EpSquare: SquareType;
begin
  with CC, Move do
  begin
    { Perform Move }
    if ResetMove then
    begin
      MovePiece(Old,New1);
      if Content <> Empty then
        InsertPiece(Content,Opponent,New1);
    end
    else
    begin
      if Content <> Empty then
        DeletePiece(New1);
      MovePiece(New1,Old);
    end;

    { Test if Move is special }
    if Spe then
      if MovPiece = King then
      begin

        { Castling Move }
        GenCastSquare(New1,CastSquare,CornerSquare);
        if ResetMove then
          MovePiece(CornerSquare,CastSquare)
        else
          MovePiece(CastSquare,CornerSquare);
      end
      else
        if MovPiece = Pawn then
        begin

          { E.p. capture }
          EpSquare := (New1 and 7) + (Old and $70);
          if ResetMove then
            InsertPiece(Pawn,Opponent,EpSquare)
          else
            DeletePiece(EpSquare);
        end
        else

          { Pawn-promotion }
          if ResetMove then
            ChangeType(Pawn,Old)
          else
            ChangeType(MovPiece,New1);

  end; { with }
end; { Perform }

end.