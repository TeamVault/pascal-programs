{**************************************************}
{                                                  }
{   Object Linking and Embedding demo program      }
{   Copyright (c) 1992 by Borland International    }
{                                                  }
{**************************************************}

program OleClnt;

{ This program demonstrates how to implement an OLE client application.
  The program uses the new Ole, ShellAPI, and CommDlg units, and requires
  that the OLECLI.DLL, SHELL.DLL, and COMMDLG.DLL libraries are present.
  The program allows you to create embedded and linked objects using the
  Edit|Paste and Edit|Paste link commands. The OLE objects can be moved
  and resized, and they can be activated through double clicks or using
  the Edit|Object menu. Workspaces can be saved and loaded using the
  File menu. }

uses Strings, WinTypes, WinProcs, Objects, OWindows, ODialogs, Ole, 
  ShellAPI, CommDlg;

{$R OLECLNT}

const

{ Resource IDs }

  id_Menu  = 100;
  id_About = 100;

{ Menu command IDs }

  cm_FileNew       = 100;
  cm_FileOpen      = 101;
  cm_FileSave      = 102;
  cm_FileSaveAs    = 103;
  cm_FileExit      = 104;
  cm_EditCut       = 200;
  cm_EditCopy      = 201;
  cm_EditPaste     = 202;
  cm_EditPasteLink = 203;
  cm_EditClear     = 204;
  cm_HelpAbout     = 300;
  cm_VerbMin       = 900;
  cm_VerbMax       = 999;

{ Menu item positions }

  pos_Edit   = 1;  { Position of Edit item on main menu }
  pos_Object = 6;  { Position of Object item on Edit menu }

type

{ Pointer types }

  PAppClient    = ^TAppClient;
  PAppStream    = ^TAppStream;
  PObjectWindow = ^TObjectWindow;
  PMainWindow   = ^TMainWindow;

{ Filename string }

  TFilename = array[0..255] of Char;

{ OLE file header }

  TOleFileHeader = array[1..4] of Char;

{ Application client structure }

  TAppClient = record
    OleClient: TOleClient;
    ObjectWindow: PObjectWindow;
  end;

{ Application stream structure }

  TAppStream = record
    OleStream: TOleStream;
    OwlStream: PStream;
  end;

{ OLE object window }

  TObjectWindow = object(TWindow)
    AppClient: TAppClient;
    OleObject: POleObject;
    Framed: Boolean;
    constructor Init(Link: Boolean);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    function GetClassName: PChar; virtual;
    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
    procedure SetupWindow; virtual;
    procedure Store(var S: TStream); virtual;
    function CanClose: Boolean; virtual;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure Check(OleStatus: TOleStatus);
    procedure GetObjectClass(ClassName: PChar);
    function IsLinked: Boolean;
    procedure Update;
    procedure OpenObject(Verb: Word);
    procedure CloseObject;
    procedure CopyToClipboard;
    procedure Delete;
    procedure Changed;
    procedure BringToFront;
    procedure GetBounds(var R: TRect);
    procedure SetBounds(var R: TRect);
    procedure ShowFrame(EnableFrame: Boolean);
    procedure WMGetMinMaxInfo(var Msg: TMessage);
      virtual wm_First + wm_GetMinMaxInfo;
    procedure WMMove(var Msg: TMessage);
      virtual wm_First + wm_Move;
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMMouseMove(var Msg: TMessage);
      virtual wm_First + wm_MouseMove;
    procedure WMLButtonUp(var Msg: TMessage);
      virtual wm_First + wm_LButtonUp;
    procedure WMLButtonDblClk(var Msg: TMessage);
      virtual wm_First + wm_LButtonDblClk;
  end;

{ Application main window }

  TMainWindow = object(TWindow)
    ObjectWindow: PObjectWindow;
    ClientDoc: LHClientDoc;
    Modified: Boolean;
    Filename: TFilename;
    constructor Init;
    destructor Done; virtual;
    function CanClose: Boolean; virtual;
    procedure SetupWindow; virtual;
    procedure InitDocument;
    procedure DoneDocument;
    procedure UpdateDocument;
    procedure SetFilename(Name: PChar);
    function NewFile(Name: PChar): Boolean;
    function LoadFile: Boolean;
    function SaveFile: Boolean;
    function Save: Boolean;
    function SaveAs: Boolean;
    procedure NewObjectWindow(Link: Boolean);
    procedure SelectWindow(Window: PObjectWindow);
    procedure UpdateObjectMenu;
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMInitMenu(var Msg: TMessage);
      virtual wm_First + wm_InitMenu;
    procedure CMFileNew(var Msg: TMessage);
      virtual cm_First + cm_FileNew;
    procedure CMFileOpen(var Msg: TMessage);
      virtual cm_First + cm_FileOpen;
    procedure CMFileSave(var Msg: TMessage);
      virtual cm_First + cm_FileSave;
    procedure CMFileSaveAs(var Msg: TMessage);
      virtual cm_First + cm_FileSaveAs;
    procedure CMFileExit(var Msg: TMessage);
      virtual cm_First + cm_FileExit;
    procedure CMEditCut(var Msg: TMessage);
      virtual cm_First + cm_EditCut;
    procedure CMEditCopy(var Msg: TMessage);
      virtual cm_First + cm_EditCopy;
    procedure CMEditPaste(var Msg: TMessage);
      virtual cm_First + cm_EditPaste;
    procedure CMEditPasteLink(var Msg: TMessage);
      virtual cm_First + cm_EditPasteLink;
    procedure CMEditClear(var Msg: TMessage);
      virtual cm_First + cm_EditClear;
    procedure CMHelpAbout(var Msg: TMessage);
      virtual cm_First + cm_HelpAbout;
    procedure DefCommandProc(var Msg: TMessage); virtual;
  end;

