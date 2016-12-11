{************************************************}
{                                                }
{   Chess - Shared DLL Example                   }
{   CHESS.DLL Implementation file.               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit ChessInf;

{$R-,Q-,S-,W-}

interface

type
  TPiece = (pEmpty, pKing, pQueen, pRook, pBishop, pKnight, pPawn);
  TColor = (cWhite, cBlack);
  TKind  = (kNormal, kEnPassant, kCastling, kPawnPromote);
  HChess = Word;

type
  TSquare = record
    Piece: TPiece;
    Color: TColor;
  end;
  TBoard = array[1..8,1..8] of TSquare;

  TLocation = record
    X: 0..8;            { 0 is off-board or empty }
    Y: 0..8;            { 0 is off-board or empty }
  end;

  PChange = ^TChange;
  TChange = record
    Piece: TPiece;
    Source: TLocation;
    Dest: TLocation;
  end;

  PMove = ^TMove;
  TMove = record
    Change: TChange;
    Capture: Boolean;
    Contents: TPiece;
    case Kind: TKind of
      kEnPassant: (EPCapture: TLocation);
      kCastling: (RookSource, RookDest: TLocation);
  end;

type
  TSearchStatus = (
    ssComplete,                 { Completed last opperation }
    ssMoveSearch,               { Searching for a move for the current
                                  player }
    ssThinkAhead,               { Thinking ahead while waiting for a
                                  SubmitMove }
    ssGameOver                  { Game is complete }
  );

  TChessStatus = (
    csNormal,                   { Nothing is special about the current state }
    csCheck,                    { The current player is in check }
    csCheckMate,                { The current player is in checkmate }
    csStaleMate,                { The game is a stalemate }
    csResigns,                  { The opponent is so far ahead there is no
                                  point in playing the game further }
    csMateFound,                { Checkmate will happen in a maximum of
                                  Count moves (Count is a parameter of
                                  GetChessStatus) }
    csFiftyMoveRule,            { The game violates the 50 move rule
                                  (stalemate) }
    csRepetitionRule);          { The game violates the 3 repetition rule
                                  (stalemate) }

type
  TChessError = (
                                { General results }
    ceOK,                       { Request sucessful }
    ceInvalidHandle,            { Handle passed is not valid }
    ceIllegalState,             { Call not legal in current state }

                                { NewGame results }
    ceOutOfMemory,              { Not enough memory to allocate game context }
    ceTooManyGames,             { Not enough game handles for new game }

                                { SubmitMove/VarifyMove/ParseMove results }
    ceInvalidMove,              { Cannot move specified piece there }
    ceIllegalMove,              { Move into or does not prevent check or
                                  castling through check }

                                { VerifyMove results }
    ceInvalidSyntax,            { Move syntax cannot be determined }
    ceAmbiguousMove,            { More then one piece fits move (i.e. if you
                                  pass in NF3 and two Knights can be there) }

                                { RetractMove results }
    ceNoMovesLeft);             { No moves left to retract }

{ Game handle management }

{ Allocates a game handle }
function NewGame(var GameHandle: HChess): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}

{ Frees the game handle }
function DisposeGame(CH: HChess): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}


{ Move management }

{ Parses the given Move into a change record. The syntax is as follows:

     <Location> | <Piece name><Location> | <Location><Location>

  where <Location> is in the form A3 or F5 and <Piece letter> is one of:

    P = Pawn, R = Rook, N = Knight, B = Biship, Q = Queen, K = King

  If only a Location is given and the move is ambigious it is assumed the
  piece being moved is a pawn }

function ParseMove(Move: PChar; var Change: TChange): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}

{ Retracts the last move.  NOTE: Retract move should not be called
  during a search! }
function RetractMove(CH: HChess; const Move: TMove): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}

{ Submits a move for the current player.  Both the "Piece" field and
  the "From" field can be empty if the move is unambigious.  This is
  only legal to call while idle or during a "think ahead" }
function SubmitMove(CH: HChess; const Change: TChange): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}

{ Verify the legality of the given change but do not perform the
  change.  The "Source" and "Piece" fields can be empty if move is
  unambigious. This is only legal to call while complete or during a
  "think ahead" }
function VerifyMove(CH: HChess; const Change: TChange): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}


{ Search management }

{ Starts a move search.  It will always return immediately.  You need
  to call Think to perform the actual search. TimeLimit is in 1/18ths
  of a second. }
