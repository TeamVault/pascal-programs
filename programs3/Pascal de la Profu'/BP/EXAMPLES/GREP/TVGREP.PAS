{************************************************}
{                                                }
{   Turbo Vision Grep Demo                       }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ The grep text search programs consist of 3 binary files:

    TVGREP.EXE    - DOS text mode grep program (uses Turbo Vision)
    OWLGREP.EXE   - Windows grep program (uses ObjectWindows)
    REGEXP.DLL    - Text search engine dynamic link library (DLL)
                    that is written in Borland C++ 3.1 and
                    shared by both TVGREP.EXE and OWLGREP.EXE

  IMPORTANT NOTE: If you use the IDE to build this program, make sure
  to change to the \BP\EXAMPLES\GREP directory before doing a compile.

  TVGREP is a DOS protected mode application (DPMI). To build
  it, set Compile|Target to Protected from inside the IDE or type the
  following command-line at a DOS prompt:

    bpc /m /cp tvgrep

  OWLGREP is a Windows application. To build it, set Compile|Target to
  Windows from inside the IDE or type the following command-line at a
  DOS prompt:

    bpc /m /cw owlgrep

  REGEXP.DLL is a Windows format DLL and comes already built. To rebuild
  it, make sure Borland C++ 3.1 is on your DOS path, change to the
  \BP\EXAMPLES\GREP\DLL directory and then run MAKE.

}

program TVGrep;

{$V-}

{$IFNDEF DPMI}
   This example requires the target to be protected mode.
{$ENDIF}

uses Dos, Strings, Objects, Drivers, Memory, Views, Menus, Dialogs, App,
  MsgBox, GrepDlg, Regexp;

{ If you get a FILE NOT FOUND error when compiling this program
  from a DOS IDE, change to the \BP\EXAMPLES\GREP directory
  (use File|Change dir).

  This will enable the compiler to find all of the units used by
  this program.
}

const
  cmFindNext = 100;
  cmFindPrev = 101;

  cmAbout = 1000;
  cmView  = 1001;
  cmStart = 1002;

const
  cmUpdateStatus = 2000;
  cmCloseResult  = 2001;

const
  hcSearchWindow = 10;

type
  PStatusView = ^TStatusView;
  TStatusView = object(TView)
    Message: String;
    CurrentFile: PathStr;
    constructor Init(var Bounds: TRect; const AMessage: String);
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  PStatusWindow = ^TStatusWindow;
  TStatusWindow = object(TWindow)
    constructor Init(const Message: String);
  end;

  PResultViewer = ^TResultViewer;
  TResultViewer = object(TListViewer)
    Results: PStringCollection;
    constructor Init(var Bounds: TRect; ScrollBar: PScrollBar;
      AResults: PStringCollection);
    destructor Done; virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    procedure SelectItem(Item: Integer); virtual;
  end;

  PResultDialog = ^TResultDialog;
  TResultDialog = object(TDialog)
    Request: TRequest;
    FileList: PResultViewer;
    constructor Init(const ARequest: TRequest; Results: PStringCollection);
    destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  PLine = ^TLine;
  TLine = object(TObject)
    Line: PChar;
    Hits: TRegMatch;
    constructor Init(ALine: PChar; Regex: HRegexp; CaseSensitive: Boolean);
    destructor Done; virtual;
  end;

  PSearchViewer = ^TSearchViewer;
  TSearchViewer = object(TScroller)
    Lines: PCollection;
    IsValid: Boolean;
    Cur: Integer;
    NumFinds: Integer;
    constructor Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PScrollBar;
      var AFileName: PathStr; const Request: TRequest);
    destructor Done; virtual;
    procedure CenterFind;
    procedure Draw; virtual;
    procedure FindNext;
    procedure FindPrev;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure ReadFile(var FName: PathStr; Regex: HRegexp;
      CaseSensitive: Boolean);
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure UpdateCommands;
    function Valid(Command: Word): Boolean; virtual;
  end;

  PSearchWindow = ^TSearchWindow;
  TSearchWindow = object(TWindow)
    ResultDlg: PResultDialog;
    constructor Init(var Bounds: TRect; var AFilename: PathStr;
      var Request: TRequest; AResultDlg: PResultDialog);
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  TSearch = object(TApplication)
    Request: TRequest;
    constructor Init;
    procedure DoSearch;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Idle; virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure GetRequest;
  end;

{ TStatusView }

