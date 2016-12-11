{************************************************}
{                                                }
{   ObjectWindows Chess Demo                     }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ The chess programs consist of 3 binary files:

    OWLCHESS.EXE  - Windows chess program (uses ObjectWindows)
    TVCHESS.EXE   - DOS text mode chess program (uses Turbo Vision)
    CHESS.DLL     - Chess analysis engine dynamic link library (DLL)
                    that is shared by both TVCHESS.EXE and OWLCHESS.EXE

  TVCHESS is a DOS protected mode application (DPMI). To build
  it, set Compile|Target to Protected from inside the IDE or type the
  following command-line at a DOS prompt:

    bpc /m /cp tvchess

  (Note you can also produce a real mode version of TVCHESS which
  will statically link in the CHESS DLL units.)

  OWLCHESS is a Windows application. To build it, set Compile|Target to
  Windows from inside the IDE or type the following command-line at a
  DOS prompt:

    bpc /m /cw owlchess

  CHESS.DLL is a Windows format DLL and comes already built. To rebuild
  it, set Compile|Target to Windows from inside the IDE or type the
  following command-line at a DOS prompt:

    bpc /m /cw chess

}

program OWLChess;

{$C Moveable, Preload, Permanent }

uses WinProcs, WinTypes, Objects, OWindows, ODialogs, BWCC, OWUtils,
     Chessdll, OWBoard, MoveList, OWChDlgs, OWConst, OWLCmDlg, Strings,
     CommDlg, WinDos, CTimers, OWAbout;

{$R OWLChess}

const
  ChessSignature : array [0..33] of Char = 'Borland Pascal Chess saved game'#26#0;
  ChessFileFilter = 'Chess games'#0'*.chs'#0#0;
  csEndGame = [csCheckMate, csStaleMate, csResigns,
               csFiftyMoveRule, csRepetitionRule];

type

  TGameMode = (mSinglePlayer, mTwoPlayer, mAutoPlay, mStartup);

  PChessApp = ^TChessApp;
  TChessApp = object(TXtendedApp)
    procedure InitInstance; virtual;
    procedure InitMainWindow; virtual;
    function  IdleAction: Boolean; virtual;
  end;

  PChessWindow = ^TChessWindow;
  TChessWindow = object(TWindow)
    Game: HChess;
    Board: TChessBoard;
    BoardFrame: PBoardFrame;
    ThinkState: TSearchStatus;
    Mode : TGameMode;
    Player: TColor;
    MoveHistory: PMoveList;
    InfoPane: PChessInfoWindow;
    ThinkMenu: HMenu;
    GameFileName: array [0..fsPathName] of Char;
    Timer: array [cWhite..cBlack] of PChessTimer;
    ActiveTimer: PChessTimer;   { = nil means game is suspended }
    GameOver: Boolean;
    Paused: Boolean;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    destructor  Done; virtual;
    procedure SetupWindow; virtual;         { first place HWindow is valid }
    procedure WMDestroy(var Msg: TMessage); { last place HWindow is valid }
      virtual wm_First + wm_Destroy;
    function  GetClassName: PChar; virtual;
    procedure GetWindowClass(var WC: TWndClass); virtual;
    procedure Sleep;
    procedure Revive;
    procedure RestartGame;
    function  CanClose: Boolean; virtual;
    function  IdleAction: Boolean;
    function  ShowMsg(const Ctx, MsgCode: Integer; Override: PChar): Integer;
    function  GameTimeExpired: Boolean;
    procedure LockDownGameOver;
    procedure UnlockGameOver;
    procedure ReportGameState;
    function  SaveGame(FileName: PChar): Boolean;
    function  LoadGame(FileName: PChar): Boolean;
    procedure RecordMove(const Move: TMove);
    procedure StartComputerMove;
    procedure AcceptComputerMove;
    procedure AMSubmitMove(var Msg: TMessage);
      virtual am_SubmitMove;
    procedure AMChoosePawnPromote(var Msg: TMessage);
      virtual am_ChoosePawnPromote;
    procedure CMNewGame(var Msg: TMessage);
      virtual cm_First + cm_NewGame;
    procedure CMLoadGame(var Msg: TMessage);
      virtual cm_First + cm_LoadGame;
    procedure CMSaveGame(var Msg: TMessage);
      virtual cm_First + cm_SaveGame;
    procedure CMSaveAs(var Msg: TMessage);
      virtual cm_First + cm_SaveAs;
    procedure CMAutoPlay(var Msg: TMessage);
      virtual cm_First + cm_AutoPlay;
    procedure CMPauseGame(var Msg: TMessage);
      virtual cm_First + cm_PauseGame;
    procedure CMUndoMove(var Msg: TMessage);
      virtual cm_First + cm_UndoMove;
    procedure CMRedoMove(var Msg: TMessage);
      virtual cm_First + cm_RedoMove;
    procedure CMComputerMove(var Msg: TMessage);
      virtual cm_First + cm_ComputerMove;
    procedure CMEnterMove(var Msg: TMessage);
      virtual cm_First + cm_EnterMove;
    procedure CMSettings(var Msg: TMessage);
      virtual cm_First + cm_Settings;
    procedure CMAbout(var Msg: TMessage);
      virtual cm_First + cm_About;
    procedure CMStopThinking(var Msg: TMessage);
      virtual cm_First + cm_StopThinking;
    procedure WMTimer(var Msg: TMessage);
      virtual wm_First + wm_Timer;
    procedure WMSetCursor(var Msg: TMessage);
      virtual wm_First + wm_SetCursor;
    procedure WMActivate(var Msg: TMessage);
      virtual wm_First + wm_Activate;
  end;

