{************************************************}
{                                                }
{   Turbo Vision Chess Demo                      }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit TVChsApp;

interface

uses App, Views, Dialogs, Menus, Objects, Drivers, Dos;

type
  PChessApp = ^TChessApp;
  TChessApp = object(TApplication)
    ConfigFile: PathStr;
    constructor Init;
    destructor Done; virtual;
    procedure ChangeColors;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Idle; virtual;
    procedure InitChessBoard;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure InitDesktop; virtual;
    procedure InitStatusDialog;
    procedure InitScreenMode;
    procedure LoadConfig;
    procedure SaveConfig;
    procedure ShowAbout;
  end;

implementation

uses TVChsCmd, TVStatus, TVBoard, TVPieces, MoveList, TVChsDlg, TVChstat,
  Strings, ColorSel, HistList;

const
  ChessPalettes: array[apColor..apMonochrome] of string[Length(CChessAppColor)] =
    (CChessAppColor, CChessAppBlackWhite, CChessAppMonochrome);

  ConfigSignature : array [0..33] of Char = 'Turbo Vision Chess Configuration'#26#0;
  ConfigName = 'TVCHESS.CFG';

constructor TChessApp.Init;
begin
  inherited Init;
  InitScreenMode;
  LoadConfig;
  InitStatusDialog;
  InitChessBoard;
  if ChessBoard <> nil then Insert(ChessBoard);
  if StatusDialog <> nil then InsertWindow(StatusDialog);
  RegisterType(RMoveList);
end;

destructor TChessApp.Done;
begin
  SaveConfig;
  inherited Done;
end;

procedure TChessApp.ChangeColors;
var
  D: PColorDialog;
  R: TRect;
  P: PView;
  AGroups: PColorGroup;
begin
  AGroups :=
    ColorGroup('Desktop',
      ColorItem('Color',             1, nil),
    ColorGroup('Dialogs',
      ColorItem('Frame/background',  33,
      ColorItem('Frame icons',       34,
      ColorItem('Scroll bar page',   35,
      ColorItem('Scroll bar icons',  36,
      ColorItem('Static text',       37,
      ColorItem('Label normal',      38,
      ColorItem('Label selected',    39,
      ColorItem('Label shortcut',    40,
      ColorItem('Label disabled',     135,
      ColorItem('Button normal',     41,
      ColorItem('Button default',    42,
      ColorItem('Button selected',   43,
      ColorItem('Button disabled',   44,
      ColorItem('Button shortcut',   45,
      ColorItem('Button shadow',     46,
      ColorItem('Cluster normal',    47,
      ColorItem('Cluster selected',  48,
      ColorItem('Cluster shortcut',  49,
      ColorItem('Cluster disabled',  62,
      ColorItem('Input normal',      50,
      ColorItem('Input selected',    51,
      ColorItem('Input arrow',       52,
      ColorItem('Input disabled',    136,
      ColorItem('History button',    53,
      ColorItem('History sides',     54,
      ColorItem('History bar page',  55,
      ColorItem('History bar icons', 56,
      ColorItem('List normal',       57,
      ColorItem('List focused',      58,
      ColorItem('List selected',     59,
      ColorItem('List divider',      60,
      ColorItem('Information pane',  61,
      nil)))))))))))))))))))))))))))))))),
    ColorGroup('Menus',
      ColorItem('Normal',            2,
      ColorItem('Disabled',          3,
      ColorItem('Shortcut',          4,
      ColorItem('Selected',          5,
      ColorItem('Selected disabled', 6,
      ColorItem('Shortcut selected', 7, nil)))))),
    ColorGroup('Board',
      ColorItem('Border',           128,
      ColorItem('Black square',     130,
      ColorItem('White square',     129,
      ColorItem('Black hint',       147,
      ColorItem('White hint',       146, nil))))),
    ColorGroup('Pieces',
      ColorItem('Black piece',      131,
      ColorItem('White piece',      132,
      ColorItem('Black in jeopardy',133,
      ColorItem('White in jeopardy',134, nil)))),
    ColorGroup('Glyph buttons',
      ColorItem('Background',        137,
      ColorItem('Black piece',       139,
      ColorItem('White piece',       138,
      ColorItem('Black selected',    141,
      ColorItem('White selected',    140, nil))))),
    ColorGroup('Status window',
      ColorItem('Frame/background',  97,
      ColorItem('Frame icons',       98,
      ColorItem('Scroll bar page',   99,
      ColorItem('Scroll bar icons',  100,
      ColorItem('Static text',       101,
      ColorItem('List normal',       121,
      ColorItem('List focused',      122,
      ColorItem('List selected',     123,
      ColorItem('List divider',      124,
      ColorItem('Bestline',          142,
      ColorItem('White timer',       143,
      ColorItem('Black timer',       144,
      ColorItem('Game timer',        145, nil))))))))))))),
    nil)))))));

  D := New(PColorDialog, Init('' , AGroups));

  D^.SetData(ChessPalettes[AppPalette]);
  if Application^.ExecView(D) <> cmCancel then
  begin
    D^.GetData(ChessPalettes[AppPalette]);
    Redraw;
    ChessBoard^.Redraw;
  end;

  Dispose(D, Done);
