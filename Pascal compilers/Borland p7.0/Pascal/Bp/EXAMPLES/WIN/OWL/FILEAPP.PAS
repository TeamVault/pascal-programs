{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program FileEditor;

uses WinTypes, WinProcs, OWindows, ODialogs, OStdWnds;

type

  { Declare TFileApp, a TApplication descendant }
  TFileApp = object(TApplication)
    procedure InitMainWindow; virtual;
    procedure InitInstance;  virtual;
  end;

  { Declare TMyFileWindow, a TFileWindow descendant }
  PMyFileWindow = ^TMyFileWindow;
  TMyFileWindow = object(TFileWindow)
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
  end;

{ Construct a TMyFileWindow, loading its menu }
constructor TMyFileWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  TFileWindow.Init(AParent, ATitle, nil);
  Attr.Menu := LoadMenu(HInstance, 'FileCommands');
end;

{ Construct the TFileApp's MainWindow of type TMyEditWindow }
procedure TFileApp.InitMainWindow;
begin
  MainWindow := new(PMyFileWindow, Init(nil, 'File Window'));
end;

{ Initialize each MS-Windows application instance, loading an
  accelerator table }
procedure TFileApp.InitInstance;
begin
  TApplication.InitInstance;
  if Status = 0 then
    HAccTable := LoadAccelerators(HInstance, 'FileCommands');
end;

{ Declare a variable of type TFileApp }
var
  FileApp: TFileApp;

{ Run the FileApp }
begin
  FileApp.Init('FileApp');
  FileApp.Run;
  FileApp.Done;
end.