constructor TChessWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  inherited Init(AParent, ATitle);
  Attr.X := 0;
  Attr.Y := 50;
  Attr.W := 350;
  Attr.H := 350;
  Attr.Style := ws_Overlapped or ws_Caption or ws_Border or
                ws_SysMenu or ws_MinimizeBox;
  Attr.Menu := LoadMenu(HInstance, PChar(idMainMenu));
  ThinkMenu := LoadMenu(HInstance, PChar(idThinkMenu));
  LoadINISettings;
  GameFileName[0] := #0;
  Mode := mStartup;
  Player := cWhite;
  Status := Context(cxChessError, Ord(NewGame(Game)));
  if Status <> 0 then Exit;
  ThinkState := GetSearchStatus(Game);
  Timer[cWhite] := New(PChessTimer, Init);
  Timer[cBlack] := New(PChessTimer, Init);
  ActiveTimer := nil;
  GameOver := False;
  Paused := False;
  MoveHistory := New(PMoveList, Init(20, 10));
  Board.Init(@Self, Game);
  InfoPane := New(PChessInfoWindow, Init(@Self, PChar(dlgInfoPane)));
  BoardFrame := New(PBoardFrame, Init(@Self, @Board));
end;

destructor  TChessWindow.Done;
begin
  Dispose(MoveHistory, Done);
  Dispose(Timer[cWhite], Done);
  Dispose(Timer[cBlack], Done);
  SaveINISettings;
  DisposeGame(Game);
  DestroyMenu(ThinkMenu);
  RemoveChild(@Board);
  Board.Done;
  inherited Done;
end;

procedure TChessWindow.SetupWindow;
var
  W, WX, WY, H: Word;
  WR, CR, IR: TRect;
  XSpacer, YSpacer: Integer;
  DC: HDC;
begin
  inherited SetupWindow;
  W := BoardFrame^.IdealWidth;
  H := W;
  GetWindowRect(HWindow, WR);
  GetClientRect(HWindow, CR);
  GetClientRect(InfoPane^.HWindow, IR);
  WX := (WR.Right - WR.Left) - CR.Right;
  WY := (WR.Bottom - WR.Top) - CR.Bottom;
  if H < IR.Bottom then
    H := IR.Bottom;
  DC := GetDC(HWindow);
  XSpacer := GetDeviceCaps(DC, LogPixelsX) div 8;
  YSpacer := GetDeviceCaps(DC, LogPixelsY) div 8;
  ReleaseDC(HWindow, DC);
  SetWindowPos(HWindow, 0, 0, 0, W + 3*XSpacer + IR.Right + WX,
                    H + 2*YSpacer + WY, swp_NoZOrder or swp_NoMove);
  SetWindowPos(BoardFrame^.HWindow, 0, XSpacer, YSpacer, W, W,swp_NoZOrder);
  SetWindowPos(InfoPane^.HWindow, 0, W + 2*XSpacer, YSpacer, 0, 0,
                               swp_NoZOrder or swp_NoSize);
  ShowWindow(BoardFrame^.HWindow, sw_ShowNormal);
  ShowWindow(Board.HWindow, sw_ShowNormal);
  SetTimer(HWindow, 1, ChessSettings.RefreshRate, nil);
end;

procedure TChessWindow.WMDestroy(var Msg: TMessage);
begin
  KillTimer(HWindow, 1);
  inherited WMDestroy(Msg);
end;

function  TChessWindow.GetClassName: PChar;
begin
  GetClassName := 'TPWOWLChess';
end;

procedure TChessWindow.GetWindowClass(var WC: TWndClass);
var
  LB: TLogBrush;
begin
  inherited GetWindowClass(WC);
  WC.Style := cs_ByteAlignWindow;
  WC.hCursor := 0;
  { Duplicate the BWCCPattern brush.  hbrBackground brush will be destroyed
    when our window is closed.  If we didn't duplicate this brush, but just
    used BWCCGetPattern's result directly, BWCC could be left without
    a valid background brush when our window closes.  }
  GetObject(BWCCGetPattern, SizeOf(LB), @LB);
  WC.hbrBackground := CreateBrushIndirect(LB);
  WC.hIcon := LoadIcon(HInstance, PChar(100));
end;

procedure TChessWindow.Sleep;
begin
  if not (GameOver or Paused) then
  begin
    if ActiveTimer <> nil then
      ActiveTimer^.Stop;
    ActiveTimer := nil;
    KillTimer(HWindow, 1);
    if ChessSettings.CoverBoard then
      Board.Cover(True);
    Board.Disable;
  end;
