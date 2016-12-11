{************************************************}
{                                                }
{   ObjectWindows Chess Demo                     }
{   Dialogs unit                                 }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit OWCHDlgs;

interface

uses WinProcs, WinTypes, OWindows, ODialogs, Validate, ChessDLL, OWConst;

const
  AM_InfoUpdate = wm_User + 502;

type

  PMoveListbox = ^TMoveListbox;
  TMoveListbox = object(TListbox)
    procedure SetupWindow; virtual;
    procedure AddMove(Turn: Integer; White, Black: PChar);
    procedure DeleteRest(Turn: Integer);
    procedure AMInfoUpdate(var Msg: TMessage);
      virtual wm_First + am_InfoUpdate;
  end;

  PChessInfoWindow = ^TChessInfoWindow;
  TChessInfoWindow = object(TDlgWindow)
    Msg: PStatic;
    MoveListBox: PMoveListBox;
    UpdateSearchInfo: Boolean;
    constructor Init(AParent: PWindowsObject; AName: PChar);
    function GetClassName: PChar; virtual;
    procedure GetWindowClass(var WC: TWndClass); virtual;
    procedure EnableSearchInfoUpdates(EnableUpdates: Boolean);
    procedure ZeroNodes;
    procedure Update(Game: HChess; WhiteTime, BlackTime,
                     LastInterval: Longint;
                     MoveNum: Integer; GameMode: Word);
  end;

  PSettingsXferRec = ^TSettingsXferRec;
  TSettingsXferRec = record
    LimitGame,
    LimitTurn,
    MatchUser,
    NoLimit:  WordBool;
    GameTime,
    TurnTime: Longint;
    ShowAttacks,
    ShowJeopardies,
    ShowBestLine,
    RightClickHints,
    OnePlayer,
    TwoPlayer: WordBool;
    ThinkTime: TScrollBarTransferRec;
    AllowThinkAhead,
    CoverBoard: WordBool;
    { The following are not used by the dialog, but are used by the program.
      Keep them at the bottom of this record }
    RefreshRate: Word;
  end;

  PSettingsDlg = ^TSettingsDlg;
  TSettingsDlg = object(TDialog)
    constructor Init(AParent: PWindowsObject; AName: PChar;
                     var XferBuf: TSettingsXferRec);
    procedure SetupWindow; virtual;
    procedure EnableSet(Game, Turn: Boolean);
    procedure ShowSet(Game, Turn: Boolean);
    procedure LimitGameTime(var Msg: TMessage);
      virtual id_First + idLimitGameTime;
    procedure LimitTurnTime(var Msg: TMessage);
      virtual id_First + idLimitTurnTime;
    procedure MatchUserTime(var Msg: TMessage);
      virtual id_First + idMatchUserTime;
    procedure NoTimeLimit(var Msg: TMessage);
      virtual id_First + idNoTimeLimit;
  end;

  PCoverDlg = ^TCoverDlg;
  TCoverDlg = object(TDlgWindow)
    Locked: Bool;
    constructor Init(AParent: PWindowsObject; AResName: PChar);
    procedure Lock;
    procedure Unlock;
    procedure Show(ShowCmd: Integer); virtual;
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;
  end;

  PRelocatingDlg = ^TRelocatingDlg;
  TRelocatingDlg = object(TDialog)
    procedure SetupWindow; virtual;
  end;

  PChoosePawnPromoteDlg = ^TChoosePawnPromoteDlg;
  TChoosePawnPromoteDlg = object(TRelocatingDlg)
    Buffer: array [0..3] of WordBool;  { 4 radio buttons }
    Change: PChange;
    constructor Init(AParent: PWindowsObject;
                     AResName: PChar; AChange: PChange);
    procedure TransferData(Direction: Word); virtual;
  end;

  PEnterMoveDlg = ^TEnterMoveDlg;
  TEnterMoveDlg = object(TRelocatingDlg)
    constructor Init(AParent: PWindowsObject;
                     AResName: PChar;
                     AMoveStr: PChar);
  end;

var
  ChessSettings: TSettingsXferRec;

