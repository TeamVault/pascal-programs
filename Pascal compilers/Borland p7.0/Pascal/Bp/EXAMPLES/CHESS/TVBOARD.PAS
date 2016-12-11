{************************************************}
{                                                }
{   Turbo Vision Chess Demo                      }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit TVBoard;

interface

{$IFDEF DPMI}
uses Views, Objects, Dialogs, Validate, TVChsCmd, ChessDLL, MoveList,
  Drivers, StdDlg, Dos, CTimers;
{$ELSE}
uses Views, Objects, Dialogs, Validate, TVChsCmd, ChessInf, MoveList,
  Drivers, StdDlg, Dos, CTimers;
{$ENDIF}

const
  ChessSignature : array [0..33] of Char = 'Borland Pascal Chess saved game'#26#0;

type
  { TChessSurface }

  PChessSurface = ^TChessSurface;
  TChessSurface = object(TView)
    ValidMoves: array[1..8, 1..8] of Boolean;
    Squares: array[1..8, 1..8] of PView;
    procedure Clear;
    procedure Draw; virtual;
  end;

  { TValidateMove }

  PValidateMove = ^TValidateMove;
  TValidateMove = object(TValidator)
    function IsValid(const S: String): Boolean; virtual;
    procedure Error; virtual;
    function Transfer(var S: String; Buffer: Pointer; Flag: TVTransfer):
      Word; virtual;
  end;

  { Palette layout }
  { 1 = Border }
  { 2 = White square }
  { 3 = Black sqaure }
  { 4 = Black piece }
  { 5 = White piece }
  { 6 = Black in jeopardy }
  { 7 = White in jeopardy }
  { 8 = White hint }
  { 9 = Black hint }

  PChessBoard = ^TChessBoard;
  TChessBoard = object(TGroup)
    Surface: PChessSurface;
    Game: HChess;
    Computer, Player: TColor;
    GameMode: Word;
    GameOver: Boolean;
    MoveHistory: PMoveList;
    GameName: PathStr;
    ThinkState: TSearchStatus;
    ChessTimers: array[TColor] of PChessTimer;
    ValidMoves,
    OpponentMoves: array [0..(28*16+1)] of TMove;
    QSquare: TLocation;
    constructor Init(var Bounds: TRect);
    destructor Done; virtual;
    procedure AddToHistory(const AMove: TMove);
    procedure AcceptComputerMove;
    function CanMovePiece(Color: TColor): Boolean;
    function CheckActiveGame: Word;
    procedure ClearBoard;
    procedure DoThink;
    procedure DrawSurface;
    procedure DrawValidMoves(Empty: Boolean);
    function GetComputerTime: Longint;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitGameBoard;
    procedure InsertPiece(Piece: PView; Location: TLocation);
    procedure MovePiece(Piece: PView; FromLoc, ToLoc: TLocation);
    procedure Process;
    procedure ReadGame;
    procedure Redo;
    procedure RemovePiece(Piece: PView; Location: TLocation);
    procedure ResetCurrentPlayer;
    procedure ResetValidMoves;
    function SaveGame: Word;
    function SaveGameAs: Word;
    procedure SetGameBoard(const ABoard: TBoard);
    procedure SetupNewGameBoard;
    procedure ShowEndGame(Reason: Integer);
    procedure StartComputerMove;
    procedure Undo;
    function ValidateMove(var C: TChange): TChessError;
    function Valid(Command: Word): Boolean; virtual;
    procedure Update;
    procedure UpdateCommands;
  end;

const
  ChessBoard: PChessBoard = nil;

function Opponent(Color: TColor): TColor;

implementation

uses TVPieces, TVChsUtl, TVStatus, App, MsgBox, Strings, TVChstat;

function Opponent(Color: TColor): TColor;
begin
  if Color = cWhite then
    Opponent := cBlack
  else Opponent := cWhite;
end;

{ TValidateMove }

function TValidateMove.IsValid(const S: String): Boolean;
var
  Change: TChange;
  MoveStr: array[0..20] of Char;
begin
  StrPCopy(MoveStr, S);
  IsValid := ParseMove(MoveStr, Change) = ceOK;
end;

procedure TValidateMove.Error;
begin
  MessageBox(^C'Invalid move syntax', nil, mfError + mfOKButton +
    mfInsertInApp);
end;

function TValidateMove.Transfer(var S: String; Buffer: Pointer;
  Flag: TVTransfer): Word;