end;

procedure TChessWindow.Revive;
begin
  if not (GameOver or Paused) then
  begin
    ActiveTimer := Timer[GetPlayer(Game)];
    ActiveTimer^.Start;
    SetTimer(HWindow, 1, ChessSettings.RefreshRate, nil);
    if IsWindowVisible(Board.CoverDlg^.HWindow) then
      Board.Cover(False);
    Board.Enable;
  end;
end;

procedure TChessWindow.RestartGame;
var
  Cursor : HCursor;
begin
  UpdateWindow(HWindow);  { Clean up after the dialog that just closed }
  Cursor := SetCursor(LoadCursor(0, idc_Wait));
  if GameOver then
    UnlockGameOver;
  if ActiveTimer <> nil then
    ActiveTimer^.Stop;
  Timer[cWhite]^.Clear;
  Timer[cBlack]^.Clear;
  MoveHistory^.Purge;
  InfoPane^.MoveListBox^.DeleteRest(0);
  EnableMenuItem(Attr.Menu, cm_UndoMove, mf_ByCommand or
                                         mf_Disabled or mf_Grayed);
  EnableMenuItem(Attr.Menu, cm_RedoMove, mf_ByCommand or
                                         mf_Disabled or mf_Grayed);
  DisposeGame(Game);
  if ChessSettings.OnePlayer then
    Mode := mSinglePlayer
  else
    Mode := mTwoPlayer;
  ShowMsg(cxChessError, Ord(NewGame(Game)), nil);
  Player := cWhite;
  InfoPane^.Update(0, 0, 0, 0, 0, Word(Mode));
  GameOver := False;
  ThinkState := GetSearchStatus(Game);
  Board.ResetBoard(Game);
  SetCursor(Cursor);
end;

function TChessWindow.CanClose: Boolean;
begin
  CanClose := inherited CanClose and
              ( GameOver or
               (MoveHistory^.Count = 0) or
               (MessageBox(HWindow, PChar(strCancelGame),
                 PChar(strLeaveGame), mb_YesNo) = id_Yes));
  UpdateWindow(HWindow);    { Clean up after the message box asap }
end;

function  TChessWindow.IdleAction: Boolean;
var
  OldState: TSearchStatus;
  Value: Integer;
  Line: array [0..15] of TMove;
begin
  if not GameOver then
  begin
    OldState := ThinkState;
    if (OldState = ssMoveSearch) and (ActiveTimer <> nil) then
      ActiveTimer^.Start;
    if OldState = ssThinkAhead then
      Think(Game, 1, ThinkState)
    else
      Think(Game, ChessSettings.ThinkTime.Position, ThinkState);
    if (OldState = ssMoveSearch) and (ActiveTimer <> nil) then
      ActiveTimer^.Stop;
    if (ThinkState = ssComplete) and (OldState = ssMoveSearch) then
      AcceptComputerMove
    else
    if not GameOver and (ThinkState = ssGameOver) then
      ReportGameState;
  end;
    { Return True if we want to continue to get IdleAction calls ASAP,
      Return False if we don't need more IdleAction immediately
      ssThinkAhead is not included to minimize performance hits.
      IdleAction will be called frequently enough for ThinkAhead,
      since every wm_Timer message will set off an IdleAction call. }
  IdleAction := (ThinkState = ssMoveSearch) and not GameOver;
end;

function  TChessWindow.ShowMsg(const Ctx, MsgCode: Integer;
                               Override: PChar): Integer;
var
  S: array [0..100] of Char;
begin
  S[0] := #0;
  if Override <> nil then
    InfoPane^.Msg^.SetText(Override)
  else
  begin
    if (MsgCode <> 0) then
      StrLoadRes(S, Ctx + MsgCode);
    InfoPane^.Msg^.SetText(S);
  end;
  ShowMsg := MsgCode;
end;

function TChessWindow.GameTimeExpired: Boolean;
begin
  GameTimeExpired := ChessSettings.LimitGame and
   (Player = GetPlayer(Game)) and    { enforce game limit only on computer moves }
   (Timer[cWhite]^.GetCurrentTicks +
    Timer[CBlack]^.GetCurrentTicks > Trunc(ChessSettings.GameTime * 60 * 18.2065));
end;

procedure TChessWindow.LockDownGameOver;
var
  M: TMove;
begin
  AbortSearch(Game);
  if ThinkState = ssMoveSearch then  { Computer thought too long }
  begin
    Board.Enable;
    SetMenu(HWindow, Attr.Menu);
    Board.ResetValidMoves;
  end;
  if GameTimeExpired then
  begin
    EnableMenuItem(Attr.Menu, cm_RedoMove, mf_ByCommand or
                                         mf_Disabled or mf_Grayed);
    EnableMenuItem(Attr.Menu, cm_UndoMove, mf_ByCommand or
                                         mf_Disabled or mf_Grayed);
  end;
  EnableMenuItem(Attr.Menu, cm_ComputerMove, mf_ByCommand or
                                         mf_Disabled or mf_Grayed);
  EnableMenuItem(Attr.Menu, cm_AutoPlay, mf_ByCommand or
                                         mf_Disabled or mf_Grayed);