{ Application object }

  TApp = object(TApplication)
    constructor Init(AName: PChar);
    destructor Done; virtual;
    procedure InitMainWindow; virtual;
  end;

{ Initialized globals }

const
  Dragging: Boolean = False;
  OleFileHeader: TOleFileHeader = 'TPOF';
  OleProtocol: PChar = 'StdFileEditing';
  OleObjectName: PChar = 'Object';
  OleClntTitle: PChar = 'OLE Client Demo';

{ Global variables }

var
  App: TApp;
  DragPoint: TPoint;
  MainWindow: PMainWindow;
  OleClientVTbl: TOleClientVTbl;
  OleStreamVTbl: TOleStreamVTbl;
  PixPerInch: TPoint;
  CFObjectLink, CFOwnerLink: Word;

{ TObjectWindow stream registration record }

const
  RObjectWindow: TStreamRec = (
    ObjType: 999;
    VmtLink: Ofs(TypeOf(TObjectWindow)^);
    Load: @TObjectWindow.Load;
    Store: @TObjectWindow.Store);

{ Display a message using the MessageBox API routine. }

function Message(S: PChar; Flags: Word): Word;
begin
  Message := MessageBox(MainWindow^.HWindow, S, OleClntTitle, Flags);
end;

{ Display an error message. }

procedure Error(ErrorStr, ErrorArg: PChar);
var
  S: array[0..255] of Char;
begin
  wvsprintf(S, ErrorStr, ErrorArg);
  Message(S, mb_IconExclamation + mb_Ok);
end;

{ Display OLE operation error message. }

procedure OleError(Status: TOleStatus);
var
  S: array[0..7] of Char;
begin
  wvsprintf(S, '%d', Status);
  Error('Warning: OLE operation failed, error code = %s.', S);
end;

{ Display an Open or Save As file dialog using the Common Dialog DLL. }

function FileDialog(Owner: HWnd; Filename: PChar; Save: Boolean): Boolean;
const
  DefOpenFilename: TOpenFilename = (
    lStructSize: SizeOf(TOpenFilename);
    hwndOwner: 0;
    hInstance: 0;
    lpstrFilter: 'OLE files (*.OLE)'#0'*.ole'#0;
    lpstrCustomFilter: nil;
    nMaxCustFilter: 0;
    nFilterIndex: 0;
    lpstrFile: nil;
    nMaxFile: SizeOf(TFilename);
    lpstrFileTitle: nil;
    nMaxFileTitle: 0;
    lpstrInitialDir: nil;
    lpstrTitle: nil;
    Flags: 0;
    nFileOffset: 0;
    nFileExtension: 0;
    lpstrDefExt: 'ole');
var
  OpenFilename: TOpenFilename;
begin
  OpenFilename := DefOpenFilename;
  OpenFilename.hwndOwner := Owner;
  OpenFilename.lpstrFile := Filename;
  if Save then
  begin
    OpenFilename.Flags := ofn_PathMustExist + ofn_NoChangeDir +
      ofn_OverwritePrompt;
    FileDialog := GetSaveFilename(OpenFilename);
  end else
  begin
    OpenFileName.Flags := ofn_PathMustExist + ofn_HideReadOnly;
    FileDialog := GetOpenFilename(OpenFilename);
  end;
end;

{ OLE client callback routine. Called by the OLE client library to notify
  the application of any changes to an object. In this application, the
  Client parameter is always a PAppClient, so a typecast can be used to
  find the corresponding TObjectWindow. The OLE object window's Changed
  method is called whenever the contained OLE object is changed, saved,
  or renamed. The callback routine returns 1 to satisfy ole_Query_Paint
  and ole_Query_Retry notifications. }

function ClientCallBack(Client: POleClient; Notification:
  TOle_Notification; OleObject: POleObject): Integer; export;
begin
  ClientCallBack := 1;
  case Notification of
    ole_Changed, ole_Saved, ole_Renamed:
      PAppClient(Client)^.ObjectWindow^.Changed;
  end;
end;

{ Selector increment. This is not a true procedure. Instead, it is an
  external symbol whose offset represents the value to add to a selector
  to increment a pointer by 64K bytes. }