constructor TStatusView.Init(var Bounds: TRect; const AMessage: String);
begin
  inherited Init(Bounds);
  CurrentFile := '';
  Message := AMessage;
  EventMask := EventMask or evBroadcast;
end;

procedure TStatusView.Draw;
var
  S: String;
  B: TDrawBuffer;
  Color: Byte;
  J: Integer;
begin
  Color := GetColor(6);
  S := Message + CurrentFile;
  MoveChar(B, ' ', Color, Size.X);
  J := (Size.X - Length(S)) div 2;
  if J < 0 then J := 0;
  MoveStr(B, S, Color);
  WriteLine(0, 0, Size.X, Size.Y, B);
end;

procedure TStatusView.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  case Event.What of
    evBroadcast:
      case Event.Command of
        cmUpdateStatus:
          begin
            CurrentFile := PString(Event.InfoPtr)^;
            DrawView;
          end;
      end;
  end;
end;

{ TStatusWindow }

constructor TStatusWindow.Init(const Message: String);
var
  Bounds: TRect;
begin
  Bounds.Assign(0, 0, 60, 5);
  inherited Init(Bounds, 'Status', wnNoNumber);
  Options := Options or ofCentered;
  Flags := 0;
  Bounds.Assign(2, 2, 58, 3);
  Insert(New(PStatusView, Init(Bounds, Message)));
end;

{ TResultViewer }

constructor TResultViewer.Init(var Bounds: TRect; ScrollBar: PScrollBar;
  AResults: PStringCollection);
begin
  inherited Init(Bounds, 1, nil, ScrollBar);
  Results := AResults;
  SetRange(Results^.Count);
end;

destructor TResultViewer.Done;
begin
  inherited Done;
  Dispose(Results, Done);
end;

function TResultViewer.GetText(Item: Integer; MaxLen: Integer): String;
begin
  GetText := PString(Results^.At(Item))^
end;

procedure TResultViewer.SelectItem(Item: Integer);
var
  Event: TEvent;
begin
  Event.What := evCommand;
  Event.Command := cmView;
  PutEvent(Event);
end;

{ TResultDialog }

constructor TResultDialog.Init(const ARequest: TRequest;
  Results: PStringCollection);
var
  R: TRect;
  C: PView;
  S: PScrollBar;
begin
  R.Assign(0, 0, 50, 17);
  inherited Init(R, 'Search Results');
  Options := Options or ofCentered;
  Palette := dpBlueDialog;
  Request := ARequest;

  R.Assign(1, 1, 49, 4);
  C := New(PStaticText, Init(R, ''));
  with C^ do Options := Options or ofFramed;
  Insert(C);

  R.Assign(3, 1, 48, 2);
  Insert(New(PStaticText, Init(R, 'Expression: ' + ARequest.Expression)));

  R.Move(0, 1);
  Insert(New(PStaticText, Init(R, 'File mask:  ' + ARequest.FileMask)));

  R.Move(0, 1);
  Insert(New(PStaticText, Init(R, 'Directory:  ' + ARequest.StartDir)));

  R.Assign(46, 7, 47, 13);
  S := New(PScrollBar, Init(R));
  Insert(S);

  R.Assign(3, 7, 46, 13);
  FileList := New(PResultViewer, Init(R, S, Results));
  Insert(FileList);

  R.Assign(2, 6, 8, 7);
  Insert(New(PLabel, Init(R, '~F~iles', FileList)));

  R.Assign(37, 14, 47, 16);
  Insert(New(PButton, Init(R, '~V~iew', cmView, bfDefault)));
  SelectNext(False);
end;

destructor TResultDialog.Done;
begin
  Message(Desktop, evBroadcast, cmCloseResult, @Self);
  inherited Done;
end;

procedure TResultDialog.HandleEvent(var Event: TEvent);
var
  R: TRect;
begin
  inherited HandleEvent(Event);
  case Event.What of
    evCommand:
      case Event.Command of
        cmView:
          begin
            Desktop^.GetExtent(R);
            if FileLIst^.Results^.Count > 0 then
              Application^.InsertWindow(New(PSearchWindow,
                Init(R, PString(FileList^.Results^.At(FileList^.Focused))^,
                  Request, @Self)));
            ClearEvent(Event);
          end;
      end;
  end;
end;

{ TLine }