var
  Change: TChange;
  MoveStr: array[0..20] of Char;
begin
  case Flag of
    vtGetData:
    begin
      FillChar(Change, SizeOf(Change), 0);
      StrPCopy(MoveStr, S);
      if ParseMove(MoveStr, Change) = ceOK then
        PChange(Buffer)^ := Change
      else FillChar(Buffer^, SizeOf(TChange), 0);
    end;
  end;
  Transfer := SizeOf(TChange);
end;

{ TChessSurface }

procedure TChessSurface.Clear;
begin
  FillChar(Squares, SizeOf(Squares), 0);
end;

procedure TChessSurface.Draw;
var
  Border, White, Black, Color: Word;
  B: TDrawBuffer;
  I, J, K, Line: Integer;
  DrawChr: Char;
  XOfs, XLen: Integer;

  procedure TellPieceToDraw(P: PView);
  begin
    if (P <> nil) and (P^.State and sfDragging = 0) then
      PChessPiece(P)^.RawDraw(B, 2 + 6 * K, I, XOfs, XLen);
  end;

begin
  Border := GetColor($0101);
  White := GetColor($0802);
  Black := GetColor($0903);
  Line := 0;
  for J := 7 downto 0 do
  begin
    if J = 7 then
    begin
      MoveChar(B, ' ', Border, 2);
      for I := 0 to 7 do
      begin
        MoveChar(B[2 + 6 * I], ' ', Border, 3);
        MoveChar(B[5 + 6 * I], Chr($41 + I), Border, 1);
        MoveChar(B[6 + 6 * I], ' ', Border, 2);
      end;
      MoveChar(B[Size.X - 2], ' ', Border, 2);
      WriteBuf(0, Line, Size.X, 1, B);
      Inc(Line);
    end;
    for I := 0 to 2 do
    begin
      MoveChar(B, ' ', Border, 2);
      if I = 1 then
        MoveChar(B, Chr($31 + J), Border, 1);
      for K := 0 to 7 do
      begin
        if (K + J) and 1 = 0 then
        begin
          DrawChr := '°';
          Color := Black
        end
        else
        begin
          DrawChr := '²';
          Color := White;
        end;
        if ValidMoves[K + 1, J + 1] then
        begin
          DrawChr := ' ';
          Color := Swap(Color);
        end;
        MoveChar(B[2 + 6 * K], DrawChr, Color, 6);
        TellPieceToDraw(Squares[K + 1, J + 1])
      end;
      MoveChar(B[Size.X - 2], ' ', Border, 2);
      WriteBuf(0, Line, Size.X, 1, B);
      Inc(Line);
    end;
  end;
end;

constructor TChessBoard.Init(var Bounds: TRect);
var
  Color: TColor;
begin
  inherited Init(Bounds);
  EventMask := EventMask or evMove;
  Options := Options or ofPostprocess;
  Surface := New(PChessSurface, Init(Bounds));
  Insert(Surface);
  Computer := cBlack;
  Player := cWhite;
  GameMode := Settings.Players;
  for Color := cWhite to cBlack do
    ChessTimers[Color] := New(PChessTimer, Init);
  MoveHistory := New(PMoveList, Init(20, 10));
  if NewGame(Game) <> ceOK then
    Game := 0
  else SetupNewGameBoard;
  if (StatusDialog <> nil) and (Game <> 0) then
    StatusDialog^.Update(Game, ChessTimers, 0, 0, GameMode);
end;

destructor TChessBoard.Done;
begin
  if Game <> 0 then DisposeGame(Game);
  inherited Done;
end;

procedure TChessBoard.AcceptComputerMove;
var
  Move: TMove;
begin
  if GetLastMove(Game, Move) = ceOK then
  begin
    AddToHistory(Move);
    Message(@Self, evMove, cmMovePiece, @Move);
    Wait(5);
    Message(@Self, evMove, cmUndoMove, @Move);
    Wait(5);
    Message(@Self, evMove, cmMovePiece, @Move);
    if (GameMode and gmDemo <> 0) and not GameOver then
      StartComputerMove
    else
    begin
      if Settings.Hints and hoThinkAhead <> 0 then
        ThinkAhead(Game);
      ChessTimers[GetPlayer(Game)]^.Mark;
      ChessTimers[GetPlayer(Game)]^.Start;
      ThinkState := GetSearchStatus(Game);
    end;
    ResetValidMoves;
    Update;
  end;
