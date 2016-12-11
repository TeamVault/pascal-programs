(***********************************************)
(*                                             *)
(* Hello World!                                *)
(* Copyright (c) 1999 by TMT Development Corp. *)
(* Author: Vadim Bodrov, TMT Development Corp. *)
(*                                             *)
(* Targets:                                    *)
(*   MS-DOS 32-bit protected mode              *)
(*   OS/2 console application                  *)
(*   WIN32 application                         *)
(*                                             *)
(***********************************************)

program Hello;

{$ifdef __GUI__} uses WinCRT; {$endif}

begin
  Writeln('Hello World!');
end.