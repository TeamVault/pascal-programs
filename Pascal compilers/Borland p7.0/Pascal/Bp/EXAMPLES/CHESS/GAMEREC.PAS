{************************************************}
{                                                }
{   Chess - Shared DLL Example                   }
{   CHESS.DLL Game record and internal types.    }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit GameRec;
{ contains all internal types and the big game context record }

interface

uses ChessInf, LTimer, TaskMgr;

type
  LevelType = (Normal, PlySearch, MateSearch);

const
  Back = -104;                   { Number of stored moves }
  MaxPly = 23;                   { Maximal search depth }
  MaxGames = 5;                  { Max number of simultaneous games }

type

  { Squarenumbers. a1=0, b1=1,..., a2=$10,..., h8=$77 }

  { The 64 squares }
  SquareType = $00..$77;
  EdgeSquareType = -$21..$98;

  ColorType = (White, Black);
  PieceType = (Empty, King, Queen, Rook, Bishop, Knight, Pawn);

  IndexType = 0..15;       { Index in PieceTab }

  BoardType = record
    Piece: PieceType;      { PieceType }
    Color: ColorType;      { Color }
    Index: 0..16;          { Index to PieceTab }
  end;

  { The MoveType, which is used to represent all moves in the program }
  MoveType = record
    New1, Old : SquareType; { New1 and Old Square }
    Spe:      Boolean;      { Indicates special Move:
                              case MovPiece of
                                King: Castling
                                Pawn: E.p. capture
                              else : Pawnpromotion }
    MovPiece,               { Moving Piece }
    Content :  PieceType;   { Evt. captured Piece }
  end;

const
  { The undefined Move. Testing is Done using MovPiece=Empty }
  ZeroMove : MoveType = (
    New1: 8;
    Old: 8;
    Spe: False;
    MovPiece: Empty;
    Content: Empty);

  Pieces : array[0..7] of PieceType =
    (Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook);

  PieceLetter : array[Empty..Pawn] of char = ' KQRBNP';

{ The played moves. MovTab[Back..Depth] contains all the moves played
  so far }
type
  DepthType = Back..MaxPly;
  MoveTabType = array[depthtype] of movetype;

  { Evaluation type }
  MaxType  = Integer;

  { Principal variation type }
  LineType = array[0..MaxPly] of MoveType;

  NodeVal = LongInt;

  StateTypes = (GameOver, InLibrary, Analysis, OppAnalysis, MovePending);

  StateSet = set of StateTypes;

  { GameOver    = A checkmate or stalemate has been detected.
    InLibrary   = Using the opening library to make moves.
    Analysis    = Currently searching for a move.
    OppAnalysis = Performing look-ahead search.
    MovePending = }

const
  { Magic number used for safety checking }
  gmGameMagic = $4246;

type
  PGameData = ^TGameData;
  TGameData = record

    { Magic number should always equal gmGameMagic.  Used for a safety
      check }
    Magic: Word;

    { Board contains the Content of each Square, Square by Square }
    Board: array[SquareType] of BoardType;

    { PieceTab contains the squares of all the Pieces,
      Piece by Piece.
      Board and PieceTab is two different representations of the
      same position, and they are always changed simultaniously.

      No. 0 is the King,
      No. 1 - OfficerNo is the officers and evt. Pawns,
      No. OfficerNo + 1 - PawnNo is the pawns }

    PieceTab: array[ColorType,IndexType] of record
      ISquare: SquareType;  { Square and Index to Board }
      IPiece:  PieceType;                   { PieceType }
    end;

    { Indexes to PieceTab, used to speed Up the program a Bit }
    OfficerNo, PawnNo: array[ColorType] of - 1..15;

    { Player is always Next to Move }
    Player,
    Opponent: ColorType;

    Depth: DepthType;
    MovTab: MoveTabType;

    { The Piece-Value-table }
    PVTable: array[ColorType, King..Pawn, SquareType] of -64..191;

    NextMove: MoveType;                     { The generated move }
    Buffer: array[1..80] of MoveType;       { Buffer of generated moves }
    BufCount,
    BufPnt: 0..80;                          { Counters for Buffer    }

    ProgramColor: ColorType;                { Color of program }
    MaxDepth: Integer;                      { Search Depth counter }
    LegalMoves: Integer;                    { Number of Legal moves }
    MoveNo: Integer;                        { Move Number }
    MainLine: LineType;                     { Principal variation }
    MainEvalu: MaxType;                     { Evaluation for principal
                                              variation }
    Nodes: NodeVal;                           { Number of analysed Nodes }
    Clock: TTaskTimer;                      { Time limit per complete turn }
    TaskTimer: TTaskTimer;                  { Time limit per Think period  }

    PlayerMove: MoveType;

    { The two chess clocks. Running indicates that the Clock for RunColor
      is Running }
    ChessTime: array[ColorType] of TStopWatch;
    RunColor: ColorType;
    Running: Boolean;
    KeyMove: MoveType;
    HintLine: LineType;                    { Suggested Hint Line }
    HintEvalu: MaxType;                    { Evaluation for HintLine }

    OpCount:  -1..61;                      { Opening library }
    LibNo: Integer;
    UseLib: Integer;                       { program uses library
                                             if MoveNo < UseLib }

    Level: LevelType;                      { LevelType }
    MaxLevel: Byte;                        { Maximum Search Depth }
    AverageTime: Longint;

    State: StateSet;                       { State transitions }

    Engaged: Boolean;                      { Game task managment variables }
    AppStack,
    GameStack: TTaskInfo;
   end;

var
  GameList: array [1..MaxGames] of TGameData;

  { Index of current game context in the GameList }
  CCHandle: HChess;

  { Current game context, set by exported DLL functions before performing
    any game-related operations.  All game operations are done relative to
    this game context }
  CC: TGameData;

implementation

end.