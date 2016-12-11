(****************************************************************************
*                                                                           *
*                            The Zen Timer Unit                             *
*                                                                           *
*                            TMT Pascal Version                             *
*            Copyright (C) 1997-2000 TMT Development Corporation            *
*                            All rights reserved.                           *
*                                                                           *
*           Portions Copyright (C) 1991-1997 SciTech Software, Inc.         *
*                            All rights reserved.                           *
*                                                                           *
*                                                                           *
* Filename:             $Workfile:   zentimer.pas  $                        *
* Version:              $Revision:   2.8  $                                 *
*                                                                           *
* Language:             TMT Pascal Multi-target                             *
* Environment:          IBM PC (MSDOS 32-bit protected mode, OS/2, Win32)   *
*                                                                           *
* Description:  Source file of the Zen Timer library. Provides a number     *
*               of routines to accurately time segments of code. A long     *
*               period timer is provided to time code that takes up to      *
*               one hour to execute, with microsecond precision, and an     *
*               ultra long period timer for timing code that takes up to    *
*               24 hours to execute (raytracing etc).                       *
*                                                                           *
*               We also provide a set of Pascal objects to manipulate       *
*               the Zen Timers. Note that you can only have one LZTimer     *
*               running at a time (you can have multiple ULZTimers however),*
*               and that the total aggregate time of thr ULZTimer is about  *
*               65,000 hours, which should suit most timing purposes.       *
*                                                                           *
*               This unit also includes routines for querying the CPU       *
*               type, CPU speed and CPU features, and includes support for  *
*               high precision timing on Pentium based systems using the    *
*               Read Time Stamp Counter. Based on Intel sample code.        *
*                                                                           *
* $Date:  19 Jul 2000 $ $Author of TMT Pascal version :  Vadim Bodrov  $    *
* $Date:  01 Oct 1997 $ $Author of original C/C++ code:  KendallB  $        *
*                                                                           *
*****************************************************************************)
{$r-,q-,i-,t-,x+,v-,a+,cc+,oa+}

unit ZenTimer;

interface

const
  CPU_unknown     = 0;            // Unknown proccessor
  CPU_i386        = 1;            // Intel 80386 processor
  CPU_i486        = 2;            // Intel 80486 processor
  CPU_Pentium     = 3;            // Intel Pentium(R) processor
  CPU_PentiumPro  = 4;            // Intel PentiumPro(R) processor
  CPU_PentiumII   = 5;            // Intel PentiumII(R) processor
  CPU_PentiumIII  = 6;            // Intel PentiumIII(R) processor
  CPU_Pentium4    = 7;            // Intel PentiumIII(R) processor
  CPU_UnkPentium  = $FFFF;        // Unknown Intel Pentium family processor

CpuTypes: array [0..8] of string[20] =
(
'Unknown',
'Intel 80386',
'Intel 80486',
'Intel Pentium(R)',
'Intel PentiumPro(R)',
'Intel PentiumII(R)',
'Intel PentiumIII(R)',
'Intel Pentium4(R)',
'Unknown Pentium'
);

(* Routines to obtain CPU information *)
function  CPU_getProcessorType: DWord;
function  CPU_isIntelClone: Boolean;
function  CPU_haveMMX: Boolean;
function  CPU_have3DNow: Boolean;
function  CPU_haveRDTSC: Boolean;
function  CPU_getProcessorSpeed: DWord;
function  CPU_getCPUIDFeatures: DWord;

(* Routine to initialise the library. You may not call this procedure,
since it calls automaticaly at unit initialization. ZTimerInit
procedure listed here only for compatibility with original C/C++
ztimer library                                                     *)
procedure ZTimerInit;

(* Long period timing routines (times up to 1 hour) *)
procedure LZTimerOn;
function  LZTimerLap: DWord;
procedure LZTimerOff;
function  LZTimerCount: DWord;

(* New procedure added *)
procedure LZDelay(Value: DWord);

(* Ultra long period timing routines (times up to 65,000 hours) *)
procedure ULZTimerOn;
procedure ULZTimerOff;
function  ULZTimerLap: DWord;
function  ULZTimerCount: DWord;
function  ULZReadTime: DWord;
function  ULZElapsedTime(start, finish: DWord): DWord;
function  ULZTimerResolution: Double;

(* New procedure added *)
procedure ULZDelay(Value: DWord);

////////////////////////////////////////////////////////////////////////////
// Long Period Zen Timer object. This can be used to time code that takes
// up to 1 hour to execute between calls to Start and Stop or lap. The
// aggregate count can be up to 2^32 - 1 microseconds (about 1 hour and
// 10 mins).
////////////////////////////////////////////////////////////////////////////
type LZTimer = object
private
  _count:    DWord;
  _overflow: Boolean;
  procedure  ComputeTime;
public
  procedure LZTimer;
  procedure Start;
  procedure Restart;
  function  Lap: DWord;
  procedure Stop;
  function  Count: DWord;
  procedure Reset;
  function  Overflow: Boolean;
  function  Resolution: Double;
  procedure Delay(Value: DWord);
end;

