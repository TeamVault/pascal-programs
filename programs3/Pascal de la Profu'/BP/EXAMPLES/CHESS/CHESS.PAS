{************************************************}
{                                                }
{   Chess - Shared DLL Example                   }
{   CHESS.DLL Main file.                         }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ The chess programs consist of 3 binary files:

    CHESS.DLL     - Chess analysis engine dynamic link library (DLL)
                    that is shared by both TVCHESS.EXE and OWLCHESS.EXE
    OWLCHESS.EXE  - Windows chess program (uses ObjectWindows)
    TVCHESS.EXE   - DOS text mode chess program (uses Turbo Vision)

  IMPORTANT NOTE: If you use the IDE to build this DLL, make sure
  to change to the \BP\EXAMPLES\CHESS directory before doing a compile.

  CHESS.DLL is a Windows format DLL and comes already built. To rebuild
  it, set Compile|Target to Windows from inside the IDE or type the
  following command-line at a DOS prompt:

    bpc /m /cw chess

  OWLCHESS is a Windows application. To build it, set Compile|Target to
  Windows from inside the IDE or type the following command-line at a
  DOS prompt:

    bpc /m /cw owlchess

  TVCHESS is a DOS protected mode application (DPMI). To build
  it, set Compile|Target to Protected from inside the IDE or type the
  following command-line at a DOS prompt:

    bpc /m /cp tvchess

  (Note you can also produce a real mode version of TVCHESS which
  will statically link in the CHESS DLL units.)

}

library Chess;

{$D Chess anlsysis engine for DOS and Windows}
{$C PRELOAD MOVEABLE DISCARDABLE}

{$IFNDEF WINDOWS}
  Set Target to Windows.
{$ENDIF}

uses ChessInf;

{ If you get a FILE NOT FOUND error when compiling this DLL
  from a DOS IDE, change to the \BP\EXAMPLES\CHESS directory
  (use File|Change dir).

  This will enable the compiler to find all of the units used by
  this DLL.
}

exports
  NewGame,
  DisposeGame,
  ParseMove,
  RetractMove,
  SubmitMove,
  VerifyMove,
  ComputerMove,
  ForceMove,
  AbortSearch,
  ThinkAhead,
  Think,
  SetBoard,
  SetPlayer,
  MakeChange,
  GetSearchStatus,
  GetChessStatus,
  GetLastMove,
  GetHintMove,
  MoveToStr,
  GetBoard,
  GetPlayer,
  GetCurrentMove,
  GetMainLine,
  GetValidMoves,
  GetNodes;

begin
end.
