{************************************************}
{                                                }
{   Toolbar Demo Program                         }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ This is a modified version of MFILEAPP from the DEMOS\WIN\OWL
  subdirectory that shows how to use the TOOLBAR unit. }

program MDIFileEditor;

{$R MFILEAPP.RES}

uses WinProcs, WinTypes, Objects, OWindows, ODialogs, OStdDlgs,
     OStdWnds, OMemory, Strings, WinDos, Toolbar, MFileC;

const
  DskFile = 'MFILEAPP.DSK';
  DskSignature : array [0..23] of Char = 'MFileApp Desktop file'#26#0;

  { If we're running under Win 3.1, we'll use this function to prevent flicker }
  Win31LockWindowUpdate: function (Wnd: HWnd): Bool = nil;

type

  { Declare TMDIFileApp, a TApplication descendant }
  TMDIFileApp = object(TApplication)
    procedure InitMainWindow; virtual;
    procedure InitInstance; virtual;
  end;

  { Declare TMDIFileWindow, a TMDIWindow descendant }
  PMDIFileWindow = ^TMDIFileWindow;
  TMDIFileWindow = object(TMDIWindow)
    Toolbar: PToolbar;
    constructor Init(ATitle: PChar; AMenu: HMenu);
    procedure EnableCommand(Command: Word; EnableIt: Boolean);
    procedure SetupWindow; virtual;
    procedure RedoClientRect;
    procedure CalcClientRect(var R: TRect); 
    procedure NewFile(var Msg: TMessage);
      virtual cm_First + cm_MDIFileNew;
    procedure OpenFile(var Msg: TMessage);
      virtual cm_First + cm_MDIFileOpen;
    procedure SaveState(var Msg: TMessage);
      virtual cm_First + cm_SaveState;
    procedure RestoreState(var Msg: TMessage);
      virtual cm_First + cm_RestoreState;
    procedure HorizontalToolbar(var Msg: TMessage);
      virtual cm_First + cm_HorizontalToolbar;
    procedure RightVerticalToolbar(var Msg: TMessage);
      virtual cm_First + cm_RightVerticalToolbar;
    procedure LeftVerticalToolbar(var Msg: TMessage);
      virtual cm_First + cm_LeftVerticalToolbar;
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;
  end;

  { Declare TFileEditor, a TFileWindow desendant }
  PFileEditor = ^TFileEditor;
  TFileEditor = object(TFileWindow)
    constructor Init(AParent: PWindowsObject; AFileName: PChar);
    destructor Done; virtual;
    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
    function  GetClassName: PChar; virtual;
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

procedure EnableEditorMenuItems(NewState: Boolean);
begin
  { Bail out if the window is already closed }
  if Application^.MainWindow^.HWindow = 0 then Exit;

  with PMDIFileWindow(Application^.MainWindow)^ do
  begin
    EnableCommand(cm_FileSave, NewState);
    EnableCommand(cm_FileSaveAs, NewState);
    EnableCommand(cm_ArrangeIcons, NewState);
    EnableCommand(cm_TileChildren, NewState);
    EnableCommand(cm_CascadeChildren, NewState);
    EnableCommand(cm_CloseChildren, NewState);
    EnableCommand(cm_EditCut, NewState);
    EnableCommand(cm_EditCopy, NewState);
    EnableCommand(cm_EditPaste, NewState);
    EnableCommand(cm_EditDelete, NewState);
    EnableCommand(cm_EditClear, NewState);
    EnableCommand(cm_EditUndo, NewState);
    EnableCommand(cm_EditFind, NewState);
    EnableCommand(cm_EditReplace, NewState);
    EnableCommand(cm_EditFindNext, NewState);
  end;
end;

procedure IncEditors;
begin
  if EditorCount = 0 then EnableEditorMenuItems(True);
  Inc(EditorCount);
end;

procedure DecEditors;
begin
  Dec(EditorCount);
  if EditorCount = 0 then EnableEditorMenuItems(False);
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


{ The main window object - TMDIFileWindow }

constructor TMDIFileWindow.Init(ATitle: PChar; AMenu: HMenu);
begin
  TMDIWindow.Init(ATitle, AMenu);
  Attr.Style := Attr.Style or ws_ClipChildren;
  Toolbar := New(PToolbar, Init(@Self, 'Toolbar_1', tbHorizontal));
end;

{ Make sure the menus that require an editor are disabled and that the toolbar
  is synchronized with the disabled menu items. }
procedure TMDIFileWindow.SetupWindow;
begin
  TMDIWindow.SetupWindow;
  EnableEditorMenuItems(False);
  CheckMenuItem(Attr.Menu, cm_HorizontalToolbar, mf_ByCommand or mf_Checked);
end;


{ Allow special windows such as the Toolbar the opportunity to say how
  much room they need to take away from the MDI client area AND draw themselves.}
procedure TMDIFileWindow.RedoClientRect;
var R: TRect;
  procedure NotifyChildren( P: PWindow ); far;
  begin
    if P^.HWindow <> 0 then
      SendMessage(P^.HWindow, am_CalcParentClientRect, AllowRepaint, Longint(@R));
  end;