////////////////////////////////////////////////////////////////////////////
// Ultra Long Period Zen Timer object. This can be used to time code that
// takes up 24 hours total to execute between calls to Start and Stop.
// The aggregate count can be up to 2^32 - 1 1/18ths of a second, which
// is about 65,000 hours! Should be enough for most applications.
/////////////////////////////////////////////////////////////////////////////
type ULZTimer = object
private
  _count:  DWord;
  _start:  DWord;
  _finish: DWord;
public
  procedure ULZTimer;
  procedure Start;
  procedure Restart;
  function  Lap: DWord;
  procedure Stop;
  function  Count: DWord;
  procedure Reset;
  function  Resolution: Double;
  procedure Delay(Value: DWord);
end;

implementation

{$ifdef __WIN32__}
uses Windows;

type
  CPU_LargeInteger = TLargeInteger;
{$endif}

{$ifdef __OS2__}
uses DOSCall;
{$endif}

{$ifndef __WIN32__}
type CPU_largeInteger = record
  LowPart:  DWord;
  HighPart: DWord;
end;
{$endif}

const
  Intel_id: string[12]  = 'GenuineIntel';
  TOLERANCE             = 1;
  MAXCLOCKS             = 150;
  ROUND_THRESHOLD       = 6;
  ITERATIONS            = 16000;
  MAX_TRIES             = 20;
  SAMPLINGS             = 10;

  CPU_mask              = $7FFF;
  CPU_IntelClone        = $8000;
  CPU_HaveMMX_          = $00800000;
  CPU_HaveRDTSC_        = $00000010;

var
  StartBIOSCount,EndBIOSCount: DWord            := 0;
  EndTimedCount:               Word             := 0;
  CpuSpeed:                    LongInt          := 0;
  HaveRDTSC:                   Boolean          := FALSE;
  tmStart,tmEnd:               CPU_largeInteger;
  start,finish:                DWord            := 0;
  ZTimerBIOS:                  DWord            := 0;

{$ifdef __WIN32__}
var
  CountFreq:                   CPU_LargeInteger;
  havePerformanceCounter:      Boolean;

function timeGetTime: DWORD; stdcall; external 'winmm.dll' name 'timeGetTime';
{$endif}

{$ifdef __OS2__}
var
  CountFreq:                   CPU_LargeInteger;

function timeGetTime: DWORD;
begin
  DosQuerySysInfo(qsv_Ms_Count,qsv_Ms_Count, Result, 4);
end;
{$endif}

////////////////////////////////////////////////////////////////////////////
// Determines if we have an i386 processor.
////////////////////////////////////////////////////////////////////////////
function CPU_check80386: Boolean;
     asm
       xor     edx,edx         // EDX = 0, not an 80386
       mov     bx, sp
       and     sp, not 3
       pushfd                  // Push original EFLAGS
       pop     eax             // Get original EFLAGS
       mov     ecx, eax        // Save original EFLAGS
       xor     eax, 40000h     // Flip AC bit in EFLAGS
       push    eax             // Save new EFLAGS value on
                               // stack
       popfd                   // Replace current EFLAGS value
       pushfd                  // Get new EFLAGS
       pop     eax             // Store new EFLAGS in EAX
       xor     eax, ecx        // Can't toggle AC bit,
                               // processor=80386
       jnz     @@Done          // Jump if not an 80386 processor
       inc     edx             // We have an 80386

@@Done: push    ecx
       popfd
       mov     sp, bx
       mov     eax, edx
end;

////////////////////////////////////////////////////////////////////////////
// Determines if we have an i486 processor.
////////////////////////////////////////////////////////////////////////////
function CPU_check80486: Boolean;
     asm
       pushfd                  // Get original EFLAGS
       pop     eax
       mov     ecx, eax
       xor     eax, 200000h    // Flip ID bit in EFLAGS
       push    eax             // Save new EFLAGS value on stack
       popfd                   // Replace current EFLAGS value
       pushfd                  // Get new EFLAGS
       pop     eax             // Store new EFLAGS in EAX
       xor     eax, ecx        // Can not toggle ID bit,
       jnz     @@1             // Processor=80486
       mov     eax,1           // We dont have a Pentium
       jmp     @@Done
@@1:    xor     eax,eax         // We have Pentium or later
@@Done:
end;

////////////////////////////////////////////////////////////////////////////
// Determines if we have support for the CPUID instruction.
////////////////////////////////////////////////////////////////////////////
function CPU_haveCPUID: Boolean; assembler;
     asm
       pushfd                  // Get original EFLAGS
       pop     eax
       mov     ecx, eax
       xor     eax, 200000h    // Flip ID bit in EFLAGS
       push    eax             // Save new EFLAGS value on stack
       popfd                   // Replace current EFLAGS value
       pushfd                  // Get new EFLAGS
       pop     eax             // Store new EFLAGS in EAX
       xor     eax, ecx        // Can not toggle ID bit,
       jnz     @@1             // Processor=80486
       mov     eax,0           // We dont have CPUID support
       jmp     @@Done
@@1:    mov     eax,1           // We have CPUID support
@@Done:
end;

////////////////////////////////////////////////////////////////////////////
// Determines the CPU type using the CPUID instruction.
////////////////////////////////////////////////////////////////////////////
function CPU_checkCPUID: DWord; assembler;
     asm
       xor     eax, eax             // Set up for CPUID instruction
       cpuid                        // Get and save vendor ID
       cmp     eax, 1               // Make sure 1 is valid input for CPUID
       jl      @@Fail               // We dont have the CPUID instruction
       xor     eax,eax              // Assume Genuine Intel
       cmp     dword ptr [intel_id+1], ebx
       jne     @@NotGenuineIntel
       cmp     dword ptr [intel_id+5], edx
       jne     @@NotGenuineIntel
       cmp     dword ptr [intel_id+9], ecx
       je      @@HaveGenuineIntel
