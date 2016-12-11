{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program HelpEx;

{ ObjectWindows version of the HelpEx example program }

{$R OWLHELP.RES}

uses WinTypes, WinProcs, Strings, OWindows, ODialogs;

const
  cm_Print  = 104;

  { Help Items }
  cm_About        = 300;
  cm_HelpIndex    = 301;
  cm_HelpKeyboard = 302;
  cm_HelpHelp     = 303;

  ExeNameMaxSize = 128;

  { Help contexts }
  hc_EditClear = 100;
  hc_EditCopy  = 101;
  hc_EditCut   = 102;
  hc_EditPaste = 103;
  hc_EditUndo  = 104;
  hc_FileExit   = 200;
  hc_FileNew    = 201;
  hc_FileOpen   = 202;
  hc_FilePrint  = 203;
  hc_FileSave   = 204;
  hc_FileSaveAs = 205;
  hc_EditWindow   = 300;
  hc_MaximizeIcon = 301;
  hc_MinimizeIcon = 302;
  hc_SystemMenu   = 303;
  hc_TitleBar     = 306;
  hc_SizingBorder = 307;

type
  THelpExApp = object(TApplication)
    procedure InitMainWindow; virtual;
    procedure InitInstance; virtual;
  end;

  PHelpExWindow = ^THelpExWindow;
  THelpExWindow = object(TWindow)
    Help: Boolean;
    HelpCursor: HCursor;
    HelpFileName: PChar;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    destructor Done; virtual;
    procedure NotImplemented;
    procedure WMCommand(var Message: TMessage);
      virtual wm_First + wm_Command;
    procedure WMLButtonDown(var Message: TMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMKeyDown(var Message: TMessage);
      virtual wm_First + wm_KeyDown;
    procedure WMSetCursor(var Message: TMessage);
      virtual wm_First + wm_SetCursor;
    procedure WMInitMenu(var Message: TMessage);
      virtual wm_First + wm_InitMenu;
    procedure WMEnterIdle(var Message: TMessage);
      virtual wm_First + wm_EnterIdle;
    procedure WMDestroy(var Message: TMessage);
      virtual wm_First + wm_Destroy;
    procedure WMNCLButtonDown(var Message: TMessage);
      virtual wm_First + wm_NCLButtonDown;
    procedure CMFileNew(var Message: TMessage);
      virtual cm_First + cm_FileNew;
    procedure CMFileOpen(var Message: TMessage);
      virtual cm_First + cm_FileOpen;
    procedure CMFileSave(var Message: TMessage);
      virtual cm_First + cm_FileSave;
    procedure CMFileSaveAs(var Message: TMessage);
      virtual cm_First + cm_FileSaveAs;
    procedure CMPrint(var Message: TMessage);
      virtual cm_First + cm_Print;
    procedure CMEditUndo(var Message: TMessage);
      virtual cm_First + cm_EditUndo;
    procedure CMEditCut(var Message: TMessage);
      virtual cm_First + cm_EditCut;
    procedure CMEditClear(var Message: TMessage);
      virtual cm_First + cm_EditClear;
    procedure CMEditCopy(var Message: TMessage);
      virtual cm_First + cm_EditCopy;
    procedure CMEditPaste(var Message: TMessage);
      virtual cm_First + cm_EditPaste;
    procedure CMHelpIndex(var Message: TMessage);
      virtual cm_First + cm_HelpIndex;
    procedure CMHelpKeyBoard(var Message: TMessage);
      virtual cm_First + cm_HelpKeyBoard;
    procedure CMHelpHelp(var Message: TMessage);
      virtual cm_First + cm_HelpHelp;
    procedure CMAbout(var Message: TMessage);
     virtual cm_First + cm_About;
  end;

{ THelpExApp }
procedure THelpExApp.InitMainWindow;
begin
  MainWindow := New(pHelpExWindow, Init(nil, 'HelpEx'));
end;

procedure THelpExApp.InitInstance;
begin
  TApplication.InitInstance;
  if Status = 0 then
    HAccTable := LoadAccelerators(HInstance, 'HELPEXACC');
end;

{ THelpExWindow }
constructor THelpExWindow.Init;
var
  FileNameLen: Integer;
  FileName: array[0..ExeNameMaxSize + 1] of Char;
  I: Integer;
begin
  { Get Menu from the Resource File }
  TWindow.Init(AParent, ATitle);
  Attr.Menu := LoadMenu(HInstance, 'HELPEXMENU');

  { Construct HelpFileName from Module Name }
  FileNameLen := GetModuleFileName(HInstance, FileName, ExeNameMaxSize);
  I := FileNameLen - 1;
  while (I <> 0) and ((FileName[I] <> '\') and (FileName[I] <> ':')) do
    Dec(I);
  Inc(I);
  if I + 13 <= ExeNameMaxSize then
    StrCopy(@FileName[I], 'helpex.hlp')
  else
    StrCopy(@FileName[I], '?');
  HelpFileName := StrNew(FileName);

  {Load the Cursor from from the Resource }
  HelpCursor := LoadCursor(HInstance, 'HELPCURSOR');
  Help := False;
end;

destructor THelpExWindow.Done;
begin
  TWindow.Done;
  StrDispose(HelpFileName);
end;

procedure THelpExWindow.NotImplemented;
begin
  Messagebox(HWindow, 'Command not Implemented', 'Help Example', mb_Ok);
end;

procedure THelpExWindow.WMCommand;
var
  HelpContextId: LongInt;
begin
  if Help then
  begin

    { Determine the Appropriate Help Context }
    case Message.wParam of
      cm_FileNew: HelpContextId := hc_FileNew;
      cm_FileOpen: HelpContextId := hc_FileOpen;
      cm_FileSave: HelpContextId := hc_FileSave;
      cm_FileSaveAs: HelpContextId := hc_FileSaveAs;
      cm_Print: HelpContextId := hc_FilePrint;
      cm_Exit: HelpContextId := hc_FileExit;
      cm_EditUndo: HelpContextId := hc_EditUndo;
      cm_EditCut: HelpContextId := hc_EditCut;
      cm_EditClear: HelpContextId := hc_EditClear;
      cm_EditCopy: HelpContextId := hc_EditCopy;
      cm_EditPaste: HelpContextId := hc_EditPaste;
    else
      HelpContextId := 0;
    end;

    { Warn of No Context Help Available }
    { or Let the Help System take over. }
    if HelpContextId = 0 then
    begin
      MessageBox(HWindow, 'Help not available for Help Menu Item',
        'Help Example', Mb_Ok);
      DefWndProc(Message);
    end
    else
    begin
      Help := False;
      WinHelp(HWindow, HelpFileName, Help_Context, HelpContextId);
    end;
  end
  else TWindow.WMCommand(Message);
end;

{ Handles the Press of the Left Button of the Mouse }
procedure THelpExWindow.WMLButtonDown;
begin
  if Help then
  begin
    Help := False;
    WinHelp(HWindow,HelpFileName, Help_Context, hc_EditWindow);
  end
  else DefWndProc(Message);
end;

{ Responds to normal keypresses }
procedure THelpExWindow.WMKeyDown;
begin
  if Message.wParam = vk_F1 then
    if GetKeyState(vk_Shift) < 0 then
    begin
      Help := True;
      SetCursor(HelpCursor);
      DefWndProc(Message);
    end
    else WinHelp(HWindow, HelpFileName, Help_Index, 0)
  else if (Message.wParam = vk_Escape) and Help then
  begin
    Help := False;
    SetCursor(HCursor(GetClassWord(HWindow, gcw_HCursor)));
  end;
end;

{ Sets the Help Cursor if appropriate }
procedure THelpExWindow.WMSetCursor;
begin
  if Help then
    SetCursor(HelpCursor)
  else DefWndProc(Message);
end;

{ Sets the Help Cursor if appropriate }
procedure THelpExWindow.WMInitMenu;
begin
  if Help then
    SetCursor(HelpCursor);
end;

{ Select Help during Idle }
procedure THelpExWindow.WMEnterIdle;
begin
  if ((Message.wParam = msgf_Menu) and ((GetKeyState(vk_F1)
    and $8000) <> 0)) then
  begin
    Help := True;
    PostMessage(HWindow, wm_KeyDown, vk_Return, 0);
  end;
end;

{ Shut Down the Help System and post Quit }
procedure THelpExWindow.WMDestroy;
begin
  WinHelp(HWindow, HelpFileName, help_Quit, 0);
  PostQuitMessage(0);
end;

{ Handle Help outside Client Window }
procedure THelpExWindow.WMNCLButtonDown;
var
  HelpContextId: LongInt;
begin
  if Help then
  begin
    case Message.wParam of
      htCaption: HelpContextId := hc_TitleBar;
      htReduce: HelpContextId := hc_MinimizeIcon;
      htZoom: HelpContextId := hc_MaximizeIcon;
      htSysMenu: HelpContextId := hc_SystemMenu;
      htBottom: HelpContextId := hc_SizingBorder;
      htBottomLeft: HelpContextId := hc_SizingBorder;
      htBottomRight: HelpContextId := hc_SizingBorder;
      htTop: HelpContextId := hc_SizingBorder;
      htLeft: HelpContextId := hc_SizingBorder;
      htRight: HelpContextId := hc_SizingBorder;
      htTopLeft: HelpContextId := hc_SizingBorder;
      htTopRight: HelpContextId := hc_SizingBorder;
    else
      HelpContextId := 0;
    end;
    if HelpContextId <> 0 then
    begin
      Help := False;
      WinHelp(HWindow, HelpFileName, Help_Context, HelpContextId);
    end
    else DefWndProc(Message);
  end
  else DefWndProc(Message);
end;

procedure THelpExWindow.CMFileNew(var Message: TMessage);
begin
  NotImplemented;
end;

procedure THelpExWindow.CMFileOpen(var Message: TMessage);
begin
  NotImplemented;
end;

procedure THelpExWindow.CMFileSave(var Message: TMessage);
begin
  NotImplemented
end;

procedure THelpExWindow.CMFileSaveAs(var Message: TMessage);
begin
  NotImplemented;
end;

procedure THelpExWindow.CMPrint(var Message: TMessage);
begin
  NotImplemented;
end;

procedure THelpExWindow.CMEditUndo(var Message: TMessage);
begin
  NotImplemented;
end;

procedure THelpExWindow.CMEditCut(var Message: TMessage);
begin
  NotImplemented;
end;

procedure THelpExWindow.CMEditClear(var Message: TMessage);
begin
  NotImplemented;
end;

procedure THelpExWindow.CMEditCopy(var Message: TMessage);
begin
  NotImplemented;
end;

procedure THelpExWindow.CMEditPaste(var Message: TMessage);
begin
  NotImplemented;
end;

procedure THelpExWindow.CMHelpIndex(var Message: TMessage);
begin
  WinHelp(HWindow, HelpFileName, Help_Index, 0);
end;

procedure THelpExWindow.CMHelpKeyBoard(var Message: TMessage);
begin
  WinHelp(HWindow, HelpFileName, Help_Key, LongInt(PChar('keys')));
end;

procedure THelpExWindow.CMHelpHelp(var Message: TMessage);
begin
  WinHelp(HWindow, 'WINHELP.HLP', Help_Index, 0);
end;

procedure THelpExWindow.CMAbout(var Message: TMessage);
begin
  Application^.ExecDialog(New(PDialog, Init(@Self, 'ABOUTBOX')));
end;

var
  HelpExApp:THelpExApp;

begin
  HelpExApp.Init('HelpEx');
  HelpExApp.Run;
  HelpExApp.Done;
end.