function ComputerMove(CH: HChess; TimeLimit: LongInt): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}

{ Force the computer to make a move with the information it has now.
  The move will be completed with the next call to Think. This is only
  legal while performing a move search }
function ForceMove(CH: HChess): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}

{ Start using the Think time to begin a search assuming the opponent is
  going to follow the main line.  If the opponent does, the next search
  will start at the think-ahead point, otherwise a new search is started.
  This is only legal to call while idle }
function ThinkAhead(CH: HChess): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}


{ Aborts the current search being performed whether started with ThinkAhead
  or ComputerMove.  The move under consideration is not performed and the
  player is unchanged.  This call is ignored if no search is active }
function AbortSearch(CH: HChess): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}

{ Chess process management }

{ Gives TimeLimit ticks to the computer to think (1/18'ths of a second).
  This call performs the move search.  Think should be called whenever
  the chess program is idle, even while waiting for the opponent.
  The engine utilizes the opponents idle time to "look ahead" to
  improve the results of the next move. The number given in TimeLimit
  should be small (below 10 when searching for a computer move, below
  5 when waiting for the opponent) to allow the rest of the app to be
  responsive.  This is especially important in Windows.  }
function Think(CH: HChess; TimeLimit: LongInt;
  var Status: TSearchStatus): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}


{ Board editing }

{ !!! NOTE: Board editing routines are not valid during a search }

{ Replace the current board with the given board }
function SetBoard(CH: HChess; const ABoard: TBoard): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}

{ Set the current player to Player }
function SetPlayer(CH: HChess; APlayer: TColor): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}

{ Make the following modification to the board.  If the "Source" Location
  is blank the piece is new, if the "Dest" Location is blank the piece is
  taken from the board. If neither are blank the piece is moved.  If the
  piece type does not match the piece in the Source location, the piece
  is changed to be the given type }
function MakeChange(CH: HChess; Color: TColor;
  const Change: TChange): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}


{ Status interface }

{ Returns the status of the move search }
function GetSearchStatus(CH: HChess): TSearchStatus; {$IFDEF WINDOWS} export; {$ENDIF}

{ Returns the current status of the game }
function GetChessStatus(CH: HChess; var Count: Integer): TChessStatus; {$IFDEF WINDOWS} export; {$ENDIF}

{ Format the move as a text string }
function MoveToStr(const Move: TMove; var Str: array of Char): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}

{ !!! NOTE: These functions are not valid to call during a search. }

{ Returns the last move }
function GetLastMove(CH: HChess; var Move: TMove): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}

{ Returns the hint move }
function GetHintMove(CH: HChess; var Move: TMove): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}

{ Returns the current state of the board.  If a search is being performed
  it is the state of the board that is being searched. }
function GetBoard(CH: HChess; var ABoard: TBoard): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}

{ Return the whose turn it is }
function GetPlayer(CH: HChess): TColor; {$IFDEF WINDOWS} export; {$ENDIF}

{ Returns a list of the valid given Change.  Empty fields in the change
  record are used as wildcards in the search.  For example, if you
  want all the legal pawn moves only fill in the Piece field leaving
  the Location fields blank.  If you want all the legal moves for the
  piece on A4, fill in Source with A4 and leave Piece and Dest blank.
  Leaving all fields of Change blank will return all legal moves }
function GetValidMoves(CH: HChess; Change: TChange;
  var Moves: array of TMove): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}

{ !!! NOTE: This function are only meaningful during a search }

{ Returns the current move being searched by the computer }
function GetCurrentMove(CH: HChess; var Move: TMove): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}

{ Returns the current priciple line being used by the computer. }
function GetMainLine(CH: HChess; var Value: Integer;
  var Line: array of TMove): TChessError; {$IFDEF WINDOWS} export; {$ENDIF}

{ Returns the number of nodes processed during the last (or current)
  search }
function GetNodes(CH: HChess): LongInt; {$IFDEF WINDOWS} export; {$ENDIF}

implementation

uses GameRec, LBoard, LMoveGen, LOpenLib, LMoves, Strings, TaskMgr,
  LEval, GameTask;


const
  PieceLetter: array[TPiece] of Char =
    (' ', 'K', 'Q', 'R', 'B', 'N', 'P');


{ Internal verification routines }