end;

procedure TChessWindow.UnlockGameOver;
begin
  if GameOver then
  begin
    GameOver := False;
    Board.SetGameOver(False);
    if MoveHistory^.UndoAvail then
      EnableMenuItem(Attr.Menu, cm_RedoMove, mf_ByCommand or mf_Enabled);
    if MoveHistory^.RedoAvail then
      EnableMenuItem(Attr.Menu, cm_UndoMove, mf_ByCommand or mf_Enabled);
    EnableMenuItem(Attr.Menu, cm_ComputerMove, mf_ByCommand or mf_Enabled);
    EnableMenuItem(Attr.Menu, cm_AutoPlay, mf_ByCommand or mf_Enabled);
  end;
end;

procedure TChessWindow.ReportGameState;
var State: TChessStatus;
    StrID: Word;
    Count: Integer;
    Color: TColor;
    Data : array [0..1] of PChar;
    S : array [0..100] of Char;
    P : PChar;
    WTime, BTime: Longint;
begin
  State := GetChessStatus(Game, Count);
  Data[0] := nil;
  Data[1] := nil;
  StrID := cxChessState + ord(State);
  case State of
    csCheckMate:
      Data[0] := StrNewRes(strWhite + ord(OtherPlayer(GetPlayer(Game))));
    csResigns:
      begin
        Data[0] := StrNewRes(strWhite + ord(OtherPlayer(GetPlayer(Game))));
        Data[1] := StrNewRes(strWhite + ord(GetPlayer(Game)));
      end;
    csMateFound:
      Data[0] := PChar(Count);
    else
      if GameTimeExpired then
      begin
        StrID := strGameTimeExpired;
        Data[0] := StrNewRes(strWhite + ord(GetPlayer(Game)));
        Data[1] := StrNewRes(strWhite + ord(OtherPlayer(GetPlayer(Game))));
      end;
  end;
  P := StrNewRes(StrID);
  S[0] := #0;
  if P <> nil then
    WVSprintf(S, P, Data);
  if Seg(Data[0]^) <> 0 then StrDispose(Data[0]);
  StrDispose(Data[1]);
  ShowMsg(0,0,S);
  InfoPane^.Update(Game, Timer[cWhite]^.GetCurrentTicks,
                         Timer[cBlack]^.GetCurrentTicks,
                         Timer[GetPlayer(Game)]^.GetMarkTime,
                         (MoveHistory^.UndoPos+1) div 2,
                         Word(Mode));
  { Check for game over conditions }
  if GameTimeExpired or
     not (State in [csNormal, csCheck, csMateFound]) then
  begin
    if ActiveTimer <> nil then
      ActiveTimer^.Stop;
    ActiveTimer := nil;
    if Board.Dragger <> nil then
      Board.CancelDrag;
    Data[0] := StrNewRes(strGameOver);
    GameOver := True;
    Board.SetGameOver(True);
    MessageBox(HWindow, S, Data[0], mb_Ok);
    LockDownGameOver;
  end;
end;

procedure TChessWindow.RecordMove(const Move: TMove);
var
  S, T: array [0..7] of Char;
begin
  if MoveHistory^.Count = 0 then  { Enable the menu on first move }
    EnableMenuItem(Attr.Menu, cm_UndoMove, mf_ByCommand or mf_Enabled);
  if MoveHistory^.RedoAvail then  { not any more...}
    EnableMenuItem(Attr.Menu, cm_RedoMove, mf_ByCommand or mf_Disabled
                                                        or mf_Grayed);
  MoveHistory^.AddMove(Move);
  if Odd(MoveHistory^.UndoPos) then
  begin    { Black move, need to package with the previous white move }
    MoveToStr(Move, T);
    MoveToStr(PMove(MoveHistory^.At(MoveHistory^.UndoPos-1))^, S);
  end
  else
  begin    { White move, no black move to bundle }
    MoveToStr(Move, S);
    T[0] := ' ';
    T[1] := #0;
  end;
  InfoPane^.MoveListBox^.AddMove(MoveHistory^.UndoPos div 2,S,T);
end;

procedure TChessWindow.StartComputerMove;
var
  TimeLimit : Longint;
begin
  with ChessSettings do
  begin
    if NoLimit then
      TimeLimit := MaxLongint
    else
    if LimitGame then
    begin
      TimeLimit := (ChessSettings.GameTime * 1092 -
        Timer[OtherPlayer(GetPlayer(Game))]^.GetCurrentTicks) div 44;
      if MoveHistory^.UndoPos <= 80 then        { Shoot for a 40 move game }
        TimeLimit := 91 + (TimeLimit - 91) *
          ((80 - MoveHistory^.UndoPos div 2) div 40);
    end
    else
    if MatchUser then
    begin
      TimeLimit := Timer[OtherPlayer(GetPlayer(Game))]^.GetMarkTime;
      if TimeLimit <= 1 then
        TimeLimit := 5 * 18;
    end
    else
      TimeLimit := TurnTime * 18;
  end;
  ComputerMove(Game, TimeLimit);
  ThinkState := GetSearchStatus(Game);
  SetMenu(HWindow, ThinkMenu);
  InfoPane^.EnableSearchInfoUpdates(True);
  Board.Disable;              { Prevent mouse dragging of pieces }
  EnableMenuItem(Attr.Menu, cm_PauseGame, mf_ByCommand or
                                          mf_Disabled or mf_Grayed);
  ActiveTimer := Timer[GetPlayer(Game)];
  ActiveTimer^.Mark;