end;


function TChessApp.GetPalette: PPalette;
begin
  GetPalette := @ChessPalettes[AppPalette];
end;

procedure TChessApp.HandleEvent(var Event: TEvent);
var
  D: PDialog;
begin
  inherited HandleEvent(Event);
  case Event.What of
    evCommand:
      case Event.Command of
        cmSettings:
          begin
            D := CreateSettingsDlg;
            D^.SetData(Settings);
            if ExecView(ValidView(D)) <> cmCancel then
              D^.GetData(Settings);
            Dispose(D, Done);
            ClearEvent(Event);
            with ChessBoard^ do
            begin
              ResetValidMoves;
              GameMode := (GameMode and not gmTwoPlay) or Settings.Players;
            end;
          end;
        cmAbout: ShowAbout;
        cmColors: ChangeColors;
      else
        Exit;
      end;
  end;
  ClearEvent(Event);
end;

procedure TChessApp.Idle;
begin
  inherited Idle;
  if ChessBoard <> nil then ChessBoard^.DoThink;
end;

procedure TChessApp.InitChessBoard;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.X := R.B.X - 28;
  ChessBoard := New(PChessBoard, Init(R));
end;

procedure TChessApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  R.A.X := R.B.X - 28;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~G~ame', hcNoContext, NewMenu(
      NewItem('~N~ew', '', kbNoKey, cmNew, hcNoContext,
      NewItem('~L~oad', 'F3', kbF3, cmOpen, hcNoContext,
      NewItem('~S~ave', 'F2', kbF2, cmSave, hcNoContext,
      NewItem('Save ~a~s', '', kbNoKey, cmSaveAs, hcNoContext,
      NewLine(
      NewItem('~R~un demo', '', kbNoKey, cmRunDemo, hcNoContext,
      NewItem('S~t~op', 'Alt+T', kbAltT, cmStop, hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt+X', kbAltX, cmQuit, hcNoContext,
      nil)))))))))),
    NewSubMenu('~M~ove', hcNoContext, NewMenu(
      NewItem('~U~ndo', 'Alt+Bksp', kbAltBack, cmUndo, hcNoContext,
      NewItem('~R~edo', 'Ctrl+Bksp', kbCtrlBack, cmRedo, hcNoContext,
      NewLine(
      NewItem('~C~omputer move', 'Alt+C', kbAltC, cmComputerMove, hcNoContext,
      NewItem('~E~nter move...', 'Alt+E', kbAltE, cmEnterMove, hcNoContext,
      NewItem('~S~how hint', 'Alt+S', kbAltS, cmShowHint, hcNoContext,
      nil))))))),
    NewSubMenu('~O~ptions', hcNoContext, NewMenu(
      NewItem('~S~ettings', '', kbNoKey, cmSettings, hcNoContext,
      NewItem('~C~olors', '', kbNoKey, cmColors, hcNoContext,
      nil))),
    NewSubMenu('~H~elp', hcNoContext, NewMenu(
      NewItem('~A~bout', '', kbNoKey, cmAbout, hcNoContext,
      nil)), nil)))))));