function LoadGameHandle(CH: HChess): Boolean;
begin
  if (CH >= 1) and (CH <= MaxGames) and
    (GameList[CH].Magic = gmGameMagic) then
  begin
    LoadGameHandle := True;
    CCHandle := CH;
    CC := GameList[CCHandle];
  end
  else
    LoadGameHandle := False;
end;

procedure StoreGameHandle;
begin
  GameList[CCHandle] := CC;
end;

{ Utility functions }

function OppColor(Color: TColor): TColor;
begin
  if Color = cWhite then OppColor := cBlack else OppColor := cWhite;
end;

{ Internal vs. External representation conversion }

procedure ICoordToECoord(ICoord: Byte; var Location: TLocation);
begin
  if ICoord and $88 <> 0 then
  begin
    Location.X := 0;
    Location.Y := 0;
  end
  else
  begin
    Location.X := ICoord and $F + 1;
    Location.Y := ICoord shr 4  + 1;
  end;
end;

function ECoordToICoord(const Location: TLocation): Byte;
begin
  ECoordToICoord := (Location.X - 1) or (Location.Y - 1) shl 4;
end;

{ Convert an TChange into a MoveType.  Fills in just the partial
  information enough for MoveCheck to fill in the rest }
procedure ChangeToMoveType(const Change: TChange; var IMove: MoveType);
begin
  with Change, IMove do
  begin
    if Source.X <> 0 then
      Old := ECoordToICoord(Change.Source)
    else
      Old := $08;
    if Dest.X <> 0 then
      New1 := ECoordToICoord(Dest)
    else
      New1 := $08;
    MovPiece := PieceType(Piece);
    Spe := False;
    Content := Empty;
  end;
end;

procedure MoveTypeToTMove(const IMove: MoveType; var EMove: TMove);

  { Calculates the Locations for the Rook Move in a castling }
  procedure GenCastLocation(New1 : SquareType; var CastLocation,
    CornerLocation : SquareType);
  begin
    if (New1 and 7) >= 4 then
    begin
      CastLocation := New1 - 1;
      CornerLocation := New1 + 1;
    end
    else
    begin
      CastLocation := New1 + 1;
      CornerLocation := New1 - 2;
    end;
  end; { GenCastLocation }

var
  EpLocation: SquareType;
  CastLocation, CornerLocation: SquareType;
begin
  with IMove, EMove do
  begin
    Change.Piece := TPiece(MovPiece);
    ICoordToECoord(Old, Change.Source);
    ICoordToECoord(New1, Change.Dest);

    { Capture moves }
    Contents := TPiece(Content);
    Capture := Content <> Empty;

    { Process special moves }
    if not Spe then
      Kind := kNormal
    else
      if MovPiece = King then
      begin

        { Castling Move }
        Kind := kCastling;
        GenCastLocation(New1, CastLocation, CornerLocation);
        ICoordToECoord(CornerLocation, RookSource);
        ICoordToECoord(CastLocation, RookDest);
      end
      else
        if MovPiece = Pawn then
        begin

          { E.P. capture }
          Capture := True;
          Kind := kEnPassant;

          EpLocation := (New1 and 7) + (Old and $70);
          ICoordToECoord(EpLocation, EPCapture);
        end
        else

          { Pawn-promotion }
          Kind := kPawnPromote;
  end;
end;


{ Interface implementation }

function NewGame(var GameHandle: HChess): TChessError;
var
  X: Integer;
begin
  NewGame := ceOK;
  GameHandle := 0;
  X := 0;
  repeat
    Inc(X);
  until (X > MaxGames) or (GameList[X].Magic <> gmGameMagic);
  if X > MaxGames then
  begin
    NewGame := ceTooManyGames;
    Exit;
  end;

  CCHandle := X;
  GameHandle := X;
  CC := GameList[CCHandle];

  { Initiallize everything to zero }
  FillChar(CC, SizeOf(TGameData), 0);

  with CC do
  begin
    Magic := gmGameMagic;
    Level := Normal;                   { set Level }
    AverageTime := 15000;
    MaxLevel := MaxPly;
    InitBoard;
    Player := White;
    Opponent := Black;
    ProgramColor := White;
    ResetMoves;
    UseLib := 200;
    MovTab[-1].Content := King;
    InitChessTime;
    MoveNo := 0;
    ClearHint;
    PlayerMove := ZeroMove;
    Nodes := 0;
    Clock.Init;
    Clock.Reset;
    Clock.SetLimit(180);   { max 10 seconds per turn }

    State := [];
    AllocateTask(20000);

    Spawn(DoGameTask);    { Assumes it will immediatly block on a message }
  end;
  StoreGameHandle;