begin
  GetClientRect(HWindow, R);
  ForEach(@NotifyChildren);
  SetWindowPos(ClientWnd^.HWindow, 0, R.Left, R.Top,
                                      R.Right - R.Left,
                                      R.Bottom - R.Top, swp_NoZOrder);
end;

{ Allow special windows such as the Toolbar the opportunity to say how
  much room they need to take away from the MDI client area BUT NOT draw themselves.}
procedure TMDIFileWindow.CalcClientRect(var R: TRect);
  procedure NotifyChildren( P: PWindow ); far;
  begin
    if P^.HWindow <> 0 then
      SendMessage(P^.HWindow, am_CalcParentClientRect, DenyRepaint, Longint(@R));
  end;
begin
  GetClientRect(HWindow, R);
  ForEach(@NotifyChildren);
end;

{ Enable or disable menu items and toolbar icons at the request of
  child windows }
procedure TMDIFileWindow.EnableCommand(Command: Word; EnableIt: Boolean);
var
  StateFlags: Word;
begin
  if Attr.Menu <> 0 then
  begin
    if EnableIt then
      StateFlags := mf_ByCommand or mf_Enabled
    else
      StateFlags := mf_ByCommand or mf_Disabled or mf_Grayed;
    EnableMenuItem(Attr.Menu, Command, StateFlags);
    Toolbar^.EnableTool(Command, EnableIt);
  end;
end;

{ Respond to "New" command by constructing, creating, and setting up a
  new TFileWindow MDI child }
procedure TMDIFileWindow.NewFile(var Msg: TMessage);
begin
  Application^.MakeWindow(New(PFileEditor, Init(@Self, '')));
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

  function FileDelete(Name: PChar): Integer; assembler;
  asm
	PUSH	DS
	LDS	DX,Name
	MOV	AH,41H
	INT	21H
	JC	@@1
	XOR	AX,AX
  @@1:  NEG	AX
	POP	DS
  end;

var
  S: PStream;
  R: TRect;
begin
  S := New(PBufStream, Init(DskFile, stCreate, 1024));
  S^.Write(DskSignature, SizeOf(DskSignature));
  PutChildren(S^);
  PutChildPtr(S^, Toolbar);
  S^.Write(EditorCount, SizeOf(EditorCount));
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
  R: TRect;
  ErrorMsg: PChar;
  OldToolbar: PToolbar;
  X: Integer;
  OldCursor: HCursor;
  TestSignature: array [0..SizeOf(DskSignature)] of Char;
begin
  OldToolbar := nil;
  ErrorMsg := nil;
  S := New(PBufStream, Init(DskFile, stOpenRead, 1024));
  if S^.Status = stOK then
    S^.Read(TestSignature, SizeOf(DskSignature));   
  if S^.Status <> stOk then
    ErrorMsg := 'Unable to open desktop file.'
  else
  if StrComp(TestSignature, DskSignature) <> 0 then
    ErrorMsg := 'Invalid or corrupted desktop file.'
  else
  begin
    OldCursor := SetCursor(LoadCursor(0, PChar(idc_Wait)));
    CloseChildren;            { Close the MDI child windows }
    OldToolbar := Toolbar;    { Save the Toolbar, in case the load fails }
    RemoveChild(Toolbar);     { Remove the Toolbar from the child list }
    GetChildren(S^);          { Read children, including a new Toolbar }
    GetChildPtr(S^, Toolbar);
    S^.Read(X, SizeOf(X));
    if (S^.Status <> stOk) or LowMemory then
    begin                     { Stream error or out of memory }
      CloseChildren;
      EditorCount := 0;
      if Toolbar <> nil then Dispose(Toolbar, Done);
      if S^.Status <> 0 then
        ErrorMsg := 'Error reading desktop file.'
      else
        ErrorMsg := 'Not enough memory to open file.';
      Toolbar := OldToolbar;     { Go back to old toolbar }
      AddChild(Toolbar);
    end
    else
    begin
      if Assigned(Win31LockWindowUpdate) then
        Win31LockWindowUpdate(HWindow);
      CreateChildren;            { Create the MDI child windows just loaded }
      Toolbar^.Show(sw_Hide);
      RedoClientRect;            { Give Toolbar a chance to reorient itself }
      Toolbar^.Show(sw_Show);
      Dispose(OldToolbar, Done);
      if Assigned(Win31LockWindowUpdate) then
        Win31LockWindowUpdate(0);
      EditorCount := X;
      EnableEditorMenuItems(EditorCount > 0);

      { Make the menu check match the Toolbar orientation }
      CheckMenuItem(Attr.Menu, cm_HorizontalToolbar, mf_ByCommand or mf_UnChecked);
      CheckMenuItem(Attr.Menu, cm_LeftVerticalToolbar, mf_ByCommand or mf_UnChecked);
      CheckMenuItem(Attr.Menu, cm_RightVerticalToolbar, mf_ByCommand or mf_UnChecked);
      case Toolbar^.GetOrientation of
        tbHorizontal   : X := cm_HorizontalToolbar;
        tbLeftVertical : X := cm_LeftVerticalToolbar;
        tbRightVertical: X := cm_RightVerticalToolbar;
      end;
      CheckMenuItem(Attr.Menu, X, mf_ByCommand or mf_Checked);
    end;
    Dispose(S, Done);
    SetCursor(OldCursor);
  end;
  if ErrorMsg <> nil then
    MessageBox(HWindow, ErrorMsg, 'Disk error', mb_Ok or mb_IconExclamation);
