 ////////////////////////////////////////////////////////////////////////////
 //                  EXEMPLE TO WORK WITH 32-BITS SELECTORS                //
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

 program TestFar;

 {$r-,w-}

 // This program shows, how to allocate protected mode selector
 // and get access to it.

 uses DPMI, CRT;

 var j,i: DWord;
     ScrSeg: Word;

 begin

  (* Allocate new 32-bit protected selector with 0A0000h base address *)
  (* and 0FFFFh bytes limit it's enough for access to a VGA memory    *)
  ScrSeg:=CreateDataDescriptor($A0000,$FFFF);

  (* Set MCGA/VGA mode 320x200x256 *)
  asm mov ax,$13; int $10; end;

  (* Fill VGA memory with vertical color lines *)
  for j:=0 to 199 do
    for i:=0 to 319 do
      FarPutByte(ScrSeg,i+j*320,Byte(i));

  (* Wait a key *)
  ReadKey;

  (* Fill VGA memory with horizontal color lines *)
  for j:=0 to 199 do
    for i:=0 to 319 do
       FarPutByte(ScrSeg,i+j*320,Byte(j));

  (* Wait a key *)
  ReadKey;

  (* Set VGA text mode (03h BIOS) *)
  asm mov ax,$03; int $10; end;

  (* Free allocated selector and exit *)
  FreeDescriptor(ScrSeg);

 end.