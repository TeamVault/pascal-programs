{************************************************}
{                                                }
{   Chess - Shared DLL Example                   }
{   CHESS.DLL Task managment.                    }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ This unit allocates and manages a separate stack that is used to
  preform the game searches.   It is *very* important that, when running
  under Windows, Windows calls are made while in the child task.  Many
  Windows calls use the stack to determine the task handle and the stack
  must be the DLL's client's stack or Windows will become confused. }

unit TaskMgr;

{$R-,Q-,G+,S-,W-}

interface

type
  { Stores the state of the stack   }
  TTaskInfo = record
    SPtr, SSeg, Size: Word;
  end;

  TSpawnProc = procedure;


{ Allocate the stack used by the game task }
procedure AllocateTask(Size: Word);

{ Dispose of the stack allocated by AllocateTask }
procedure DisposeTask;

{ Spawn a mini process which will call the given function upon start-up. }
procedure Spawn(Proc: TSpawnProc);

{ Suspend the current task waiting for a message from another task.  The
  return value of this function is the Msg paramter of the Message call
  perfomed by the other task. Each task will alternate (coopertivly
  multitask) calling Message. }
function Message(Msg: Word): Word;

implementation

{$IFDEF WINDOWS}
uses GameRec, OMemory;
{$ELSE}
uses GameRec, Memory;
{$ENDIF}

procedure AllocateTask(Size: Word);
var
  P : Pointer;
begin
  P := MemAllocSeg(Size);
  if P = nil then Exit;
  with CC do
  begin
    GameStack.SSeg := Seg(P^);
    GameStack.Size := Size;
    GameStack.SPtr := Size - 2;
    AppStack.SSeg  := SSeg;
  end;
end;


procedure DisposeTask;
begin
  with CC.GameStack do
    if SSeg <> 0 then FreeMem(Ptr(SSeg, 0), Size);
  FillChar(CC.GameStack, 0, SizeOf(CC.GameStack));
end;

 { TerminateTask kills the game stack and RETurns to the ret addr  }
 { already on App stack, presumeably, the last caller of Resume.   }
 { The Game stack only shares a common starting point with the App }
 { stack - after that, it runs to completion without trying to     }
 { splice its execution back into the App stack.                   }

procedure TerminateTask(Dummy: Word); far; assembler;
asm
        { Switch to the App's stack }
	MOV	SS, CC.AppStack.SSeg
	MOV	SP, CC.AppStack.SPtr
        MOV	BP, SP
end;

function Message(Msg: Word): Word; assembler;
asm
	MOV	AX, Msg
	MOV	BX, SS
	CMP	BX, CC.AppStack.SSeg
	JNE	@@1

        { Switch to game stack }
	MOV	CC.AppStack.SPtr, SP

	MOV	SS, CC.GameStack.SSeg   { Now on the new stack }
	MOV	SP, CC.GameStack.SPtr
	JMP	@@2

        { Back to the App stack }
@@1:	MOV	CC.GameStack.SPtr, SP

	MOV	SS, CC.AppStack.SSeg     { Now on the new stack }
	MOV	SP, CC.AppStack.SPtr
@@2:
	MOV	BP, SP
end;



procedure Spawn( Proc: TSpawnProc); assembler;
asm
	MOV	AX, SS

	{ only an App can Spawn a game }
	CMP	AX, CC.AppStack.SSeg
	JNE	@@1

        { Setup task stack }
        LES	DI,DWORD PTR CC.GameStack.TTaskInfo.SPtr
        STD

        {  Returning out will terminate task }
        MOV	AX, SEG TerminateTask
        STOSW
        MOV	AX, OFFSET TerminateTask
        STOSW

        { Setup ret to "call" proc }
        MOV	AX, Proc.Word[2]
        STOSW
        MOV	AX, Proc.Word[0]
        STOSW
        MOV	AX, DI			{ Fake BP }
        STOSW
        CLD
        MOV	CC.GameStack.TTaskInfo.SPtr,AX

        PUSH	0
        CALL	Message
@@1:
end;

end.

