{************************************************}
{                                                }
{   Turbo Vision Chess Demo                      }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit TVStatus;

interface

{$IFDEF DPMI}
uses Objects, Views, Dialogs, ChessDLL, CTimers, MoveList;
{$ELSE}
uses Objects, Views, Dialogs, ChessInf, CTimers, MoveList;
{$ENDIF}

type
  TTimerColor = (tcWhite, tcBlack, tcTotal);

{ TTimerView }

  PTimerView = ^TTimerView;
  TTimerView = object(TParamText)
    Color: TTimerColor;
    constructor Init(var Bounds: TRect; AText: String; AParamCount:
      Integer; AColor: TTimerColor);
    constructor Load(var S: TStream);
    function GetPalette: PPalette; virtual;
    procedure Store(var S: TStream);
  end;

{ TTurnText }

  PTurnText = ^TTurnText;
  TTurnText = object(TTimerView)
    function DataSize: Word; virtual;
    procedure SetData(var Rec); virtual;
  end;

{ TBestLine }

  PBestLine = ^TBestLine;
  TBestLine = object(TParamText)
    function GetPalette: PPalette; virtual;
  end;

{ TMoveListBox }

  PMoveListBox = ^TMoveListBox;
  TMoveListBox = object(TListViewer)
    List: PMoveList;
    constructor Init(var Bounds: TRect; AScrollBar: PScrollBar);
    function GetText(Item: Integer; AMaxLen: Integer): String; virtual;
    procedure Update(AMoveList: PMoveList);
  end;

{ TStatusDialog }

  PStatusDialog = ^TStatusDialog;
  TStatusDialog = object(TDialog)
    LastNodes: Longint;
    LastSec: Word;
    MoveListBox: PMoveListBox;
    constructor Init(var Bounds: TRect);
    function GetPalette: PPalette; virtual;
    procedure Update(Game: HChess; ATimers: array of PChessTimer;
      Nodes: Longint; MoveNumber: Integer; GMode: Word);
    procedure UpdateList(AMoveList: PMoveList);
  end;

  PGameStatus = ^TGameStatus;
  TGameStatus = record
    MoveColor: TColor;
    MoveNo:   Longint;
    ToMove:   PString;
    Mode:     PString;
    GameTime: PString;
    WhtTime:  PString;
    BlkTime:  PString;
    Value:    Longint;
    Nodes:    Longint;
    NodesSec: Longint;
    SearchSt: PString;
    MainLine: PString;
  end;

const
  StatusDialog: PStatusDialog = nil;

  CurPlayer: String[5] = '';
  BestLine: String = '';
  GTime: String[11] = '';
  TimeStrs: array [TColor] of String[11] = ('', '');
  GameMode: String[11] = '';
  SearchStatus: String[14] = '';
  GameStatus: TGameStatus = (
    MoveColor: cWhite;
    MoveNo:   0;
    ToMove:   @CurPlayer;
    Mode:     @GameMode;
    GameTime: @GTime;
    WhtTime:  @TimeStrs[cWhite];
    BlkTime:  @TimeStrs[cBlack];
    Value:    0;
    Nodes:    0;
    NodesSec: 0;
    SearchSt: @SearchStatus;
    MainLine: @BestLine
  );

implementation

uses Strings, TVChsCmd, Drivers;

{ TTimerView }

constructor TTimerView.Init(var Bounds: TRect; AText: String;
  AParamCount: Integer; AColor: TTimerColor);
begin
  inherited Init(Bounds, AText, AParamCount);
  Color := AColor;
end;

constructor TTimerView.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(Color, SizeOf(Color));
end;

function TTimerView.GetPalette: PPalette;
const
  P: array[TTimerColor] of String[Length(CWTimerView)] = (
    CWTimerView, CBTimerView, CGTimerView);
begin
  GetPalette := @P[Color];
end;

procedure TTimerView.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(Color, SizeOf(Color));
end;

{ TTurnText }

function TTurnText.DataSize: Word;
begin
  DataSize := SizeOf(Color) + inherited DataSize;
