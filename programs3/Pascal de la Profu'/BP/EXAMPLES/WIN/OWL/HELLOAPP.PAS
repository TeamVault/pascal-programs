{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program Hello;
         
uses WinTypes, WinProcs, OWindows;
         
type
 
  { Define a TApplication descendant } 
  THelloApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

{ Construct the THelloApp's MainWindow object } 
procedure THelloApp.InitMainWindow;
begin
  MainWindow := New(PWindow, Init(nil, 'Hello, Turbo Pascal World'));
end;
 
{ Declare a variable of type THelloApp } 
var
  HelloApp: THelloApp;

{ Run the HelloApp }
begin
  HelloApp.Init('HelloApp');
  HelloApp.Run;
  HelloApp.Done;
end.  