procedure AHIncr; far; external 'KERNEL' index 114;

{ Read or write to or from a stream. This function supports transfers of
  blocks larger than 64K bytes. It guards against segment overruns, and
  transfers data in blocks of up to 32K bytes. }

function StreamInOut(var S: TStream; Buffer: Pointer; Size: Longint;
  Writing: Boolean): Longint;
var
  N: Longint;
begin
  StreamInOut := Size;
  while Size <> 0 do
  begin
    N := $10000 - PtrRec(Buffer).Ofs;
    if N > $8000 then N := $8000;
    if N > Size then N := Size;
    if Writing then S.Write(Buffer^, N) else S.Read(Buffer^, N);
    Inc(PtrRec(Buffer).Ofs, N);
    if PtrRec(Buffer).Ofs = 0 then Inc(PtrRec(Buffer).Seg, Ofs(AHIncr));
    Dec(Size, N);
  end;
  if S.Status <> 0 then StreamInOut := 0;
end;

{ OLE stream read callback function. In this application, the Stream
  parameter is always a PAppStream, so a typecast can be used to find the
  corresponding ObjectWindows stream. }

function StreamGet(Stream: POleStream; Buffer: PChar;
  Size: LongInt): LongInt; export;
begin
  StreamGet := StreamInOut(PAppStream(Stream)^.OwlStream^,
    Buffer, Size, False);
end;

{ OLE stream write callback function. In this application, the Stream
  parameter is always a PAppStream, so a typecast can be used to find the
  corresponding ObjectWindows stream. }

function StreamPut(Stream: POleStream; Buffer: PChar;
  Size: LongInt): LongInt; export;
begin
  StreamPut := StreamInOut(PAppStream(Stream)^.OwlStream^,
    Buffer, Size, True);
end;

{ TObjectWindow methods }

{ Construct an OLE object window. The AppClient structure is initialized
  to reference the newly created TObjectWindow so that the ClientCallBack
  routine can later locate it when notifications are received. If the OLE
  object is successfully created, its bounds are queried to determine the
  initial bounds of the OLE object window. Notice that the bounds are
  returned in mm_HiMetric units, which are converted to mm_Text units. }

constructor TObjectWindow.Init(Link: Boolean);
var
  R: TRect;
  Cursor: HCursor;
begin
  TWindow.Init(MainWindow, nil);
  Attr.Style := ws_Child + ws_ClipSiblings;
  AppClient.OleClient.lpvtbl := @OleClientVTbl;
  AppClient.ObjectWindow := @Self;
  OleObject := nil;
  Framed := False;
  Cursor := SetCursor(LoadCursor(0, idc_Wait));
  if Link then
    Check(OleCreateLinkFromClip(OleProtocol, @AppClient.OleClient,
      MainWindow^.ClientDoc, OleObjectName, OleObject,
      olerender_Draw, 0))
  else
    Check(OleCreateFromClip(OleProtocol, @AppClient.OleClient,
      MainWindow^.ClientDoc, OleObjectName, OleObject,
      olerender_Draw, 0));
  SetCursor(Cursor);

  if OleObject = nil then Status := -1 else
  begin
    OleQueryBounds(OleObject, R);
    Attr.X := 0;
    Attr.Y := 0;
    Attr.W := MulDiv(R.right, PixPerInch.X, 2540);
    Attr.H := MulDiv(-R.bottom, PixPerInch.Y, 2540);
  end;
end;

{ Load an OLE object window from a stream. Loads the contained OLE object
  from the stream, using a TAppStream for I/O. }

constructor TObjectWindow.Load(var S: TStream);
var
  ObjectType: Longint;
  AppStream: TAppStream;
begin
  TWindow.Load(S);
  AppClient.OleClient.lpvtbl := @OleClientVTbl;
  AppClient.ObjectWindow := @Self;
  OleObject := nil;
  Framed := False;
  AppStream.OleStream.lpstbl := @OleStreamVTbl;
  AppStream.OwlStream := @S;
  Check(OleLoadFromStream(@AppStream.OleStream, OleProtocol,
    @AppClient.OleClient, MainWindow^.ClientDoc, OleObjectName,
    OleObject));
  if OleObject = nil then Status := -1;
end;

{ Destroy an OLE object window. Closes and releases the contained OLE
  object. }

destructor TObjectWindow.Done;
begin
  if OleObject <> nil then
  begin
    CloseObject;
    Check(OleRelease(OleObject));
  end;
  TWindow.Done;
end;

{ Return the OLE object window class name }

function TObjectWindow.GetClassName: PChar;
begin
  GetClassName := 'OleWindow';
end;

{ Return the OLE object window class structure. Enables double click
  processing. }

procedure TObjectWindow.GetWindowClass(var AWndClass: TWndClass);
begin
  TWindow.GetWindowClass(AWndClass);
  AWndClass.Style := AWndClass.Style or cs_DblClks;
end;

