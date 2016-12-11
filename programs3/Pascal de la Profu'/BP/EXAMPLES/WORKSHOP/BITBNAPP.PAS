{************************************************}
{                                                }
{   Resource Workshop Demo program               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ This program uses a DLL that implements custom controls.
  Make sure you build the DLL (BITBTN.PAS) before running
  this program. }

program BitBnApp;

{$R BitBnApp.RES}

uses WinTypes, WinProcs, Win31, Objects, OWindows, ODialogs;

const
  DLLName = 'BITBTN.DLL';

const
  em_DLLNotFound = 1;

type
  PBitWindow = ^TBitWindow;
  TBitWindow = object(TDlgWindow)
    procedure Yes(var Msg: TMessage);
      virtual id_First + id_Yes;
    procedure No(var Msg: TMessage);
      virtual id_First + id_No;
    procedure Ok(var Msg: TMessage);
      virtual id_First + id_OK;
    procedure Cancel(var Msg: TMessage);
      virtual id_First + id_Cancel;
  end;

  PBitApp = ^TBitApp;
  TBitApp = object(TApplication)
    Lib: THandle;
    constructor Init(AName: PChar);
    destructor Done; virtual;
    procedure InitMainWindow; virtual;
    procedure Error(ErrorCode: Integer); virtual;
  end;

{ TBitApp }

constructor TBitApp.Init(AName: PChar);
begin
  { Tell Windows not to display a 'DLL not found' error
    dialog if the LoadLibrary function fails.  We'll handle
    the error and inform the user ourselves.
    Note that even though this SEM_ constant is defined and
    documented only in Windows 3.1, it actually works in
    Windows 3.0 as well... }
  SetErrorMode(SEM_NoOpenFileErrorBox);
  Lib := LoadLibrary(DLLName);
  if Lib < 32 then
    Status := em_DLLNotFound
  else
    TApplication.Init(AName);
end;

destructor TBitApp.Done;
begin
  TApplication.Done;
  FreeLibrary(Lib);
end;

procedure TBitApp.InitMainWindow;
begin
  MainWindow := New(PBitWindow, Init(nil, MakeIntResource(100)));
end;

procedure TBitApp.Error(ErrorCode: Integer);
begin
  case ErrorCode of
    em_DLLNotFound:
      MessageBox(0, DLLName + ' not found. Please compile BITBTN.PAS ' +
        'before executing this application.', 'Fatal error',
        mb_Ok or mb_IconStop);
  else
    TApplication.Error(ErrorCode);
  end;
end;

{ TBitWindow }

procedure TBitWindow.Yes(var Msg: TMessage);
begin
  CloseWindow;
end;

procedure TBitWindow.No(var Msg: TMessage);
begin
  CloseWindow;
end;

procedure TBitWindow.Ok(var Msg: TMessage);
begin
  CloseWindow;
end;

procedure TBitWindow.Cancel(var Msg: TMessage);
begin
  CloseWindow;
end;

var
  App: TBitApp;

begin
  App.Init('TBITBTN.DDL Demo');
  App.Run;
  App.Done;
end.