constructor TLine.Init(ALine: PChar; Regex: HRegexp; CaseSensitive: Boolean);
begin
  inherited Init;
  Line := StrNew(ALine);

  if not CaseSensitive then StrUpper(ALine);
  if RegExec(Regex, ALine, Hits) <> 0 then
    FillChar(Hits, SizeOf(Hits), $FF);
end;

destructor TLine.Done;
begin
  StrDispose(Line);
end;

{ TSearchViewer }

constructor TSearchViewer.Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PScrollBar;
  var AFileName: PathStr; const Request: TRequest);
var
  Exp: array[0..255] of Char;
  Regex: HRegexp;
  Error: Integer;

  procedure DoCount(P: PLine); far;
  begin
    if P^.Hits.Start <> $FFFF then Inc(NumFinds);
  end;

begin
  inherited Init(Bounds, AHScrollBar, AVScrollBar);
  GrowMode := gfGrowHiX + gfGrowHiY;
  Lines := New(PCollection, Init(10, 10));
  IsValid := True;

  StrPCopy(Exp, Request.Expression);
  if Request.Options and roCase = 0 then StrUpper(Exp);
  Regex := RegComp(Exp, Error);
  ReadFile(AFileName, Regex, Request.Options and roCase <> 0);
  RegFree(Regex);

  Lines^.ForEach(@DoCount);
  Cur := 1;
end;

destructor TSearchViewer.Done;
begin
  inherited Done;
  Dispose(Lines, Done);
end;

procedure TSearchViewer.CenterFind;
var
  CurFind: Integer;
  Line: Integer;

  function IsFind(P: PLine): Boolean; far;
  begin
    Inc(Line);
    if P^.Hits.Start <> $FFFF then Dec(CurFind);
    IsFind := CurFind = 0;
  end;

begin
  CurFind := Cur;
  Line := 0;
  Lines^.FirstThat(@IsFind);
  { Center on the screen }
  Line := Line - Size.Y div 2;
  if Line < 0 then Line := 0;
  if Line > Limit.Y then Line := Limit.Y - Size.Y;
  ScrollTo(0, Line);
end;

procedure TSearchViewer.Draw;
var
  B: TDrawBuffer;
  C: Word;
  I, J: Integer;
  S: String;
  P: PLine;
  HitBeg, HitEnd: Word;
begin
  C := GetColor($0201);
  for I := 0 to Size.Y - 1 do
  begin
    MoveChar(B, ' ', C, Size.X);
    HitBeg := $FFFF;
    if Delta.Y + I < Lines^.Count then
    begin
      P := Lines^.At(Delta.Y + I);
      S := '';
      if (P <> nil) and (P^.Line <> nil) then
        with P^ do
        begin
          if StrLen(Line) > Delta.X then
          begin
            S := StrPas(@Line[Delta.X]);
            if Hits.Start <> $FFFF then
            begin
              if Hits.Stop > Delta.X then
              begin
                HitEnd := Hits.Stop - Delta.X - 1;
                if Hits.Start < Delta.X then
                  HitBeg := 0;
              end;
              if Hits.Start >= Delta.X then
                HitBeg := Hits.Start - Delta.X;
            end;
          end;
        end;
      MoveStr(B, S, C);
      if HitBeg <> $FFFF then
        for J := HitBeg to HitEnd do
          WordRec(B[J]).Hi := WordRec(C).Hi;
    end;
    WriteLine(0, I, Size.X, 1, B);
  end;
end;

procedure TSearchViewer.FindNext;
begin
  if Cur < NumFinds then Inc(Cur);
  CenterFind;
  UpdateCommands;
end;

procedure TSearchViewer.FindPrev;
begin
  if Cur > 1 then Dec(Cur);
  CenterFind;
  UpdateCommands;
end;

procedure TSearchViewer.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  case Event.What of
    evCommand:
      case Event.Command of
        cmFindPrev: FindPrev;
        cmFindNext: FindNext;
      end;
  end;
end;

procedure TSearchViewer.ReadFile(var FName: PathStr; Regex: HRegexp;
  CaseSensitive: Boolean);
var
  FileToSearch: Text;
  Line: array[0..255] of Char;
  MaxWidth: Integer;
  E: TEvent;
  W: PWindow;
