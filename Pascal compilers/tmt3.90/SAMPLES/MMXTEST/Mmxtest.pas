(***********************************************)
(*                                             *)
(* MMX Demo Program                            *)
(* Copyright (c) 1997 by TMT Development Corp. *)
(* Author: Anton Moscal, TMT Development Corp. *)
(*                                             *)
(* Targets:                                    *)
(*   MS-DOS 32-bit protected mode              *)
(*   OS/2 console application                  *)
(*   WIN32 console application                 *)
(*                                             *)
(***********************************************)

program MMXTest;

{$ifndef __CON__}
  This program must be compiled for MS-DOS, OS/2 or Win32 console mode
{$endif}

uses use32, zentimer;

const n = 50;

type vec = array [1..n*4] of system.word;

var a,b:vec;

function vprod(const a, b: vec): dword;
var
  i: Integer;
begin
  result := 0;
  for i := 1 to high(vec) do
    result +:= a[i] * b[i];
end;

function vprod_asm(const a, b: vec): DWORD; assembler;
asm
    xor ebx, ebx
    mov ecx, n*4
    mov esi, a
    mov edi, b
    xor eax, eax
@@l:
    mov   ax, word ptr [esi]
    lea   esi, [esi+2]
    mul   word ptr [edi]
    lea   edi, [edi+2]
    shl   edx, 16
    mov   dx, ax
    add   ebx, edx
    dec   ecx
    jne   @@l
    mov   eax, ebx
end;

function vprod_mmx (const a, b: vec): dword; assembler;
var
  muls: record l, h: dword end;
asm
    xor ebx, ebx
    mov ecx, n
    mov esi, a
    mov edi, b
    xor eax, eax
@@l:
    movq    mm0, [esi]
    pmaddwd mm0, [edi]
    lea     esi, [esi+8]
    movq    muls, mm0
    lea     edi, [edi+8]
    add     eax, muls.l
    add     eax, muls.h
    dec     ecx
    jne     @@l
    emms
end;

var i:integer;
begin
  if not CPU_haveMMX then begin
    Writeln('MMX(tm) technology not detected');
    Halt(0);
  end else
    Writeln('Please wait...');
  for i := 1 to high(vec) do
  begin
    a [i] := i;
    b [high (vec) + 1 - i] := i;
  end;

  LZTimerOn;
  for i := 1 to 100000 do vprod(a, b);
  LZTimerOff;
  writeln('Pascal  =', LZTimerCount/1000000:5:2, ' sec.');

  LZTimerOn;
  for i := 1 to 100000 do vprod_asm(a, b);
  LZTimerOff;
  writeln('Asm x86 =', LZTimerCount/1000000:5:2, ' sec.');

  LZTimerOn;
  for i := 1 to 100000 do vprod_mmx(a, b);
  LZTimerOff;
  writeln ('Asm MMX =', LZTimerCount/1000000:5:2, ' sec.');

  writeln(vprod(a, b));
  writeln(vprod_asm(a, b));
  writeln(vprod_mmx(a, b));
end.