procedure LoadINISettings;
procedure SaveINISettings;

implementation

uses OWUtils, Strings, CTimers;

  { The LockWindowUpdate function will eliminate all flicker caused by
    switching between the two edit controls set up in the Settings dialog.
    This function is only available in Windows 3.1, though, so in order
    to allow this program to run (with some flicker) in Windows 3.0,
    this program should:

      1) Never call LockWindowUpdate when running under Windows 3.0
      2) Avoid using static declarations (like Win31.pas) to import
         the function, since Windows 3.0 won't load an app if the app
         contains static references to DLL functions Windows 3.0
         doesn't have.

    The following code uses a function variable and GetProcAddress to
    request the address of the LockWindowUpdate function.  Windows 3.0
    will return a nil function address if you ask for a function that
    doesn't exist in the indicated DLL.  Before each use of the
    function variable, test it for nil using the Assigned function.
  }

type
  Win31LockWindowUpdateFunc = function (Wnd: HWnd): Bool;

const
  Win31LockWindowUpdate: Win31LockWindowUpdateFunc = nil;

type
  PUpdateRec = ^TUpdateRec;
  TUpdateRec = record
    Time : array [cWhite..cBlack] of Longint;
    MoveNum : Integer;
    GameMode: Word;
    Nodes: Longint;
    LastInterval: Longint;
    UpdateSearchInfo: Boolean;
  end;

  TColoredStatic = object(TWindow)
    Color: TColor;
    constructor InitResource(AParent: PWindowsObject; ResID: Integer;
                             AColor: TColor);
    procedure Paint(DC: HDC; var PS: TPaintStruct); virtual;
    procedure OutputText(DC: HDC; var PS: TPaintStruct); virtual;
  end;

  PTurnDisplay = ^TTurnDisplay;
  TTurnDisplay = object(TColoredStatic)
    Tag: array [cWhite..cBlack] of PChar;
    TurnNum: Integer;
    constructor InitResource(AParent: PWindowsObject; ResID: Integer);
    destructor Done; virtual;
    procedure OutputText(DC: HDC; var PS: TPaintStruct); virtual;
    procedure AMInfoUpdate(var Msg: TMessage);
      virtual wm_First + am_InfoUpdate;
  end;

  PTimeDisplay = ^TTimeDisplay;
  TTimeDisplay = object(TColoredStatic)
    CurrentTime: array [0..20] of Char;
    constructor InitResource(AParent: PWindowsObject; ResID: Integer;
                             AColor: TColor);
    procedure OutputText(DC: HDC; var PS: TPaintStruct); virtual;
    procedure AMInfoUpdate(var Msg: TMessage);
      virtual wm_First + am_InfoUpdate;
  end;

  PGameTimeDisplay = ^TGameTimeDisplay;
  TGameTimeDisplay = object(TStatic)
    CurrentTime: array [0..20] of Char;
    constructor InitResource(AParent: PWindowsObject; ResID: Integer);
    procedure AMInfoUpdate(var Msg: TMessage);
      virtual wm_First + am_InfoUpdate;
  end;

  PBestLine = ^TBestLine;
  TBestLine = object(TStatic)
    CurrentLine: array [0..100] of Char;
    constructor InitResource(AParent: PWindowsObject; ResID: Integer);
    procedure AMInfoUpdate(var Msg: TMessage);
      virtual wm_First + am_InfoUpdate;
  end;

  PValueLine = ^TValueLine;
  TValueLine = object(TStatic)
    CurrentValue: Integer;
    constructor InitResource(AParent: PWindowsObject; ResID: Integer);
    procedure AMInfoUpdate(var Msg: TMessage);
      virtual wm_First + am_InfoUpdate;
  end;

  PModeDisplay = ^TModeDisplay;
  TModeDisplay = object(TStatic)
    CurrentMode: Word;
    constructor InitResource(AParent: PWindowsObject; ResID: Integer);
    procedure AMInfoUpdate(var Msg: TMessage);
      virtual wm_First + am_InfoUpdate;
  end;

  PNodeDisplay = ^TNodeDisplay;
  TNodeDisplay = object(TStatic)
    NodeCount: Longint;
    constructor InitResource(AParent: PWindowsObject; ResID: Integer);
    procedure Zero;
    procedure AMInfoUpdate(var Msg: TMessage);
      virtual wm_First + am_InfoUpdate;
  end;

  PNodesPerSecond = ^TNodesPerSecond;
  TNodesPerSecond = object(TNodeDisplay)
    procedure AMInfoUpdate(var Msg: TMessage);
      virtual wm_First + am_InfoUpdate;
  end;


