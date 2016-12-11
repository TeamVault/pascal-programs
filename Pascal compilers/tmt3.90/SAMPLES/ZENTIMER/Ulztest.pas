(***********************************************)
(*                                             *)
(* Demo Program for ZenTimer Unit              *)
(* Copyright (c) 1999 by TMT Development Corp. *)
(* Author: Vadim Bodrov, TMT Development Corp. *)
(*                                             *)
(* Targets:                                    *)
(*   MS-DOS 32-bit protected mode              *)
(*   OS/2 console application                  *)
(*   WIN32 console application                 *)
(*                                             *)
(***********************************************)

program ULZTest;

{$ifndef __CON__}
  This program must be compiled for MS-DOS, OS/2 or Win32 console mode
{$endif}

uses ZenTimer,CRT;

var
  Timer1: ULZTimer;     // ULZTimer #1
  Timer2: ULZTimer;     // ULZTimer #2
  Key:    Char;

function ZeroFill(n: Real): String;
var
  i: Dword;
  s: String;
begin
  str(n:10:2,s);
  Result := '';
  for i := 1 to Length(s) do
    if s[i] = ' ' then
      Result := Result + '0'
    else
      Result := Result + s[i];
end;

begin
  ULZTimerOn;

  ClrScr;
  HideCursor;
  Writeln('Zen Timer Demo');
  Writeln('Copyright (c) 1995-99 TMT Development Corporation');
  Writeln;

  Writeln('CPU type          : ', CPUTypes[CPU_getProcessorType]);
  Writeln('CPU speed         : ', CPU_getProcessorSpeed,' Mhz');

  Write('RDTSC instruction : ');
  if CPU_haveRDTSC then
    Writeln('Supported')
  else
    Writeln('Not supported');

  Write('MMX technology    : ');
  if CPU_haveMMX then
    Writeln('Supported')
  else
    Writeln('Not supported');

  Write('3DNow! technology : ');
  if CPU_have3DNow then
    Writeln('Supported')
  else
    Writeln('Not supported');

  Timer1.Start;
  Timer2.Start;

  GotoXY(1, 13);
  Writeln('Press "Esc" to quit this test');
  repeat
   if Keypressed then
     Key := ReadKey
   else
     Key := Char(0);
   GotoXY(1, 10);
   Writeln('ULZ Timer #1      : ', ZeroFill(Timer1.Lap * Timer1.Resolution),
    '   - press `1` to restart this timer');
   Writeln('ULZ Timer #2      : ', ZeroFill(Timer2.Lap * Timer2.Resolution),
    '   - press `2` to restart this timer');

   if Key='1' then Timer1.Restart;
   if Key='2' then Timer2.Restart;
  until Key = #27;

  GotoXY(1, 17);
  Writeln('Wait for 3 seconds..');
  ULZDelay(Trunc(3 / ULZTimerResolution));

  Timer1.Stop;
  Timer2.Stop;
  ShowCursor;

  ULZTimerOff;

  Writeln;
  Writeln('Test performing time: ', Round(ULZTimerCount * ULZTimerResolution), ' secs.');
end.