end;


procedure TChessWindow.AcceptComputerMove;
var
  Move: TMove;
begin
  if (Mode = mStartup) then
  begin
    if ChessSettings.OnePlayer then
      Mode := mSinglePlayer
    else
      Mode := mTwoPlayer;
    EnableMenuItem(Attr.Menu, cm_PauseGame, mf_ByCommand or mf_Enabled);
  end;
  InfoPane^.EnableSearchInfoUpdates(False);
  GetLastMove(Game, Move);
  RecordMove(Move);
  Board.ExecuteMove(Move);
  ReportGameState;
  if (not GameOver) and
    ((Mode = mAutoPlay) or
     (Mode = mSinglePlayer) and (Player <> GetPlayer(Game)))  then
    StartComputerMove
  else
  begin
    Board.Enable;
    SetMenu(HWindow, Attr.Menu);
    if not GameOver then
    begin
      Board.ResetValidMoves;
      ActiveTimer := Timer[GetPlayer(Game)];
      ActiveTimer^.Mark;
      ActiveTimer^.Start;
      EnableMenuItem(Attr.Menu, cm_PauseGame, mf_ByCommand or mf_Enabled);
      if (Mode = mSinglePlayer) and ChessSettings.AllowThinkAhead then
      begin
        Player := GetPlayer(Game);
        ThinkAhead(Game);
        ThinkState := GetSearchStatus(Game);
        InfoPane^.ZeroNodes;
        InfoPane^.EnableSearchInfoUpdates(True);
      end;
    end;
  end;
end;

function TChessWindow.LoadGame(FileName: PChar): Boolean;
var
  S: PBufStream;
  Test: array [0..SizeOf(ChessSignature)] of Char;
  Blk: array [0..7] of Char;
  NewMoveList : PMoveList;
  Y, X: Integer;

  function ReplayMoves(P: PMove): Boolean; far;
  begin
    SubmitMove(Game, P^.Change);
    Board.ExecuteMove(P^);
    if Odd(X) then
    begin
      MoveToStr(P^, Blk);
      InfoPane^.MoveListBox^.AddMove(X div 2, Test, Blk);
    end
    else
      MoveToStr(P^, Test);
    ReplayMoves := (X >= MoveHistory^.UndoPos);
    Inc(X);
  end;

begin
  LoadGame := False;
  S := New(PBufStream, Init(FileName, stOpenRead, 1024));
  S^.Read(Test, SizeOf(ChessSignature));
  if S^.Status <> stOK then
    MessageBox(HWindow, PChar(Context(cxStreamError, S^.Status)),
                        PChar(strLoadError), mb_Ok)
  else
  if StrLComp(ChessSignature, Test, SizeOf(ChessSignature)) <> 0 then
    MessageBox(HWindow, PChar(strNotAChessFile),
                        PChar(strInvalidFile), mb_Ok)
  else
  begin
    NewMoveList := PMoveList(S^.Get);
    if S^.Status <> stOK then
      MessageBox(HWindow, PChar(Context(cxStreamError, S^.Status)),
                          PChar(strLoadError), mb_Ok)
    else
    begin
      RestartGame;
      Dispose(MoveHistory, Done);
      MoveHistory := NewMoveList;
      X := 0;
      Test[0] := #0;
      MoveHistory^.FirstThat(@ReplayMoves);

      { Copy undone moves to the move listbox as well }
      for Y := X+1 to MoveHistory^.Count-1 do
      begin
        if Odd(Y) then
        begin
          MoveToStr(PMove(MoveHistory^.At(Y))^, Blk);
          InfoPane^.MoveListBox^.AddMove(Y div 2, Test, Blk);
        end
        else
          MoveToStr(PMove(MoveHistory^.At(Y))^, Test);
      end;
      if Odd(MoveHistory^.Count) then
        InfoPane^.MoveListBox^.AddMove(
                  (MoveHistory^.Count-1) div 2, Test, ' ');
      InfoPane^.MoveListBox^.SetSelIndex(MoveHistory^.UndoPos div 2);

      if MoveHistory^.UndoAvail then
        EnableMenuItem(Attr.Menu, cm_UndoMove, mf_ByCommand or mf_Enabled);
      if MoveHistory^.RedoAvail then
        EnableMenuItem(Attr.Menu, cm_RedoMove, mf_ByCommand or mf_Enabled);
      Board.ResetValidMoves;
      ReportGameState;
      LoadGame := True;
    end;
  end;
  Dispose(S, Done);
end;

function TChessWindow.SaveGame(FileName: PChar): Boolean;
var
  S: PBufStream;
