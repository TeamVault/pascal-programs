{************************************************}
{                                                }
{   ObjectWindows Grep Demo                      }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ The grep text search programs consist of 3 binary files:

    OWLGREP.EXE   - Windows grep program (uses ObjectWindows)
    TVGREP.EXE    - DOS text mode grep program (uses Turbo Vision)
    REGEXP.DLL    - Text search engine dynamic link library (DLL)
                    that is written in Borland C++ 3.1 and
                    shared by both TVGREP.EXE and OWLGREP.EXE

  OWLGREP is a Windows application. To build it, set Compile|Target to
  Windows from inside the IDE or type the following command-line at a
  DOS prompt:

    bpc /m /cw owlgrep

  TVGREP is a DOS protected mode application (DPMI). To build
  it, set Compile|Target to Protected from inside the IDE or type the
  following command-line at a DOS prompt:

    bpc /m /cp tvgrep

  REGEXP.DLL is a Windows format DLL and comes already built. To rebuild
  it, make sure Borland C++ 3.1 is on your DOS path, change to the
  \BP\EXAMPLES\GREP\DLL directory and then run MAKE.

}

program OwlGrep;

{$M 20000,8192}

uses Strings, WinCrt, WinDos, WinProcs, WinTypes, Objects,
  OWindows, ODialogs, RegExp, OGConst;

{$R OwlGrep}

const
  Profile = 'OWLGREP.INI';

const
  wm_GetPrivateStrings = wm_User;


  rgb_Yellow      = $0000FFFF;
  rgb_DarkYellow  = $0000C1FF;
  rgb_Blue        = $00FF0000;
  rgb_Red         = $000000FF;
  rgb_Green       = $0000FF00;
  rgb_DarkGreen   = $00007F00;

type
  TRequest = record
    Expression: array[0..80] of Char;
    FileMask: array[0..40] of Char;
    StartDir: array[0..128] of Char;
    CaseSensitive,
    UseSubDirs: Boolean;
  end;

  PGrep = ^TGrep;
  TGrep = object(TDlgWindow)
    BoxBrush,
    TheBrush: HBrush;
    FileList: PListBox;
    CaseCheck,
    SubDirCheck: PCheckBox;
    StatusText: PStatic;
    FileMask,
    Directory,
    Expression: PEdit;
    FileColl: PStrCollection;
    constructor Init(P: PWindowsObject; N: PChar);
    procedure InitControls;
    destructor Done; virtual;
    procedure SetupWindow; virtual;
    procedure GetWindowClass(var WndClass: TWndClass); virtual;
    function GetClassName: PChar; virtual;
    function RunSearch: Boolean;
    procedure FillBox;
    procedure GetControlData;
    procedure SetControlData;
    procedure ReadProfile;
    procedure WriteProfile;
    procedure ListClick(var Msg: TMessage);
      virtual id_First + idFileList;
    procedure BeginSearch(var Msg: TMessage);
      virtual id_First + idBeginSearch;
    procedure WMControlColor(var Msg: TMessage);
      virtual wm_First + wm_CtlColor;
  end;

  TWhereApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

var
  Request: TRequest;

procedure ACenterDlg(HWindow: HWnd);
var
  R: TRect;
  StartX,
  StartY : Integer;
  Frame,
  Caption: Integer;
begin
  Frame := GetSystemMetrics(sm_CxFrame) * 2;
  Caption := GetSystemMetrics(sm_CyCaption);
  GetClientRect(HWindow, R);
  StartX := ((GetSystemMetrics(sm_CxScreen) - (R.Right - R.Left)) div 2);
  StartY := ((GetSystemMetrics(sm_CyScreen) - (R.Bottom - R.Top)) div 2);
  MoveWindow(HWindow, StartX, StartY - ((Caption + Frame) div 2),
    R.Right + Frame, R.Bottom + Frame + Caption, False);
end;

{ TGrep }

constructor TGrep.Init(P: PWindowsObject; N: PChar);
begin
  inherited Init(P, N);
  InitControls;
  FileColl := nil;
end;

procedure TGrep.InitControls;
var
  LogBrush: TLogBrush;
begin
  FileList := New(PListBox, InitResource(@Self, idFileList));
  Directory := New(PEdit, InitResource(@Self, idDirectory, 80));
  FileMask := New(PEdit, InitResource(@Self, idFileMask, 80));
  Expression := New(PEdit, InitResource(@Self, idExpression, 80));

  StatusText := New(PStatic, InitResource(@Self, idStatus,80));

  CaseCheck := New(PCheckBox, InitResource(@Self, idCaseSensitive));
  SubDirCheck := New(PCheckBox, InitResource(@Self, idRecurseDirs));

  LogBrush.lbStyle := bs_Solid;
  LogBrush.lbColor := RGB(128,128,128);
  LogBrush.lbHatch := bs_Solid;
  TheBrush  := CreateBrushIndirect(LogBrush);

  LogBrush.lbStyle := bs_Solid;
  LogBrush.lbColor := RGB(0,0,64);
  LogBrush.lbHatch := bs_Solid;
  BoxBrush := CreateBrushIndirect(LogBrush);
