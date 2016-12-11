{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program MDIFileEditor;

{$R MFILEAPP.RES}

uses WinTypes, WinProcs, WinDos, Objects, OWindows, ODialogs, OMemory,
  OStdDlgs, OStdWnds, Strings;

const
  cm_SaveState    = 200;
  cm_RestoreState = 201;

const
  DskFile = 'MFILEAPP.DSK';

type

  { Declare TMDIFileApp, a TApplication descendant }
  TMDIFileApp = object(TApplication)
    procedure InitMainWindow; virtual;
    procedure InitInstance; virtual;
  end;

  { Declare TMDIFileWindow, a TMDIWindow descendant }
  PMDIFileWindow = ^TMDIFileWindow;
  TMDIFileWindow = object(TMDIWindow)
    procedure SetupWindow; virtual;
    procedure NewFile(var Msg: TMessage);
      virtual cm_First + cm_MDIFileNew;
    procedure OpenFile(var Msg: TMessage);
      virtual cm_First + cm_MDIFileOpen;
    procedure SaveState(var Msg: TMessage);
      virtual cm_First + cm_SaveState;
    procedure RestoreState(var Msg: TMessage);
      virtual cm_First + cm_RestoreState;
  end;

  { Declare TFileEditor, a TFileWindow desendant }
  PFileEditor = ^TFileEditor;
  TFileEditor = object(TFileWindow)
    constructor Init(AParent: PWindowsObject; AFileName: PChar);
    destructor Done; virtual;
    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
    function GetClassName: PChar; virtual;
  end;

const
  RFileEditor: TStreamRec = (
    ObjType: 1000;
    VmtLink: Ofs(TypeOf(TFileEditor)^);
    Load:    @TFileEditor.Load;
    Store:   @TFileEditor.Store);

{ TFileEditor }

const
  EditorCount: Integer = 0;

type
  TMenuState = (msEnable, msDisable);

procedure MenuItems(State: TMenuState);

procedure ModifyCommand(Command: Word);
var
  NewState: Word;
begin
  NewState := mf_ByCommand;
  if State = msEnable then Inc(NewState, mf_Enabled)
  else Inc(NewState, mf_Disabled + mf_Grayed);
  EnableMenuItem(PWindow(Application^.MainWindow)^.Attr.Menu, Command,
    NewState);
end;

begin
  { Bail out if the window is already closed }
  if Application^.MainWindow^.HWindow = 0 then Exit;

  ModifyCommand(cm_FileSave);
  ModifyCommand(cm_FileSaveAs);
  ModifyCommand(cm_ArrangeIcons);
  ModifyCommand(cm_TileChildren);
  ModifyCommand(cm_CascadeChildren);
  ModifyCommand(cm_CloseChildren);
  ModifyCommand(cm_EditCut);
  ModifyCommand(cm_EditCopy);
  ModifyCommand(cm_EditPaste);
  ModifyCommand(cm_EditDelete);
  ModifyCommand(cm_EditClear);
  ModifyCommand(cm_EditUndo);
  ModifyCommand(cm_EditFind);
  ModifyCommand(cm_EditReplace);
  ModifyCommand(cm_EditFindNext);
end;

procedure IncEditors;
begin
  if EditorCount = 0 then MenuItems(msEnable);
  Inc(EditorCount);
end;

procedure DecEditors;
begin
  Dec(EditorCount);
  if EditorCount = 0 then MenuItems(msDisable);
end;

constructor TFileEditor.Init(AParent: PWindowsObject; AFileName: PChar);
begin
  TFileWindow.Init(AParent, '', AFileName);
  IncEditors;
end;

destructor TFileEditor.Done;
begin
  DecEditors;
  TFileWindow.Done;
end;

procedure TFileEditor.GetWindowClass(var AWndClass: TWndClass);
begin
  TFileWindow.GetWindowClass(AWndClass);
  AWndClass.hIcon := LoadIcon(HInstance, 'FILEICON');
end;

function TFileEditor.GetClassName: PChar;
begin
  GetClassName := 'FileEditor';
end;

{ Respond to "New" command by constructing, creating, and setting up a
  new TFileWindow MDI child }
procedure TMDIFileWindow.NewFile(var Msg: TMessage);
begin
  Application^.MakeWindow(New(PFileEditor, Init(@Self, '')));
end;

procedure TMDIFileWindow.SetupWindow;
begin
  TMDIWindow.SetupWindow;
  MenuItems(msDisable);
end;

{ Respond to "Open" command by constructing, creating, and setting up a
  new TFileWindow MDI child }
procedure TMDIFileWindow.OpenFile(var Msg: TMessage);
var
  FileName: array[0..fsPathName] of Char;
begin
  if Application^.ExecDialog(New(PFileDialog, Init(@Self, PChar(sd_FileOpen),
      StrCopy(FileName, '*.*')))) = id_Ok then
    Application^.MakeWindow(New(PFileEditor, Init(@Self, FileName)));
end;

{ Save the the position and contents of the windows to the
  "desk top" file. }
procedure TMDIFileWindow.SaveState(var Msg: TMessage);
var
  S: PStream;

function FileDelete(Name: PChar): Integer; assembler;
asm
	PUSH	DS
	LDS	DX,Name
	MOV	AH,41H
	INT	21H
	JC	@@1
	XOR	AX,AX
@@1:	NEG	AX
	POP	DS
end;

begin
  S := New(PBufStream, Init(DskFile, stCreate, 1024));
  PutChildren(S^);
  if S^.Status <> stOk then
  begin
    Dispose(S, Done);
    FileDelete(DskFile);
    MessageBox(HWindow, 'Unable to write desktop file.', 'Disk error',
      mb_Ok or mb_IconExclamation);
  end
  else Dispose(S, Done);
end;

{ Read windows positions and contents from the "desk top" file. }
procedure TMDIFileWindow.RestoreState(var Msg: TMessage);
var
  S: PStream;
  ErrorMsg: PChar;
begin
  ErrorMsg := nil;
  S := New(PBufStream, Init(DskFile, stOpenRead, 1024));
  if S^.Status <> stOk then
    ErrorMsg := 'Unable to open desktop file.'
  else
  begin
    CloseChildren;
    GetChildren(S^);
    if S^.Status <> stOk then
      ErrorMsg := 'Error reading desktop file.';
    if LowMemory then
    begin
      CloseChildren;
      ErrorMsg := 'Not enough memory to open file.'
    end
    else CreateChildren;
  end;
  if ErrorMsg <> nil then
    MessageBox(HWindow, ErrorMsg, 'Disk error', mb_Ok or mb_IconExclamation);
end;

{ Construct the TMDIFileApp's MainWindow of type TMDIFileWindow,
  loading its menu }
procedure TMDIFileApp.InitMainWindow;
begin
  MainWindow := New(PMDIFileWindow, Init('MDI Files',
    LoadMenu(HInstance, 'Commands')));
  PMDIFileWindow(MainWindow)^.ChildMenuPos := 3;

  { Register types to be written to stream }
  RegisterType(RWindow);
  RegisterType(REdit);
  RegisterType(RFileEditor);
end;

{ Initialize each MS-Windows application instance, loading an
  accelerator table }
procedure TMDIFileApp.InitInstance;
begin
  TApplication.InitInstance;
  if Status = 0 then
  begin
    HAccTable := LoadAccelerators(HInstance, 'FileCommands');
    if HAccTable = 0 then
      Status := em_InvalidWindow;
  end;
end;

{ Declare a variable of type TFileApp }
var
  MDIFileApp : TMDIFileApp;

{ Run the FileApp }
begin
  MDIFileApp.Init('MDIFileApp');
  MDIFileApp.Run;
  MDIFileApp.Done;
end.