end;

function DisposeGame(CH: HChess): TChessError;
begin
  DisposeGame := ceInvalidHandle;
  if LoadGameHandle(CH) then
  begin
    DisposeGame := ceOK;
    DisposeTask;
    GameList[CCHandle].Magic := 0;
    CCHandle := 0;
  end;
end;


{ Converts the Location indicator from its input form to a form that the
  Analysis part of the program understands }
procedure CalcLocation(X, Y: Char; var Location: TLocation);
begin
  if (X in ['A'..'H']) and (Y in ['1'..'8']) then
  begin
    Location.X := ord(X) - ord('A') + 1;
    Location.Y := ord(Y) - ord('1') + 1;
  end
  else
  begin
    Location.X := 0;
    Location.Y := 0;
  end;
end;

function ParseMove(Move: PChar; var Change: TChange): TChessError;
var
  APiece: TPiece;
begin
   ParseMove := ceInvalidSyntax;
   with Change do
   begin
     Source.X := 0;
     Dest.X := 0;
     Piece := pEmpty;

     case StrLen(Move) of
       4: { Two Locations (e2e4) }
         begin
           CalcLocation(UpCase(Move[0]),Move[1], Change.Source);
           if Source.X = 0 then Exit;
           CalcLocation(UpCase(Move[2]),Move[3], Change.Dest);
         end;
       3: { Piece and Location (Pe4) }
         begin
           CalcLocation(UpCase(Move[1]),Move[2], Change.Dest);
           for APiece := Low(TPiece) to High(TPiece) do
             if UpCase(Move[0]) = PieceLetter[APiece] then
             begin
               Piece := APiece;
               Break;
             end;
           if Piece = pEmpty then Exit;
         end;
       2: { Location only (e4) }
         CalcLocation(UpCase(Move[0]), Move[1], Change.Dest);
     end;

     if Dest.X = 0 then Exit;
   end;
   ParseMove := ceOk;
end;

function RetractMove(CH: HChess; const Move: TMove): TChessError;
begin
  RetractMove := ceInvalidHandle;
  if not LoadGameHandle(CH) then Exit;

  with CC do
    TakeBackMove(MovTab[Depth]);

  RetractMove := ceOk;

  StoreGameHandle;
end;

function SubmitMove(CH: HChess; const Change: TChange): TChessError;
var
  Move: MoveType;
  Result: TChessError;
begin
  SubmitMove := ceInvalidHandle;
  if not LoadGameHandle(CH) then Exit;

  ChangeToMoveType(Change, Move);
  Result := MoveCheck(Move); { Move now in CC^.KeyMove }

  if Result = ceOK then
    Message(tmEnterMove);

  SubmitMove := Result;
  StoreGameHandle;
end;


function VerifyMove(CH: HChess; const Change: TChange): TChessError;
var
  Move: MoveType;
begin
  VerifyMove := ceInvalidHandle;
  if not LoadGameHandle(CH) then Exit;

  ChangeToMoveType(Change, Move);

  VerifyMove := MoveCheck(Move);
end;

function ComputerMove(CH: HChess; TimeLimit: LongInt): TChessError;
begin
  ComputerMove := ceInvalidHandle;
  if not LoadGameHandle(CH) then Exit;

  with CC do
  begin
    Clock.SetLimit(TimeLimit);
    Clock.Reset;
    Message(tmFindMove);
  end;

  ComputerMove := ceOk;
  StoreGameHandle;
end;

function ForceMove(CH: HChess): TChessError;
begin
  ForceMove := ceInvalidHandle;
  if not LoadGameHandle(CH) then Exit;

  CC.Clock.SetLimit(0);

  ForceMove := ceOk;

  StoreGameHandle;
end;

function ThinkAhead(CH: HChess): TChessError;
begin
  ThinkAhead := ceInvalidHandle;
  if not LoadGameHandle(CH) then Exit;

  Message(tmThinkAhead);

  ThinkAhead := ceOk;

  StoreGameHandle;
end;

function AbortSearch(CH: HChess): TChessError;
begin
  AbortSearch := ceInvalidHandle;
  if not LoadGameHandle(CH) then Exit;

  Message(tmAbort);

  AbortSearch := ceOk;

  StoreGameHandle;
