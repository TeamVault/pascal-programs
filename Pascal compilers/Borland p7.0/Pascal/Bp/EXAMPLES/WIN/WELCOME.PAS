{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program Welcome;

uses
  WinCrt;  { Allows Writeln, Readln, cursor movement, etc. }

{ WinCrt Demo Program

  (Press Ctrl-F9 to run this program.)

  This program demonstrates how to use the WinCrt unit to perform
  "traditional" screen I/O. This is the easiest way to build text mode
  programs that run in a window. For more information about the WinCrt
  unit, refer to the Programmer's Guide. For information on writing more
  advanced Windows applications, read about the ObjectWindows
  application framework in the Windows Programming Guide.
}

begin
  Writeln('Welcome to Turbo Pascal for Windows');
end.