@@NotGenuineIntel:
       mov     eax,CPU_IntelClone   // Set the clone flag
@@HaveGenuineIntel:
       push    eax
       xor     eax, eax
       inc     eax
       cpuid                        // Get family/model/stepping/features
       and     eax, 0F00h
       shr     eax, 8               // Isolate family
       and     eax, 0Fh
       pop     ecx
       or      eax,ecx              // Combine in the clone flag
       jmp     @@Done
@@Fail:
       xor     eax,eax
@@Done:
end;

////////////////////////////////////////////////////////////////////////////
// Determines the CPU type using the CPUID instruction.
////////////////////////////////////////////////////////////////////////////
function CPU_getCPUIDModel: DWord; assembler;
     asm
       xor     eax, eax        // Set up for CPUID instruction
       cpuid                   // Get and save vendor ID
       cmp     eax, 1          // Make sure 1 is valid input for CPUID
       jl      @@Fail          // We dont have the CPUID instruction
       xor     eax, eax
       inc     eax
       cpuid                   // Get family/model/stepping/features
       and     eax, 0F0h
       shr     eax, 4          // Isolate model
       jmp     @@Done
@@Fail:
       xor     eax,eax
@@Done:
end;

////////////////////////////////////////////////////////////////////////////
// Determines the CPU type using the CPUID instruction.
////////////////////////////////////////////////////////////////////////////
function CPU_getCPUIDFeatures: DWord; assembler;
     asm
       xor     eax, eax        // Set up for CPUID instruction
       cpuid                   // Get and save vendor ID
       cmp     eax, 1          // Make sure 1 is valid input for CPUID
       jl      @@Fail          // We dont have the CPUID instruction
       xor     eax, eax
       inc     eax
       cpuid                   // Get family/model/stepping/features
       mov     eax, edx
       jmp     @@Done
@@Fail: xor     eax,eax
@@Done:
end;

////////////////////////////////////////////////////////////////////////////
// Checks if the i386 or i486 processor is a clone or genuine Intel.
////////////////////////////////////////////////////////////////////////////
function CPU_checkClone: DWord; assembler;
     asm
       mov     ax,5555h        // Check to make sure this is a 32-bit processor
       xor     dx,dx
       mov     cx,0002h
       div     cx              // Perform Division
       clc
       jnz     @@NoClone
       jmp     @@Clone
@@NoClone:
       stc
@@Clone:
       pushfd
       pop     eax             // Get the flags
       and     eax,1
       xor     eax,1           // EAX=0 is probably Intel, EAX=1 is a Clone
end;
////////////////////////////////////////////////////////////////////////////
// Reads the time stamp counter and returns the low order 32-bits
////////////////////////////////////////////////////////////////////////////
function CPU_quickRDTSC: DWord; code;
     asm
       rdtsc
       ret
end;

////////////////////////////////////////////////////////////////////////////
// Runs a loop of BSF instructions for the specified number of iterations
////////////////////////////////////////////////////////////////////////////
procedure CPU_runBSFLoop(interations: DWord); assembler;
     asm
       mov     edx,[interations]
       mov     eax,80000000h
       mov     ebx,edx
       ALIGN   4
@@loop: bsf     ecx,eax
       dec     ebx
       jnz     @@loop
end;

////////////////////////////////////////////////////////////////////////////
// Reads the time stamp counter and returns the 64-bit result.
////////////////////////////////////////////////////////////////////////////
procedure CPU_readTimeStamp(var time: CPU_largeInteger); assembler;
     asm
       db      00Fh,031h
       rdtsc
       mov     ecx,[time]      // Access directly without stack frame
       mov     [ecx],eax
       mov     [ecx+4],edx
end;

////////////////////////////////////////////////////////////////////////////
// Computes the difference between two 64-bit numbers.
////////////////////////////////////////////////////////////////////////////
function CPU_diffTime64 (var t1,t2,t: CPU_largeInteger): DWord; assembler;
     asm
       mov     ecx,[t2]
       mov     eax,[ecx]       // EAX := t2.low
       mov     ecx,[t1]
       sub     eax,[ecx]
       mov     edx,eax         // EDX := low difference
       mov     ecx,[t2]
       mov     eax,[ecx+4]     // ECX := t2.high
       mov     ecx,[t1]
       sbb     eax,[ecx+4]     // EAX := high difference
       mov     ebx,[t]         // Store the result
       mov     [ebx],edx       // Store low part
       mov     [ebx+4],eax     // Store high part
       mov     eax,edx         // Return low part
end;