end;

function CalcSearchStatus: TSearchStatus;
begin
  with CC do
  begin
    if GameOver in State then CalcSearchStatus := ssGameOver
    else if Analysis in State then CalcSearchStatus := ssMoveSearch
    else if OppAnalysis in State then CalcSearchStatus := ssThinkAhead
    else CalcSearchStatus := ssComplete;
  end;
end;

function Think(CH: HChess; TimeLimit: LongInt; var Status: TSearchStatus): TChessError;
begin
  Think := ceInvalidHandle;
  if not LoadGameHandle(CH) then Exit;

  with CC do
  begin
    { Give more time to the task }
    TaskTimer.SetLimit(TimeLimit);
    TaskTimer.Reset;
    TaskTimer.Start;

    Message(tmResume);

    Status := CalcSearchStatus;
  end;

  Think := ceOk;

  StoreGameHandle;
end;

function SetBoard(CH: HChess; const ABoard: TBoard): TChessError;
begin
  SetBoard := ceInvalidHandle;
  if not LoadGameHandle(CH) then Exit;

  { Not implemented yet }

  SetBoard := ceOk;

  StoreGameHandle;
end;

function SetPlayer(CH: HChess; APlayer: TColor): TChessError;
begin
  SetPlayer := ceInvalidHandle;
  if not LoadGameHandle(CH) then Exit;

  with CC do
  begin
    Player := ColorType(APlayer);
    Opponent := ColorType(Byte(APlayer) xor 1);
  end;

  SetPlayer := ceOk;

  StoreGameHandle;
end;

function MakeChange(CH: HChess; Color: TColor;
  const Change: TChange): TChessError;
begin
  MakeChange := ceInvalidHandle;
  if not LoadGameHandle(CH) then Exit;

  { Not implemented yet }

  MakeChange := ceOk;
end;

function GetChessStatus(CH: HChess; var Count: Integer): TChessStatus;
var
  Check,PossibleMove,CheckMate : boolean;
  NumMoves : integer;
begin
  GetChessStatus := csNormal;
  if not LoadGameHandle(CH) then Exit;

  with CC do
  begin
    CheckMate := False;
    Inc(Depth);               { Test if there is a Possible Move }
    PossibleMove := False;
    InitMovGen;
    repeat
       MovGen;
       if NextMove.MovPiece <> Empty then
          if not IllegalMove(NextMove) then
             PossibleMove := true;
    until (NextMove.MovPiece = Empty) or PossibleMove;
    Dec(Depth);
    Check := Attacks(Opponent, PieceTab[Player,0].ISquare); { Calculate Check }

    { No Possible Move means Checkmate or Stalemate }
    if not PossibleMove then
    begin
       if Check then
         GetChessStatus := csCheckMate
       else
         GetChessStatus := csStaleMate;
    end
    else if Check then
      GetChessStatus := csCheck
    else if FiftyMoveCnt >= 100 then
      GetChessStatus := csFiftyMoveRule
    else if Repetition(False) >= 3 then
      GetChessStatus := csRepetitionRule
    else if HintEvalu >= MateValue - DepthFactor * 16 then
    begin
      GetChessStatus := csMateFound;
      Count := (MateValue - HintEvalu + $40) div (DepthFactor * 2);
    end
    else if (-25500 < HintEvalu) and (HintEvalu <- $880) then
      GetChessStatus := csResigns;
  end;
end;

function GetSearchStatus(CH: HChess): TSearchStatus;
begin
  GetSearchStatus := ssComplete;
  if not LoadGameHandle(CH) then Exit;

  GetSearchStatus := CalcSearchStatus;
end;

function GetLastMove(CH: HChess; var Move: TMove): TChessError;
begin
  GetLastMove := ceInvalidHandle;
  if not LoadGameHandle(CH) then Exit;

  with CC do
    MoveTypeToTMove(MovTab[Depth], Move);

  GetLastMove := ceOk;
end;

function GetHintMove(CH: HChess; var Move: TMove): TChessError;
begin
  GetHintMove := ceInvalidHandle;
  if not LoadGameHandle(CH) then Exit;

  with CC do
    MoveTypeToTMove(HintLine[0], Move);

  GetHintMove := ceOk;
end;


