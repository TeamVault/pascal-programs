{************************************************}
{                                                }
{   Chess - Shared DLL Example                   }
{   CHESS.DLL Move list and making managment     }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit LMoves;

{$R-,Q-,S-,W-}

interface

uses GameRec, ChessInf;

const
  LoseValue = $7D00;             { Evaluation constants }
  MateValue = $7C80;
  DepthFactor = $80;

procedure InitChessTime;
procedure StopChessTime;
procedure StartChessTime(Color : ColorType);
function IllegalMove(Move : MoveType) : boolean;
procedure MakeMove(Move : MoveType);
procedure TakeBackMove(Move : MoveType);
procedure EnterKeyMove;
procedure ResetMoves;
procedure AdjustMoves;
procedure StoreMoves;
procedure ClearHint;
function  CalcSquare(a,b : char) : EdgeSquareType;
function  MoveCheck(const Move : MoveType): TChessError;
procedure EnterMove(Move : MoveType);

implementation

uses LBoard, LMoveGen, LTimer;

procedure InitChessTime;
{ Initializes the chess clocks }
begin
  CC.ChessTime[White].Init;
  CC.ChessTime[Black].Init;
  CC.Running := False;
end; { InitChessTime }

procedure StopChessTime;
{ Stop the Running chess Clock }
begin
  with CC do
  begin
    if Running then
      ChessTime[RunColor].Stop;
    Running := False;
  end;
end; { StopChessTime }

procedure StartChessTime(Color : ColorType);
{ Stop the Running chess Clock and Start the Clock for Color }
begin
  StopChessTime;
  with CC do
  begin
    RunColor := Color;
    Running := True;
    ChessTime[RunColor].Start;
  end;
end; { StartChessTime }

function IllegalMove(Move : MoveType) : boolean;
{ Tests whether the Move is Legal for
  ProgramColor = Player in the position }
begin
  Perform(Move,DoIt);
  with CC do
    IllegalMove := Attacks(Opponent,PieceTab[Player,0].ISquare);
  Perform(Move,UndoIt);
end; { IllegalMove }

procedure MakeMove(Move : MoveType);
{ Makes Move for ProgramColor=Player, and updates variables }
begin
  with CC do
  begin
    Inc(Depth);
    Inc(MoveNo);
    Perform(Move, DoIt);
    ProgramColor := Opponent;
    Opponent := Player;
    Player := ProgramColor;
  end;
end; { MakeMove }

procedure TakeBackMove(Move : MoveType);
{ Takes Back Move and updates variables }
begin
  with CC do
  begin
    ProgramColor := Opponent;
    Opponent := Player;
    Player := ProgramColor;
    Perform(Move, UndoIt);
    MoveNo := Pred(MoveNo);
    Depth := Pred(Depth);
  end;
end; { TakeBackMove }

procedure ResetMoves;
{ Resets MovTab }
begin
  with CC do
  begin
    Depth := -1;
    MovTab[-1] := ZeroMove;
  end;
end; { ResetMoves }

procedure AdjustMoves;
{ Moves MovTab to Depth=-1 }
var   i :     integer;
begin
  if CC.Depth <> -1 then
  with CC do
  begin
    for i := Depth downto Back do
       MovTab[i - Succ(Depth)] := MovTab[i];
    Depth := -1;
  end;
end; { AdjustMoves }

procedure StoreMoves;
{ Moves MovTab One Move Back }
var   i : integer;
begin
  with CC do
  begin
    Dec(Depth);
   for i := Back to Depth do
      MovTab[i] := MovTab[Succ(i)];

    MovTab[Back] := ZeroMove;
  end;
end; { StoreMoves }

procedure ClearHint;
{ Clears HintLine }
begin
  with CC do
  begin
    HintLine[0] := ZeroMove;
    HintEvalu := 0;
  end;
end; { ClearHint }


procedure EnterMove(Move : MoveType);
{ Performs a Move in the game }
begin
   MakeMove(Move);
   StartChessTime(CC.ProgramColor);
end;

procedure EnterKeyMove;
{ Perform the Move entered from the keyboard (KeyMove) }
begin
  with CC do
  begin
    MovTab[Succ(Depth)] := KeyMove;
    PlayerMove := KeyMove;
    ClearHint;
    EnterMove(MovTab[Succ(Depth)]);
  end;
end;


function CalcSquare(a,b : char) : EdgeSquareType;
{ Converts the Square indicator from its input from to a
  form that the Analysis part of the program understands  }
begin
   if (a in ['A'..'H']) and (b in ['1'..'8']) then
      CalcSquare := (ord(b) - ord('1')) * 16 +
                  (ord(a) - ord('A'))
   else
      CalcSquare := -1;
end; { CalcSquare }



{ This procedure checks to see if the given Move is Legal }
function MoveCheck(const Move : MoveType): TChessError;
begin
  with CC do
  begin
    Inc(Depth);                    { Check Move }

    KeyMove := ZeroMove;
    InitMovGen;
    repeat
      { Generate all moves and find One which matches the input }
      MovGen;
      if (NextMove.MovPiece <> Empty) and
        ((NextMove.MovPiece = Move.MovPiece) or (Move.MovPiece = Empty)) and
        ((NextMove.New1 = Move.New1) or (Move.New1 and $88 <> 0)) and
        ((NextMove.Old = Move.Old) or (Move.Old and $88 <> 0)) then
      begin
        if KeyMove.MovPiece = Empty then
          KeyMove := NextMove
        else
        begin
          if (NextMove.MovPiece = Pawn) and (KeyMove.MovPiece <> Pawn) then
            KeyMove := NextMove
          else if (NextMove.MovPiece <> Pawn) and (KeyMove.MovPiece = Pawn) then
          begin
            { Leave KeyMove in place }
          end
          else 
          begin
            Dec(Depth);
            MoveCheck := ceAmbiguousMove;
            Exit;
          end;
        end;
      end;
    until NextMove.MovPiece = Empty;

    Dec(Depth);
    if KeyMove.MovPiece = Empty then
      MoveCheck := ceInvalidMove
    else
      if IllegalMove(KeyMove) then
        MoveCheck := ceIllegalMove
      else
        MoveCheck := ceOK;

    { The entered Move has been checked for correctness. It has
      been placed in KeyMove for Search }
  end;  { with CC^ }
end; { MoveCheck }

end.