{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program MDI;

{$R MDIAPP.RES}
                       
uses WinTypes, WinProcs, OWindows;
         
type

  { Define a TApplication descendant } 
  TMDIApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

{ Construct the THelloApp's MainWindow object, loading its menu }
procedure TMDIApp.InitMainWindow;
begin
  MainWindow := New(PMDIWindow, Init('MDI Conformist',
    LoadMenu(HInstance, 'MDIMenu')));
end;
 
{ Declare a variable of type TMDIApp} 
var
  MDIApp: TMDIApp;

{ Run the MDIApp }
begin
  MDIApp.Init('MDIApp');
  MDIApp.Run;
  MDIApp.Done;
end.
