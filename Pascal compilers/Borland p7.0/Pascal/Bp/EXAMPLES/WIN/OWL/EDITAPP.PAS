{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program TextEditor;
 
uses WinTypes, WinProcs, OWindows, OStdWnds;

type

  { Declare TEditApp, a TApplication descendant }
  TEditApp = object(TApplication)
    procedure InitMainWindow; virtual;
    procedure InitInstance; virtual;
  end;

  { Declare TMyEditWindow, a TEditWindow descendant }
  PMyEditWindow = ^TMyEditWindow;
  TMyEditWindow = object(TEditWindow)
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
  end;

{ Construct a TMyEditWindow, loading its menu }
constructor TMyEditWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  TEditWindow.Init(AParent, ATitle);
  Attr.Menu := LoadMenu(HInstance, 'EditCommands');
end;

{ Construct the TEditApp's MainWindow of type TMyEditWindow }
procedure TEditApp.InitMainWindow;
begin
  MainWindow := New(PMyEditWindow, Init(nil, 'EditWindow'));
end;

{ Initialize each MS-Windows application instance, loading an
  accelerator table }
procedure TEditApp.InitInstance;
begin
  TApplication.InitInstance;
  HAccTable := LoadAccelerators(HInstance, 'EditCommands');
end;

{ Declare a variable of type TEditApp } 
var
  EditApp : TEditApp;

{ Run the EditApp }
begin
  EditApp.Init('EditApp');
  EditApp.Run;
  EditApp.Done;
end.