end;

procedure TChessBoard.AddToHistory(const AMove: TMove);
var
  ChessPiece: PChessPiece;
begin
  if MoveHistory <> nil then MoveHistory^.AddMove(AMove);
  if StatusDialog <> nil then StatusDialog^.UpdateList(MoveHistory);
end;

function TChessBoard.CanMovePiece(Color: TColor): Boolean;
begin
  CanMovePiece := False;
  if (Game <> 0) and (GetSearchStatus(Game) in [ssComplete, ssThinkAhead]) and
    (Color = GetPlayer(Game)) then CanMovePiece := True;
end;

function TChessBoard.CheckActiveGame: Word;
var
  Result: Word;
begin
  if (MoveHistory <> nil) and (MoveHistory^.Count <> 0) then
  begin
    Result := MessageBox('Save currently active game?', nil,
      mfError + mfYesNoCancel + mfInsertInApp);
    if Result = cmYes then
      Result := SaveGame;
  end else Result := cmOK;
  CheckActiveGame := Result;
end;

procedure TChessBoard.ClearBoard;
var
  KillCollection: TCollection;
begin
  Surface^.Clear;
  KillCollection.Init(32, 0);
  Message(@Self, evBroadcast, cmRegisterSave, @KillCollection);
  KillCollection.Done;
end;

procedure TChessBoard.DoThink;
begin
  if (Game <> 0) and not GameOver and
    not (ThinkState in [ssComplete, ssGameOver]) then
    Process;
  if not GameOver then Update;
end;

procedure TChessBoard.DrawSurface;
begin
  Surface^.DrawView;
end;

procedure TChessBoard.DrawValidMoves(Empty: Boolean);

  procedure TestAndInvert(Test, Show: TLocation);
  var
    R: TRect;
  begin
    if Word(Test) = Word(QSquare) then
      Surface^.ValidMoves[Show.X, Show.Y] := True;
  end;

var
  X : Integer;
begin
  FillChar(Surface^.ValidMoves, SizeOf(Surface^.ValidMoves), 0);
  if not Empty then
    { Show where this piece can move to }
  begin
    X := 0;
    while (X <= High(ValidMoves)) and
          (ValidMoves[X].Change.Piece <> pEmpty) do
    begin
      with ValidMoves[X].Change do
        TestAndInvert(Source, Dest);
      Inc(X);
    end;
    X := 0;
    while (X <= High(ValidMoves)) and
          (OpponentMoves[X].Change.Piece <> pEmpty) do
    begin
      with OpponentMoves[X].Change do
        TestAndInvert(Source, Dest);
      Inc(X);
    end;
  end
  else
    { Show what pieces can move to this square }
  begin
    X := 0;
    while (X <= High(ValidMoves)) and
          (ValidMoves[X].Change.Piece <> pEmpty) do
    begin
      with ValidMoves[X].Change do
        TestAndInvert(Dest, Source);
      Inc(X);
    end;
    X := 0;
    while (X <= High(OpponentMoves)) and
          (OpponentMoves[X].Change.Piece <> pEmpty) do
    begin
      with OpponentMoves[X].Change do
        TestAndInvert(Dest, Source);
      Inc(X);
    end;
  end;
end;

function TChessBoard.GetComputerTime: Longint;
var
  MarkTime: Longint;
begin
  case Settings.TimeMode of
    tmGameLimit:
      begin
        MarkTime := (Settings.GameTime * 1092 -
          ChessTimers[Computer]^.GetCurrentTicks) div 44;
        if MoveHistory^.UndoPos shr 1 <= 40 then
          MarkTime := 91 + (MarkTime - 91) *
            ((80 - MoveHistory^.UndoPos shr 1) div 40);
        GetComputerTime := MarkTime;
      end;
    tmTurnLimit: GetComputerTime := Settings.TurnTime * 18;
    tmMatchUser:
      begin
        MarkTime := ChessTimers[Opponent(GetPlayer(Game))]^.GetMarkTime;
        if MarkTime > 0 then
          GetComputerTime := MarkTime
        else GetComputerTime := 5 * 18;
      end;
    tmInfinite:  GetComputerTime := High(Longint);
  end;
end;

function TChessBoard.GetPalette: PPalette;
const
  P: string[Length(CChessBoard)] = CChessBoard;
begin
  GetPalette := @P;
end;

procedure TChessBoard.HandleEvent(var Event: TEvent);
var
  Move: TMove;
  LastSquare: TLocation;

