{***************************************************}
{                                                   }
{   Windows 3.1 OLE Server Demonstration Program    }
{   Main Program Unit                               }
{   Copyright (c) 1992 by Borland International     }
{                                                   }
{***************************************************}

program OleSrvApp;

{$K-}  { Servers cannot have smart callbacks }

{ This program demonstrates the development of an OLE
  Server application.  It supports a simple 'document'
  consisting of a shape (selectable as either a rectangle,
  circle, or triangle) which can be pasted or linked into
  an OLE Client (such as the OLE Client demo program, or
  Word for Windows).
}

{ NOTE: The order in which units appear in this statement is
  significant: some units require this compilation order.
}

{ Note: To compile the OLE Server demo, set Compile|Primary File to OLESERVR.PAS
}

uses Strings, WinTypes, WinProcs, OWindows, Ole, CommDlg, ShellAPI, BWCC,
     OleTypes, OleObj, Server, OleApp;

{$R OLESERVR.RES}

{ Global Variables }

var
  App: TOleApp;

{ Main program }

begin
  App.Init(DemoTitle);
  App.Run;
  App.Done;
end.

