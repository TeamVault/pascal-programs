{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

{ "Generic" Windows application written in Turbo Pascal }

program Generic;

{$R GENERIC}

uses WinTypes, WinProcs;

const
  AppName = 'Generic';

const
  idm_About = 100;

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

function WindowProc(Window: HWnd; Message, WParam: Word;
  LParam: Longint): Longint; export;
var
  AboutProc: TFarProc;
begin
  WindowProc := 0;
  case Message of
    wm_Command:
      if WParam = idm_About then
      begin
        AboutProc := MakeProcInstance(@About, HInstance);
        DialogBox(HInstance, 'AboutBox', Window, AboutProc);
        FreeProcInstance(AboutProc);
        Exit;
      end;
    wm_Destroy:
      begin
        PostQuitMessage(0);
        Exit;
      end;
  end;
  WindowProc := DefWindowProc(Window, Message, WParam, LParam);
end;

procedure WinMain;
var
  Window: HWnd;
  Message: TMsg;
const
  WindowClass: TWndClass = (
    style: 0;
    lpfnWndProc: @WindowProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0;
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: AppName;
    lpszClassName: AppName);
begin
  if HPrevInst = 0 then
  begin
    WindowClass.hInstance := HInstance;
    WindowClass.hIcon := LoadIcon(0, idi_Application);
    WindowClass.hCursor := LoadCursor(0, idc_Arrow);
    WindowClass.hbrBackground := GetStockObject(white_Brush);
    if not RegisterClass(WindowClass) then Halt(255);
  end;
  Window := CreateWindow(
    AppName,
    'Turbo Pascal Generic',
    ws_OverlappedWindow,
    cw_UseDefault,
    cw_UseDefault,
    cw_UseDefault,
    cw_UseDefault,
    0,
    0,
    HInstance,
    nil);
  ShowWindow(Window, CmdShow);
  UpdateWindow(Window);
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