{ The chess board holds the board surface and all pieces on that surface.
  Pieces are "hidden" until asked to drag themselves.  Since the views are
  hidden they don't recieve mouse events.  The following procedures will
  insure that the pieces get mouse events so they can drag themselves. }

  procedure HandEventToPiece(P: PView);
  begin
    if Event.What and P^.EventMask <> 0 then P^.HandleEvent(Event);
  end;

  function ContainsMouse(P: PView): Boolean; far;
  begin
    ContainsMouse := P^.MouseInView(Event.Where);
  end;

  procedure EnterMove;
  var
    Dlg: PDialog;
    R: TRect;
    Control: PView;
    Change: TChange;
    P: PChessPiece;
    Result: TChessError;
  Begin
    R.Assign(0,0,39,7);
    New(Dlg, Init(R, 'Enter Move'));

    with Dlg^ do
    begin
      Options := Options or ofCentered;

      R.Assign(14, 2, 36, 3);
      Control := New(PInputLine, Init(R, 20));
      PInputLine(Control)^.SetValidator(New(PValidateMove, Init));
      PInputLine(Control)^.Validator^.Options := voTransfer;
      Insert(Control);
      R.Assign(2, 2, 14, 3);
      Insert(New(PLabel, Init(R, '~E~nter move ', Control)));

      R.Assign(8, 4, 18, 6);
      Insert(New(PButton, Init(R, 'O~K~', cmOK, bfDefault)));

      Inc(R.A.X, 14); Inc(R.B.X, 14);
      Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

      SelectNext(False);
    end;

    if Application^.ExecView(Dlg) <> cmCancel then
    begin
      Dlg^.GetData(Change);
      Result := ValidateMove(Change);
      if Result in [ceOK, ceAmbiguousMove] then
      begin
        P := Message(@Self, evMove, cmFindPiece, Ptr(0, Word(Change.Source)));
        if P = nil then
          MessageBox(^C'Piece not located there.', nil, mfError + mfOKButton +
            mfInsertInApp)
        else
        begin
          if Result = ceAmbiguousMove then
            Change.Piece := P^.GetPromotionPiece;
          Message(@Self, evMove, cmSubmitMove, @Change);
        end;
      end
      else MessageBox(^C'Invalid move.', nil,
        mfError + mfOKButton + mfInsertInApp);
    end;

    Dispose(Dlg, Done);
  end;

  procedure ShowHint;
  var
    Move: TMove;
  begin
    GetHintMove(Game, Move);
    if VerifyMove(Game, Move.Change) = ceOK then
    begin
      Message(@Self, evMove, cmMovePiece, @Move);
      Wait(5);
      Message(@Self, evMove, cmUndoMove, @Move);
      Wait(5);
      Message(@Self, evMove, cmMovePiece, @Move);
      Wait(5);
      Message(@Self, evMove, cmUndoMove, @Move);
      Wait(5);
    end
    else MessageBox(^C'No hint available', nil, mfInformation + mfOKButton +
      mfInsertInApp);
  end;