end;


procedure TMDIFileWindow.HorizontalToolbar(var Msg: TMessage);
begin
  if Toolbar^.GetOrientation <> tbHorizontal then
  begin
    if Assigned(Win31LockWindowUpdate) then
      Win31LockWindowUpdate(HWindow);
    Toolbar^.Show(sw_Hide);
    Toolbar^.SetOrientation(tbHorizontal);
    RedoClientRect;
    Toolbar^.Show(sw_Show);
    if Assigned(Win31LockWindowUpdate) then
      Win31LockWindowUpdate(0);
    CheckMenuItem(Attr.Menu, cm_HorizontalToolbar, mf_ByCommand or mf_Checked);
    CheckMenuItem(Attr.Menu, cm_LeftVerticalToolbar, mf_ByCommand or mf_UnChecked);
    CheckMenuItem(Attr.Menu, cm_RightVerticalToolbar, mf_ByCommand or mf_UnChecked);
  end;
end;

procedure TMDIFileWindow.RightVerticalToolbar(var Msg: TMessage);
begin
  if Toolbar^.GetOrientation <> tbRightVertical then
  begin
    if Assigned(Win31LockWindowUpdate) then
      Win31LockWindowUpdate(HWindow);
    Toolbar^.Show(sw_Hide);
    Toolbar^.SetOrientation(tbRightVertical);
    RedoClientRect;
    Toolbar^.Show(sw_Show);
    if Assigned(Win31LockWindowUpdate) then
      Win31LockWindowUpdate(0);
    CheckMenuItem(Attr.Menu, cm_HorizontalToolbar, mf_ByCommand or mf_UnChecked);
    CheckMenuItem(Attr.Menu, cm_LeftVerticalToolbar, mf_ByCommand or mf_UnChecked);
    CheckMenuItem(Attr.Menu, cm_RightVerticalToolbar, mf_ByCommand or mf_Checked);
  end;
end;

procedure TMDIFileWindow.LeftVerticalToolbar(var Msg: TMessage);
begin
  if Toolbar^.GetOrientation <> tbLeftVertical then
  begin
    if Assigned(Win31LockWindowUpdate) then
      Win31LockWindowUpdate(HWindow);
    Toolbar^.Show(sw_Hide);
    Toolbar^.SetOrientation(tbLeftVertical);
    RedoClientRect;
    Toolbar^.Show(sw_Show);
    if Assigned(Win31LockWindowUpdate) then
      Win31LockWindowUpdate(0);
    CheckMenuItem(Attr.Menu, cm_HorizontalToolbar, mf_ByCommand or mf_UnChecked);
    CheckMenuItem(Attr.Menu, cm_LeftVerticalToolbar, mf_ByCommand or mf_Checked);
    CheckMenuItem(Attr.Menu, cm_RightVerticalToolbar, mf_ByCommand or mf_UnChecked);
  end;
end;

{ Allow special windows such as the Toolbar the opportunity to say how much room
 they need outside the MDI client area.  The default Windows processing for
 wm_Size always sets the MDI client area to fill the main window's client area,
 and it forces a repaint.  We don't want that, so we don't call the inherited
 wm_Size or the Windows default message processor. }
procedure TMDIFileWindow.wmSize(var Msg: TMessage);
var
  R: TRect;
begin
  if (Scroller <> nil) and (Msg.WParam <> sizeIconic) then
    Scroller^.SetPageSize;
  if Msg.wParam = sizeNormal then
  begin
    GetWindowRect(HWindow, R);
    Attr.H := R.bottom - R.top;
    Attr.W := R.right - R.left;
  end;
  RedoClientRect;
end;



{ Construct the TMDIFileApp's MainWindow of type TMDIFileWindow,
  loading its menu }
procedure TMDIFileApp.InitMainWindow;
var x: PWindowsObject;
begin
  MainWindow := New(PMDIFileWindow, Init('MDI Files',
    LoadMenu(HInstance, 'Commands')));
  PMDIFileWindow(MainWindow)^.ChildMenuPos := 3;
  { Register types to be written to stream }
  RegisterType(RWindow);
  RegisterType(REdit);
  RegisterType(RFileEditor);
  RegisterType(RToolbar);
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
  { In Windows 3.0, the following GetProcAddress call will return nil,
    but not cause a critical error message.  Any code that uses
    this function variable should always test it first with
    the Assigned system function. }

  @Win31LockWindowUpdate :=
    GetProcAddress(GetModuleHandle('User'), PChar(294));
  MDIFileApp.Init('MDIFileApp');
  MDIFileApp.Run;
  MDIFileApp.Done;
end.