constructor TColoredStatic.InitResource(AParent: PWindowsObject;
                                        ResID: Integer;
                                        AColor: TColor);
begin
  inherited InitResource(AParent, ResID);
  Color := AColor;
end;

procedure TColoredStatic.Paint(DC: HDC; var PS: TPaintStruct);
var
  R: TRect;
begin
  SaveDC(DC);
  GetClientRect(HWindow, R);
  if Color = cBlack then
  begin
    SetTextColor(DC, RGB(255,255,255));
    SetBkColor(DC, RGB(0,0,0));
    PatBlt(DC, R.Left, R.Top, R.Right, R.Bottom, Blackness);
  end
  else
  begin
    SetTextColor(DC, RGB(0,0,0));
    SetBkColor(DC, RGB(255,255,255));
    PatBlt(DC, R.Left, R.Top, R.Right, R.Bottom, Whiteness);
  end;
  OutputText(DC, PS);
  RestoreDC(DC, -1);
end;

procedure TColoredStatic.OutputText(DC: HDC; var PS: TPaintStruct);
begin
end;

constructor TTurnDisplay.InitResource(AParent: PWindowsObject;
                                      ResID: Integer);
begin
  inherited InitResource(AParent, ResID, cWhite);
  TurnNum := 0;
  Tag[cWhite] := StrNewRes(strWhite);
  Tag[cBlack] := StrNewRes(strBlack);
end;

destructor TTurnDisplay.Done;
begin
  StrDispose(Tag[cWhite]);
  StrDispose(Tag[cBlack]);
  inherited Done;
end;

procedure TTurnDisplay.OutputText(DC: HDC; var PS: TPaintStruct);
var
  R: TRect;
  TE1, TE2: Word;
  TempStr: array [0..7] of Char;
begin
  GetClientRect(HWindow, R);
  TempStr[0] := #0;
  Str(TurnNum, TempStr);
  TextOut(DC, 3, 0, TempStr, StrLen(TempStr));
  TE1 := 3 + LoWord(GetTextExtent(DC, TempStr, StrLen(TempStr)));
  TE2 := LoWord(GetTextExtent(DC, Tag[Color], StrLen(Tag[Color])));
  TextOut(DC, TE1 + ((R.Right - TE1) div 2) - (TE2 div 2), 0,
                 Tag[Color], StrLen(Tag[Color]));
end;

procedure TTurnDisplay.AMInfoUpdate(var Msg: TMessage);
begin
  if Msg.WParam = 0 then  { Game reset }
  begin
    TurnNum := 0;
    Color := cWhite;
    InvalidateRect(HWindow, nil, False);
  end
  else
  if (GetPlayer(HChess(Msg.WParam)) <> Color) or
     (TurnNum <> PUpdateRec(Msg.LParam)^.MoveNum) then
  begin
    Color := GetPlayer(HChess(Msg.WParam));
    TurnNum := PUpdateRec(Msg.LParam)^.MoveNum;
    InvalidateRect(HWindow,nil,False);
  end;
end;

constructor TTimeDisplay.InitResource(AParent: PWindowsObject;
                                      ResID: Integer;
                                      AColor: TColor);
begin
  inherited InitResource(AParent, ResID, AColor);
  CurrentTime[0] := #0;
end;

procedure TTimeDisplay.OutputText(DC: HDC; var PS: TPaintStruct);
var
  R: TRect;
begin
  SetTextAlign(DC, ta_Center);
  GetClientRect(HWindow, R);
  TextOut(DC, R.Right div 2, 0, CurrentTime, StrLen(CurrentTime));
