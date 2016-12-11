(***********************************************)
(*                                             *)
(* Demo Program for ZenTimer Unit              *)
(* Copyright (c) 1997 by TMT Development Corp. *)
(* Author: Vadim Bodrov, TMT Development Corp. *)
(*                                             *)
(* Targets:                                    *)
(*   MS-DOS 32-bit protected mode              *)
(*   OS/2 console application                  *)
(*   WIN32 console application                 *)
(*                                             *)
(***********************************************)

{$ifndef __CON__}
  This program must be compiled for MS-DOS, OS/2 or Win32 console mode
{$endif}

program LZTest;

uses ZenTimer;

function lu06(val: Longint): String;
var
  i: Longint;
  s: String;
begin
  Str(val:6,s);
  for i := 1 to 6 do if s[i] = ' ' then
    s[i] := '0';
  lu06 := s;
end;

procedure ReportTime(count: Longint);
var
  secs: Longint;
begin
  secs := count div 1000000;
  count := count - secs * 1000000;
  Writeln('Time taken: ', secs, '.', lu06(count), ' seconds');
end;

var
  i, j, a: DWORD;

begin
  LZTimerOn;
   for j := 0 to 9 do
     for i := 0 to 19999 do
       a := i;
  LZTimerOff;
  ReportTime(LZTimerCount);
end.