begin
  IsValid := True;

  {$I-}
  Assign(FileToSearch, FName);
  Reset(FileToSearch);
  if IOResult <> 0 then
  begin
    MessageBox('Cannot open file ' + FName + '.', nil, mfError + mfOkButton);
    IsValid := False;
  end
  else
  begin
    W := Application^.InsertWindow(New(PStatusWindow, Init('Loading: ')));
    Message(W, evBroadcast, cmUpdateStatus, @FName);
    MaxWidth := 0;
    while not Eof(FileToSearch) and not LowMemory do
    begin
      Readln(FileToSearch, Line);
      if StrLen(Line) > MaxWidth then MaxWidth := StrLen(Line);
      Lines^.Insert(New(PLine, Init(Line, Regex, CaseSensitive)));
    end;
    Close(FileToSearch);
    Dispose(W, Done);
  end;
  {$I+}
  SetLimit(MaxWidth, Lines^.Count);
end;

procedure TSearchViewer.SetState(AState: Word; Enable: Boolean);
begin
  inherited SetState(AState, Enable);
  case AState of
    sfActive: UpdateCommands;
    sfExposed:
      if Enable then CenterFind;
  end;
end;

procedure TSearchViewer.UpdateCommands;
begin
  SetCmdState([cmFindNext], (State and sfActive <> 0) and (Cur < NumFinds));
  SetCmdState([cmFindPrev], (State and sfActive <> 0) and (Cur > 1));
end;

function TSearchViewer.Valid(Command: Word): Boolean;
begin
  Valid := IsValid;
end;

{ TSearchWindow }

constructor TSearchWindow.Init(var Bounds: TRect; var AFilename: PathStr;
  var Request: TRequest; AResultDlg: PResultDialog);
var
  C: PView;
  S: PScrollBar;
  R, R1: TRect;
begin
  inherited Init(Bounds, AFilename, wnNoNumber);
  ResultDlg := AResultDlg;
  Options := Options or ofTileable;
  HelpCtx := hcSearchWindow;

{  HelpCtx := hcSearchWindow;}

  GetExtent(R);
  R.Grow(-1, -1);
  R.B.Y := R.A.Y + 1;
  C := New(PStaticText, Init(R, 'Expression: ' + Request.Expression));
  with C^ do
  begin
    Options := Options or ofFramed;
    GrowMode := gfGrowHiX;
  end;
  Insert(C);

  GetExtent(R);
  R.Grow(-1, -2);
  R.Move(0, 1);
  R1.Assign(R.B.X, R.A.Y, R.B.X + 1, R.B.Y);
  S := New(PScrollBar, Init(R1));
  with S^ do Options := Options or ofPostProcess;
  Insert(S);
  Insert(New(PSearchViewer, Init(R,
    StandardScrollBar(sbHorizontal + sbHandleKeyboard), S, AFilename,
      Request)));
end;

procedure TSearchWindow.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  case Event.What of
    evBroadcast:
      case Event.Command of
        cmCloseResult:
          if Event.InfoPtr = ResultDlg then Close;
      end;
  end;
end;

{ TSearch }

constructor TSearch.Init;
var
  Event: TEvent;
  R: TRect;
begin
  inherited Init;

  with Request do
  begin
    Expression := '';
    FileMask := '*.PAS';
    GetDir(0, StartDir);
    Options := $00;
  end;

  Event.What := evCommand;
  Event.Command := cmStart;
  PutEvent(Event);
end;