end;


procedure TTimeDisplay.AMInfoUpdate(var Msg: TMessage);
var
  s: array [0..20] of Char;
  P: array [0..3] of Word;
begin
  if Msg.WParam = 0 then
  begin
    CurrentTime[0] := #0;
    InvalidateRect(HWindow, nil, False);
  end
  else
  if GetPlayer(HChess(Msg.WParam)) = Color then
  begin
    ConvertTicks(PUpdateRec(Msg.LParam)^.Time[Color],P[0],P[1],P[2],P[3]);
    WVSprintf(S, '%02i:%02i:%02i.%02i', P);
    if StrComp(CurrentTime, S) <> 0 then
    begin
      StrCopy(CurrentTime, S);
      InvalidateRect(HWindow, nil, False);
    end;
  end;
end;

constructor TGameTimeDisplay.InitResource(AParent: PWindowsObject;
                                          ResID: Integer);
begin
  inherited InitResource(AParent, ResID, SizeOf(CurrentTime));
  CurrentTime[0] := #0;
end;

procedure TGameTimeDisplay.AMInfoUpdate(var Msg: TMessage);
var
  s: array [0..20] of Char;
  P: array [0..3] of Word;
begin
  with PUpdateRec(Msg.LParam)^ do
    ConvertTicks(Time[cWhite] + Time[cBlack],P[0],P[1],P[2],P[3]);
  WVSprintf(S, '%02i:%02i:%02i.%02i', P);
  if StrComp(CurrentTime, S) <> 0 then
  begin
    SetText(S);
    StrCopy(CurrentTime, S);
  end;
end;

constructor TBestLine.InitResource(AParent: PWindowsObject; ResID: Integer);
begin
  inherited InitResource(AParent, ResID, 100);
  CurrentLine[0] := #0;
end;

procedure TBestLine.AMInfoUpdate(var Msg: TMessage);
var
  Value: Integer;
  Line: array [0..23] of TMove;
  S: array [0..8] of Char;
  NewLine : array [0..100] of Char;
  X, L: Integer;
begin
  NewLine[0] := #0;
  if (Msg.WParam <> 0) and
     ChessSettings.ShowBestLine then
  begin
    GetMainLine(HChess(Msg.WParam), Value, Line);
    X := 0;
    L := 0;
    while (X <= High(Line))
      and (Line[X].Change.Piece <> pEmpty)
      and (L <= (High(NewLine) - High(S))) do
    begin
      MoveToStr(Line[X],S);
      StrCopy(@NewLine[L],StrCat(S, ' '));
      Inc(L, StrLen(S));
      Inc(X);
    end;
  end;
  if StrComp(CurrentLine, NewLine) <> 0 then
  begin
    SetText(NewLine);
    StrCopy(CurrentLine, NewLine);
  end;
end;

constructor TValueLine.InitResource(AParent: PWindowsObject;
                                    ResID: Integer);
begin
  inherited InitResource(AParent, ResID, 10);
  CurrentValue := 0;
end;

procedure TValueLine.AMInfoUpdate(var Msg: TMessage);
var
  Value: Integer;
  Move: TMove;
  S: array [0..10] of Char;
begin
  if Msg.WParam = 0 then
    Value := 0
  else
    GetMainLine(HChess(Msg.WParam), Value, Move);
  if Value <> CurrentValue then
  begin
    Str(Value, S);
    SetText(S);
    CurrentValue := Value;
  end;
end;

constructor TModeDisplay.InitResource(AParent: PWindowsObject; ResID: Integer);
begin
  inherited InitResource(AParent, ResID, 40);
  CurrentMode := $FFFF;
end;

procedure TModeDisplay.AMInfoUpdate(var Msg: TMessage);
begin
  with PUpdateRec(Msg.LParam)^ do
  if GameMode <> CurrentMode then
  begin
    CurrentMode := GameMode;
    SetText(StrNewRes(cxGameMode + CurrentMode));
  end;
end;

constructor TNodeDisplay.InitResource(AParent: PWindowsObject; ResID: Integer);
begin
  inherited InitResource(AParent, ResID, 20);
  NodeCount := 0;
