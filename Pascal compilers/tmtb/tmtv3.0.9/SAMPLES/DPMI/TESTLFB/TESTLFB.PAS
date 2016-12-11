 ////////////////////////////////////////////////////////////////////////////
 //                 LINEAR FLAT FRAME BUFFER TEST PROGRAM                  //
 //                                                                        //
 //                     Copyright (C) 1997,98 TMT Corp.                    //
 //                           All Rights Reserved.                         //
 //                                                                        //
 //  Author:              Vadim Bodrov, TMT Corp.                          //
 //                                                                        //
 //  Language:            TMT PASCAL                                       //
 //  Supported extenders: PASSTUB.EXE, PMWSTUB.EXE, DOS32.EXE              //
 //  Environment:         IBM PC i80386+ (MsDos) 32 bit Protected Mode.    //
 //                       VESA VBE 2.0 compatible video card               //
 ////////////////////////////////////////////////////////////////////////////
 {$r-,w+,oa-}

 program TestLFB;

 // This program shows, how to work with SVGA LFB video modes

 uses DPMI, CRT;

 (* VBE info block structure *)
 type
 TVbeInfo = record
  VbeSignature       : DWord;
  VbeVersion         : Word;
  OemStringPtr       : DWord;
  Capabilities       : DWord;
  VideoModePtr       : DWord;
  TotalMemory        : Word;
  OEMSoftwareRev     : Word;
  OEMVendorNamePtr   : DWord;
  OEMProductNamePtr  : DWord;
  OEMProductRevPtr   : DWord;
  Reserved           : array [0..221] of Byte;
  OEMData            : array [0..255] of Byte;
 end;

 (* VBE mode info block structure *)
 TVbeModeInfo = record
  ModeAttributes     : Word;
  WinAAttributes     : Byte;
  WinBAttributes     : Byte;
  WinGranularity     : Word;
  WinSize            : Word;
  WinASegment        : Word;
  WinBSegment        : Word;
  WinFuncPtr         : Pointer;
  BytesPerScanLine   : Word;
  XResolution        : Word;
  YResolution        : Word;
  XCharSize          : Byte;
  YCharSize          : Byte;
  NumberOfPlanes     : Byte;
  BitsPerPixel       : Byte;
  NumberOfBanks      : Byte;
  MemoryModel        : Byte;
  BankSize           : Byte;
  NumberOfImagePages : Byte;
  Reserved           : Byte;
  RedMaskSize        : Byte;
  RedFieldPosition   : Byte;
  GreenMaskSize      : Byte;
  GreenFieldPosition : Byte;
  BlueMaskSize       : Byte;
  BlueFieldPosition  : Byte;
  RsvdMaskSize       : Byte;
  RsvdFieldPosition  : Byte;
  DirectColorModeInfo: Byte;
  PhysBasePtr        : DWord;
  OffScreenMemOffset : DWord;
  OffScreenMemSize   : Word;
  Reserved2          : Array [0..205] of Byte;
 end;

 var VESAInfo: TVBEInfo;
     VESAModeInfo: TVBEModeInfo;
     Regs: TRmRegs;
     VBE_VideoMem: DWord;
     i,j: DWord;

 begin

  ClrScr;

  Writeln(' LINEAR FLAT FRAME BUFFER TEST demo program for DPMILIB.FPD unit');
  Writeln(' ---------------------------------------------------------------');
  Writeln;

  (* Always clear Real Mode Registers Table before simulate *)
  (* Real Mode Interupt                                     *)
  ClearRmRegs(Regs);
  (* VBE function 4F00h - Get VESA Info. *)
  Regs.AX:=$4F00;
  (* Use 8k internal system buffer for simplification *)
  Regs.ES:=Buf_16;
  RealModeInt($10,Regs);
  (* Move VESA information block to VESAInfo structure *)
  Move(Pointer(Buf_32)^,VESAInfo,256);
  (* Is VESA supported? *)
  if (Regs.AX<>$004F) or (VESAInfo.VbeSignature<>$41534556) then begin
   Writeln(' VESA not detected...');
   exit;
  end;
  Writeln(' Detected VESA BIOS EXTENSION');
  Writeln(' VBE version: ',Hi(VESAInfo.VbeVersion),'.',Lo(VESAInfo.VbeVersion));
  Writeln(' Total video memory: ',VESAInfo.TotalMemory*64,' Kb');
  if VESAInfo.VbeVersion<$200 then begin
   Writeln(' LFB require VESA version 2.0 or higher...');
   Writeln(' Try to run UniVBE 5.1+ by SciTech Soft.');
   exit;
  end;
  if VESAInfo.TotalMemory<16 then begin
   Writeln(' 1024 K video memory required!..');
   exit;
  end;

  (* Get VESA mode info for SVGA LFB mode 4101h (640x480x256) *)
  ClearRmRegs(Regs);
  Regs.ES:=Buf_16;
  Regs.AX:=$4F01;
  Regs.DI:=$0000;
  Regs.CX:=$0101;
  RealModeInt($10,Regs);
  Move(Pointer(Buf_32)^,VESAModeInfo,256);
  (* Is mode supported? *)
  if (Regs.AX<>$004F) or (VESAModeInfo.PhysBasePtr=0) then begin
   Writeln(' VESA VBE mode 4101h (SVGA LFB 640x480x256) not supported...');
   exit;
  end;

  (* Map physical address, returned in VESAModeInfo.PhysBasePtr *)
  (* by function 4F01h. Set limit on 4 Mb for any case *)
  Vbe_VideoMem:=MapPhysicalToLinear(VESAModeInfo.PhysBasePtr,4096*1024);

  if Vbe_VideoMem=0 then begin
   Writeln(' Can`t map physical memory to linear (error execute function 800h DPMI)');
   Writeln(' Try to run this program under QEMM in RAW DOS or under Windows`95...');
   exit;
  end;

  Writeln(' Press any key to run LFB test...');
  (* Wait a key *)
  ReadKey;

  (* Set VESA VBE video mode 4101h *)
  ClearRmRegs(Regs);
  Regs.AX:=$4F02;
  Regs.BX:=$4101;
  RealModeInt($10,Regs);
  (* Is mode installed corectly ? *)
  if (Regs.AX<>$004F) then begin
   Writeln(' Can`t set VESA VBE mode 4101h (SVGA LFB 640x480x256)...');
   exit;
  end;

  (* Fill screen with color 15 to make it white... *)
  FillChar(Pointer(VBE_VideoMem)^,640*480,15);
  (* Wait a key *)
  ReadKey;

  (* Fill screen with horizontal color lines... *)
  for j:=0 to 479 do
   for i:=0 to 639 do Byte(Pointer(VBE_VideoMem+i+j*640)^):=(j);
  (* Wait a key *)
  ReadKey;

  (* Fill screen with vertical color lines... *)
  for j:=0 to 479 do
   for i:=0 to 639 do Byte(Pointer(VBE_VideoMem+i+j*640)^):=(i);
  (* Wait a key *)
  ReadKey;

  (* Fill screen with color 12 to make it light red... *)
  FillChar(Pointer(VBE_VideoMem)^,640*480,12);
  (* Wait a key *)
  ReadKey;

  (* Set standard VGA text mode (03h BIOS) *)
  ClearRmRegs(Regs);
  Regs.AX:=$03;
  RealModeInt($10,Regs);

  (* Free physical mapping *)
  FreePhysicalMap(VBE_VideoMem);

  Writeln(' Test passed successful!');

 end.