begin
  S := New(PBufStream, Init(FileName, stCreate, 1024));
  S^.Write(ChessSignature, SizeOf(ChessSignature));
  S^.Put(MoveHistory);
  if S^.Status <> stOK then
    MessageBox(HWindow, PChar(Context(cxStreamError, S^.Status)),
                        PChar(strSaveError), mb_Ok);
  SaveGame := S^.Status = stOK;
  Dispose(S, Done);
end;

procedure TChessWindow.AMSubmitMove(var Msg: TMessage);
var
  Move: TMove;
begin
  if (Mode = mStartup) then
  begin
    if ChessSettings.OnePlayer then
      Mode := mSinglePlayer
    else
      Mode := mTwoPlayer;
    EnableMenuItem(Attr.Menu, cm_PauseGame, mf_ByCommand or mf_Enabled);
  end;
  Msg.Result := ShowMsg(cxChessError, Ord(SubmitMove(Game, PChange(Msg.LParam)^)), nil);
    { Result = True if SubmitMove returns zero, else Result = False }
  LongBool(Msg.Result) := not LongBool(Msg.Result);
  if LongBool(Msg.Result) then
  begin
    if ActiveTimer <> nil then
      ActiveTimer^.Stop;
    GetLastMove(Game, Move);       { Retrieve the full move from the engine }
    RecordMove(Move);              { Enter in history list, enable Redo menu}
    Board.ExecuteMove(Move);      { Adjust the board }
    ReportGameState;
    if not GameOver then
      if ChessSettings.TwoPlayer then
      begin
        Player := GetPlayer(Game);
        Board.ResetValidMoves;       { Refresh the valid move tables }
        ActiveTimer := Timer[GetPlayer(Game)];
        ActiveTimer^.Mark;
        ActiveTimer^.Start;
      end
      else
        StartComputerMove;
  end;
end;

procedure TChessWindow.AMChoosePawnPromote(var Msg: TMessage);
begin
  XApp^.ExecDialog(New(PChoosePawnPromoteDlg,
    Init(InfoPane, PChar(dlgChoosePawnPromote), PChange(Msg.LParam))));
end;

procedure TChessWindow.CMNewGame(var Msg: TMessage);
begin
  if  GameOver or
     (MoveHistory^.Count = 0) or
     (MessageBox(HWindow, PChar(strCancelGame),
        PChar(strStartNewGame), mb_YesNo) = id_Yes) then
  begin
    RestartGame;
  end;
end;

procedure TChessWindow.CMLoadGame(var Msg: TMessage);
var
  Temp : array [0..fsPathName] of Char;
  Count: Integer;
begin
  StrCopy(Temp, GameFileName);
  if ( GameOver or
     (GetChessStatus(Game, Count) in csEndGame) or
     (MoveHistory^.Count = 0) or
     (MessageBox(HWindow, PChar(strCancelGame),
        PChar(strLoadSavedGame), mb_YesNo) = id_Yes))
    and
     (XApp^.ExecDialog(New(PCDFileOpen, Init(@Self,
        ofn_FileMustExist, Temp, SizeOf(Temp),
        ChessFileFilter))) = idOk) then
    if LoadGame(Temp) then
      StrCopy(GameFileName, Temp);
end;

procedure TChessWindow.CMSaveGame(var Msg: TMessage);
begin
  if GameFileName[0] = #0 then
    CMSaveAs(Msg)
  else
    SaveGame(GameFileName);
end;

procedure TChessWindow.CMSaveAs(var Msg: TMessage);
var
  Temp : array [0..fsPathName] of Char;
begin
  StrCopy(Temp, GameFileName);
  if XApp^.ExecDialog(New(PCDFileSaveAs, Init(@Self,
      ofn_PathMustExist, Temp, SizeOf(Temp), ChessFileFilter))) = idOk then
    if SaveGame(Temp) then
      StrCopy(GameFileName, Temp);
end;

procedure TChessWindow.CMAutoPlay(var Msg: TMessage);
begin
  if Paused then   { The game is paused }
    CMPauseGame(Msg);   { Clear the paused state before entering autoplay }
  Mode := mAutoPlay;
  AbortSearch(Game);
  StartComputerMove;
end;

procedure TChessWindow.CMPauseGame(var Msg: TMessage);
var
  S: array [0..20] of Char;