end;

procedure TNodeDisplay.Zero;
begin
  NodeCount := 0;
  SetText('0');
end;

procedure TNodeDisplay.AMInfoUpdate(var Msg: TMessage);
var
  S: array [0..10] of Char;
begin
  with PUpdateRec(Msg.LParam)^ do
  if UpdateSearchInfo then
    if NodeCount <> Nodes then
    begin
      NodeCount := Nodes;
      Str(NodeCount, S);
      SetText(S);
    end;
end;

procedure TNodesPerSecond.AMInfoUpdate(var Msg: TMessage);
var
  S: array [0..10] of Char;
  Temp: Longint;
begin
  with PUpdateRec(Msg.LParam)^ do
  if UpdateSearchInfo then
    if (LastInterval = 0) then
      if NodeCount <> 0 then
        Zero
      else
    else
    begin
      Temp := Nodes div Succ(LastInterval div 18);
      if (NodeCount <> Temp) then
      begin
        NodeCount := Temp;
        Str(NodeCount, S);
        SetText(S);
      end;
    end;
end;

procedure TMoveListbox.SetupWindow;
var
  TabStops: array [0..1] of Integer;
begin
  inherited SetupWindow;
  TabStops[0] := 13;
  TabStops[1] := 39;
  SendMessage(HWindow, lb_SetTabStops, 2, Longint(@TabStops));
end;

procedure TMoveListBox.AddMove(Turn: Integer;
                               White, Black: PChar);
var
  S: array [0..20] of Char;
  Params: array [0..2] of PChar;