////////////////////////////////////////////////////////////////////////////
// Computes the value in microseconds for the elapsed time with maximum
// precision. The formula we use is:
//
//      us = (((diff * 0x100000) / freq) * 1000000) / 0x100000)
//
// The power of two multiple before the first divide allows us to scale the
// 64-bit difference using simple shifts, and then the divide brings the
// final result into the range to fit into a 32-bit integer.
////////////////////////////////////////////////////////////////////////////
function CPU_calcMicroSec (var Count: CPU_largeInteger; freq: DWord): DWord; assembler;
     asm
       mov     ecx,[count]
       mov     eax,[ecx]        // EAX := low part
       mov     edx,[ecx+4]      // EDX := high part
       shld    edx,eax,20
       shl     eax,20           // diff * 0x100000
       div     dword ptr [freq] // (diff * 0x100000) / freq
       mov     ecx,1000000
       xor     edx,edx
       mul     ecx              // ((diff * 0x100000) / freq) * 1000000)
       shrd    eax,edx,20       // ((diff * 0x100000) / freq) * 1000000) / 0x100000
end;

////////////////////////////////////////////////////////////////////////////
// Starts the Long period Zen timer counting.
////////////////////////////////////////////////////////////////////////////
procedure LZ_TimerOn; assembler;
     asm
       mov     al,34h
       out     43h,al
       db      0EBh,00h,0EBh,00h,0EBh,00h
       xor     ax,ax
       out     40h,al
       db      0EBh,00h,0EBh,00h,0EBh,00h
       out     40h,al
       cli
       mov     edi,46Ch
       mov     eax,dword ptr [edi]
       sti
       mov     dword ptr [StartBIOSCount],eax
       mov     al,34h
       out     43h,al
       db      0EBh,00h,0EBh,00h,0EBh,00h
       xor     ax,ax
       out     40h,al
       db      0EBh,00h,0EBh,00h,0EBh,00h
       out     40h,al
end;

////////////////////////////////////////////////////////////////////////////
// Stops the long period Zen timer and saves count.
////////////////////////////////////////////////////////////////////////////
procedure LZ_TimerOff; assembler;
     asm
       xor     al,al
       out     43h,al
       cli
       mov     edi,46Ch
       mov     eax,dword ptr [edi]
       mov     dword ptr [EndBIOSCount],eax
       in      al,40h
       db      0EBh,00h,0EBh,00h,0EBh,00h
       mov     ah,al
       in      al,40h
       xchg    ah,al
       neg     ax
       mov     [EndTimedCount],ax
       sti
end;

////////////////////////////////////////////////////////////////////////////
// Latches the current count and converts it to a microsecond timing value,
// but leaves the timer still running. We dont check for and overflow,
// where the time has gone over an hour in this routine, since we want it
// to execute as fast as possible.
////////////////////////////////////////////////////////////////////////////
function LZ_TimerLap: DWord; assembler;
     asm
       xor     al,al
       out     43h,al
       cli
       mov     edi,46Ch
       mov     eax,dword ptr [edi]
       mov     dword ptr [EndBIOSCount],eax
       in      al,40h
       db      0EBh,00h,0EBh,00h,0EBh,00h
       mov     ah,al
       in      al,40h
       xchg    ah,al
       neg     ax
       mov     [EndTimedCount],ax
       sti
       mov     eax,dword ptr [EndBIOSCount]
       cmp     eax,dword ptr [StartBIOSCount]
       jae     @CalcBIOSTime
       add     dword ptr [EndBIOSCount],001800B0h
@CalcBIOSTime:
       mov     eax,[EndBIOSCount]
       sub     eax,[StartBIOSCount]
       mov     edx,54925
       mul     edx
       mov     ebx,eax
       movzx   eax,[EndTimedCount]
       mov     esi,8381
       mul     esi
       mov     esi,10000
       div     esi
       add     eax,ebx
end;

////////////////////////////////////////////////////////////////////////////
// Returns an unsigned long representing the net time in microseconds.
//
// If an hour has passed while timing, we return 0xFFFFFFFF as the count
// (which is not a possible count in itself).
////////////////////////////////////////////////////////////////////////////
function LZ_TimerCount: DWord; assembler;
     asm
       mov     eax,dword ptr [EndBIOSCount]
       cmp     eax,dword ptr [StartBIOSCount]
       jae     @CheckForHour
       add     dword ptr [EndBIOSCount],001800B0h
@CheckForHour:
       mov     ax,word ptr [StartBIOSCount+2]
       cmp     ax,word ptr [EndBIOSCount+2]
       je      @CalcBIOSTime
       inc     ax
       cmp     ax,word ptr [EndBIOSCount+2]
       jne     @TestTooLong
       mov     ax,word ptr [EndBIOSCount]
       cmp     ax,word ptr [StartBIOSCount]
       jb      @CalcBIOSTime
@TestTooLong:
       mov     eax,0FFFFFFFFh
       ret
@CalcBIOSTime:
       mov     eax,[EndBIOSCount]
       sub     eax,[StartBIOSCount]
       mov     edx,54925
       mul     edx
       mov     ebx,eax
       movzx   eax,[EndTimedCount]
       mov     esi,8381
       mul     esi
       mov     esi,10000
       div     esi
       add     eax,ebx
end;

function GetCPUType: DWORD;
var
  cpu, model, clone: DWord;
