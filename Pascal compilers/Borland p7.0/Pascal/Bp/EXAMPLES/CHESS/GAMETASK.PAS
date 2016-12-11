{************************************************}
{                                                }
{   Chess - Shared DLL Example                   }
{   CHESS.DLL Game task managment.               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit GameTask;

{$R-,Q-,S-,W-}

interface

const
  tmFindMove    = 1;
  tmThinkAhead  = 2;
  tmResume      = 3;
  tmComplete    = 4;
  tmEnterMove   = 5;
  tmTimeExpired = 6;
  tmAbort       = 7;  { Aborts the current search (FindMove or ThinkAhead) }
  tmTerminate   = $FFFF;

procedure DoGameTask;

implementation

uses GameRec, LMoves, LMoveGen, LOpenLib, LEval, TaskMgr;

procedure EnterOppMove;
begin
  AdjustMoves;
  EnterKeyMove;
  StoreMoves;
  Exclude(CC.State, MovePending);
end;

procedure RecordFindMove;
begin
  with CC do
  begin

    { Copy the MainLine to HintLine }
    MovTab[0] := MainLine[0];
    Move(MainLine[1], HintLine[0], Sizeof(MainLine) - Sizeof(MoveType));
    HintEvalu := MainEvalu;
    if MovTab[0].MovPiece = Empty then
    begin

      { No Possible Move }
      HintLine[0] := ZeroMove;
      Include(State, GameOver);
      Exit;
    end; { if }

    EnterMove(MovTab[Depth + 1]);
    StoreMoves;
    PlayerMove := ZeroMove;
    Exclude(State, Analysis);
  end;
end;

{ The program moves }
procedure StartMove;
var
  Result: Integer;
  Dep: DepthType;
  Msg: Word;
begin
  Include(CC.State, Analysis);
  Exclude(CC.State, OppAnalysis);

  { Wait for a Think }
  repeat
    Msg := Message(tmComplete)
  until Msg in [tmResume, tmAbort];
  if Msg = tmAbort then
  begin
    Exclude(CC.State, Analysis);
    Exit;
  end;

  { Try to find a Move in the opening library  }
  AdjustMoves;
  CalcLibNo;
  with CC do
  begin
    Depth := 0;
    if LibNo > 0 then
    begin
      Include(State, InLibrary);
      FindOpeningMove;
    end
    else
    begin
      Exclude(State, InLibrary);

      { Perform the Search }
      FindMove(MaxLevel);
    end;
    Depth := -1;
    if Analysis in State then
      RecordFindMove;
  end;  { with }
end; { StartMove }

{ Perform analysis in the opponents time of reflection.
  The program assumes that the Opponent will Perform the
  Hint Move, and starts analysing On it counter Move }
procedure ThinkAhead;
var
  Msg: Word;
begin
  with CC do
  begin
    if HintLine[0].MovPiece = Empty then
      Exit;

    Exclude(State, Analysis);
    Include(State, OppAnalysis);

    { Wait for a Think }
    repeat
      Msg := Message(tmComplete);
    until Msg in [tmResume, tmAbort];
    if Msg = tmAbort then
    begin
      Exclude(State, OppAnalysis);
      Exit;
    end;

    { Setup surroundings as if the Opponent had performed the hint move }
    AdjustMoves;
    MovTab[Depth + 1] := HintLine[0];
    MakeMove(MovTab[Depth + 1]);
    StoreMoves;
    AdjustMoves;

    { Analyse until a tmEnterMove is received }
    Depth := 0;
    FindMove(MaxLevel);

    Depth := -1;

    if MovePending in State then
    begin

      { Here if we received a tmEnterMove and the opponent did not make
        the hint move.  Find the move the old fashioned way }
      TakeBackMove(MovTab[Depth]);

      { Enter opponents move }
      EnterOppMove;

      { Only legal message to receive now is tmFindMove }
      Exclude(State, OppAnalysis);
      repeat
        Msg := Message(tmFindMove);
      until Msg in [tmFindMove, tmAbort];

      if Msg <> tmAbort then
        { Start the move }
        StartMove;
    end
    else
      if Analysis in State then
        RecordFindMove
      else
        { was aborted with tmAbort }
        TakeBackMove(MovTab[Depth]);
    Exclude(State, OppAnalysis);
  end;
end; { ThinkAwhile }

{ Game background task's main loop }

procedure DoGameTask;
begin
  repeat
    case Message(tmComplete) of
      tmEnterMove:  EnterOppMove;
      tmFindMove:   StartMove;
      tmThinkAhead: ThinkAhead;
      tmTerminate:  Exit;
    end;
  until False;
end;

end.