{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program HelpEx;

{$X+}

{$R HELPEX.RES}

uses WinTypes, WinProcs, Strings;

const

  { File Menu Items }

  IdmNew    = 100;
  IdmOpen   = 101;
  IdmSave   = 102;
  IdmSaveAs = 103;
  IdmPrint  = 104;
  IdmExit   = 105;

  { Edit Menu Items }

  IdmUndo  = 200;
  IdmCut   = 201;
  IdmCopy  = 202;
  IdmPaste = 203;
  IdmClear = 204;

  { Help Items }

  IdmAbout        = 300;
  IdmHelpIndex    = 301;
  IdmHelpKeyboard = 302;
  IdmHelpHelp     = 303;

  ExeNameMaxSize = 128;

  HelpIdEditClear = 100;
  HelpIdEditCopy  = 101;
  HelpIdEditCut   = 102;
  HelpIdEditPaste = 103;
  HelpIdEditUndo  = 104;

  HelpIdFileExit   = 200;
  HelpIdFileNew    = 201;
  HelpIdFileOpen   = 202;
  HelpIdFilePrint  = 203;
  HelpIdFileSave   = 204;
  HelpIdFileSaveAs = 205;

  HelpIdEditWindow   = 300;
  HelpIdMaximizeIcon = 301;
  HelpIdMinimizeIcon = 302;
  HelpIdSystemMenu   = 303;
  HelpIdTitleBar     = 306;
  HelpIdSizingBorder = 307;

type
  THelpName = array[0..ExeNameMaxSize+1] of Char;

var
  Wnd: Hwnd;
  Inst: tHandle;
  Help: Boolean;
  HelpCursor: HCursor;
  HelpFileName: THelpName;
  AccTable: THandle;

procedure MakeHelpPathName(var FileName: THelpName);
var
  FileNameLen: integer;
  I: integer;
begin
  FileNameLen:= GetModuleFileName(Inst, FileName, ExeNameMaxSize);

  I := FileNameLen - 1;
  while (I <> 0) and ((Filename[I] <> '\') and (Filename[I] <> ':')) do
    Dec(I);
  Inc(I);
  if I + 13 <= ExeNameMaxSize then
    StrCopy(@FileName[I], 'helpex.hlp')
  else
    StrCopy(@FileName[I], '?');
end;

function About(Dlg: Hwnd; Message, WParam: Word; LParam: Longint): Boolean;
  far;
begin
  About := False;
  case Message of
    WM_INITDIALOG:
      About := True;
    WM_COMMAND:
      if WParam = idOk then
      begin
        EndDialog(Dlg, 1);
        About := True;
      end;
  end;
end;

function MainWndProc(Wnd: Hwnd; Message, WParam: Word;
  LParam: LongInt): LongInt; export;
var
  ProcAbout: TFarProc;
  HelpContextId: Longint;
  Rect: TRect;
  Pt: TPoint;
  DoubleWord: LongInt;
  WFormat: Word;
  Arrow: HCursor;
begin
  MainWndProc := 0;
  case message of

    WM_COMMAND:
      { Was F1 just pressed in a menu, or are we in help mode
        Shift+F1?  }
      if Help then
      begin
        case WParam of
          IdmNew: HelpContextId := HelpIdFileNew;
          IdmOpen: HelpContextId := HelpIdFileOpen;
          IdmSave: HelpContextId := HelpIdFileSave;
          IdmSaveAs: HelpContextId := HelpIdFileSaveAs;
          IdmPrint: HelpContextId := HelpIdFilePrint;
          IdmExit: HelpContextId := HelpIdFileExit;
          IdmUndo: HelpContextId := HelpIdEditUndo;
          IdmCut: HelpContextId := HelpIdEditCut;
          IdmClear: HelpContextId := HelpIdEditClear;
          IdmCopy: HelpContextId := HelpIdEditCopy;
          IdmPaste: HelpContextId := HelpIdEditPaste;
        else
          HelpContextId := 0;
        end;

        if HelpContextId = 0 then
        begin
          MessageBox(Wnd, 'Help not available for Help Menu Item',
            'Help Example', Mb_Ok);
          MainWndProc := DefWindowProc(Wnd, Message, WParam, LParam);
        end
        else
        begin
          Help := False;
          WinHelp(Wnd, HelpFileName, Help_Context, HelpContextId);
        end
      end
      else
        case WParam of
          IdmNew,
          IdmOpen,
          IdmSave,
          IdmSaveAs,
          IdmPrint,
          IdmUndo,
          IdmCut,
          IdmClear,
          IdmCopy,
          IdmPaste:
            Messagebox(Wnd, 'Command not Implemented', 'Help Example', mb_Ok);
          IdmExit:
            DestroyWindow(Wnd);
          IdmHelpIndex:
            WinHelp(Wnd, HelpFileName, Help_Index, 0);
          IdmHelpKeyBoard:
            WinHelp(Wnd, HelpFileName, Help_Key, LongInt(PChar('keys')));
          IdmHelpHelp:
            WinHelp(Wnd, 'WINHELP.HLP', Help_Index, 0);
          IdmAbout:
            begin
              ProcAbout:= MakeProcInstance(@About, Inst);
              DialogBox(Inst, 'AboutBox', Wnd, ProcAbout);
              FreeProcInstance(ProcAbout);
            end;
        else
          MainWndProc := DefWindowProc(Wnd, Message, WParam, LParam);
        end;

    WM_LBUTTONDOWN:
      if Help then
      begin
        Help := False;
        WinHelp(Wnd, HelpFileName, Help_Context, HelpIDEditWindow);
      end
      else
        MainWndProc := DefWindowProc(Wnd, Message, WParam, LParam);

    WM_NCLBUTTONDOWN:

      { If we are in help mode (Shift+F1) then display
        context sensitive help for non-client area.  }

      if Help then
      begin
        case WParam of
          HtCaption: HelpContextId := HelpIdTitleBar;
          HtReduce: HelpContextId := HelpIdMinimizeIcon;
          HtZoom: HelpContextId := HelpIdMaximizeIcon;
          HtSysMenu: HelpContextId := HelpIdSystemMenu;
          HtBottom: HelpContextId := HelpIdSizingBorder;
          HtBottomLeft: HelpContextId := HelpIdSizingBorder;
          HtBottomRight: HelpContextId := HelpIdSizingBorder;
          HtTop: HelpContextId := HelpIdSizingBorder;
          HtLeft: HelpContextId := HelpIdSizingBorder;
          HtRight: HelpContextId := HelpIdSizingBorder;
          HtTopLeft: HelpContextId := HelpIdSizingBorder;
          HtTopRight: HelpContextId := HelpIdSizingBorder;
        else
          HelpContextId := 0;
        end;
        if HelpContextId = 0 then
          MainWndProc := DefWindowProc(Wnd, Message, WParam, LParam)
        else
        begin
          Help := False;
          WinHelp(Wnd, HelpFileName, Help_Context, HelpContextId);
        end
      end
      else
        MainWndProc := DefWindowProc(Wnd, Message, WParam, LParam);

    WM_KEYDOWN:
      if WParam = vk_F1 then

        { If Shift-F1, turn help mode on and set help cursor }

        if GetKeyState(VK_Shift) < 0 then
        begin
          Help := True;
          SetCursor(HelpCursor);
          MainWndProc := DefWindowProc(Wnd, Message, WParam, LParam);
        end

        { If F1 without shift, call up help main index topic }

        else
          WinHelp(Wnd, HelpFileName, Help_Index, 0)

        { Escape during help mode: turn help mode off }

      else if (WParam = vk_Escape) and Help then
      begin
        Help := False;
        SetCursor(hCursor(GetClassWord(Wnd, GCW_HCursor)));
      end;

    WM_SETCURSOR:

      { In help mode it is necessary to reset the cursor
        in response to every WM_SETCURSOR message.  Otherwise,
        by default, Windows will reset the cursor to that
        of the window class.  }

      if Help then
        SetCursor(HelpCursor)
      else
        MainWndProc := DefWindowProc(Wnd, Message, WParam, LParam);

    WM_INITMENU:
      if Help then
        SetCursor(HelpCursor)
      else
        MainWndProc := 1;

    WM_ENTERIDLE:
      if ((WParam = msgf_Menu) and ((GetKeyState(VK_F1) and $8000) <> 0)) then
      begin
        Help := True;
        PostMessage(Wnd, WM_KEYDOWN, VK_RETURN, 0);
      end;

    WM_DESTROY:
      begin
        WinHelp(Wnd, HelpFileName, HELP_QUIT, 0);
        PostQuitMessage(0);
      end
  else
    MainWndProc := DefWindowProc(Wnd, Message, WParam, LParam);
  end;
end;

function InitInstance(Instance: THandle; CmdShow: Integer): Boolean;
begin
  Inst := Instance;
  AccTable := LoadAccelerators(Inst,'HELPEXACC');
  Wnd := CreateWindow('Helpex', 'Help Example', WS_OVERLAPPEDWINDOW,
    CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, GetFocus, 0, Instance, nil);
  if Wnd = 0 then
  begin
    InitInstance := False;
    Exit;
  end;
  ShowWindow(Wnd, CmdShow);
  UpdateWindow(Wnd);
  EnableMenuItem(GetSubMenu(GetMenu(Wnd), 1), IdmClear, Mf_Enabled);

  MakeHelpPathName(HelpFileName);
  HelpCursor := LoadCursor(Inst,'HELPCURSOR');
  InitInstance := True;
end;

function InitApplication(Instance: THandle): Boolean;
var
  WC: TWndClass;
begin
  with WC do
  begin
    style := CS_HRedraw or CS_VRedraw;
    lpfnWndProc := @MainWndProc;
    cbClsExtra := 0;
    cbWndEXtra := 0;
    hInstance := Instance;
    hIcon := LoadIcon(0, IDI_Application);
    hCursor := LoadCursor(0, IDC_Arrow);
    hbrBackground := GetStockObject( White_Brush);
    lpszMenuName := 'HELPEXMENU';
    lpszClassName := 'Helpex';
  end;
  InitApplication := RegisterClass(WC);
end;


var
  Message: TMsg;

begin { main }
  if hPrevInst = 0 then
    if not InitApplication(hInstance) then Halt;
  if not InitInstance(hInstance, CmdShow) then Halt;
  while GetMessage(Message, 0, 0, 0) do
    if TranslateAccelerator(Wnd, AccTable, Message) = 0 then
    begin
      TranslateMessage(Message);
      DispatchMessage(Message);
    end;
end.