end;

procedure TTurnText.SetData(var Rec);
begin
  Color := TTimerColor(Rec);
  ParamList := Ptr(Seg(Rec), Ofs(Rec) + SizeOf(Color));
  DrawView;
end;

{ TBestLine }

function TBestLine.GetPalette: PPalette;
const
  P: string[Length(CBestLine)] = CBestLine;
begin
  GetPalette := @P;
end;

{ TMoveListBox }

constructor TMoveListBox.Init(var Bounds: TRect; AScrollBar: PScrollBar);
begin
  inherited Init(Bounds, 1, nil, AScrollBar);
  List := nil;
  SetRange(0);
end;

{$V-}
function TMoveListBox.GetText(Item: Integer; AMaxLen: Integer): String;
var
  White, Black: String[6];
  P: array[0..2] of Longint;
  Str: array[0..6] of Char;
  Entry: String;
begin
  if (List <> nil) and (List^.Count >= Item * 2) then
  begin
    P[0] := Item + 1;
    MoveToStr(PMove(List^.At(Item * 2))^, Str);
    White := StrPas(Str);
    if List^.Count > Item * 2 + 1 then
    begin
      MoveToStr(PMove(List^.At(Item * 2 + 1))^, Str);
      Black := StrPas(Str);
    end else Black := '';
    P[1] := Longint(@White);
    P[2] := Longint(@Black);
    FormatStr(Entry, '%3d  %6s  %6s', P);
  end else Entry := '';
  GetText := Copy(Entry, 1, AMaxLen);
end;
{$V+}

procedure TMoveListBox.Update(AMoveList: PMoveList);
var
  ARange: Integer;
  AUndoPos: Integer;
  OldRange: Integer;
begin
  List := AMoveList;
  if List <> nil then
  begin
    ARange := (List^.Count + 1) div 2;
    AUndoPos := List^.UndoPos div 2;
    OldRange := Range;
    SetRange(ARange);
    FocusItem(AUndoPos);
    if OldRange = ARange then DrawView;
  end else SetRange(0);
end;

{ TStatusDialog }

constructor TStatusDialog.Init(var Bounds: TRect);
var
  R: TRect;
  SB: PScrollBar;
begin
  inherited Init(Bounds, '');
  Flags := 0;

  R.Assign(1, 1, 7, 2);
  Insert(New(PStaticText, Init(R, 'Turn:')));
  R.Assign(7, 1, Size.X - 8, 2);
  Insert(New(PTurnText, Init(R, ' %-3d   %s', 2, tcWhite)));

  Inc(R.A.Y); Inc(R.B.Y);
  R.Assign(1, R.A.Y, Size.X - 1, R.B.Y);
  Insert(New(PParamText, Init(R, 'Mode: %s', 1)));

  Inc(R.A.Y); Inc(R.B.Y);
  R.Assign(Size.X div 4, R.A.Y, Size.X div 2 + Size.X div 4 - 1, R.B.Y);
  Insert(New(PTimerView, Init(R, ^C'%s', 1, tcTotal)));

  Inc(R.A.Y); Inc(R.B.Y);
  R.Assign(1, R.A.Y, (Size.X) div 2, R.B.Y);
  Insert(New(PTimerView, Init(R, ^C'%s', 1, tcWhite)));

  R.Assign(Size.X div 2, R.A.Y, Size.X - 1, R.B.Y);
  Insert(New(PTimerView, Init(R, ^C'%s', 1, tcBlack)));

  Inc(R.A.Y, 2); Inc(R.B.Y, 2);
  R.Assign(1, R.A.Y, Size.X - 1, R.B.Y);
  Insert(New(PParamText, Init(R, 'Value: %6d', 1)));

  Inc(R.A.Y); Inc(R.B.Y);
  R.Assign(1, R.A.Y, Size.X - 1, R.B.Y);
  Insert(New(PParamText, Init(R, 'Nodes: %6d %5d/sec', 2)));

  Inc(R.A.Y);
  R.Assign(Size.X - 1, R.A.Y, Size.X, Size.Y - 9);
  SB := New(PScrollBar, Init(R));
  Insert(SB);

  R.Assign(1, R.A.Y, Size.X - 1, R.B.Y);
  MoveListBox := New(PMoveListBox, Init(R, SB));
  Insert(MoveListBox);

  R.Assign(1, Size.Y - 9, Size.X - 1, Size.Y - 8);
  Insert(New(PParamText, Init(R, 'Bestline: %s', 1)));
  R.Assign(1, Size.Y - 8, Size.X - 1, Size.Y - 1);
  Insert(New(PBestLine, Init(R, '%s', 1)));

  SetData(GameStatus);
