 ////////////////////////////////////////////////////////////////////////////
 //                   16-bit REAL MODE PROCEDURE EXECUTE                   //
 //                                                                        //
 //                     Copyright (C) 1997,98 TMT Corp.                    //
 //                           All Rights Reserved.                         //
 //                                                                        //
 //  Author:              Vadim Bodrov, TMT Corp.                          //
 //                                                                        //
 //  Language:            TMT PASCAL                                       //
 //  Supported extenders: PASSTUB.EXE, PMWSTUB.EXE, DOS32.EXE              //
 //  Environment:         IBM PC i80386+ (MsDos) 32 bit Protected Mode.    //
 ////////////////////////////////////////////////////////////////////////////

 program Exec16;

 // This program shows, how to call 16-bit real mode procedures (.COM files)
 // from protected mode program.

 uses DPMI, CRT;

 var f:      file;
     Regs:   TRmRegs;
     Size:   DWord;
     DosSeg: Word;

 begin
  (* Read COM-file into protected mode memory *)
  Assign(f,'example.com');
  Reset(f);
  (* Get size of real mode procedure *)
  Size:=FileSize(f);
  if Size=0 then exit;
  (* Allocate buffer in DOS (lower) memory *)
  DosSeg:=DosMemoryAlloc(Size);
  if DosSeg=0 then begin
   Writeln(' Not enaugh free DOS memory!');
   exit;
  end;
  (* Read real mode procedure to the lower memory *)
  BlockRead(f,Pointer(DWord(DosSeg)*16)^,Size);
  Close(f);

  Writeln;
  Writeln('Press any key to fill the screen...');
  (* Wait a key *)
  ReadKey;

  (* Execute 16-bit real mode procedure with far ret frame *)
  ClearRmRegs(Regs);
  Regs.CS:=DosSeg;
  Regs.IP:=10;
  CallRealModeFar(Regs);

  DosMemoryFree(DosSeg);

  ClrScr;

  Writeln('Real mode procedure terminated...');
 end.