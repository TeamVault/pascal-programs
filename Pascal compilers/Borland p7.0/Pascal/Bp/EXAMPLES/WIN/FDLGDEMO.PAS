{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

{ Demo of FILEDLGS unit }

program FDlgDemo;

{$S-}
{$R FDLGDEMO.RES}

uses WinTypes, WinProcs, WinDos, Strings, FileDlgs;

const
  AppName = 'FDlgDemo';

const
  id_New    = 100;
  id_Open   = 101;
  id_Save   = 102;
  id_SaveAs = 103;
  id_Exit   = 199;
  id_About  = 200;

const
  GFileName: array[0..fsPathName] of Char = '';

function About(Dialog: HWnd; Message, WParam: Word;
  LParam: Longint): Bool; export;
begin
  About := True;
  case Message of
    wm_InitDialog:
      Exit;
    wm_Command:
      if (WParam = id_Ok) or (WParam = id_Cancel) then
      begin
        EndDialog(Dialog, 1);
        Exit;
      end;
  end;
  About := False;
end;

function MainWndProc(Window: HWnd; Message, WParam: Word;
  LParam: Longint): Longint; export;
var
  AboutProc: TFarProc;
  DC: HDC;
  PS: TPaintStruct;
  P: PChar;
  S: array[0..127] of Char;
begin
  MainWndProc := 0;
  case Message of
    wm_Command:
      case WParam of
        id_Open:
          begin
            DoFileOpen(Window, StrCopy(GFileName, '*.pas'));
            InvalidateRect(Window, nil, True);
            Exit;
          end;
        id_Save, id_SaveAs:
          begin
            DoFileSave(Window, GFileName);
            InvalidateRect(Window, nil, True);
            Exit;
          end;
        id_Exit:
          begin
            SendMessage(Window, wm_Close, 0, 0);
            Exit;
          end;
        id_About:
          begin
            AboutProc := MakeProcInstance(@About, HInstance);
            DialogBox(HInstance, 'AboutBox', Window, AboutProc);
            FreeProcInstance(AboutProc);
            Exit;
          end;
      end;
    wm_Paint:
      begin
        DC := BeginPaint(Window, PS);
        P := @GFileName;
        TextOut(DC, 10, 10, S, WVSPrintF(S, 'File name:  %s', P));
        EndPaint(Window, PS);
      end;
    wm_Destroy:
      begin
        PostQuitMessage(0);
        Exit;
      end;
  end;
  MainWndProc := DefWindowProc(Window, Message, WParam, LParam);
end;

procedure InitApplication;
const
  WindowClass: TWndClass = (
    style: 0;
    lpfnWndProc: @MainWndProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0;
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: AppName;
    lpszClassName: AppName);
begin
  WindowClass.hInstance := HInstance;
  WindowClass.hIcon := LoadIcon(0, idi_Application);
  WindowClass.hCursor := LoadCursor(0, idc_Arrow);
  WindowClass.hbrBackground := GetStockObject(white_Brush);
  if not RegisterClass(WindowClass) then Halt(1);
end;

procedure InitInstance;
var
  Window: HWnd;
begin
  Window := CreateWindow(
    AppName,
    'File Dialogs Demo',
    ws_OverlappedWindow,
    cw_UseDefault,
    cw_UseDefault,
    cw_UseDefault,
    cw_UseDefault,
    0,
    0,
    HInstance,
    nil);
  if Window = 0 then Halt(1);
  ShowWindow(Window, CmdShow);
  UpdateWindow(Window);
end;

procedure WinMain;
var
  Message: TMsg;
begin
  if HPrevInst = 0 then InitApplication;
  InitInstance;
  while GetMessage(Message, 0, 0, 0) do
  begin
    TranslateMessage(Message);
    DispatchMessage(Message);
  end;
  Halt(Message.wParam);
end;

begin
  WinMain;
end.