end;

destructor TGrep.Done;
begin
  WriteProfile;
  DeleteObject(TheBrush);
  DeleteObject(BoxBrush);
  inherited Done;
end;

function TGrep.RunSearch: Boolean;
var
  RegExp: HRegExp;
  Error: Integer;
  P: PChar;

  function Search(Filename: PChar): Boolean;
  var
    TextFile: Text;
    Line: array[0..255] of Char;
    Match: TRegMatch;
  begin
    Search := False;
    StatusText^.SetText(Filename);
    Assign(TextFile, Filename);
    {$I-}
    Reset(TextFile);
    while not Eof(TextFile) do
    begin
      Readln(TextFile, Line);
      if not Request.CaseSensitive then StrUpper(Line);
      if RegExec(RegExp, Line, Match) = 0 then
      begin
        Search := True;
        Break;
      end;
    end;
    Close(TextFile);
  end;

  procedure SearchDir(Dir: PChar);
  var
    SR: TSearchRec;
    NewDir: array[0..255] of Char;
  begin
    with Request do
    begin
      StrCopy(StrECopy(NewDir, Dir), FileMask);
      FindFirst(NewDir, faArchive, SR);
      while DosError = 0 do
      begin
        StrCopy(StrECopy(NewDir, Dir), SR.Name);
        if Search(NewDir) then
          FileColl^.Insert(StrNew(NewDir));
        FindNext(SR);
      end;

      if Request.UseSubDirs then
      begin
        StrCopy(StrECopy(NewDir, Dir), '*.*');
        FindFirst(NewDir, faDirectory, SR);
        while DosError = 0 do
        begin
          if (SR.Attr and faDirectory <> 0) and (SR.Name[0] <> '.') then
          begin
            StrCopy(StrECopy(StrECopy(NewDir, Dir), SR.Name), '\'); 
            SearchDir(NewDir);
          end;
          FindNext(SR);
        end;
      end;
    end;
  end;

  procedure CompileExp;
  var
    Exp: array[0..SizeOf(Request.Expression)] of Char;
  begin
    StrCopy(Exp, Request.Expression);
    if not Request.CaseSensitive then StrUpper(Exp);
    RegExp := RegComp(Exp, Error);
  end;
    
begin
  CompileExp;
  with Request do
  begin
    P := StrEnd(Request.StartDir);

    { Force a trailing back-slash }
    if ((P - StartDir > 2) or (StartDir[1] <> ':')) and
        ((P - 1)^ <> '\') then
      StrCopy(P, '\');
  end;
  SearchDir(Request.StartDir);
  P^ := #0; { Undo the backslash }

  RegFree(RegExp);
end;

procedure TGrep.ReadProfile;
begin
  GetPrivateProfileString('OwlGrep', 'Expression', '',
    Request.Expression, SizeOf(Request.Expression), Profile);
  GetPrivateProfileString('OwlGrep','FileMask','*.PAS',
    Request.FileMask, SizeOf(Request.FileMask), Profile);
  GetCurDir(Request.StartDir, 0);

  Request.CaseSensitive := Bool(GetPrivateProfileInt('OwlGrep',
    'CaseSensitive', 1, Profile));
  Request.UseSubDirs := Bool(GetPrivateProfileInt('OwlGrep',
    'SubDirs', 1, Profile));
end;

procedure TGrep.WriteProfile;
var
  S: array[0..10] of Char;
begin
  WritePrivateProfileString('OwlGrep', 'Expression', Request.Expression,
    Profile);
  WritePrivateProfileString('OwlGrep', 'FileMask', Request.FileMask,
    Profile);

  Str(Integer(Request.CaseSensitive), S);
  WritePrivateProfileString('OwlGrep', 'CaseSensitive', S, Profile);
  Str(Integer(Request.UseSubDirs), S);
  WritePrivateProfileString('OwlGrep', 'SubDirs', S, Profile);
end;

procedure TGrep.SetControlData;
begin
  Expression^.SetText(Request.Expression);
  FileMask^.SetText(Request.FileMask);
  Directory^.SetText(Request.StartDir);

  CaseCheck^.SetCheck(Integer(Request.CaseSensitive));
  SubDirCheck^.SetCheck(Integer(Request.UseSubDirs));
end;

procedure TGrep.GetControlData;
begin
  Expression^.GetText(Request.Expression, SizeOf(Request.Expression));
  FileMask^.GetText(Request.FileMask, SizeOf(Request.FileMask));
  Directory^.GetText(Request.StartDir, SizeOf(Request.StartDir) - 1);

  Request.CaseSensitive := CaseCheck^.GetCheck = 1;
  Request.UseSubDirs := SubDirCheck^.GetCheck = 1;
end;

procedure TGrep.SetupWindow;
var
  Msg: TMessage;
begin
  inherited SetUpWindow;

  ACenterDlg(HWindow);
  ReadProfile;
  SetControlData;
end;

procedure TGrep.WMControlColor(var Msg: TMessage);
begin
  case Msg.LParamHi of
    ctlColor_Btn:
      begin
        SetTextColor(Msg.WParam, Rgb_Blue);
        SetBkMode(Msg.WParam, transparent);
        Msg.Result := TheBrush;
      end;
    ctlColor_Static:
      begin
        SetTextColor(Msg.WParam, Rgb_Blue);
        SetBkMode(Msg.WParam, transparent);
        Msg.Result := TheBrush;
      end;
    ctlColor_ListBox, ctlColor_Edit:
      begin
        SetTextColor(Msg.WParam, Rgb_DarkYellow);
        SetBkMode(Msg.WParam, transparent);
        Msg.Result := BoxBrush;
      end;
    ctlcolor_Dlg:
      begin
        SetBkMode(Msg.WParam, Transparent);
        Msg.Result := TheBrush;
      end;
  else
    DefWndProc(Msg);
  end;
end;

procedure TGrep.FillBox;
var
  i: Integer;
begin
  FileList^.ClearList;
  if FileColl = nil then Exit;
  for i := 0 to FileColl^.Count - 1 do
    FileList^.AddString(FileColl^.At(i));
end;

procedure TGrep.ListClick(var Msg: TMessage);
var
  Choice: Integer;
  Selection: PChar;
  Cmd: array[0..300] of Char;
begin
  if Msg.LParamHi = lbn_DblClk then
  begin
    Choice := FileList^.GetSelIndex;
    Selection := FileColl^.At(Choice);
    StrCopy(StrECopy(Cmd, 'NotePad.Exe '), Selection);
    WinExec(Cmd, sw_ShowNormal);
  end;
end;

procedure TGrep.BeginSearch(var Msg: TMessage);
var
  S: array[0..255] of Char;

  function DirOk(StartDir: PChar): Boolean;
  var
    P: PChar;
  begin
    StrUpper(StartDir);
    { Strip trailing backslash }
    SetCurDir(StartDir);
    if (DosError <> 0) or (StrLen(StartDir) = 0) then
    begin
      StrCopy(StrECopy(S, 'Could not find directory: '), StartDir);
      MessageBox(HWindow, S, 'Notice',mb_Ok);
      SetFocus(Directory^.HWindow);
      DirOk := False;
    end;
  end;

  function FileMaskOk(Mask: PChar): Boolean;
  begin
    if Mask[0] = #0 then
    begin
      FileMaskOk := False;
      MessageBox(HWindow, 'You must provide a file mask. For Instance: *.*',
        'Notice', mb_Ok);
      SetFocus(FileMask^.HWindow);
    end
    else FileMaskOk := True;
  end;

  function KeyOk(SrchStr: PChar): Boolean;
  var
    RegExp: HRegExp;
    Error: Integer;
    P: PChar;
  begin
    P := nil;
    if SrchStr[0] = #0 then
      P := 'Search Key can''t be empty'
    else
    begin
      RegExp := RegComp(SrchStr, Error);
      if RegExp = 0 then
        P := 'Invalid regular expression'
      else
        RegFree(RegExp);
    end;

    if P <> nil then
    begin
      KeyOk := False;
      MessageBox(HWindow, P, 'Notice', mb_Ok);
      SetFocus(Expression^.HWindow);
    end
    else
      KeyOk := True;
  end;

begin
  if FileColl <> nil then Dispose(FileColl, Done);
  FileColl := New(PStrCollection, Init(100, 50));
  GetControlData;
  if not DirOk(Request.StartDir) then Exit;
  if not FileMaskOk(Request.FileMask) then Exit;
  if not KeyOk(Request.Expression) then Exit;
  SetControlData;

  StatusText^.SetText('Searching...');
  RunSearch;
  FillBox;
  WVSPrintF(S, 'Number found: %d', FileColl^.Count);
  StatusText^.SetText(S);
end;

procedure TGrep.GetWindowClass(var WndClass: TWndClass);
begin
  inherited GetWindowClass(WndClass);
  WndClass.hIcon := LoadIcon(hInstance,'WhereIcon');
end;

function TGrep.GetClassName : PChar;
begin
  GetClassName := 'TGrep';
end;

{ TWhereApp }

procedure TWhereApp.InitMainWindow;
begin
  MainWindow := New(PGrep, Init(nil, 'GrepDlg'));
end;

var
  WhereApp: TWhereApp;

begin
  WhereApp.Init('Search');
  WhereApp.Run;
  WhereApp.Done;
end.