begin
  if Turn < GetCount then
    DeleteRest(Turn);
  Params[0] := PChar(Turn);
  Params[1] := White;
  Params[2] := Black;
  S[0] := #0;
  wvsprintf(S, '%li'#9'%s'#9'%s', Params);
  InsertString(S, -1);
  SetSelIndex(Turn);
end;

procedure TMoveListBox.DeleteRest(Turn: Integer);
var
  X: Integer;
begin
  for X := GetCount downto Turn do
    DeleteString(X);
end;

procedure TMoveListbox.AMInfoUpdate(var Msg: TMessage);
begin
end;


constructor TChessInfoWindow.Init(AParent: PWindowsObject; AName: PChar);
var
  Dummy : PWindowsObject;
begin
  inherited Init(AParent, AName);
  UpdateSearchInfo := False;
  Msg := New(PStatic, InitResource(@Self, idInfoMsg, 50));
  Dummy := New(PValueLine, InitResource(@Self, idInfoValue));
  Dummy := New(PBestLine, InitResource(@Self, idInfoBestLine));
  Dummy := New(PTimeDisplay, InitResource(@Self, idInfoWhite, cWhite));
  Dummy := New(PTimeDisplay, InitResource(@Self, idInfoBlack, cBlack));
  Dummy := New(PGameTimeDisplay, InitResource(@Self, idInfoTime));
  Dummy := New(PTurnDisplay, InitResource(@Self, idInfoTurn));
  Dummy := New(PModeDisplay, InitResource(@Self, idInfoMode));
  Dummy := New(PNodeDisplay, InitResource(@Self, idInfoNodes));
  Dummy := New(PNodesPerSecond, InitResource(@Self, idInfoNPSec));
  MoveListBox := New(PMoveListBox, InitResource(@Self, idMovesListbox));
end;

function TChessInfoWindow.GetClassName: PChar;
begin
  GetClassName := 'BorDlg_ChessInfo';
end;

procedure TChessInfoWindow.GetWindowClass(var WC: TWndClass);
begin
  inherited GetWindowClass(WC);
  WC.hCursor := 0;      { reflect wm_setcursor back to parent window }
end;

procedure TChessInfoWindow.EnableSearchInfoUpdates(EnableUpdates: Boolean);
begin
  UpdateSearchInfo := EnableUpdates;
end;

procedure TChessInfoWindow.ZeroNodes;
begin
  PNodeDisplay(ChildWithID(idInfoNodes))^.Zero;
  PNodesPerSecond(ChildWithID(idInfoNPSec))^.Zero;
end;

procedure TChessInfoWindow.Update(Game: HChess;
                                  WhiteTime,
                                  BlackTime,
                                  LastInterval: Longint;
                                  MoveNum: Integer;
                                  GameMode: Word);
var
  N: TUpdateRec;

  procedure DoUpdate(P: PWindowsObject); far;
  begin
    SendMessage(P^.HWindow, AM_InfoUpdate, Game, Longint(@N));
  end;

begin
  N.Time[cWhite] := WhiteTime;
  N.Time[cBlack] := BlackTime;
  N.LastInterval := LastInterval;
  N.MoveNum := MoveNum;
  N.GameMode := GameMode;
  N.Nodes := GetNodes(Game);
  N.UpdateSearchInfo := UpdateSearchInfo;
  ForEach(@DoUpdate);
end;


constructor TSettingsDlg.Init(AParent: PWindowsObject;
                              AName: PChar;
                              var XferBuf: TSettingsXferRec);
var
  P : PWindowsObject;
begin
  inherited Init(AParent, AName);
  P := New(PRadioButton, InitResource(@Self, idLimitGameTime));
  P := New(PRadioButton, InitResource(@Self, idLimitTurnTime));
  P := New(PRadioButton, InitResource(@Self, idMatchUserTime));
  P := New(PRadioButton, InitResource(@Self, idNoTimeLimit));
  P := New(PEdit, InitResource(@Self, idLimitGameTimeInput, TimeLimitInputLen));
  PEdit(P)^.SetValidator(New(PRangeValidator, Init(1, 600)));
  with PEdit(P)^.Validator^ do
    Options := Options or voTransfer;
  P := New(PEdit, InitResource(@Self, idLimitTurnTimeInput, TimeLimitInputLen));
  PEdit(P)^.SetValidator(New(PRangeValidator, Init(1, 36000)));
  with PEdit(P)^.Validator^ do
    Options := Options or voTransfer;
  P := New(PCheckBox, InitResource(@Self, idShowAttacks));
  P := New(PCheckBox, InitResource(@Self, idShowJeopardies));
  P := New(PCheckBox, InitResource(@Self, idShowBestLine));
  P := New(PCheckBox, InitResource(@Self, idRightClickQueries));
  P := New(PRadioButton, InitResource(@Self, idSinglePlayer));
  P := New(PRadioButton, InitResource(@Self, idTwoPlayer));
  P := New(PScrollbar, InitResource(@Self, idThinkTime));
  P^.EnableTransfer;
  P := New(PCheckBox, InitResource(@Self, idAllowThinkAhead));
  P := New(PCheckBox, InitResource(@Self, idCoverBoard));
  TransferBuffer := @XferBuf;
end;

procedure TSettingsDlg.SetupWindow;
begin
  inherited SetupWindow;
  with PSettingsXferRec(TransferBuffer)^ do
    ShowSet(LimitGame, LimitTurn);
end;

procedure TSettingsDlg.EnableSet(Game, Turn: Boolean);
begin
  EnableWindow(GetItemHandle(idLimitTurnTimeLabel), Turn);
  EnableWindow(GetItemHandle(idLimitTurnTimeInput), Turn);
  EnableWindow(GetItemHandle(idTurnTimeUnit), Turn);
  EnableWindow(GetItemHandle(idLimitGameTimeLabel), Game);
  EnableWindow(GetItemHandle(idLimitGameTimeInput), Game);
  EnableWindow(GetItemHandle(idGameTimeUnit), Game);
end;

procedure TSettingsDlg.ShowSet(Game, Turn: Boolean);
const
  sw : array [False..True] of Word = (sw_Hide, sw_Show);
begin
  if Assigned(Win31LockWindowUpdate) then
    Win31LockWindowUpdate(HWindow);
  ShowWindow(GetItemHandle(idLimitTurnTimeInput), sw[Turn]);
  ShowWindow(GetItemHandle(idLimitTurnTimeLabel), sw[Turn]);
  ShowWindow(GetItemHandle(idTurnTimeUnit), sw[Turn]);
  ShowWindow(GetItemHandle(idLimitGameTimeInput), sw[Game]);
  ShowWindow(GetItemHandle(idLimitGameTimeLabel), sw[Game]);
  ShowWindow(GetItemHandle(idGameTimeUnit), sw[Game]);
  if Assigned(Win31LockWindowUpdate) then
    Win31LockWindowUpdate(0);
  EnableSet(Game, Turn);
end;

procedure TSettingsDlg.LimitGameTime(var Msg: TMessage);
begin
  DefWndProc(Msg);
  if Msg.LParamHi = BN_Clicked then
    ShowSet(True, False);
end;

procedure TSettingsDlg.LimitTurnTime(var Msg: TMessage);
begin
  DefWndProc(Msg);
  if Msg.LParamHi = BN_Clicked then
    ShowSet(False, True);
end;

procedure TSettingsDlg.MatchUserTime(var Msg: TMessage);
begin
  DefWndProc(Msg);
  if Msg.LParamHi = BN_Clicked then
    EnableSet(False, False);
end;

procedure TSettingsDlg.NoTimeLimit(var Msg: TMessage);
begin
  DefWndProc(Msg);
  if Msg.LParamHi = BN_Clicked then
    EnableSet(False, False);
end;


procedure LoadINISettings;
var
  I: Longint;
begin
  FillChar(ChessSettings, SizeOf(ChessSettings), 0);
  with ChessSettings, XApp^ do
  begin
    I := GetAppProfileLongint('Settings','TimeLimitType',2);
    case I of
      1: LimitGame := True;
      2: LimitTurn := True;
      4: MatchUser := True;
      8: NoLimit   := True;
    else
      {!! Display error msg }
      LimitTurn := True;
    end;
    TurnTime := GetAppProfileLongint('Settings','SecsPerTurn',10);
    GameTime := GetAppProfileLongint('Settings','MinsPerGame',30);
    ShowAttacks := GetAppProfileBoolean('Settings','ShowAttacks',True);
    ShowJeopardies := GetAppProfileBoolean('Settings',
                                           'ShowJeopardies',True);
    ShowBestLine := GetAppProfileBoolean('Settings','ShowBestLine',True);
    RightClickHints := GetAppProfileBoolean('Settings',
                                            'RightClickHints',True);
    TwoPlayer := GetAppProfileBoolean('Settings','TwoPlayers',False);
    OnePlayer := not TwoPlayer;
    with ThinkTime do
    begin
      LowValue := 1;
      HighValue := 36;
      Position := Integer(GetAppProfileLongint('Settings',
                                               'TicsPerThink',2));
    end;
    AllowThinkAhead := GetAppProfileBoolean('Settings',
                                            'AllowThinkAhead',True);
    CoverBoard := GetAppProfileBoolean('Settings','PauseCoversBoard',True);
    RefreshRate := Word(GetAppProfileLongint('Settings','RefreshRate',500));
  end;
end;

procedure SaveINISettings;
var
  X: Longint;
begin
  with ChessSettings, XApp^ do
  begin
    X := Word(LimitGame) +
         Word(LimitTurn) shl 1 +
         Word(MatchUser) shl 2 +
         Word(NoLimit) shl 3;
    WriteAppProfileLongint('Settings','TimeLimitType',X);
    WriteAppProfileLongint('Settings','SecsPerTurn',TurnTime);
    WriteAppProfileLongint('Settings','MinsPerGame',GameTime);
    WriteAppProfileBoolean('Settings','ShowAttacks',ShowAttacks);
    WriteAppProfileBoolean('Settings','ShowJeopardies',ShowJeopardies);
    WriteAppProfileBoolean('Settings','ShowBestLine',ShowBestLine);
    WriteAppProfileBoolean('Settings','RightClickHints',RightClickHints);
    WriteAppProfileBoolean('Settings','TwoPlayers',TwoPlayer);
    WriteAppProfileLongint('Settings','TicsPerThink',ThinkTime.Position);
    WriteAppProfileBoolean('Settings','AllowThinkAhead',AllowThinkAhead);
    WriteAppProfileBoolean('Settings','PauseCoversBoard',CoverBoard);
    WriteAppProfileLongint('Settings','RefreshRate',RefreshRate);
  end;
end;


constructor TCoverDlg.Init(AParent: PWindowsObject; AResName: PChar);
begin
  inherited Init(AParent, AResName);
  Locked := False;
end;

procedure TCoverDlg.Lock;
begin
  Inc(Locked);
end;

procedure TCoverDlg.Unlock;
begin
  if Locked then
    Dec(Locked);
end;

procedure TCoverDlg.Show(ShowCmd: Integer);
begin
  if not Locked then
    if ShowCmd = sw_Hide then
      SetWindowPos(HWindow, 0,0,0,0,0,
        swp_NoZOrder or swp_HideWindow)
    else
    begin
      SetWindowPos(HWindow, 0,0,0,0,0,
        swp_NoActivate or swp_NoZOrder or swp_ShowWindow);
      { Win 3.0 needs the following forced repaint. }
      InvalidateRect(HWindow, nil, True);
    end;
end;

procedure TCoverDlg.WMSize(var Msg: TMessage);
var
  R: TRect;
begin
  DefWndProc(Msg);
  SetWindowPos(GetDlgItem(HWindow, idCoverGroup), 0,
        Msg.LParamLo div 5, Msg.LParamHi div 5,
        Integer(Msg.LParamLo - 2*(Msg.LParamLo div 5)),
        Integer(Msg.LParamHi - 2*(Msg.LParamHi div 5)),
        swp_NoZOrder or swp_NoActivate);
  GetClientRect(GetDlgItem(HWindow, idCoverText), R);
  SetWindowPos(GetDlgItem(HWindow, idCoverText), 0,
        Msg.LParamLo div 5 + 2,
        Integer(Msg.LParamHi div 2 - R.Bottom div 2),
        Integer(Msg.LParamLo - 2*(Msg.LParamLo div 5) - 4), R.Bottom,
        swp_NoZOrder or swp_NoActivate);
end;


procedure TRelocatingDlg.SetupWindow;
var
  R: TRect;
begin
  inherited SetupWindow;
  GetWindowRect(Parent^.HWindow, R);
  SetWindowPos(HWindow, 0, R.Left, R.Top, 0, 0, swp_NoSize or swp_NoZOrder);
end;


constructor TChoosePawnPromoteDlg.Init(AParent: PWindowsObject;
                                       AResName: PChar;
                                       AChange: PChange);
var
  Dummy: PRadiobutton;
begin
  inherited Init(AParent, AResName);
  Change := AChange;
  FillChar(Buffer, SizeOf(Buffer), 0);
  Buffer[0] := True;           { Queen is the default choice }
  TransferBuffer := @Buffer;
  New(Dummy, InitResource(@Self, idQueen));
  New(Dummy, InitResource(@Self, idRook));
  New(Dummy, InitResource(@Self, idBishop));
  New(Dummy, InitResource(@Self, idKnight));
end;

procedure TChoosePawnPromoteDlg.TransferData(Direction: Word);
var
  X: Byte;
begin
  inherited TransferData(Direction);
  if Direction = tf_GetData then
  begin
    for X := 0 to High(Buffer) do
      if Buffer[X] then Break;
    Change^.Piece := TPiece(ord(pQueen) + X);
  end;
end;

constructor TEnterMoveDlg.Init(AParent: PWindowsObject;
                               AResName: PChar;
                               AMoveStr: PChar);
var
  Dummy : PWindowsObject;
begin
  inherited Init(AParent, AResName);
  Dummy := New(PEdit, InitResource(@Self, idEnterMoveEdit, 10));
  TransferBuffer := AMoveStr;
end;


begin
      { In Windows 3.0, the following GetProcAddress call will return nil,
        but not cause a critical error message.  Any code that uses
        this function variable should always test it first, with
        the Assigned system function. }
  @Win31LockWindowUpdate := GetProcAddress(
                             GetModuleHandle('User'), PChar(294));
end.