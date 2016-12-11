{************************************************}
{                                                }
{   Grep Demo DLL Interface Unit                 }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ The grep text search programs consist of 3 binary files:

    REGEXP.DLL    - Text search engine dynamic link library (DLL)
                    that is written in Borland C++ 3.1 and
                    shared by both TVGREP.EXE and OWLGREP.EXE
    OWLGREP.EXE   - Windows grep program (uses ObjectWindows)
    TVGREP.EXE    - DOS text mode grep program (uses Turbo Vision)

  REGEXP.DLL is a Windows format DLL and comes already built. To rebuild
  it, make sure Borland C++ 3.1 is on your DOS path, change to the
  \BP\EXAMPLES\GREP\DLL directory and then run MAKE.

  OWLGREP is a Windows application. To build it, set Compile|Target to
  Windows from inside the IDE or type the following command-line at a
  DOS prompt:

    bpc /m /cw owlgrep

  TVGREP is a DOS protected mode application (DPMI). To build
  it, set Compile|Target to Protected from inside the IDE or type the
  following command-line at a DOS prompt:

    bpc /m /cp tvgrep

}

unit Regexp;

interface

type
  HRegexp = Word;

  TRegMatch = record
    Start: Word;        { Start of match }
    Stop:  Word;        { End of match }
  end;

function RegComp(Pattern: PChar; var Error: Integer): HRegexp;
function RegExec(Regex: HRegexp; Str: PChar; var Match: TRegMatch): Integer;
function RegError(Regex: HRegexp; Error: Integer;
  ErrorBuf: array of Char): Integer;
procedure RegFree(Regex: HRegexp);

implementation

procedure RegFree;              external 'REGEXP' index 2;
function RegError;              external 'REGEXP' index 3;
function RegExec;               external 'REGEXP' index 4;
function RegComp;               external 'REGEXP' index 5;

end.