begin
  case Event.What of
    evMove:
      case Event.Command of
        cmSubmitMove:
          begin
            ChessTimers[GetPlayer(Game)]^.Stop;
            if SubmitMove(Game, TChange(Event.InfoPtr^)) = ceOK then
            begin
              if GetLastMove(Game, Move) = ceOK then
              begin
                AddToHistory(Move);
                Message(@Self, evMove, cmMovePiece, @Move);
                ResetValidMoves;
              end;
              if GameMode and gmTwoPlay <> gmTwoPlay then
                StartComputerMove
              else
              begin
                ResetCurrentPlayer;
                ChessTimers[Player]^.Mark;
                ChessTimers[Player]^.Start;
              end;
              Exit;
            end;
          end;
      end;
    evMouseDown:
      begin

        { The board handles all right mouse actions }

        if Event.Buttons = mbRightButton then
        begin
          if Settings.Hints and hoRtClickHints <> 0 then
          begin
            LastSquare := QSquare;
            repeat
              PointInSquare(Event.Where, QSquare);
              if Word(QSquare) <> Word(LastSquare) then
              begin
                DrawValidMoves(Message(@Self, evMove, cmFindPiece, Ptr(0, Word(QSquare))) = nil);
                Surface^.DrawView;
                LastSquare := QSquare;
              end;
            until not MouseEvent(Event, evMouseMove + evMouseAuto);
            Word(Qsquare) := 0;
            DrawValidMoves(False);
            Surface^.DrawView;
          end;
          ClearEvent(Event);
          Exit;
        end;

        { All other mouse actions go to the appropriate piece }

        HandEventToPiece(FirstThat(@ContainsMouse));
      end;
  end;
  inherited HandleEvent(Event);
  case Event.What of
    evCommand:
      begin
        case Event.Command of
          cmNew:
            begin
              if GameOver or (CheckActiveGame <> cmCancel) then
              begin
                DisposeGame(Game);
                if NewGame(Game) <> ceOK then
                  Game := 0;
                SetupNewGameBoard;
                if Game <> 0 then StatusDialog^.Update(Game, ChessTimers,
                  0, 0, GameMode);
              end;
            end;
          cmComputerMove:
            if ThinkState in [ssComplete, ssThinkAhead] then
              StartComputerMove;
          cmRunDemo:
            if GameMode and gmDemo = 0 then
            begin
              GameMode := GameMode or gmDemo;
              if ThinkState in [ssComplete, ssThinkAhead] then
                StartComputerMove;
            end;
          cmStop:
            if (Game <> 0) and (ThinkState = ssMoveSearch) then
            begin
              ForceMove(Game);
              Computer := GetPlayer(Game);
              Player := Opponent(Computer);
              GameMode := GameMode and not gmDemo;
            end;
          cmUndo: Undo;
          cmRedo: Redo;
          cmGameOver: ShowEndGame(Event.InfoInt);
          cmSave: SaveGame;
          cmSaveAs: SaveGameAs;
          cmOpen: ReadGame;
          cmEnterMove: EnterMove;
          cmShowHint: ShowHint;
        else
          Exit
        end;
        ClearEvent(Event);
      end;
    evKeyDown:
      if ThinkState in [ssComplete, ssThinkAhead] then
      begin
        PutEvent(Event);
        EnterMove;
        ClearEvent(Event);
      end;
  end;
end;

procedure TChessBoard.InitGameBoard;
var
  I, J: Integer;
  P: PChessPiece;
  R: TRect;
  Board: TBoard;
  Location: TLocation;
  ChessStatus: TChessStatus;
begin
  if Game <> 0 then
  begin
    if GetBoard(Game, Board) = ceOK then
      for J := 1 to 8 do
        for I := 1 to 8 do
          if Board[I, J].Piece <> pEmpty then
          begin
            Location.X := I; Location.Y := J;
            SquareToLocal(Location, R.A, Size.Y);
            R.Assign(R.A.X, R.A.Y, R.A.X + 6, R.A.Y + 3);
            P := New(PChessPiece, Init(R, Board[I, J], Location));
            P^.Hide;
            InsertPiece(P, P^.Location);
          end;
    Player := cWhite;
    Computer := cBlack;
    GameMode := GameMode and not gmDemo;
    GameOver := False;
    ThinkState := GetSearchStatus(Game);
    Update;
  end;
end;

procedure TChessBoard.InsertPiece(Piece: PView; Location: TLocation);
begin
  Insert(Piece);
  Surface^.Squares[Location.X, Location.Y] := Piece;
end;

procedure TChessBoard.MovePiece(Piece: PView; FromLoc, ToLoc: TLocation);
begin
  Surface^.Squares[FromLoc.X, FromLoc.Y] := nil;
  Surface^.Squares[ToLoc.X, ToLoc.Y] := Piece;
  DrawSurface;
end;

procedure TChessBoard.Process;
var
  OldState: TSearchStatus;
  ChessStatus: TChessStatus;
  Move: TMove;
  Event: TEvent;
  ComputerPlayer: TColor;
  I: Integer;
begin
  OldState := ThinkState;
  if (GetPlayer(Game) = Computer) or (GameMode and gmDemo <> 0) then
  begin
    ComputerPlayer := GetPlayer(Game);
    ChessTimers[ComputerPlayer]^.Start;
    Think(Game, 4, ThinkState);
    ChessTimers[ComputerPlayer]^.Stop;
  end else Think(Game, 2, ThinkState);
  if (OldState = ssMoveSearch) and (ThinkState = ssComplete) then
    AcceptComputerMove;
end;