end;

function TStatusDialog.GetPalette: PPalette;
const
  P: string[Length(CStatusDialog)] = CStatusDialog;
begin
  GetPalette := @P;
end;

{$V-}
procedure TStatusDialog.Update(Game: HChess; ATimers: array of PChessTimer;
  Nodes: Longint; MoveNumber: Integer; GMode: Word);
var
  MLine: array[0..10] of TMove;
  MainValue: Integer;
  Str: array[0..20] of Char;
  I: Integer;
  Params: array[0..3] of Longint;
  LastSrch, SrchStat: TSearchStatus;

  procedure GetTime(TickTime: Longint;
    var Hours, Minutes, Seconds, Ticks: Longint);
  var
    H, M, S, T: Word;
  begin
    ConvertTicks(TickTime, H, M, S, T);
    Hours := H;
    Minutes := M;
    Seconds := S;
    Ticks := T;
  end;

begin
  GameStatus.MoveColor := GetPlayer(Game);
  if GameStatus.MoveColor = cWhite then
    CurPlayer := 'White'
  else CurPlayer := 'Black';
  GameStatus.MoveNo := MoveNumber;
  GameStatus.Nodes := Nodes;
  LastSrch := SrchStat;
  SrchStat := GetSearchStatus(Game);
  case SrchStat of
    ssMoveSearch: SearchStatus := 'Thinking';
    ssThinkAhead: SearchStatus := 'Thinking ahead';
  else
    SearchStatus := '';
  end;
  if GMode and gmDemo <> 0 then
    GameMode := 'Demo'
  else if GMode = gmOnePlay then
    GameMode := 'One Player'
  else GameMode := 'Two Player';
  GetTime(ATimers[Ord(cWhite)]^.GetCurrentTicks + ATimers[Ord(cBlack)]^.GetCurrentTicks,
    Params[0], Params[1], Params[2], Params[3]);
  FormatStr(GTime, '%02d:%02d:%02d.%02d', Params);
  if (SrchStat in [ssMoveSearch, ssThinkAhead]) and
    (LastSec <> Params[2]) then
  begin
    LastSec := Params[2];
    if LastSrch = SrchStat then
      GameStatus.NodesSec := Nodes - LastNodes
    else
      GameStatus.NodesSec := 0;
    LastNodes := Nodes;
  end;
  for I := Low(ATimers) to High(ATimers) do
  begin
    GetTime(ATimers[I]^.GetCurrentTicks, Params[0], Params[1], Params[2], Params[3]);
    FormatStr(TimeStrs[TColor(I)], '%02d:%02d:%02d.%02d', Params);
  end;
  BestLine := '';
  GetMainLine(Game, MainValue, MLine);
  GameStatus.Value := MainValue;
  if Settings.Hints and hoBestLine <> 0 then
  begin
    for I := Low(MLine) to High(MLine) do
    begin
      if MLine[I].Change.Piece <> pEmpty then
      begin
        MoveToStr(MLine[I], Str);
        BestLine := BestLine + StrPas(Str) + ' ';
      end else Break;
    end;
  end;
  SetData(GameStatus);
end;

procedure TStatusDialog.UpdateList(AMoveList: PMoveList);
begin
  MoveListBox^.Update(AMoveList);
end;

end.