begin
  if CPU_haveCPUID then
  begin
    cpu := CPU_checkCPUID;
    clone := (cpu and CPU_IntelClone);
    case (cpu and CPU_mask) of
     4: cpu := CPU_i486;
     5: cpu := CPU_Pentium;
     6: begin
          model := CPU_getCPUIDModel;
          case model of
            1:     cpu := CPU_PentiumPro
            3,5,6: cpu := CPU_PentiumII;
            7,8:   cpu := CPU_PentiumIII;
            9:     cpu := CPU_Pentium4;
          else
                   cpu := CPU_UnkPentium;
          end;
        end;
     else
        cpu := CPU_UnkPentium;
    end;
  end else
  begin
    clone := CPU_checkClone * CPU_IntelClone;
    if CPU_check80386 then
      cpu := CPU_i386
    else if CPU_check80486 then
      cpu := CPU_i486
    else
      cpu := CPU_Pentium;
  end;
  Result := cpu or clone;
end;

(****************************************************************************
 DESCRIPTION:
 Returns the type of processor in the system.

 RETURNS:
 Numerical identifier for the installed processor

 REMARKS:
 Returns the type of processor in the system. Note that if the CPU is an
 unknown Pentium family processor that we don't have an enumeration for,
 the return value will be greater than or equal to the value of CPU_UnkPentium
 (depending on the value returned by the CPUID instruction).

 SEE ALSO:
 CPU_getProcessorSpeed, CPU_haveMMX
****************************************************************************)
function CPU_getProcessorType: DWord;
begin
  Result := GetCPUType and $7FFF;
end;

(****************************************************************************
 DESCRIPTION:
 Returns TRUE if the processor is an Intel clone.
****************************************************************************)
function CPU_isIntelClone: Boolean;
begin
  Result := (GetCPUType and CPU_IntelClone) <> 0;
end;

(****************************************************************************
 DESCRIPTION:
 Returns true if the processor supports Intel MMX extensions.

 RETURNS:
 True if MMX is available, false if not.

 REMARKS:
 This function determines if the processor supports the Intel MMX extended
 instruction set. If the processor is not an Intel or Intel clone CPU, this
 function will always return false.

 SEE ALSO:
 CPU_getProcessorType, CPU_getProcessorSpeed, CPU_have3DNow
****************************************************************************)
function CPU_haveMMX: Boolean;
begin
  if CPU_haveCPUID then
   Result:= (CPU_getCPUIDFeatures and CPU_HaveMMX_) <> 0
  else
   Result := FALSE;
end;

(****************************************************************************
 DESCRIPTION:
 Returns true if the processor supports AMD 3DNow! extensions.

 RETURNS:
 True if 3DNow is available, false if not.

 REMARKS:
 This function determines if the processor supports the Intel MMX extended
 instruction set. If the processor is not an Intel or Intel clone CPU, this
 function will always return false.

 SEE ALSO:
 CPU_getProcessorType, CPU_getProcessorSpeed, CPU_haveMMX
****************************************************************************)
function CPU_have3DNow: Boolean; code;
      asm
        call   CPU_haveCPUID
        and    eax, 00000001h
        jz     @@NO_3DNOW
        mov    eax, 80000000h   // query for extended functions
        CPUID                   // get extended function limit
        cmp    eax, 80000000h   // is 8000_0001h supported?
        jbe    @@NO_3DNOW       // if not, 3DNow! tech. not supported
        mov    eax, 80000001h   // setup extended function 1
        CPUID                   // call the function
        test   edx, 80000000h   // test bit 31
        jz     @@NO_3DNOW
        xor    eax, eax         // 3DNow! technology supported
        inc    eax
        ret
@@NO_3DNOW:
        xor    eax, eax
        ret
end;

(****************************************************************************
 DESCRIPTION:
 Returns true if the processor supports the RDTSC instruction

 RETURNS:
 True if the RTSC instruction is available, false if not.

 REMARKS:
 This function determines if the processor supports the Intel RDTSC
 instruction, for high precision timing. If the processor is not an Intel or
 Intel clone CPU, this function will always return false.

 SEE ALSO:
 CPU_getProcessorType, CPU_isMMXAvailable
****************************************************************************)
function CPU_haveRDTSC: Boolean;
begin
  if CPU_haveCPUID then
   Result := (CPU_getCPUIDFeatures and CPU_HaveRDTSC_) <> 0
  else
   Result := FALSE;
end;

procedure ZTimerQuickInit;
begin
{$ifdef __DOS__}
  ZTimerBIOS := $400;
{$endif}
end;

{$ifdef __WIN32__}
procedure GetCounterFrequency(var freq: CPU_largeInteger);
begin
  if not QueryPerformanceFrequency(freq) then
  begin
    HavePerformanceCounter := FALSE;
    freq.LowPart  := 100000;
    freq.HighPart := 0;
  end else
    havePerformanceCounter := TRUE;
end;

procedure GetCounter(var t: CPU_largeInteger);
begin
  if havePerformanceCounter then
    QueryPerformanceCounter(t)
  else begin
    t.LowPart := timeGetTime * 100;
    t.HighPart := 0;
  end;
end;
{$endif}

{$ifdef __OS2__}
procedure GetCounterFrequency(var freq: CPU_largeInteger);
begin
  freq.LowPart  := 100000;
  freq.HighPart := 0;
end;

procedure GetCounter(var t: CPU_largeInteger);
begin
  t.LowPart := timeGetTime * 100;
  t.HighPart := 0;
end;
{$endif}

{$ifdef __DOS__}
procedure GetCounterFrequency(var freq: CPU_largeInteger);
begin
  ZTimerQuickInit;
  freq.LowPart := 100000;
  freq.HighPart := 0;