procedure TSearch.DoSearch;
var
  Result: PStringCollection;
  Exp: array[0..255] of Char;
  W: PWindow;
  Regex: HRegexp;
  Error: Integer;

  function Search(const Filename: String): Boolean;
  var
    TextFile: Text;
    Line: array[0..255] of Char;
    Match: TRegMatch;
  begin
    Search := False;
    Message(Desktop, evBroadcast, cmUpdateStatus, @Filename);
    Assign(TextFile, Filename);
    {$I-}
    Reset(TextFile);
    while not Eof(TextFile) do
    begin
      Readln(TextFile, Line);
      if Request.Options and roCase = 0 then StrUpper(Line);
      if RegExec(Regex, Line, Match) = 0 then
      begin
        Search := True;
        Break;
      end;
    end;
    Close(TextFile);
  end;

  procedure SearchDir(const Dir: PathStr);
  var
    SR: SearchRec;
  begin
    with Request do
    begin
      FindFirst(Dir + FileMask, Archive, SR);
      while DosError = 0 do
      begin
        if Search(Dir + SR.Name) then
          Result^.Insert(NewStr(Dir + SR.Name));
        FindNext(SR);
      end;

      if Request.Options and roSubDir <> 0 then
      begin
        FindFirst(Dir + '*.*', Directory, SR);
        while DosError = 0 do
        begin
          if (SR.Attr and Directory <> 0) and (SR.Name[1] <> '.') then
            SearchDir(Dir + SR.Name + '\');
          FindNext(SR);
        end;
      end;
    end;
  end;

begin
  W := InsertWindow(New(PStatusWindow, Init('Searching: ')));

  if W <> nil then
  begin
    Result := New(PStringCollection, Init(5, 5));

    StrPCopy(Exp, Request.Expression);
    if Request.Options and roCase = 0 then StrUpper(Exp);

    Regex := RegComp(Exp, Error);
    SearchDir(Request.StartDir);
    Dispose(W, Done);
    RegFree(Regex);

    InsertWindow(New(PResultDialog, Init(Request, Result)));
  end;
end;

procedure TSearch.Idle;

  function IsTileable(P: PView): Boolean; far;
  begin
    IsTileable := P^.Options and ofTileable <> 0;
  end;

begin
  inherited Idle;
  if Desktop^.FirstThat(@IsTileable) <> nil then
    EnableCommands([cmTile, cmCascade, cmCloseAll])
  else
    DisableCommands([cmTile, cmCascade, cmCloseAll]);
end;

procedure TSearch.HandleEvent(var Event: TEvent);

  procedure About;
  var
    D: PDialog;
    R: TRect;
  begin
    R.Assign(0, 0, 50, 9);
    D := New(PDialog, Init(R, 'About'));
    with D^ do begin
      Options := Options or ofCentered;
      R.Grow(-1, -1);
      Dec(R.B.Y, 3);
      Insert(New(PStaticText, Init(R,
        #13 +
        ^C'TVGrep' + #13 +
        ^C'A Text Search Program' + #13 +
        ^C'Copyright (c) 1992 Borland International'
        )));
      R.Assign(20, 6, 30, 8);
      Insert(New(PButton, Init(R, 'O~K', cmOk, bfDefault)));
    end;

    ExecuteDialog(D, nil);
  end;


begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmStart: GetRequest;
      cmAbout: About;
      {cmViewFile: FileView(Event.InfoPtr);}
    else
      Exit;
    end;
    ClearEvent(Event);
  end;
end;

procedure TSearch.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
      NewItem('~S~tart grep...', 'F9', kbF9, cmStart, {hcGrepDialog}0,
      NewLine(
      NewItem('E~x~it', 'Alt+X', kbAltX, cmQuit, hcNoContext,
      nil)))),
    NewSubMenu('~W~indows', {hcWindows} 0, NewMenu(
      StdWindowMenuItems(nil)),
    NewSubMenu('~H~elp', {hcSystem} 0, NewMenu(
      NewItem('~A~bout', '', kbNoKey, cmAbout, {hcSAbout} 0,
      nil)),
    nil))
  ))));
end;

procedure TSearch.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(hcNoContext, {hcViewKey} 1,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('~F1~ Help', kbF1, cmHelp,
      NewStatusKey('~Alt+X~ Exit', kbAltX, cmQuit,
      NewStatusKey('~F9~ Start', kbF9, cmStart,
      NewStatusKey('~Alt+F3~ Close', kbAltF3, cmClose,
      StdStatusKeys(
      nil)))))),
    NewStatusDef(hcSearchWindow, hcSearchWindow,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('~F1~ Help', kbF1, cmHelp,
      NewStatusKey('~Alt+X~ Exit', kbAltX, cmQuit,
      NewStatusKey('~F9~ Start', kbF9, cmStart,
      NewStatusKey('~Alt+F3~ Close', kbAltF3, cmClose,
      NewStatusKey('~Alt+N~ Next', kbAltN, cmFindNext,
      NewStatusKey('~Alt+P~ Prev', kbAltP, cmFindPrev,
      StdStatusKeys(
      nil)))))))),
    nil))
  ));
end;

procedure TSearch.GetRequest;
begin
  if ExecuteDialog(New(PGrepDialog, Init), @Request) <> cmCancel then
  begin
    with Request do
      if ((Length(StartDir) <> 2) or (StartDir[2] <> ':')) and
        (StartDir[Length(StartDir)] <> '\') then
      begin
        Inc(StartDir[0]);
        StartDir[Length(StartDir)] := '\';
      end;
    DoSearch;
  end;
end;

var
  SearchApp: TSearch;

begin
  SearchApp.Init;
  SearchApp.Run;
  SearchApp.Done;
end.