end;

procedure TChessApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  R.A.X := R.B.X - 28;
  StatusLine := New(PChessStatusLine, Init(R,
    NewStatusDef($0, $FFFF,
      StdStatusKeys(nil), nil)));
end;

procedure TChessApp.InitDesktop;
var
  R: TRect;
begin
  GetExtent(R);
  R.Grow(0, -1);
  R.A.X := R.B.X - 28;
  Desktop := New(PDesktop, Init(R));
end;

procedure TChessApp.InitStatusDialog;
var
  R: TRect;
begin
  R.Assign(0, 0, Desktop^.Size.X, Size.Y - 2);
  StatusDialog := New(PStatusDialog, Init(R));
end;

procedure TChessApp.InitScreenMode;
begin
  ShadowSize.X := 2;
  SetScreenMode(ScreenMode and (not smFont8x8));
end;

procedure TChessApp.LoadConfig;
var
  S: PBufStream;
  CfgName: PathStr;
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
  Test: array [0..SizeOf(ConfigSignature)] of Char;
  NSettings: TSettings;
  TempPalettes: array[apColor..apMonochrome] of
    String[Length(CChessAppColor)];
  I: Integer;
begin
  Dir := '';
  CfgName := ParamStr(0);
  if CfgName = '' then CfgName := FSearch('TVCHESS.EXE', GetEnv('PATH'));
  if CfgName <> '' then
    FSplit(CfgName, Dir, Name, Ext);
  CfgName := Dir + ConfigName;
  S := New(PBufStream, Init(CfgName, stOpenRead, 1024));
  if S^.Status = stOK then
  begin
    S^.Read(Test, SizeOf(ConfigSignature));
    if (S^.Status = stOK) and
      (StrLComp(ConfigSignature, Test, SizeOf(ConfigSignature)) = 0) then
    begin
      S^.Read(NSettings, SizeOf(NSettings));
      S^.Read(TempPalettes, SizeOf(TempPalettes));
      LoadIndexes(S^);
      LoadHistory(S^);
      if S^.Status = stOK then
      begin
        Settings := NSettings;
        ConfigFile := CfgName;
        for I := apColor to apMonochrome do
          ChessPalettes[I] := TempPalettes[I];
      end;
    end;
  end;
  Dispose(S, Done);
end;

procedure TChessApp.SaveConfig;
var
  S: PBufStream;
begin
  if ConfigFile = '' then ConfigFile := ConfigName;
  S := New(PBufStream, Init(ConfigFile, stCreate, 1024));
  S^.Write(ConfigSignature, SizeOf(ConfigSignature));
  S^.Write(Settings, SizeOf(Settings));
  S^.Write(ChessPalettes, SizeOf(ChessPalettes));
  StoreIndexes(S^);
  StoreHistory(S^);
  Dispose(S, Done);
end;

procedure TChessApp.ShowAbout;
var
  D: PDialog;
  R: TRect;
  Control: PView;
begin
  R.Assign(21, 0, 58, 11);
  D := New(PDialog, Init(R, 'About'));
  with D^ do
  begin
    Options := Options or ofCentered;

    R.Assign(1, 2, Size.X - 1, 3);
    Insert(New(PStaticText, Init(R, ^C'Turbo Vision Chess Demo')));

    Inc(R.A.Y, 2); Inc(R.B.Y, 2);
    Insert(New(PStaticText, Init(R, ^C'Copyright (c) 1992 by')));

    Inc(R.A.Y, 2); Inc(R.B.Y, 2);
    Insert(New(PStaticText, Init(R, ^C'Borland International, Inc.')));

    R.Assign(13, 8, 23, 10);
    Insert(New(PButton, Init(R, 'O~K~',cmOk, bfNormal)));
  end;

  Application^.ExecView(D);
  Dispose(D, Done);
end;

end.