end;

procedure GetCounter(var t: CPU_largeInteger);
begin
  t.LowPart := ULZReadTime * 5500;
  t.HighPart := 0;
end;
{$endif}

procedure LZ_Disable; code;
     asm
       cli
       ret
end;

procedure LZ_Enable; code;
     asm
       sti
       ret
end;

(****************************************************************************
 REMARKS:
 On processors supporting the Read Time Stamp opcode, compare elapsed
 time on the High-Resolution Counter with elapsed cycles on the Time
 Stamp Register.

 The inner loop runs up to 20 times oruntil the average of the previous
 three calculated frequencies is within 1 MHz of each of the individual
 calculated frequencies. This resampling increases the accuracy of the
 results since outside factors could affect this calculation.
****************************************************************************)
function GetRDTSCCpuSpeed: LongInt;
var
  t0, t1,count_freq: CPU_largeInteger;
  freq, freq2, freq3: DWord := 0;
  total, tries, total_cycles, cycles,
  stamp0, stamp1, total_ticks, ticks: DWord := 0;
{$ifdef __WIN32__}
var
  iPriority: LongInt;
  hThread:   THandle;
{$endif}
begin
{$ifdef __WIN32__}
  hThread := GetCurrentThread;
  iPriority := GetThreadPriority(hThread);
  if iPriority <> THREAD_PRIORITY_ERROR_RETURN then
    SetThreadPriority(hThread, THREAD_PRIORITY_TIME_CRITICAL);
{$endif}
  GetCounterFrequency(Count_freq);
  repeat
    tries +:= 1;      // Increment number of times sampled
    freq3 := freq2;   // Shift frequencies back
    freq2 := freq;

  (* Loop until 50 ticks have  passed     since last read of hi-res counter.
   * This accounts for overhead later. *)

    GetCounter (t0);
    t1.LowPart := t0.LowPart;
    t1.HighPart := t0.HighPart;
    while ((t1.LowPart - t0.LowPart) < 50) do
    begin
      GetCounter (t1);
      stamp0 := CPU_quickRDTSC;
    end;

   (* Loop until 1000 ticks have passed since last read of hi-res counter.
    * This allows for elapsed time for sampling. *)

    t0.LowPart := t1.LowPart;
    t0.HighPart := t1.HighPart;
    while ((t1.LowPart - t0.LowPart) < 1000) do
    begin
      GetCounter(t1);
      stamp1 := CPU_quickRDTSC;
    end;

   (* Find the difference during the timing loop *)

    cycles := stamp1 - stamp0;
    ticks := t1.LowPart- t0.LowPart;

   (* Note that some seemingly arbitrary mulitplies and  divides are done
    * below. This is to maintain a high level of precision without truncating
    * the most significant data. According to what value ITERATIIONS is set
    * to, these multiplies and  divides might need to be shifted for optimal
    * precision. *)

    ticks := ticks * 100000;
    ticks := ticks div (count_freq.LowPart div 10);
    total_ticks +:= ticks;
    total_cycles +:= cycles;
    if ((ticks mod count_freq.LowPart) > (count_freq.LowPart div 2)) then
      ticks +:=1;                      // Round up if necessary
    freq := cycles div ticks;          // Cycles / us  = MHz
    if ((cycles mod ticks) > (ticks div 2)) then
      freq +:= 1;                      // Round up if necessary
    total := (freq + freq2 + freq3);   // Total last three frequency calculations
  until ((tries < 3 ) or (tries < 20) and
        (((3 * freq -total) > (3 * TOLERANCE)) or
        ( (3 * freq2-total) > (3 * TOLERANCE)) or
        ( (3 * freq3-total) > (3 * TOLERANCE))));
{$ifdef __WIN32__}
if iPriority <> THREAD_PRIORITY_ERROR_RETURN then
  SetThreadPriority(hThread, iPriority);
{$endif}
  Result := (total_cycles div total_ticks);
end;

(****************************************************************************
 REMARKS:
 If processor does not support time stamp reading, but is at least a 386 or
 above, utilize method of timing a loop of BSF instructions which take a
 known number of cycles to run on i386(tm), i486(tm), and Pentium(R)
 processors.
****************************************************************************)
function GetBSFCpuSpeed(Cycles: DWord): DWord;
var
  t0, t1, count_freq: CPU_largeInteger;
  ticks, current, i: DWORD;
  lowest: DWORD := High(DWORD) - 1;
{$ifdef __WIN32__}
var
  iPriority: LongInt;
  hThread:   THandle;
{$endif}
begin
{$ifdef __WIN32__}
  hThread := GetCurrentThread;
  iPriority := GetThreadPriority(hThread);
  if iPriority <> THREAD_PRIORITY_ERROR_RETURN then
    SetThreadPriority(hThread, THREAD_PRIORITY_TIME_CRITICAL);
{$endif}
{$ifdef __DOS__}
  count_freq.LowPart  := 100000;
  count_freq.HighPart := 0;
  ZTimerQuickInit;
  LZTimerOn;
{$else}
  GetCounterFrequency(Count_freq);
{$endif}
  for i := 0 to SAMPLINGS do
  begin
{$ifdef __DOS__}
    t0.LowPart := LZTimerLap div 10;
{$else}
    GetCounter(t0);
{$endif}
    CPU_runBSFLoop(ITERATIONS);
{$ifdef __DOS__}
    t1.LowPart := LZTimerLap div 10;
{$else}
    GetCounter(t1);
{$endif}
    current:= t1.LowPart - t0.LowPart;
    if current < lowest then lowest := current;
  end;
{$Ifdef __DOS__}
  LZTimerOff;
{$endif}
{$ifdef __WIN32__}
  if iPriority <> THREAD_PRIORITY_ERROR_RETURN then
    SetThreadPriority(hThread, iPriority);
{$endif}
  (* Compute frequency *)
  ticks:= lowest;
  ticks:= ticks * 100000;
  ticks:= ticks div (count_freq.LowPart div 10);
  if ((ticks mod count_freq.LowPart) > (count_freq.LowPart div 2)) then
    ticks +:= 1;
  if ticks = 0 then
    Result := 0
  else
    Result := Cycles div ticks;