function MoveToStr(const Move: TMove; var Str: array of Char): TChessError;
begin
  MoveToStr := ceOk;

  Str[0] := #0;
  if (High(Str) >= 6) and (Move.Change.Piece <> pEmpty) then
    with Move do
      case Kind of
        kCastling:
          begin
            if Change.Source.X > Change.Dest.X then
              StrCopy(PChar(@Str), 'O-O-O')
            else
              StrCopy(PChar(@Str), 'O-O');
          end;

        kNormal, kPawnPromote, kEnPassant:
          begin
            { Normal moves }
            Str[0] := PieceLetter[Change.Piece];
            Str[1] := Chr(ord('a') + Change.Source.X - 1);
            Str[2] := Chr(ord('1') + Change.Source.Y - 1);
            if Capture then
              Str[3] :='x'
            else
              Str[3] :='-';
            Str[4] := Chr(ord('a') + Change.Dest.X - 1);
            Str[5] := Chr(ord('1') + Change.Dest.Y - 1);

            Str[6] := #0;
          end;
      end
  else
    MoveToStr := ceOutOfMemory;
end;

function GetBoard(CH: HChess; var ABoard: TBoard): TChessError;
var
  I, J: Integer;
  Index: Word;
begin
  GetBoard := ceInvalidHandle;
  if not LoadGameHandle(CH) then Exit;

  with CC do
    for I := Low(ABoard) to High(ABoard) do
      for J := Low(ABoard[I]) to High(ABoard[I]) do
        with ABoard[J, I] do
        begin
          Index := (I - Low(ABoard)) shl 4 or (J - Low(ABoard[I]));
          Piece := TPiece(Board[Index].Piece);
          Color := TColor(Board[Index].Color);
        end;

  GetBoard := ceOk;
end;

function GetPlayer(CH: HChess): TColor;
begin
  GetPlayer := cWhite;
  if not LoadGameHandle(CH) then Exit;

  GetPlayer := TColor(CC.Player);
end;

function GetCurrentMove(CH: HChess; var Move: TMove): TChessError;
begin
  GetCurrentMove := ceInvalidHandle;
  if not LoadGameHandle(CH) then Exit;

  { Not implemented yet }

  GetCurrentMove := ceOk;
end;

function GetMainLine(CH: HChess; var Value: Integer;
  var Line: array of TMove): TChessError;
var
  I: Integer;
begin
  GetMainLine := ceInvalidHandle;
  if not LoadGameHandle(CH) then Exit;

  I := 0;
  with CC do
  begin
    while (I < High(Line)) and (MainLine[I].MovPiece <> Empty) do
    begin
      MoveTypeToTMove(MainLine[I], Line[I]);
      Inc(I);
    end;
    Value := MainEvalu;
  end;

  FillChar(Line[I], SizeOf(Line[I]), 0);

  GetMainLine := ceOk;
end;

function GetValidMoves(CH: HChess; Change: TChange;
  var Moves: array of TMove): TChessError;
var
  I, J, K: Integer;
  Move: MoveType;
begin
  GetValidMoves := ceInvalidHandle;
  if not LoadGameHandle(CH) then Exit;

  ChangeToMoveType(Change, Move);

  I := 0;
  with CC do
  begin
    Inc(Depth);

    KeyMove := ZeroMove;
    InitMovGen;
    repeat
       MovGen;
       if (NextMove.MovPiece <> Empty) and
          ((NextMove.MovPiece = Move.MovPiece) or (Move.MovPiece = Empty)) and
          ((NextMove.New1 = Move.New1) or (Move.New1 and $88 <> 0)) and
          ((NextMove.Old = Move.Old) or (Move.Old and $88 <> 0)) and
          not IllegalMove(NextMove) then
       begin
         MoveTypeToTMove(NextMove, Moves[I]);
         Inc(I);
       end;
    until (NextMove.MovPiece = Empty) or (I > High(Moves));

    if I > High(Moves) then
    begin
      Dec(I);
      GetValidMoves := ceOutOfMemory;
    end
    else
      GetValidMoves := ceOK;

    FillChar(Moves[I], SizeOf(Moves[I]), 0);

    Dec(Depth);
  end;
end;

function GetNodes(CH: HChess): LongInt;
begin
  if not LoadGameHandle(CH) then Exit;
  GetNodes := CC.Nodes;
end;

begin
  { Global initialization section }
  FillChar(GameList, SizeOf(GameList), 0);
  CCHandle := 0;

  { Init attack tables, shared by all game instances }
  CalcAttackTab;
  InitPawnStrTables;
end.

