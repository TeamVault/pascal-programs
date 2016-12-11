{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program ProgTalk;

uses WinTypes, WinProcs, OWindows, ODialogs, Strings;

{$R PROGTALK}

const

{ Resource IDs }

  id_DDEDialog    = 100;
  id_AddDialog    = 101;
  id_CreateDialog = 102;

{ DDE dialog item IDs }

  id_ListBox     = 100;
  id_AddItem     = 101;
  id_DeleteItem  = 102;
  id_ClearItems  = 103;
  id_CreateGroup = 104;

{ Add and Create dialog item IDs }

  id_InputLine = 100;

type

{ TInputDialog is the object type used to represent the Add Item and
  Create Group dialogs. }

  PInputDialog = ^TInputDialog;
  TInputDialog = object(TDialog)
    Buffer: PChar;
    BufferSize: Word;
    constructor Init(AParent: PWindowsObject;
      AName, ABuffer: PChar; ABufferSize: Word);
    procedure SetupWindow; virtual;
    function CanClose: Boolean; virtual;
    procedure InputLine(var Msg: TMessage);
      virtual id_First + id_InputLine;
  end;

{ TDDEWindow is the main window of the application. It engages in a DDE
  conversation with the Program Manager to create program groups with a
  user specified list of program items. }

  PDDEWindow = ^TDDEWindow;
  TDDEWindow = object(TDlgWindow)
    ListBox: PListBox;
    ServerWindow: HWnd;
    PendingMessage: Word;
    constructor Init;
    procedure SetupWindow; virtual;
    function GetClassName: PChar; virtual;
    procedure InitiateDDE;
    procedure TerminateDDE;
    procedure AddItem(var Msg: TMessage);
      virtual id_First + id_AddItem;
    procedure DeleteItem(var Msg: TMessage);
      virtual id_First + id_DeleteItem;
    procedure ClearItems(var Msg: TMessage);
      virtual id_First + id_ClearItems;
    procedure CreateGroup(var Msg: TMessage);
      virtual id_First + id_CreateGroup;
    procedure WMDDEAck(var Msg: TMessage);
      virtual wm_First + wm_DDE_Ack;
    procedure WMDDETerminate(var Msg: TMessage);
      virtual wm_First + wm_DDE_Terminate;
    procedure WMDestroy(var Msg: TMessage);
      virtual wm_First + wm_Destroy;
  end;

{ TDDEApp is the application object. It creates a main window of type
  TDDEWindow. }

  TDDEApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

{ TInputDialog }

{ Input dialog constructor. Save the input buffer pointer and size
  for later use. }

constructor TInputDialog.Init(AParent: PWindowsObject;
  AName, ABuffer: PChar; ABufferSize: Word);
begin
  TDialog.Init(AParent, AName);
  Buffer := ABuffer;
  BufferSize := ABufferSize;
end;

{ SetupWindow is called right after the dialog is created. Limit the
  edit control to the maximum length of the input buffer, and disable
  the Ok button. }

procedure TInputDialog.SetupWindow;
begin
  SendDlgItemMessage(HWindow, id_InputLine, em_LimitText,
    BufferSize - 1, 0);
  EnableWindow(GetDlgItem(HWindow, id_Ok), False);
end;

{ CanClose is called when the user presses Ok. Copy the contents of
  the edit control to the input buffer and return True to allow the
  dialog to close. }

function TInputDialog.CanClose: Boolean;
begin
  GetDlgItemText(HWindow, id_InputLine, Buffer, BufferSize);
  CanClose := True;
end;

{ Edit control response method. Enable or disable the Ok button
  based on whether the edit control contains any text. }

procedure TInputDialog.InputLine(var Msg: TMessage);
begin
  if Msg.LParamHi = en_Change then
    EnableWindow(GetDlgItem(HWindow, id_Ok),
      SendMessage(Msg.LParamLo, wm_GetTextLength, 0, 0) <> 0);
end;

{ TDDEWindow }

{ DDE window constructor. Create a TListBox object to represent the
  dialog's list box. Clear the DDE server window handle and the
  pending DDE message ID. }

constructor TDDEWindow.Init;
begin
  TDlgWindow.Init(nil, PChar(id_DDEDialog));
  ListBox := New(PListBox, InitResource(@Self, id_ListBox));
  ServerWindow := 0;
  PendingMessage := 0;
end;

{ SetupWindow is called right after the DDE window is created.
  Initiate the DDE conversation. }

procedure TDDEWindow.SetupWindow;
begin
  TDlgWindow.SetupWindow;
  InitiateDDE;
end;

{ Return window class name. This name corresponds to the class name
  specified for the DDE dialog in the resource file. }

function TDDEWindow.GetClassName: PChar;
begin
  GetClassName := 'DDEWindow';
end;

{ Initiate a DDE conversation with the Program Manager. Bring up a
  message box if the Program Manager doesn't respond to the
  wm_DDE_Initiate message. }

procedure TDDEWindow.InitiateDDE;
var
  AppAtom, TopicAtom: TAtom;
begin
  PendingMessage := wm_DDE_Initiate;
  AppAtom := GlobalAddAtom('PROGMAN');
  TopicAtom := GlobalAddAtom('PROGMAN');
  SendMessage(HWnd(-1), wm_DDE_Initiate, HWindow,
    MakeLong(AppAtom, TopicAtom));
  GlobalDeleteAtom(AppAtom);
  GlobalDeleteAtom(TopicAtom);
  PendingMessage := 0;
  if ServerWindow = 0 then
    MessageBox(HWindow, 'Cannot establish DDE link to Program Manager.',
      'Error', mb_IconExclamation or mb_Ok);
end;

{ Terminate the DDE conversation. Send the wm_DDE_Terminate message
  only if the server window still exists. }

procedure TDDEWindow.TerminateDDE;
var
  W: HWnd;
begin
  W := ServerWindow;
  ServerWindow := 0;
  if IsWindow(W) then PostMessage(W, wm_DDE_Terminate, HWindow, 0);
end;

{ Add item button response method. Bring up the Add item dialog to
  input a program item string, and add that item to the list box. }

procedure TDDEWindow.AddItem(var Msg: TMessage);
var
  Name: array[0..63] of Char;
begin
  if Application^.ExecDialog(New(PInputDialog, Init(@Self,
    PChar(id_AddDialog), Name, SizeOf(Name)))) <> id_Cancel then
    ListBox^.AddString(Name);
end;

{ Delete item button response method. Delete the currently selected
  item in the list box. }

procedure TDDEWindow.DeleteItem(var Msg: TMessage);
begin
  ListBox^.DeleteString(ListBox^.GetSelIndex);
end;

{ Clear items button response method. Clear the list box. }

procedure TDDEWindow.ClearItems(var Msg: TMessage);
begin
  ListBox^.ClearList;
end;

{ Create group button response method. Bring up the Create Group
  dialog to input the program group name. Then, if a DDE link has
  been established (ServerWindow <> 0) and there is no DDE message
  currently pending (PendingMessage = 0), build a list of Program
  Manager commands, and submit the commands using a wm_DDE_Execute
  message. To build the command list, first calculate the total
  length of the list, then allocate a global memory block of that
  size, and finally store the command list as a null-terminated
  string in the memory block. }

procedure TDDEWindow.CreateGroup(var Msg: TMessage);
const
  sCreateGroup = '[CreateGroup(%s)]';
  sAddItem = '[AddItem(%s)]';
var
  Executed: Boolean;
  I, L: Integer;
  HCommands: THandle;
  PName, PCommands: PChar;
  Name: array[0..63] of Char;
begin
  if Application^.ExecDialog(New(PInputDialog, Init(@Self,
    PChar(id_CreateDialog), Name, SizeOf(Name)))) <> id_Cancel then
  begin
    Executed := False;
    if (ServerWindow <> 0) and (PendingMessage = 0) then
    begin
      L := StrLen(Name) + (Length(sCreateGroup) - 1);
      for I := 0 to ListBox^.GetCount - 1 do
        Inc(L, ListBox^.GetStringLen(I) + (Length(sAddItem) - 2));
      HCommands := GlobalAlloc(gmem_Moveable or gmem_DDEShare, L);
      if HCommands <> 0 then
      begin
        PName := Name;
        PCommands := GlobalLock(HCommands);
        WVSPrintF(PCommands, sCreateGroup, PName);
        for I := 0 to ListBox^.GetCount - 1 do
        begin
          ListBox^.GetString(Name, I);
          PCommands := StrEnd(PCommands);
          WVSPrintF(PCommands, sAddItem, PName);
        end;
        GlobalUnlock(HCommands);
        if PostMessage(ServerWindow, wm_DDE_Execute, HWindow,
          MakeLong(0, HCommands)) then
        begin
          PendingMessage := wm_DDE_Execute;
          Executed := True;
        end else GlobalFree(HCommands);
      end;
    end;
    if not Executed then
      MessageBox(HWindow, 'Program Manager DDE execute failed.',
        'Error', mb_IconExclamation or mb_Ok);
  end;
end;

{ wm_DDE_Ack message response method. If the current DDE message
  is a wm_DDE_Initiate, store off the window handle of the window
  that responded. If more than one window responds, terminate all
  conversations but the first. If the current DDE message is a
  wm_DDE_Execute, free the command string memory block, focus our
  window, and clear the list box. }

procedure TDDEWindow.WMDDEAck(var Msg: TMessage);
begin
  case PendingMessage of
    wm_DDE_Initiate:
      begin
        if ServerWindow = 0 then
          ServerWindow := Msg.WParam
        else
          PostMessage(Msg.WParam, wm_DDE_Terminate, HWindow, 0);
        GlobalDeleteAtom(Msg.LParamLo);
        GlobalDeleteAtom(Msg.LParamHi);
      end;
    wm_DDE_Execute:
      begin
        GlobalFree(Msg.LParamHi);
        PendingMessage := 0;
        SetFocus(HWindow);
        ListBox^.ClearList;
      end;
  end;
end;

{ wm_DDE_Terminate message response method. If the window signaling
  termination is our server window (the Program Manager), terminate
  the DDE conversation. Otherwise ignore the wm_DDE_Terminate. }

procedure TDDEWindow.WMDDETerminate(var Msg: TMessage);
begin
  if Msg.WParam = ServerWindow then TerminateDDE;
end;

{ wm_Destroy message response method. Terminate the DDE link and
  call the inherited WMDestroy. }

procedure TDDEWindow.WMDestroy(var Msg: TMessage);
begin
  TerminateDDE;
  TDlgWindow.WMDestroy(Msg);
end;

{ TDDEApp }

{ Create a DDE window as the application's main window. }

procedure TDDEApp.InitMainWindow;
begin
  MainWindow := New(PDDEWindow, Init);
end;

var
  DDEApp: TDDEApp;

begin
  DDEApp.Init('ProgTalk');
  DDEApp.Run;
  DDEApp.Done;
end.