begin
  if Paused then
  begin
    Paused := False;
    Revive;
    ModifyMenu(Attr.Menu, cm_PauseGame, mf_ByCommand or mf_String,
                           cm_PauseGame, StrLoadRes(S, strPauseMenu));
    if MoveHistory^.RedoAvail then
      EnableMenuItem(Attr.Menu, cm_RedoMove, mf_ByCommand or mf_Enabled);
    if MoveHistory^.UndoAvail then
     EnableMenuItem(Attr.Menu, cm_UndoMove, mf_ByCommand or mf_Enabled);
    EnableMenuItem(Attr.Menu, cm_ComputerMove, mf_ByCommand or mf_Enabled);
    EnableMenuItem(Attr.Menu, cm_EnterMove, mf_ByCommand or mf_Enabled);
  end
  else
  begin
    Sleep;
    ModifyMenu(Attr.Menu, cm_PauseGame, mf_ByCommand or mf_String,
                           cm_PauseGame, StrLoadRes(S, strResumeMenu));
    ShowMsg(0,strGamePaused,nil);
    if MoveHistory^.RedoAvail then
      EnableMenuItem(Attr.Menu, cm_RedoMove, mf_ByCommand or
                                mf_Disabled or mf_Grayed);
    if MoveHistory^.UndoAvail then
     EnableMenuItem(Attr.Menu, cm_UndoMove, mf_ByCommand or
                                        mf_Disabled or mf_Grayed);
    EnableMenuItem(Attr.Menu, cm_ComputerMove, mf_ByCommand or
                              mf_Disabled or mf_Grayed);
    EnableMenuItem(Attr.Menu, cm_EnterMove, mf_ByCommand or
                              mf_Disabled or mf_Grayed);
    Paused := True;
  end;
end;

procedure TChessWindow.CMUndoMove(var Msg: TMessage);
var
  M : TMove;
  RedoBefore, UndoBefore: Boolean;
