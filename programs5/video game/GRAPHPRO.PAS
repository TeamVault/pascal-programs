Unit GraphPro;

Interface

{Graphics}
Procedure SetMCga;
          INLINE($B8/$13/$00/$CD/$10);

Procedure SetText;
          INLINE($B8/$03/$00/$CD/$10);

Procedure Pixel   (X,Y      : Word; Col      : Byte; P: Word       );
          INLINE($8b/$DD/        {MOV bx,bp}
                 $8B/$EC/        {MOV bp,sp}
                 $8B/$7E/$04/    {MOV di,[bp+04]}
                 $C1/$E7/$06/    {SHL di,6}
                 $67/$8D/$3C/$BF/{LEA di,[edi+edi*4]}
                 $8E/$46/$00/    {MOV es,[bp+00]}
                 $8A/$46/$02/    {MOV al,[bp+02]}
                 $03/$7E/$06/    {ADD di,[bp+06]}
                 $26/$88/$05/    {MOV es:[di],al}
                 $8B/$EB/        {MOV bp,bx}
                 $83/$C4/$08     {ADD sp,08}
                 ); {By Ken Alverson, mangled by ME!}

Function GETPixel(X,Y : Word; P : Word) : Byte;
          INLINE($8b/$DD/        {MOV bx,bp}
                 $8B/$EC/        {MOV bp,sp}
                 $8B/$7E/$04/    {MOV di,[bp+02]}
                 $C1/$E7/$06/    {SHL di,6}
                 $67/$8D/$3C/$BF/{LEA di,[edi+edi*4]}
                 $8E/$46/$00/    {MOV es,[bp+00]}
                 $03/$7E/$06/    {ADD di,[bp+04]}
                 $26/$8A/$05/    {MOV al,es:[di]}
                 $8B/$EB/        {MOV bp,bx}
                 $83/$C4/$06     {ADD sp,08}
                 );

Procedure DrawPic (where,X,Y,XLen : Word; YLen     : Byte; Pic : Pointer );
        INLINE(
          $1E/
          $55/
          $89/$E5/
          $83/$C5/$04/
          $BA/$40/$01/
          $8B/$5E/$06/
          $29/$DA/
          $8E/$46/$0C/
          $8B/$7E/$08/
          $89/$F8/
          $C1/$E7/$08/
          $C1/$E0/$06/
          $01/$C7/
          $8B/$46/$0A/
          $01/$C7/
          $8B/$76/$00/
          $8E/$5E/$02/
          $30/$E4/
          $FE/$C4/
          $3A/$66/$04/
          $74/$09/
          $8B/$4E/$06/
          $F3/$A4/
          $01/$D7/
          $EB/$F0/
          $5D/
          $1F/
          $83/$C4/$0E
          ); {By Ariel}

Procedure Box     (X,Y,XLen : Word; YLen,Col : Byte                );
Procedure FillScr (Col                       : Byte                );

{KeyBoard}
Procedure KeyInit;
Procedure KeyDone;
Procedure CleanBuff;

Var
  VGA,
  BUFF,
  KeySeg,
  KeyOfs  : Word;
  Keys    : array [ 1..127 ] of boolean;

Implementation

Uses Dos;

Var
  Old               : Procedure;

Procedure SetMode( M : Byte); Assembler;
ASM
  XOR AX,AX
  MOV AL,  M
  INT 10H
END;

Procedure Box     (X,Y,XLen : Word; YLen,Col : Byte); Assembler;
Asm
  MOV  DX,  320
  MOV  BX,  XLen
  SUB  DX,  BX
  MOV  ES,  VGA
  MOV  DI,  Y
  MOV  AX,  DI
  SHL  DI,  8
  SHL  AX,  6
  ADD  DI,  AX
  MOV  AX,  X
  ADD  DI,  AX
  MOV  Al,  Col
  XOR  BL,  BL
@LOOP:
  INC  BL
  CMP  BL,  YLen
  JE   @END
  MOV  CX,  XLen
  REP  STOSB
  ADD  DI,  DX
  JMP  @LOOP
@END:
END;

Procedure FillScr (Col : Byte); Assembler;
Asm
  XOR  DI,  DI
  MOV  ES,  VGA
  MOV  CX,  064000/4
  MOV  AL,  Col
  MOV  AH,  AL
  MOV  DX,  AX
  DB   $66
  SHL  AX,  16
  MOV  AX,  DX
  DB   $66
  REP  STOSW
End;

{KeyBoard}
Procedure KeyStatus; Interrupt; Assembler;
Asm
    PushF
    call old
    Xor  Ax,Ax
    mov  bl,0127d
    in   al,060h
    mov  dh,al
    and  al,bl
    mov  ES,Keyseg
    mov  DI,KeyOfs
    add  di,ax
    dec  di
    cmp  dh,al
    je   @A
    mov  al,FALSE
    jmp  @SF
@A: mov  al,TRUE
@SF:StosB
    Call CleanBuff
End;

Procedure Keyinit;
Var
  Count : Byte;
Begin
  For count:=1 to 127 do
    Keys[count]:=false;
  KeySeg:=Seg(Keys);
  KeyOfs:=Ofs(Keys);
  GetIntVec(9,@Old);
  SetIntVec(9,@keystatus)
End;

Procedure Keydone;
Begin
  SetIntVec(9,@Old)
End;

Procedure CleanBuff; Assembler;
Asm
  Mov Ax,BUFF
  Mov Es,Ax
  Mov Di,01ah
  Mov Al,Es:[Di]
  Mov Di,01ch
  Mov Es:[Di],Al
End;

Begin
  BUFF := SEG0040;
  VGA  := SEGA000;
End.