procedure TChessBoard.ReadGame;
var
  S: PBufStream;
  Test: array [0..SizeOf(ChessSignature)] of Char;
  NewMoveList : PMoveList;
  FileDialog: PFileDialog;
  AGameName: PathStr;
  X: Integer;

  function ReplayMoves(P: PMove): Boolean; far;
  begin
    SubmitMove(Game, P^.Change);
    ReplayMoves := (X >= MoveHistory^.UndoPos);
    Inc(X);
  end;

begin
  if CheckActiveGame <> cmCancel then
  begin
    FileDialog := New(PFileDialog, Init('*.CHS', 'Open a Game', '~G~ame',
      fdOpenButton, 100));
    if Application^.ExecView(FileDialog) <> cmCancel then
    begin
      FileDialog^.GetFileName(AGameName);
      S := New(PBufStream, Init(AGameName, stOpenRead, 1024));
      S^.Read(Test, SizeOf(ChessSignature));
      if S^.Status <> stOK then
        {!!} MessageBox('Error reading file', nil, mfError + mfOKButton + mfInsertInApp)
      else
      if StrLComp(ChessSignature, Test, SizeOf(ChessSignature)) <> 0 then
        {!!} MessageBox('This is not a chess game file', nil, mfError + mfOKButton + mfInsertInApp)
      else
      begin
        NewMoveList := PMoveList(S^.Get);
        if S^.Status <> stOK then
          {!!} MessageBox('Error reading file', nil, mfError + mfOKButton + mfInsertInApp)
        else
        begin
          ClearBoard;
          DisposeGame(Game);
          if NewGame(Game) <> ceOK then
            Game := 0
          else
          begin
            Dispose(MoveHistory, Done);
            MoveHistory := NewMoveList;
            X := 0;
            MoveHistory^.FirstThat(@ReplayMoves);
            if StatusDialog <> nil then
              StatusDialog^.UpdateList(MoveHistory);
            InitGameBoard;
            ResetValidMoves;
            Update;
          end;
        end;
      end;
      Dispose(S, Done);
    end;
  end;
end;

procedure TChessBoard.Redo;
var
  Move: TMove;
begin
  AbortSearch(Game);
  ChessTimers[Player]^.Stop;
  MoveHistory^.Redo(Move);
  if SubmitMove(Game, Move.Change) = ceOK then
    if GetLastMove(Game, Move) = ceOK then
      Message(@Self, evMove, cmMovePiece, @Move);
  if (GameMode = gmOnePlay) and (MoveHistory^.RedoAvail) and
    (Player <> GetPlayer(Game)) then
  begin
    MoveHistory^.Redo(Move);
    if SubmitMove(Game, Move.Change) = ceOK then
      if GetLastMove(Game, Move) = ceOK then
        Message(@Self, evMove, cmMovePiece, @Move);
  end
  else ResetCurrentPlayer;
  ResetValidMoves;
  ChessTimers[Player]^.Mark;
  ChessTimers[Player]^.Start;
  if StatusDialog <> nil then StatusDialog^.UpdateList(MoveHistory);
  Update;
end;

procedure TChessBoard.RemovePiece(Piece: PView; Location: TLocation);
begin
  if Surface^.Squares[Location.X, Location.Y] = Piece then
    Surface^.Squares[Location.X, Location.Y] := nil;
end;

procedure TChessBoard.ResetCurrentPlayer;
begin
  Player := GetPlayer(Game);
  Computer := Opponent(Player);
end;

procedure TChessBoard.ResetValidMoves;
var
  Chg: TChange;
  PlayerColor: TColor;
  EmptyMove: TMove;

  procedure DoAttacks(P: PView); far;
  begin
    if TypeOf(P^) = TypeOf(TChessPiece) then
      if PChessPiece(P)^.PieceType.Color <> PlayerColor then
        if Settings.Hints and hoAttacks <> 0 then
          PChessPiece(P)^.CheckJeopardy(ValidMoves)
        else PChessPiece(P)^.CheckJeopardy(EmptyMove);
  end;

  procedure DoJeopardies(P : PView); far;
  begin
    if TypeOf(P^) = TypeOf(TChessPiece) then
      if (PChessPiece(P)^.PieceType.Color = PlayerColor) then
        PChessPiece(P)^.CheckJeopardy(OpponentMoves)
      else PChessPiece(P)^.CheckJeopardy(EmptyMove);
  end;