begin
  { No error checking is performed here - it is assumed that the
    menu enable/disable code will only allow the user
    to select this menu item when there is a valid undo available. }
  UndoBefore := MoveHistory^.UndoAvail;
  RedoBefore := MoveHistory^.RedoAvail;

  AbortSearch(Game);   { You can't submit or retract moves while thinking }

  if GameOver then
    UnlockGameOver;

  if ActiveTimer <> nil then
    ActiveTimer^.Stop;
  Revive;
  ActiveTimer^.Stop;
  ActiveTimer^.Mark;

  MoveHistory^.Undo(M);
  RetractMove(Game, M);
  Board.RetractMove(M);

  if (Mode = mSinglePlayer) and
     MoveHistory^.UndoAvail then  { Undo both player's and computer's move }
  begin
    MoveHistory^.Undo(M);
    RetractMove(Game, M);
    Board.RetractMove(M);
  end;
  if MoveHistory^.RedoAvail and not RedoBefore then
    EnableMenuItem(Attr.Menu, cm_RedoMove, mf_ByCommand or mf_Enabled);
  if (not MoveHistory^.UndoAvail) and UndoBefore then
   EnableMenuItem(Attr.Menu, cm_UndoMove, mf_ByCommand or
                                          mf_Disabled or mf_Grayed);
  InfoPane^.MoveListBox^.SetSelIndex(MoveHistory^.UndoPos div 2);
  Board.ResetValidMoves;
  InfoPane^.EnableSearchInfoUpdates(False);
  ReportGameState;
  ActiveTimer^.Start;
end;

procedure TChessWindow.CMRedoMove(var Msg: TMessage);
var
  M : TMove;
  RedoBefore, UndoBefore: Boolean;
begin
  { No error checking is performed here - it is assumed that the
    menu enable/disable code will only allow the user
    to select this menu item when there is a valid redo available. }
  UndoBefore := MoveHistory^.UndoAvail;
  RedoBefore := MoveHistory^.RedoAvail;

  AbortSearch(Game);   { You can't submit or retract moves while thinking }

  if GameOver then
    UnlockGameOver;

  if ActiveTimer <> nil then
    ActiveTimer^.Stop;
  Revive;
  ActiveTimer^.Stop;
  ActiveTimer^.Mark;

  MoveHistory^.Redo(M);
  SubmitMove(Game, M.Change);
  Board.ExecuteMove(M);

  if (Mode = mSinglePlayer) and
     MoveHistory^.RedoAvail then
  begin
    MoveHistory^.Redo(M);  { Redo both player's and computer's moves }
    SubmitMove(Game, M.Change);
    Board.ExecuteMove(M);
  end;

  { Update the menus, but only when the undo/redo state changes
    (to avoid menubar flicker caused by unnecessary menu changes) }
  if (not MoveHistory^.RedoAvail) and RedoBefore then
    EnableMenuItem(Attr.Menu, cm_RedoMove, mf_ByCommand or
                                           mf_Disabled or mf_Grayed);
  if MoveHistory^.UndoAvail and not UndoBefore then
    EnableMenuItem(Attr.Menu, cm_UndoMove, mf_ByCommand or mf_Enabled);

  InfoPane^.MoveListBox^.SetSelIndex(MoveHistory^.UndoPos div 2);
  Board.ResetValidMoves;
  InfoPane^.EnableSearchInfoUpdates(False);
  ReportGameState;
  if ActiveTimer <> nil then
    ActiveTimer^.Start;
end;

procedure TChessWindow.CMComputerMove(var Msg: TMessage);
var
  Move: TMove;
begin
  AbortSearch(Game);
  GetHintMove(Game, Move);
  if VerifyMove(Game, Move.Change) = ceOK then
  begin
    Msg.LParam := Longint(@Move.Change);
    AMSubmitMove(Msg);
  end
  else
  begin
    Player := GetPlayer(Game);
    StartComputerMove;
  end;
end;

procedure TChessWindow.CMEnterMove(var Msg: TMessage);
var
  S: array [0..10] of Char;
  Chg: TChange;
begin
  S[0] := #0;
  Board.CoverDlg^.Lock;  { Prevent EnterMoveDlg from covering board }
  if XApp^.ExecDialog(New(PEnterMoveDlg,
     Init(InfoPane, PChar(dlgEnterMove), S))) = IDOK then
  begin
    if (ShowMsg(cxChessError, Ord(ParseMove(S, Chg)),nil) = 0) then
    begin
      Msg.LParam := Longint(@Chg);
      Msg.wParam := 0;
      AMSubmitMove(Msg);
    end
  end;
  Board.CoverDlg^.Unlock;
end;

procedure TChessWindow.CMSettings(var Msg: TMessage);
begin
  XApp^.ExecDialog(new(PSettingsDlg, Init(@Self, PChar(dlgSettings),
                                                 ChessSettings)));
  if (Mode <> mStartup) then
  begin
    if ChessSettings.OnePlayer then
      Mode := mSinglePlayer
    else
      Mode := mTwoPlayer;
    Board.ResetValidMoves;
  end;
  if (ChessSettings.CoverBoard <> Board.CoverDlg^.Locked) then
    if ChessSettings.CoverBoard then
      Board.CoverDlg^.Unlock
    else
      Board.CoverDlg^.Lock;
end;

procedure TChessWindow.CMAbout(var Msg: TMessage);
begin
  XApp^.ExecDialog(New(PAboutBox,
    Init(@Self, 'About OWLChess', PChar(bmBlaise))));
end;

procedure TChessWindow.CMStopThinking(var Msg: TMessage);
begin
  if ThinkState = ssMoveSearch then
    ForceMove(Game);     { Move search will terminate at next Think call }
  if Mode = mAutoPlay then
  begin
    Mode := mSinglePlayer;  { Stop the demo, if it is running }
    Player := OtherPlayer(GetPlayer(Game));
  end;
end;

procedure TChessWindow.WMTimer(var Msg: TMessage);
begin
  if not GameOver then
    ReportGameState;
end;

procedure TChessWindow.WMSetCursor(var Msg: TMessage);
begin
  DefWndProc(Msg);
  Msg.Result := 1;  { Cancel any pending WMSetCursor in children }
  if Msg.LParamLo = HTClient then
    if (ThinkState = ssMoveSearch)  then
      SetCursor(LoadCursor(0, PChar(idc_Wait)))
    else
    begin
      if Msg.WParam = Board.HWindow then
        Msg.Result := 0   { Allow Board to use its own cursor }
      else
        SetCursor(LoadCursor(0, PChar(idc_Arrow)));
    end;
end;

procedure TChessWindow.WMActivate(var Msg: TMessage);
begin
  inherited WMActivate(Msg);
  if Mode = mStartup then Exit;
  if Msg.LParamHi = 0 then  { we're not minimized }
    if Msg.WParam = 0 then   { we're going inactive }
      Sleep
    else
      Revive
  else
    if ActiveTimer <> nil then  { we're being minimized }
      Sleep;
end;


procedure TChessApp.InitInstance;
begin
  inherited InitInstance;
  if Status = 0 then
  begin
    HAccTable := LoadAccelerators(HInstance, 'Accel');
    if HAccTable = 0 then
      Status := em_InvalidWindow;
  end;
end;

procedure TChessApp.InitMainWindow;
begin
  MainWindow := new(PChessWindow, Init(nil, 'OWL Chess'));
end;

function TChessApp.IdleAction: Boolean;
begin
  IdleAction := PChessWindow(MainWindow)^.IdleAction;
end;

procedure ShowSplashScreen(var R: TRect);
var
  BM: HBitmap;
  DC, MemDC: HDC;
  BitInfo: TBitmap;
begin
  DC := GetDC(0);
  MemDC := CreateCompatibleDC(DC);
  BM := LoadBitmap(HInstance, PChar(bmBlaise));
  GetObject(BM, SizeOf(BitInfo), @BitInfo);
  BM := SelectObject(MemDC, BM);   { swap BMs}
  R.Left := GetDeviceCaps(DC,HORZRES) div 2 - BitInfo.bmWidth div 2;
  R.Top := GetDeviceCaps(DC,VERTRES) div 2 - BitInfo.bmHeight div 2;
  BitBlt(DC, R.Left, R.Top, BitInfo.bmWidth, BitInfo.bmHeight,
         MemDC, 0, 0, SrcCopy);
  DeleteObject(SelectObject(MemDC, BM));
  DeleteDC(MemDC);
  ReleaseDC(0, DC);
  R.Right := R.Left + BitInfo.bmWidth;
  R.Bottom := R.Top + BitInfo.bmHeight;
end;


var
  App: TChessApp;
  R: TRect;
begin
  RegisterType(RMoveList);

  { Show Splash screen asap }
  ShowSplashScreen(R);

  App.Init('OWL Chess');

  { Erase the splash bitmap }
  InvalidateRect(0, @R, True);

  App.Run;
  App.Done;
end.