{ Initialize an OLE object window. Called following successful creation
  of the MS-Windows window. The window is brought to front and shown. }

procedure TObjectWindow.SetupWindow;
begin
  TWindow.SetupWindow;
  BringToFront;
  ShowWindow(HWindow, sw_Show);
end;

{ Store an OLE object window on a stream. Stores the contained OLE object
  on the stream, using a TAppStream for I/O. }

procedure TObjectWindow.Store(var S: TStream);
var
  AppStream: TAppStream;
begin
  TWindow.Store(S);
  AppStream.OleStream.lpstbl := @OleStreamVTbl;
  AppStream.OwlStream := @S;
  Check(OleSaveToStream(OleObject, @AppStream.OleStream));
end;

{ Paint an OLE object window. The contained OLE object is instructed to
  draw itself to fill the entire client area. }

procedure TObjectWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  R: TRect;
begin
  GetClientRect(HWindow, R);
  Check(OleDraw(OleObject, PaintDC, R, R, 0));
end;

{ Determine whether an OLE object window can close. If the contained OLE
  object is currently open, the user must confirm before the window can
  be closed. }

function TObjectWindow.CanClose: Boolean;
begin
  CanClose := True;
  if OleQueryOpen(OleObject) = ole_Ok then
    CanClose := Message('Object is currently open. Continue anyway?',
      mb_IconExclamation + mb_OkCancel) = id_Ok;
end;

{ Check the status of an OLE operation. If an OLE operation returns
  ole_Wait_For_Release, indicating that it is executing acsynchronously,
  the Check method will enter a message loop, waiting for the OLE object
  to be released by the server. }

procedure TObjectWindow.Check(OleStatus: TOleStatus);
var
  M: TMsg;
begin
  if OleStatus = ole_Wait_For_Release then
  begin
    repeat
      OleStatus := OleQueryReleaseStatus(OleObject);
      if OleStatus = ole_Busy then
        if GetMessage(M, 0, 0, 0) then
        begin
          TranslateMessage(M);
          DispatchMessage(M);
        end;
    until OleStatus <> ole_Busy;
  end;
  if OleStatus <> ole_Ok then OleError(OleStatus);
end;

