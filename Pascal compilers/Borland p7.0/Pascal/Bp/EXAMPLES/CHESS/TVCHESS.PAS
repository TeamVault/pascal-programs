{************************************************}
{                                                }
{   Turbo Vision Chess Demo                      }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ The chess programs consist of 3 binary files:

    TVCHESS.EXE   - DOS text mode chess program (uses Turbo Vision)
    OWLCHESS.EXE  - Windows chess program (uses ObjectWindows)
    CHESS.DLL     - Chess analysis engine dynamic link library (DLL)
                    that is shared by both TVCHESS.EXE and OWLCHESS.EXE

  IMPORTANT NOTE: If you use the IDE to build this program, make sure
  to change to the \BP\EXAMPLES\CHESS directory before doing a compile.

  TVCHESS is a DOS protected mode application (DPMI). To build
  it, set Compile|Target to Protected from inside the IDE or type the
  following command-line at a DOS prompt:

    bpc /m /cp tvchess

  (Note you can also produce a real mode version of TVCHESS which
  will statically link in the CHESS DLL units.)

  OWLCHESS is a Windows application. To build it, set Compile|Target to
  Windows from inside the IDE or type the following command-line at a
  DOS prompt:

    bpc /m /cw owlchess

  CHESS.DLL is a Windows format DLL and comes already built. To rebuild
  it, set Compile|Target to Windows from inside the IDE or type the
  following command-line at a DOS prompt:

    bpc /m /cw chess

}

program ChessDemo;

uses App, Views, Dialogs, Menus, Objects, Drivers, TVChsCmd,
  TVBoard, TVChsApp;

{ If you get a FILE NOT FOUND error when compiling this program
  from a DOS IDE, change to the \BP\EXAMPLES\CHESS directory
  (use File|Change dir).

  This will enable the compiler to find all of the units used by
  this program.
}

var
  ChessDLLDemo: TChessApp;

begin
  ChessDLLDemo.Init;
  ChessDLLDemo.Run;
  ChessDLLDemo.Done;
end.