end;

(****************************************************************************
 DESCRIPTION:
 Returns the speed of the processor in Mhz.

 RETURNS:
 Processor speed in Mhz.

 REMARKS:
 This function returns the speed of the CPU in Mhz. Note that if the speed
 cannot be determined, this function will return 0.

 SEE ALSO:
 CPU_getProcessorType, CPU_haveMMX
****************************************************************************)
function CPU_getProcessorSpeed: DWord;
var
  cpuSpeed, i, tries, processor: DWord;
const
  processor_cycles: array [0..6] of DWord =
  (
   0, 115 ,47, 43, 38, 38, 38
  );

  known_speeds: array [0..23] of DWord =
  (
   600, 550, 500, 450, 400, 375, 333, 300,
   266, 233, 200, 166, 150, 133, 120, 100,
   90, 75, 66, 60, 50, 33, 20, 0
  );
begin
  processor := CPU_getProcessorType and CPU_mask;
  (* Try 3 times for insurance... *)
  for tries := 1 to 3 do
   begin
    if CPU_haveRDTSC then
      cpuSpeed := GetRDTSCCpuSpeed
    else
      cpuSpeed := GetBSFCpuSpeed(ITERATIONS * processor_cycles[processor]);
    i := 0;
    repeat
     if (CpuSpeed >= (known_speeds[i]-2)) and (CpuSpeed <= (known_speeds[i]+2))
     then begin
       Result := known_speeds[i];
       exit;
     end;
     i +:= 1;
    until known_speeds[i] = 0;
  end;
  Result:=cpuSpeed;
end;

procedure ZTimerInit;
begin
  if cpuSpeed = -1 then
  begin
    ZTimerQuickInit;
    cpuSpeed := CPU_getProcessorSpeed * 1000000;
    if CPU_getProcessorType > CPU_i486 then
      haveRDTSC := (CPU_haveRDTSC) and (cpuSpeed > 0)
    else
      haveRDTSC := FALSE;
  end;
{$ifdef __WIN32__}
  havePerformanceCounter := QueryPerformanceFrequency (CountFreq);
{$endif}
end;

procedure LZTimerOn;
begin
  if haveRDTSC then
  begin
    CPU_readTimeStamp (tmStart);
  end
{$ifdef __WIN32__}
  else
  begin
    if havePerformanceCounter then
      QueryPerformanceCounter(tmStart)
    else
      tmStart.LowPart := timeGetTime;
  end;
{$endif}
{$ifdef __OS2__}
  else
    tmStart.LowPart := timeGetTime;
{$endif}
{$ifdef __DOS__}
  else
    LZ_timerOn;
{$endif}
end;

function LZTimerLap: DWord;
var
  tmLap,tmCount: CPU_largeInteger;
begin
  if haveRDTSC then
  begin
    CPU_readTimeStamp(tmLap);
    CPU_diffTime64(tmStart, tmLap, tmCount);
    Result:=CPU_calcMicroSec(tmCount, cpuSpeed);
  end
{$ifdef __WIN32__}
  else begin
    if havePerformanceCounter then
    begin
      QueryPerformanceCounter(tmLap);
      CPU_diffTime64(tmStart, tmLap, tmCount);
      Result := CPU_calcMicroSec(tmCount, countFreq.LowPart);
    end else
    begin
      tmLap.LowPart := timeGetTime;
      Result := (tmLap.LowPart - tmStart.LowPart) * 1000;
    end;
  end;
{$endif}
{$ifdef __OS2__}
  else
  begin
    tmLap.LowPart := timeGetTime;
    Result := (tmLap.LowPart - tmStart.LowPart) * 1000;
  end;
{$endif}
{$ifdef __DOS__}
  else
    Result := LZ_timerLap
{$endif}
end;

procedure LZTimerOff;
begin
  if haveRDTSC then
  begin
    CPU_readTimeStamp(tmEnd);
  end
{$ifdef __WIN32__}
  else
    if havePerformanceCounter then
      QueryPerformanceCounter(tmEnd)
    else
      tmEnd.LowPart := timeGetTime;
{$endif}
{$ifdef __OS2__}
  else
    tmEnd.LowPart := timeGetTime;
{$endif}
{$ifdef __DOS__}
  else
    LZ_timerOff;
{$endif}
end;

function LZTimerCount: DWord;
var
  tmCount: CPU_largeInteger;
