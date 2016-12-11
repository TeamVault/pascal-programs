{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Swat;

{$R Swat}

uses
  WinTypes, WinProcs, OWindows, ODialogs, Strings, BWCC;

const
  idm_Reset    = 100;
  idm_Option   = 101;
  idm_About    = 102;
  idm_Pause    = 103;
  idm_Stop     = 104;

  InputEditBox = 109;
  LiveTimeSB   = 101;
  PopSB        = 102;

  MissedPoints = -2;
  HitPoints    =  5;
  MissedCritter = -1;
  CritterSize  = 72;

  MaxPop       = 35;
  MaxLiveTime  = 30;

  Holes: array[1..5] of TPoint = ((X: 10; Y: 10), (X: 200; Y: 10),
    (X: 100; Y: 100), (X: 10; Y: 200), (X: 200; Y: 200));

type
  TApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

  THole = record
    Time: Word;
    Dead: Boolean;
  end;

  PGameWindow = ^TGameWindow;
  TGameWindow = object(TWindow)
    Live, Dead, GameOver, ScoreBoard: HBitMap;
    CursorDown, CursorUp: HCursor;
    Counter, Score, LiveTime, Frequence, GameTime: Integer;
    Hits, Miss, Escaped: Integer;
    IsGameOver, IsPause: Boolean;
    HoleInfo: array[1..5] of THole;
    constructor Init(AParent: PWindowsObject; Title: PChar);
    procedure About(var Message: TMessage); virtual cm_First + idm_About;
    procedure DrawBMP(DC: HDC; X, Y, BitMap: HBitmap);
    procedure DrawGameOver(DC: HDC);
    procedure DrawCritter(DC: HDC; CritterNumber: Byte);
    procedure DrawScoreBoard(DC: HDC);
    procedure GetWindowClass(var WndClass: TWndClass); virtual;
    procedure Options(var Message: TMessage); virtual cm_First + idm_Option;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure Pause(var Message: TMessage); virtual cm_First + idm_Pause;
    procedure ResetGame(var Message: TMessage); virtual cm_First + idm_Reset;
    procedure SetUpWindow; virtual;
    procedure Stop(var Message: TMessage); virtual cm_First + idm_Stop;
    procedure StopGame;
    procedure WMDestroy(var Message: TMessage); virtual wm_Destroy;
    procedure WMLButtonDown(var Message: TMessage); virtual wm_LButtonDown;
    procedure WMLButtonUp(var Message: TMessage); virtual wm_LButtonUp;
    procedure WMTimer(var Message: TMessage); virtual wm_Timer + wm_First;
    procedure WMSize(var Message: TMessage); virtual wm_Size;
    procedure WriteScore(DC: HDC);
  end;

TOptionDialog = object(TDialog)
  procedure OK(var Message: TMessage); virtual id_First + id_Ok;
  procedure SetUpWindow; virtual;
  procedure WMHScroll(var Message: TMessage); virtual wm_HScroll;
end;

{--------------- TOptionDialog ---------------}

procedure TOptionDialog.SetUpWindow;
var
  S: String;
  CS: array[0..20] of Char;
begin
  TDialog.SetUpWindow;
  SetScrollRange(GetDlgItem(HWindow, LiveTimeSB), sb_Ctl, 1,
    MaxLiveTime, False);
  SetScrollRange(GetDlgItem(HWindow, PopSB), sb_Ctl, 1, MaxPop, False);
  SetScrollPos(GetDlgItem(HWindow, LiveTimeSB), sb_Ctl,
    MaxLiveTime + 1 - PGameWindow(Parent)^.LiveTime, True);
  SetScrollPos(GetDlgItem(HWindow, PopSB), sb_Ctl,
    MaxPop + 6 - PGameWindow(Parent)^.Frequence, True);
  Str(PGameWindow(Parent)^.GameTime div 10, S);
  StrPCopy(CS, S);
  SetDlgItemText(HWindow, InputEditBox, CS);
end;

procedure TOptionDialog.WMHScroll(var Message: TMessage);
const
  PageStep = 10;
var
  Pos: Integer;
  Scroll: HWnd;
begin
  Scroll := HiWord(Message.lParam);
  Pos := GetScrollPos(Scroll, SB_Ctl);
  case Message.wParam of
    sb_LineUp: Dec(Pos);
    sb_LineDown: Inc(Pos);
    sb_PageUp: Dec(Pos, PageStep);
    sb_PageDown: Inc(Pos, PageStep);
    sb_ThumbPosition: Pos := LoWord(Message.lParam);
    sb_ThumbTrack: Pos := LoWord(Message.lParam);
  end;
  SetScrollPos(Scroll, sb_Ctl, Pos, True);
end;

procedure TOptionDialog.OK(var Message: TMessage);
var
  NoError: Bool;
  Time: Integer;
begin
  PGameWindow(Parent)^.LiveTime := MaxLiveTime + 1 - GetScrollPos(
    GetDlgItem(HWindow, LiveTimeSB), sb_Ctl);
  PGameWindow(Parent)^.Frequence := MaxPop + 1 - GetScrollPos(
    GetDlgItem(HWindow, PopSB), sb_Ctl) + 5;
  Time := GetDlgItemInt(HWindow, InputEditBox, @NoError, False) * 10;
  if (NoError) and (Time > 0) then
  begin
    PGameWindow(Parent)^.GameTime := Time;
    EndDlg(id_Ok);
  end
  else
    MessageBox(HWindow, 'Game Time must be a number greater than 0!',
      'Error', mb_Ok)
end;

{--------------- TGameWindow -----------------}

constructor TGameWindow.Init(AParent: PWindowsObject; Title: PChar);
begin
  TWindow.Init(AParent, Title);
  Attr.W := 282;
  Attr.H := 400;
  Attr.Style := WS_Caption or WS_SysMenu or WS_MinimizeBox;
  Randomize;
end;

procedure TGameWindow.About(var Message: TMessage);
var
  Dialog: TDialog;
begin
  Dialog.Init(@Self, 'About');
  Dialog.Execute;
  Dialog.Done;
end;

procedure TGameWindow.DrawBMP(DC: HDC; X, Y, BitMap: HBitMap);
var
  MemDC: HDC;
  bm: TBitMap;
  MadeDC: Boolean;
begin
  if DC = 0 then
  begin
    DC := GetDC(HWindow);
    MadeDC := True;
  end
  else
    MadeDC := False;
  MemDC := CreateCompatibleDC(DC);
  SelectObject(MemDC, BitMap);
  GetObject(GameOver, SizeOf(bm), @bm);
  BitBlt(DC, X, Y, bm.bmWidth, bm.bmHeight, MemDC, 0, 0, SRCCopy);
  DeleteDC(MemDC);
  if MadeDC then ReleaseDC(HWindow, DC);
end;

procedure TGameWindow.DrawGameOver(DC: HDC);
begin
  DrawBMP(DC, 10, 70, GameOver);
end;

procedure TGameWindow.DrawCritter(DC: HDC; CritterNumber: Byte);
var
  MadeDC: Boolean;
  MemDC: HDC;
begin
  if DC = 0 then
  begin
    DC := GetDC(HWindow);
    MadeDC := True;
  end
  else MadeDC := False;

  if HoleInfo[CritterNumber].Time <> 0 then
  begin
    MemDC := CreateCompatibleDC(DC);
    if HoleInfo[CritterNumber].Dead then SelectObject(MemDC, Dead)
    else SelectObject(MemDC, Live);
    BitBlt(DC, Holes[CritterNumber].X, Holes[CritterNumber].Y,
      CritterSize, CritterSize, MemDC, 0, 0, SRCCopy);
    DeleteDC(MemDC);
  end
  else
  begin
    SelectObject(DC, GetStockObject(White_Brush));
    SelectObject(DC, GetStockObject(Null_Pen));
    Rectangle(DC, Holes[CritterNumber].X, Holes[CritterNumber].Y,
      Holes[CritterNumber].X + CritterSize + 1,
      Holes[CritterNumber].Y + CritterSize + 1);
  end;
  if MadeDC then ReleaseDC(HWindow, DC);
end;

procedure TGameWindow.DrawScoreBoard(DC: HDC);
begin
  DrawBMP(DC, 11, 214, ScoreBoard);
end;

procedure TGameWindow.GetWindowClass(var WndClass: TWndClass);
begin
  TWindow.GetWindowClass(WndClass);
  CursorUp := LoadCursor(hInstance, 'Malet');
  WndClass.Style := 0;
  WndClass.hCursor := CursorUp;
  WndClass.hbrBackGround := GetStockObject(White_Brush);
  WndClass.lpszMenuName := 'Menu';
  WndClass.hIcon := LoadIcon(hInstance, 'Critter');
end;

procedure TGameWindow.Options(var Message: TMessage);
var
  D: TOptionDialog;
begin
  D.Init(@Self, 'OptionDlg');
  D.Execute;
  D.Done;
end;

procedure TGameWindow.Paint(PaintDC: HDC;var PaintInfo: TPaintStruct);
var
  I: integer;
begin
  DrawScoreBoard(PaintDC);
  WriteScore(PaintDC);
  if IsGameOver then
    DrawGameOver(PaintDC)
  else
    for I := 1 to 5 do
      DrawCritter(PaintDC, I);
end;

procedure TGameWindow.Pause(var Message: TMessage);
begin
  if IsGameOver then Exit;
  if IsPause then
  begin
    IsPause := False;
    ModifyMenu(GetMenu(HWindow), idm_Pause, mf_ByCommand,
      idm_Pause, '&Pause');
    DrawMenuBar(hWindow);
    if SetTimer(HWindow, 1, 100, nil) = 0 then
    begin
      MessageBox(HWindow, 'No Timers Left', 'Error', mb_Ok);
      Halt(1);
    end;
  end
  else
  begin
    IsPause := True;
    KillTimer(HWindow, 1);
    ModifyMenu(GetMenu(HWindow), idm_Pause, mf_ByCommand,
      idm_Pause, '&Continue');
    DrawMenuBar(hWindow);
  end;
end;

procedure TGameWindow.ResetGame(var Message: TMessage);
begin
  ModifyMenu(GetMenu(HWindow), idm_Option, mf_ByCommand or mf_Grayed,
    idm_Option, '&Options');
  ModifyMenu(GetMenu(HWindow), idm_Pause, mf_ByCommand,
    idm_Pause, '&Pause');
  ModifyMenu(GetMenu(HWindow), idm_Stop, mf_ByCommand,
    idm_Stop, '&Stop');
  DrawMenuBar(HWindow);
  InValidateRect(HWindow, nil, True);
  if SetTimer(HWindow, 1, 100, nil) = 0 then
  begin
    MessageBox(HWindow, 'No Timers Left', 'Error', mb_Ok);
    Halt(1);
  end;
  FillChar(HoleInfo, SizeOf(HoleInfo), 0);
  Counter := 0;
  Score := 0;
  Hits := 0;
  Miss := 0;
  Escaped := 0;
  IsGameOver := False;
  if IsPause then
  begin
    IsPause := False;
    ModifyMenu(GetMenu(HWindow), idm_Pause, mf_ByCommand,
      idm_Pause, '&Pause');
    DrawMenuBar(hWindow);
  end;
end;

procedure TGameWindow.SetUpWindow;
begin
  CursorDown := LoadCursor(hInstance, 'MaletDown');
  Live := LoadBitMap(hInstance, 'Live');
  Dead := LoadBitMap(hInstance, 'Dead');
  GameOver := LoadBitMap(hInstance, 'GameOver');
  ScoreBoard := LoadBitMap(hInstance, 'Board');
  IsGameOver := True;
  IsPause := False;
  LiveTime := 10;
  Frequence := 20;
  Counter := 0;
  Score := 0;
  Hits := 0;
  Miss := 0;
  Escaped := 0;
  GameTime := 150 {fifteen seconds}
end;

procedure TGameWindow.Stop(var Message: TMessage);
begin
  StopGame;
end;

procedure TGameWindow.StopGame;
begin
  KillTimer(HWindow, 1);
  ModifyMenu(GetMenu(HWindow), idm_Option, mf_ByCommand,
    idm_Option, '&Options');
  ModifyMenu(GetMenu(HWindow), idm_Pause, mf_ByCommand or mf_Grayed,
    idm_Pause, '&Pause');
  ModifyMenu(GetMenu(HWindow), idm_Stop, mf_ByCommand or mf_Grayed,
    idm_Stop, '&Stop');
  IsPause := False;
  DrawMenuBar(HWindow);
  IsGameOver := True;
  InValidateRect(HWindow, nil, True);
  Counter := GameTime;
end;

procedure TGameWindow.WMDestroy(var Message: TMessage);
begin
  DeleteObject(Live);
  DeleteObject(Dead);
  DeleteObject(GameOver);
  DeleteObject(ScoreBoard);
  KillTimer(HWindow, 1);
  TWindow.WMDestroy(Message);
end;

procedure TGameWindow.WMLButtonDown(var Message: TMessage);
var
  Point: TPoint;
  R: TRect;
  I: Integer;
  Hit: Boolean;
begin
  SetClassWord(HWindow, GCW_hCursor, CursorDown);
  GetCursorPos(Point);
  SetCursorPos(Point.X, Point.Y);
  if IsGameOver or IsPause then Exit;
  Hit := False;
  for I := 1 to 5 do
    if not ((HoleInfo[I].Dead) or (HoleInfo[I].Time = 0)) then
    begin
      R.Top := Holes[I].X;
      R.Left := Holes[I].Y;
      R.Bottom := R.Top + CritterSize;
      R.Right := R.Left + CritterSize;
      Point.X := HiWord(Message.lParam);
      Point.Y := LoWord(Message.lParam);
      if PtInRect(R, Point) then
      begin
	Inc(Score, HitPoints);
	HoleInfo[I].Dead := True;
	HoleInfo[I].Time := Counter + 2 * LiveTime;
	Inc(Hits);
	Hit := True;
	DrawCritter(0, I);
      end;
    end;
  if not Hit then
  begin
    Inc(Score, MissedPoints);
    Inc(Miss);
  end;
  WriteScore(0);
end;

procedure TGameWindow.WMLButtonUp(var Message: TMessage);
var
  Point: TPoint;
begin
  SetClassWord(HWindow, gcw_hCursor, CursorUp);
  GetCursorPos(Point);
  SetCursorPos(Point.X, Point.Y);
end;

procedure TGameWindow.WMTimer(var Message: TMessage);
var
  I: Integer;
begin
  Inc(Counter);
  I := Random(Frequence) + 1;
  if I < 6 then
    if HoleInfo[I].Time = 0 then
    begin
      HoleInfo[I].Time := Counter + LiveTime;
      HoleInfo[I].Dead := False;
      DrawCritter(0, I);
    end;
  for I := 1 to 5 do
    if (Counter > HoleInfo[I].Time) and (HoleInfo[I].Time <> 0) then
    begin
      HoleInfo[I].Time := 0;
      if not HoleInfo[I].Dead then
      begin
	Inc(Score, MissedCritter);
	Inc(Escaped);
      end;
      DrawCritter(0, I);
    end;
  WriteScore(0);
  if Counter >= GameTime then StopGame;
end;

procedure TGameWindow.WMSize(var Message: TMessage);
begin
  if IsGameOver then Exit;
  if IsIconic(HWindow) then KillTimer(HWindow, 1)
  else
    if not IsPause then
      if SetTimer(HWindow, 1, 100, nil) = 0 then
      begin
	MessageBox(HWindow, 'No Timers Left', 'Error', mb_Ok);
	Halt(1);
      end;
end;

procedure TGameWindow.WriteScore(DC: HDC);
var
  S: array[0..20] of Char;
  MadeDC: Boolean;
begin
 if DC = 0 then
 begin
   MadeDC := True;
   DC := GetDC(HWindow);
 end
 else MadeDC := False;
 SelectObject(DC, CreateSolidBrush($8080));
 SelectObject(DC, GetStockObject(Null_Pen));
 SetBKMode(DC, TransParent);

 {Timer}
 Rectangle(DC, 130, 252, 163, 275);
 Str((GameTime-Counter):3, S);
 S[3] :=S[2];
 S[2]:='.';
 TextOut(DC, 130, 252, S, 4);

 {Hits}
 Rectangle(DC, 40, 310, 71, 329);
 Str(Hits:3, S);
 TextOut(DC, 40, 310, S, StrLen(S));

 {Misses}
 Rectangle(DC, 77, 310, 117, 329);
 Str(Miss:3, S);
 TextOut(DC, 77, 310, S, StrLen(S));

 {Escaped}
 Rectangle(DC, 133, 310, 174, 329);
 Str(Escaped:3, S);
 TextOut(DC, 133, 310, S, StrLen(S));

 {Total}
 Rectangle(DC, 203, 310, 239, 328);
 Str(Score:3, S);
 TextOut(DC, 203, 310, S, StrLen(S));

 DeleteObject(SelectObject(DC, GetStockObject(White_Brush)));
 SelectObject(DC, GetStockObject(Null_Pen));
 if MadeDC then ReleaseDC(HWindow, DC);
end;

{--------------- TApp ------------------------}

procedure TApp.InitMainWindow;
begin
  MainWindow := New(PGameWindow, Init(nil, 'Swat!'));
end;

{-------------Main Program--------------------}

var
  App: TApp;
begin
  App.Init('SwatGame');
  App.Run;
  App.Done;
end.