{ Return the class name of the contained OLE object. The first string in
  an OLE object's ObjectLink or OwnerLink data is the class name. }

procedure TObjectWindow.GetObjectClass(ClassName: PChar);
var
  H: THandle;
begin
  ClassName[0] := #0;
  if (OleGetData(OleObject, CFObjectLink, H) = ole_Ok) or
    (OleGetData(OleObject, CFOwnerLink, H) = ole_Ok) then
  begin
    StrCopy(ClassName, GlobalLock(H));
    GlobalUnlock(H);
  end;
end;

{ Return True if the contained OLE object is a linked object. }

function TObjectWindow.IsLinked: Boolean;
var
  ObjectType: Longint;
begin
  IsLinked := (OleQueryType(OleObject, ObjectType) = ole_Ok) and
    (ObjectType = ot_Link);
end;

{ Update the contained OLE object. }

procedure TObjectWindow.Update;
begin
  Check(OleUpdate(OleObject));
end;

{ Open the contained OLE object. }

procedure TObjectWindow.OpenObject(Verb: Word);
var
  Cursor: HCursor;
begin
  Cursor := SetCursor(LoadCursor(0, idc_Wait));
  Check(OleActivate(OleObject, Verb, True, True, 0, nil));
  SetCursor(Cursor);
end;

{ Close the contained OLE object if it is open. }

procedure TObjectWindow.CloseObject;
begin
  if OleQueryOpen(OleObject) = ole_Ok then Check(OleClose(OleObject));
end;

{ Copy the contained OLE object to the clipboard. }

procedure TObjectWindow.CopyToClipboard;
begin
  Check(OleCopyToClipboard(OleObject));
end;

{ Delete an OLE object window. If the window is the main window's
  current selection, it is unselected. The parent window is marked as
  modified, and the contained OLE object is closed and deleted. }

procedure TObjectWindow.Delete;
begin
  with MainWindow^ do
  begin
    if ObjectWindow = @Self then SelectWindow(nil);
    Modified := True;
  end;
  CloseObject;
  Check(OleDelete(OleObject));
  OleObject := nil;
  Free;
end;

{ This method is called by the ClientCallBack routine whenever the
  contained OLE object has changed. The client area of the OLE object
  window is invalidated to force repainting, and the main window is
  marked as modified. }

procedure TObjectWindow.Changed;
begin
  InvalidateRect(HWindow, nil, True);
  MainWindow^.Modified := True;
end;

{ Bring an OLE object window to front. }

procedure TObjectWindow.BringToFront;
begin
  SetWindowPos(HWindow, 0, 0, 0, 0, 0, swp_NoMove + swp_NoSize);
end;

{ Return the bounds of an OLE object window using parent window
  coordinates. The bounds include the window frame, if present. }

procedure TObjectWindow.GetBounds(var R: TRect);
begin
  GetWindowRect(HWindow, R);
  ScreenToClient(Parent^.HWindow, PPoint(@R.left)^);
  ScreenToClient(Parent^.HWindow, PPoint(@R.right)^);
end;

{ Set the bounds of an OLE object window within its parent window. }

procedure TObjectWindow.SetBounds(var R: TRect);
begin
  MoveWindow(HWindow, R.left, R.top,
    R.right - R.left, R.bottom - R.top, True);
  UpdateWindow(HWindow);
end;

{ Enable or disable an OLE object window's window frame. The frame is
  added or removed by modifying the window's style flags and growing or
  shrinking the window's bounds. }

procedure TObjectWindow.ShowFrame(EnableFrame: Boolean);
const
  Border = ws_Border + ws_ThickFrame;
var
  FX, FY: Integer;
  Style: Longint;
  R: TRect;
begin
  if EnableFrame <> Framed then
  begin
    Style := GetWindowLong(HWindow, gwl_Style);
    FX := GetSystemMetrics(sm_CXFrame);
    FY := GetSystemMetrics(sm_CYFrame);
    GetBounds(R);
    if EnableFrame then
    begin
      Style := Style or Border;
      InflateRect(R, FX, FY);
    end else
    begin
      Style := Style and not Border;
      InflateRect(R, -FX, -FY);
    end;
    SetWindowLong(HWindow, gwl_Style, Style);
    SetBounds(R);
    Framed := EnableFrame;
  end;
end;

{ wm_GetMinMaxInfo message handler. Modifies the minimum window size. }

procedure TObjectWindow.WMGetMinMaxInfo(var Msg: TMessage);
type
  PMinMaxInfo = ^TMinMaxInfo;
  TMinMaxInfo = array[0..4] of TPoint;
begin
  PMinMaxInfo(Msg.LParam)^[3].X := 24;
  PMinMaxInfo(Msg.LParam)^[3].Y := 24;
end;

{ wm_Move message handler. Updates the window location in the Attr field
  and marks the main window as modified. }

procedure TObjectWindow.WMMove(var Msg: TMessage);
begin
  if (Attr.X <> Integer(Msg.LParamLo)) or
    (Attr.Y <> Integer(Msg.LParamHi)) then
  begin
    Attr.X := Integer(Msg.LParamLo);
    Attr.Y := Integer(Msg.LParamHi);
    MainWindow^.Modified := True;
  end;
end;

{ wm_Size message handler. Updates the window size in the Attr field and
  marks the main window as modified. }

procedure TObjectWindow.WMSize(var Msg: TMessage);
begin
  if (Attr.W <> Msg.LParamLo) or (Attr.H <> Msg.LParamHi) then
  begin
    Attr.W := Msg.LParamLo;
    Attr.H := Msg.LParamHi;
    MainWindow^.Modified := True;
  end;
end;

{ wm_LButtonDown message handler. Brings the window to front and selects
  it, causing a frame to be drawn around the window. If a dragging
  operation is not in effect, one is initiated by capturing the mouse
  and recording the initial dragging location. }

procedure TObjectWindow.WMLButtonDown(var Msg: TMessage);
begin
  BringToFront;
  MainWindow^.SelectWindow(@Self);
  if not Dragging then
  begin
    Dragging := True;
    SetCapture(HWindow);
    DragPoint := TPoint(Msg.LParam);
    ClientToScreen(HWindow, DragPoint);
  end;
end;

{ wm_MouseMove message handler. If a dragging operation is in effect,
  the window is moved and the client area of the parent window is
  repainted. }

procedure TObjectWindow.WMMouseMove(var Msg: TMessage);
var
  P: TPoint;
  R: TRect;
begin
  if Dragging then
  begin
    P := TPoint(Msg.LParam);
    ClientToScreen(HWindow, P);
    GetBounds(R);
    OffsetRect(R, P.X - DragPoint.X, P.Y - DragPoint.Y);
    SetBounds(R);
    UpdateWindow(Parent^.HWindow);
    DragPoint := P;
  end;
end;

{ wm_LButtonUp message handler. Terminates a dragging operation. }

procedure TObjectWindow.WMLButtonUp(var Msg: TMessage);
begin
  if Dragging then
  begin
    ReleaseCapture;
    Dragging := False;
  end;
end;

{ wm_LButtonDblClk message handler. Opens the contained OLE object by
  executing its primary verb. This is typically an 'Edit' or 'Play'
  operation. }

procedure TObjectWindow.WMLButtonDblClk(var Msg: TMessage);
begin
  OpenObject(oleverb_Primary);
end;

{ TMainWindow methods }

{ Construct the application's main window. Loads the main menu and
  creates an OLE document. }

constructor TMainWindow.Init;
var
  P: PObjectWindow;
begin
  MainWindow := @Self;
  TWindow.Init(nil, nil);
  Attr.Menu := LoadMenu(HInstance, PChar(id_Menu));
  ObjectWindow := nil;
end;

{ Destroy the application's main window. Destroys the contained OLE
  document. }

destructor TMainWindow.Done;
begin
  DoneDocument;
  TWindow.Done;
end;

{ Determine whether the main window can close. Checks whether the
  contained OLE object windows can close, and then prompts the user if
  any modifications have been made since the file was opened or saved. }

function TMainWindow.CanClose: Boolean;
begin
  CanClose := False;
  if TWindow.CanClose then
  begin
    CanClose := True;
    if Modified then
      case Message('Save current changes?',
        mb_IconExclamation + mb_YesNoCancel) of
        id_Yes: CanClose := Save;
        id_Cancel: CanClose := False;
      end;
  end;
end;

{ Set the initial file name to untitled }

procedure TMainWindow.SetupWindow;
begin
  inherited SetupWindow;
  SetFilename('');
  InitDocument;
end; 

{ Create the main window's OLE document. }

procedure TMainWindow.InitDocument;
var
  P: PChar;
begin
  P := Filename;
  if P[0] = #0 then P := 'Untitled';
  OleRegisterClientDoc('OleClntDemo', P, 0, ClientDoc);
  Modified := False;
end;

{ Destroy the main window's OLE document. The contained OLE object
  windows are destroyed before the document. }

procedure TMainWindow.DoneDocument;

  procedure FreeObjectWindow(P: PObjectWindow); far;
  begin
    P^.Free;
  end;

begin
  ForEach(@FreeObjectWindow);
  OleRevokeClientDoc(ClientDoc);
end;

{ Update the main window's OLE document. Each object window is checked
  to see if it contains a linked OLE object, and if so, the user is given
  the option to update the link. }

procedure TMainWindow.UpdateDocument;
var
  Prompted, DoUpdate: Boolean;

  procedure UpdateObjectWindow(P: PObjectWindow); far;
  begin
    if P^.IsLinked then
    begin
      if not Prompted then
      begin
        DoUpdate := Message('This file contains linked objects.'#13 +
          'Update links now?',
          mb_IconExclamation + mb_YesNo) = id_Yes;
        Prompted := True;
      end;
      if DoUpdate then P^.Update;
    end;
  end;

begin
  Prompted := False;
  ForEach(@UpdateObjectWindow);
end;

{ Set the name of the file in the main window. Updates the title of the
  main window to include the base part of the filename. }

procedure TMainWindow.SetFilename(Name: PChar);
var
  Params: array[0..1] of PChar;
  Title: array[0..63] of Char;
begin
  StrCopy(Filename, Name);
  Params[0] := OleClntTitle;
  if Name[0] = #0 then Params[1] := '(Untitled)' else
  begin
    Params[1] := StrRScan(Name, '\');
    if Params[1] = nil then Params[1] := Name else Inc(Params[1]);
  end;
  wvsprintf(Title, '%s - %s', Params);
  if hWindow <> 0 then SetCaption(Title);
end;

{ Load a file into the main window. If the file does not exist, a new
  file is created. Otherwise, the file header is checked, and the
  contained OLE object windows are read from the stream. }

function TMainWindow.LoadFile: Boolean;
var
  Header: TOleFileHeader;
  S: TBufStream;
begin
  LoadFile := False;
  S.Init(Filename, stOpenRead, 4096);
  if S.Status = 0 then
  begin
    S.Read(Header, SizeOf(TOleFileHeader));
    if Longint(Header) = Longint(OleFileHeader) then
    begin
      GetChildren(S);
      if (S.Status = 0) and CreateChildren then
      begin
        UpdateDocument;
        LoadFile := True;
      end else
        Error('Error reading file %s.', Filename);
    end else
      Error('File format error %s.', Filename);
  end else
    LoadFile := True;
  S.Done;
end;

{ Save the file in the main window. The OLE client library is notified if
  the file was successfully saved. }

function TMainWindow.SaveFile: Boolean;
var
  S: TBufStream;
begin
  SaveFile := False;
  S.Init(Filename, stCreate, 4096);
  if S.Status = 0 then
  begin
    S.Write(OleFileHeader, SizeOf(TOleFileHeader));
    PutChildren(S);
    if S.Status = 0 then
    begin
      OleSavedClientDoc(ClientDoc);
      Modified := False;
      SaveFile := True;
    end else
      Error('Error writing file %s.', Filename);
  end else
    Error('Error creating file %s.', Filename);
  S.Done;
end;

{ Open a new or existing file. The current OLE document is destroyed, a
  new document is created, and the file is loaded. }

function TMainWindow.NewFile(Name: PChar): Boolean;
begin
  DoneDocument;
  SetFilename(Name);
  InitDocument;
  if Filename[0] <> #0 then NewFile := LoadFile else NewFile := True;
end;

{ Save the current file. If the file is untitled, prompt the user for a
  name. }

function TMainWindow.Save: Boolean;
begin
  if Filename[0] = #0 then Save := SaveAs else Save := SaveFile;
end;

{ Save the current file under a new name. The OLE client library is
  informed that the document has been renamed. }

function TMainWindow.SaveAs: Boolean;
var
  Name: TFilename;
begin
  SaveAs := False;
  StrCopy(Name, Filename);
  if FileDialog(HWindow, Name, True) then
  begin
    SetFilename(Name);
    OleRenameClientDoc(ClientDoc, Name);
    SaveAs := SaveFile;
  end;
end;

{ Create a new OLE object window using data in the clipboard. The Link
  parameter determines whether to create an embedded object or a linked
  object. }

procedure TMainWindow.NewObjectWindow(Link: Boolean);
begin
  OpenClipboard(HWindow);
  SelectWindow(PObjectWindow(Application^.MakeWindow(
    New(PObjectWindow, Init(Link)))));
  CloseClipboard;
end;

{ Select a given OLE object window. }

procedure TMainWindow.SelectWindow(Window: PObjectWindow);
begin
  if ObjectWindow <> Window then
  begin
    if ObjectWindow <> nil then ObjectWindow^.ShowFrame(False);
    ObjectWindow := Window;
    if ObjectWindow <> nil then ObjectWindow^.ShowFrame(True);
  end;
end;

{ Update the Edit|Object menu. The Registration Database is queried to
  find the readable version of the class name of the current OLE object,
  along with the list of verbs supported by the class. If the class
  supports more than one verb, the verbs are put on a popup submenu. }

procedure TMainWindow.UpdateObjectMenu;
var
  VerbFound: Boolean;
  VerbCount: Word;
  EditMenu, PopupMenu: HMenu;
  Size: Longint;
  Params: array[0..1] of Pointer;
  ClassName, ClassText, Verb: array[0..31] of Char;
  Buffer: array[0..255] of Char;
begin
  EditMenu := GetSubMenu(Attr.Menu, pos_Edit);
  DeleteMenu(EditMenu, pos_Object, mf_ByPosition);
  if ObjectWindow <> nil then
  begin
    ObjectWindow^.GetObjectClass(ClassName);
    if ClassName[0] <> #0 then
    begin
      Size := SizeOf(ClassText);
      if RegQueryValue(hkey_Classes_Root, ClassName,
        ClassText, Size) = 0 then
      begin
        PopupMenu := CreatePopupMenu;
        VerbCount := 0;
        repeat
          Params[0] := @ClassName;
          Params[1] := Pointer(VerbCount);
          wvsprintf(Buffer, '%s\protocol\StdFileEditing\verb\%d', Params);
          Size := SizeOf(Verb);
          VerbFound := RegQueryValue(hkey_Classes_Root,
            Buffer, Verb, Size) = 0;
          if VerbFound then
          begin
            InsertMenu(PopupMenu, VerbCount, mf_ByPosition,
              cm_VerbMin + VerbCount, Verb);
            Inc(VerbCount);
          end;
        until not VerbFound;
        if VerbCount <= 1 then
        begin
          if VerbCount = 0 then
            Params[0] := PChar('Edit') else
            Params[0] := @Verb;
          Params[1] := @ClassText;
          wvsprintf(Buffer, '%s %s &Object', Params);
          InsertMenu(EditMenu, pos_Object, mf_ByPosition,
            cm_VerbMin, Buffer);
          DestroyMenu(PopupMenu);
        end else
        begin
          Params[0] := @ClassText;
          wvsprintf(Buffer, '%s &Object', Params);
          InsertMenu(EditMenu, pos_Object, mf_ByPosition + mf_Popup,
            PopupMenu, Buffer);
        end;
        Exit;
      end;
    end;
  end;
  InsertMenu(EditMenu, pos_Object, mf_ByPosition + mf_Grayed,
    0, '&Object');
end;

{ wm_LButtonDown message handler. Deselects the current OLE object
  window. }

procedure TMainWindow.WMLButtonDown(var Msg: TMessage);
begin
  SelectWindow(nil);
end;

{ wm_InitMenu message handler. Updates the Edit menu. }

procedure TMainWindow.WMInitMenu(var Msg: TMessage);
var
  HasSelection: Boolean;

  procedure SetMenuItem(Item: Word; Enable: Boolean);
  var
    Flags: Word;
  begin
    if Enable then Flags := mf_Enabled else Flags := mf_Grayed;
    EnableMenuItem(Attr.Menu, Item, Flags);
  end;

begin
  HasSelection := ObjectWindow <> nil;
  SetMenuItem(cm_EditCut, HasSelection);
  SetMenuItem(cm_EditCopy, HasSelection);
  SetMenuItem(cm_EditClear, HasSelection);
  SetMenuItem(cm_EditPaste, OleQueryCreateFromClip(
    OleProtocol, olerender_Draw, 0) = ole_OK);
  SetMenuItem(cm_EditPasteLink, OleQueryLinkFromClip(
    OleProtocol, olerender_Draw, 0) = ole_OK);
  UpdateObjectMenu;
end;

{ File|New command handler. Checks whether the current file can be
  closed, and creates a new untitled file if possible. }

procedure TMainWindow.CMFileNew(var Msg: TMessage);
begin
  if CanClose then NewFile('');
end;

{ File|Open command handler. Checks whether the current file can be
  closed, and opens a new file if possible. }

procedure TMainWindow.CMFileOpen(var Msg: TMessage);
var
  Name: TFilename;
begin
  if CanClose then
  begin
    Name[0] := #0;
    if FileDialog(HWindow, Name, False) then
      if not NewFile(Name) then NewFile('');
  end;
end;

{ File|Save command handler. }

procedure TMainWindow.CMFileSave(var Msg: TMessage);
begin
  Save;
end;

{ File|Save as command handler. }

procedure TMainWindow.CMFileSaveAs(var Msg: TMessage);
begin
  SaveAs;
end;

{ File|Exit command handler. }

procedure TMainWindow.CMFileExit(var Msg: TMessage);
begin
  CloseWindow;
end;

{ Edit|Cut command handler. Performs a Copy followed by a Clear. }

procedure TMainWindow.CMEditCut(var Msg: TMessage);
begin
  CMEditCopy(Msg);
  CMEditClear(Msg);
end;

{ Edit|Copy command handler. If an OLE object window is currently
  selected, the clipboard is emptied, and the OLE object window is
  instructed to copy the contained OLE object to the clipboard. }

procedure TMainWindow.CMEditCopy(var Msg: TMessage);
begin
  if ObjectWindow <> nil then
  begin
    OpenClipBoard(HWindow);
    EmptyClipBoard;
    ObjectWindow^.CopyToClipboard;
    CloseClipBoard;
  end;
end;

{ Edit|Paste command handler. Creates an embedded OLE object. }

procedure TMainWindow.CMEditPaste(var Msg: TMessage);
begin
  NewObjectWindow(False);
end;

{ Edit|Paste link command handler. Creates a linked OLE object. }

procedure TMainWindow.CMEditPasteLink(var Msg: TMessage);
begin
  NewObjectWindow(True);
end;

{ Edit|Clear command handler. Deletes the currently selected OLE object
  window, if possible. }

procedure TMainWindow.CMEditClear(var Msg: TMessage);
begin
  if ObjectWindow <> nil then
    if ObjectWindow^.CanClose then ObjectWindow^.Delete;
end;

{ Help|About command handler. Brings up the About box. }

procedure TMainWindow.CMHelpAbout(var Msg: TMessage);
begin
  Application^.ExecDialog(New(PDialog, Init(@Self, PChar(id_About))));
end;

{ Default command handler method. Called when no explicit command handler
  can be found. If the command is within the range reserved for OLE
  object verbs, the current OLE object window is instructed to execute
  the verb. }

procedure TMainWindow.DefCommandProc(var Msg: TMessage);
begin
  if (Msg.WParam >= cm_VerbMin) and (Msg.WParam <= cm_VerbMax) then
  begin
    if ObjectWindow <> nil then
      ObjectWindow^.OpenObject(Msg.WParam - cm_VerbMin);
  end else
    TWindow.DefCommandProc(Msg);
end;

{ TApp methods }

{ Construct the application object. Queries the pixels-per-inch ratios
  of the display for later use in conversions between mm_HiMetric and
  mm_Text coordinates. Creates callback procedure instances for the OLE
  client and OLE stream virtual tables. Registers the OwnerLink and
  ObjectLink clipboard formats for later use in OleGetData calls.
  Registers TObjectWindow for stream I/O. }

constructor TApp.Init(AName: PChar);
var
  DC: HDC;
begin
  TApplication.Init(AName);
  DC := GetDC(0);
  PixPerInch.X := GetDeviceCaps(DC, logPixelsX);
  PixPerInch.Y := GetDeviceCaps(DC, logPixelsY);
  ReleaseDC(0, DC);
  @OleClientVTbl.CallBack := MakeProcInstance(@ClientCallBack, HInstance);
  @OleStreamVTbl.Get := MakeProcInstance(@StreamGet, HInstance);
  @OleStreamVTbl.Put := MakeProcInstance(@StreamPut, HInstance);
  CFOwnerLink := RegisterClipboardFormat('OwnerLink');
  CFObjectLink := RegisterClipboardFormat('ObjectLink');
  RegisterType(RObjectWindow);
end;

{ Destroy the application object. Frees the OLE client and OLE stream
  virtual table procedure instances. }

destructor TApp.Done;
begin
  FreeProcInstance(@OleClientVTbl.CallBack);
  FreeProcInstance(@OleStreamVTbl.Get);
  FreeProcInstance(@OleStreamVTbl.Put);
  TApplication.Done;
end;

{ Create the main window. }

procedure TApp.InitMainWindow;
begin
  MainWindow := New(PMainWindow, Init);
end;

{ Main program }

begin
  App.Init('OleClntDemo');
  App.Run;
  App.Done;
end.