begin
  Chg.Piece := pEmpty;
  Word(Chg.Source) := 0;
  Word(Chg.Dest) := 0;
  FillChar(EmptyMove, SizeOf(EmptyMove), 0);
  PlayerColor := GetPlayer(Game);
  if Settings.Hints and hoJeopardies <> 0 then
  begin
    { Switch players to see which opponent pieces attack ours }
    SetPlayer(Game, Opponent(PlayerColor));
    GetValidMoves(Game, Chg, OpponentMoves);
    SetPlayer(Game, PlayerColor);
    if Settings.Hints and hoJeopardies <> 0 then
      ForEach(@DoJeopardies);
  end
  else
  begin
    OpponentMoves[0] := EmptyMove;    { Clear the jeopardy lists }
    ForEach(@DoJeopardies);
  end;
  GetValidMoves(Game, Chg, ValidMoves);
  ForEach(@DoAttacks);
  DrawSurface;
end;

function TChessBoard.SaveGame: Word;
var
  S: PBufStream;
begin
  SaveGame := cmCancel;
  if GameName = '' then
  begin
    SaveGame := SaveGameAs;
    Exit;
  end
  else if Game <> 0 then
  begin
    S := New(PBufStream, Init(GameName, stCreate, 1024));
    S^.Write(ChessSignature, SizeOf(ChessSignature));
    S^.Put(MoveHistory);
    if S^.Status <> stOK then
      {!!} MessageBox('Error writing file', nil, mfError + mfOKButton + mfInsertInApp);
    Dispose(S, Done);
    SaveGame := cmOK;
  end;
end;

function TChessBoard.SaveGameAs: Word;
var
  FileDialog: PFileDialog;
begin
  SaveGameAs := cmCancel;
  FileDialog := New(PFileDialog, Init('*.CHS', 'Save Game As',
    '~S~ave game as', fdOKButton, 101));
  if Application^.ExecView(FileDialog) <> cmCancel then
  begin
    FileDialog^.GetFileName(GameName);
    SaveGameAs := SaveGame;
  end;
  Dispose(FileDialog, Done);
end;

procedure TChessBoard.SetGameBoard(const ABoard: TBoard);
begin
  if Game <> 0 then
    if SetBoard(Game, ABoard) <> ceOK then
      MessageBox('Error setting game board', nil,
        mfError + mfOKButton + mfInsertInApp);
end;

procedure TChessBoard.SetupNewGameBoard;
var
  Color: TColor;
begin
  ClearBoard;
  if MoveHistory <> nil then MoveHistory^.Purge;
  GameName := '';
  for Color := cWhite to cBlack do
    if ChessTimers[Color] <> nil then
      ChessTimers[Color]^.Clear;
  InitGameBoard;
  ResetValidMoves;
end;

procedure TChessBoard.ShowEndGame(Reason: Integer);
type
  TWinRec = record
    Winner, Loser: PString;
  end;
var
  ReasonStr: String;
  Winner: TColor;
  WinRec: TWinRec;
  BStr, WStr: String[5];
begin
  Winner := Opponent(GetPlayer(Game));
  BStr := 'Black';
  WStr := 'White';
  if Winner = cBlack then
  begin
    WinRec.Winner := @BStr;
    WinREc.Loser := @WStr;
  end
  else
  begin
    WinRec.Winner := @WStr;
    WinREc.Loser := @BStr;
  end;
  case TChessStatus(Reason) of
    csCheckMate: ReasonStr := ^C'Checkmate!'#13^C'%s wins!';
    csStaleMate: ReasonStr := ^C'Stalemate!';
    csResigns:   ReasonStr := ^C'%s Resigns!'#13^C'%s wins!';
    csFiftyMoveRule:
      ReasonStr := ^C'Stalemate!'#13^C'Fifty move rule.';
    csRepetitionRule:
      ReasonStr := ^C'Stalemate!'#13^C'Repitition rule.';
  end;
  MessageBox(ReasonStr, @WinRec, mfInformation + mfOKButton + mfInsertInApp);
end;

procedure TChessBoard.StartComputerMove;
var
  ComputerTime: Longint;
begin
  AbortSearch(Game);
  Computer := GetPlayer(Game);
  Player := Opponent(Computer);
  ComputerTime := GetComputerTime;
  ChessTimers[GetPlayer(Game)]^.Mark;
  ComputerMove(Game, ComputerTime);
  ThinkState := GetSearchStatus(Game);
  if StatusDialog <> nil then
    StatusDialog^.LastNodes := 0;
end;

procedure TChessBoard.Undo;
var
  Move: TMove;
  R: TRect;
  P: PChessPiece;