begin
  if haveRDTSC then
  begin
    CPU_diffTime64(tmStart, tmEnd, tmCount);
    Result:=CPU_calcMicroSec(tmCount, cpuSpeed);
  end
{$ifdef __WIN32__}
  else
    if havePerformanceCounter then
    begin
      CPU_diffTime64(tmStart, tmEnd, tmCount);
      Result := CPU_calcMicroSec(tmCount, countFreq.LowPart);
    end else
      Result := (tmEnd.LowPart - tmStart.LowPart) * 1000;
{$endif}
{$ifdef __OS2__}
  else
    Result := (tmEnd.LowPart - tmStart.LowPart) * 1000;
{$endif}
{$ifdef __DOS__}
  else
    Result := LZ_timerCount;
{$endif}
end;

procedure LZDelay(Value: DWord);
var
  CurValue: DWord;
begin
  CurValue := LZTimerLap + Value;
  while LZTimerLap < CurValue do (* nothing *)
end;

function LZTimerResolution: Double;
begin
  Result := 1E-6;
end;

procedure ULZTimerOn;
begin
{$ifdef __DOS__}
  Start := ULZReadTime;
{$else}
  Start := timeGetTime;
{$endif}
end;

procedure ULZTimerOff;
begin
{$ifdef __DOS__}
  Finish := ULZReadTime;
{$else}
  Finish := timeGetTime;
{$endif}
end;

function ULZTimerLap: DWord;
begin
{$ifdef __DOS__}
  Result := ULZElapsedTime(Start, ULZReadTime);
{$else}
  Result := timeGetTime - Start;
{$endif}
end;

function ULZTimerCount: DWord;
begin
{$ifdef __DOS__}
  Result := ULZElapsedTime(Start, Finish);
{$else}
  Result := Finish - Start;
{$endif}
end;

function ULZReadTime: DWord;
{$ifdef __DOS__}
var
  ticks: DWord;
begin
  LZ_Disable;
  ticks := DWord(Pointer(ZTimerBIOS+$6C)^);
  LZ_Enable;
  Result := ticks;
end;
{$else}
begin
  Result := timeGetTime;
end;
{$endif}

function ULZElapsedTime(start, finish: DWord): DWord;
begin
  (* Check to see whether a midnight boundary has passed, and if so
   * adjust the finish time to account for this. We cannot detect if
   * more that one midnight boundary has passed, so if this happens
   * we will be generating erronous results. *)
{$ifdef __DOS__}
  if Finish < Start then Finish +:= 1573040; // Number of ticks in 24 hours
  Result:= Finish - Start;
{$else}
  Result := Finish - Start;
{$endif}
end;

function ULZTimerResolution: Double;
begin
{$ifdef __DOS__}
  Result := 0.054925;
{$else}
  Result := 0.001;
{$endif}
end;

procedure ULZDelay(Value: DWord);
var
  CurValue: DWord;
begin
  CurValue := ULZTimerLap + Value;
  while ULZTimerLap < CurValue do (* nothing *)
end;

procedure LZTimer.ComputeTime;
var
  newcount: DWord;
begin
  if not _overflow then
  begin
    newcount := LZTimerCount;
    if newcount = $FFFFFFFF then
      _overflow := TRUE
    else
      _count +:= newcount;
  end;
end;

procedure LZTimer.LZTimer;
begin
  ZTimerInit;
  Reset;
end;

procedure LZTimer.Start;
begin
  _count := 0;
  LZTimerOn;
end;

procedure LZTimer.Restart;
begin
  Reset;
  Start;
end;

procedure LZTimer.Stop;
begin
  LZTimerOff;
  ComputeTime;
end;

function LZTimer.Lap: DWord;
begin
  Result := _count + LZTimerLap;
end;

function LZTimer.Count: DWord;
begin
  Result := _count;
end;

procedure LZTimer.Reset;
begin
  _count := 0;
  _overflow := FALSE;
end;

function LZTimer.Overflow: Boolean;
begin
  Result := _overflow;
end;

function LZTimer.Resolution: Double;
begin
  Result := 1E-6;
end;

procedure LZTimer.Delay(Value: DWord);
begin
  LZDelay(Value);
end;

procedure ULZTimer.ULZTimer;
begin
  ZTimerInit;
  _count := 0;
end;

procedure ULZTimer.Start;
begin
  _start := ULZReadTime;
end;

procedure ULZTimer.Restart;
begin
  Reset;
  Start;
end;

function ULZTimer.Lap: DWord;
begin
  Result:= ULZElapsedTime(_start,ULZReadTime);
end;

procedure ULZTimer.Stop;
begin
  _finish := ULZReadTime;
  _count +:= ULZElapsedTime(_start,_finish);
end;

function ULZTimer.Count: DWord;
begin
  Result :=_count;
end;

procedure ULZTimer.Reset;
begin
  _count := 0;
end;

function ULZTimer.Resolution: Double;
begin
{$ifdef __DOS__}
  Result := 0.054925;
{$else}
  Result := 0.001;
{$endif}
end;

procedure ULZTimer.Delay(Value: DWord);
begin
  ULZDelay(Value);
end;

begin
  CpuSpeed := -1;
  FillChar(tmStart, SizeOf(tmStart), 0);
  FillChar(tmEnd, SizeOf(tmEnd), 0);
  ZTimerInit;
end.