begin
  AbortSearch(Game);
  GameOver := False;
  ChessTimers[Player]^.Stop;
  MoveHistory^.Undo(Move);
  if RetractMove(Game, Move) = ceOK then
    Message(@Self, evMove, cmUndoMove, @Move);
  if (GameMode = gmOnePlay) and (MoveHistory^.UndoAvail) and
    (Player <> GetPlayer(Game)) then
  begin
    MoveHistory^.Undo(Move);
    if RetractMove(Game, Move) = ceOK then
      Message(@Self, evMove, cmUndoMove, @Move);
  end
  else ResetCurrentPlayer;
  ResetValidMoves;
  ChessTimers[Player]^.Mark;
  ChessTimers[Player]^.Start;
  if StatusDialog <> nil then StatusDialog^.UpdateList(MoveHistory);
  Update;
end;

procedure TChessBoard.Update;
var
  ChessStatus: TChessStatus;
  MateInMoves: Integer;
  Event: TEvent;
begin
  UpdateCommands;
  ChessStatus := GetChessStatus(Game, MateInMoves);
  if StatusLine <> nil then
    PChessStatusLine(StatusLine)^.SetStatus(ChessStatus, MateInMoves);
  if not (ChessStatus in [csNormal, csCheck, csMateFound]) then
  begin
    ChessTimers[cWhite]^.Stop;
    ChessTimers[cBlack]^.Stop;
    GameOver := True;
    AbortSearch(Game);
    GameMode := GameMode and not gmDemo;
    ThinkState := GetSearchStatus(Game);
    UpdateCommands;
    Event.What := evCommand;
    Event.Command := cmGameOver;
    Event.InfoInt := Integer(ChessStatus);
    PutEvent(Event);
  end;
end;

procedure TChessBoard.UpdateCommands;
begin
  if MoveHistory <> nil then
  begin
    if StatusDialog <> nil then
      StatusDialog^.Update(Game, ChessTimers, GetNodes(Game),
        MoveHistory^.GetNumMoves, GameMode);
    SetCmdState([cmRedo], (MoveHistory^.RedoAvail) and
      (ThinkState <> ssMoveSearch));
    SetCmdState([cmUndo], (MoveHistory^.UndoAvail) and
      (ThinkState <> ssMoveSearch));
    SetCmdState([cmComputerMove, cmEnterMove, cmShowHint],
      (ThinkState <> ssMoveSearch) and not GameOver);
    SetCmdState([cmStop], (GameMode and gmDemo <> 0) or
      (ThinkState = ssMoveSearch));
    SetCmdState([cmRunDemo], (GameMode and gmDemo = 0) and not GameOver);
  end;
end;

function TChessBoard.ValidateMove(var C: TChange): TChessError;
var
  X: Integer;
  ValidMove: TMove;
  CurMove: TMove;
begin
  ValidateMove := ceInvalidMove;
  if (ThinkState in [ssComplete, ssThinkAhead]) then
  begin
    X := 0;
    FillChar(CurMove, SizeOf(CurMove), 0);
    while (X <= High(ValidMoves)) and
      (ValidMoves[X].Change.Piece <> pEmpty) do
    begin
      ValidMove := ValidMoves[X];
      with ValidMove do
        if ((Change.Piece = C.Piece) or (C.Piece = pEmpty)) and
          ((Word(Change.Dest) = Word(C.Dest)) or (Word(C.Dest) = 0)) and
          ((Word(Change.Source) = Word(C.Source)) or (Word(C.Source) = 0)) then
        begin
          if CurMove.Change.Piece = pEmpty then
            CurMove := ValidMove
          else
          begin
            if (ValidMove.Change.Piece = pPawn) and
              (CurMove.Change.Piece <> pPawn) then
              CurMove := ValidMove
            else if (ValidMove.Change.Piece <> pPawn) and
              (CurMove.Change.Piece = pPawn) then
            else
            begin
              C := CurMove.Change;
              ValidateMove := ceAmbiguousMove;
              Exit;
            end;
          end;
        end;
      Inc(X);
    end;
    if CurMove.Change.Piece <> pEmpty then
    begin
      C := CurMove.Change;
      ValidateMove := ceOK;
    end;
  end;
end;

function TChessBoard.Valid(Command: Word): Boolean;
begin
  Valid := True;
  if Command = cmQuit then
    Valid := CheckActiveGame <> cmCancel;
end;

end.
