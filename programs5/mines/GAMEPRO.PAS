Unit GamePro;

{
  Ver 2.41 ,  By Ariel Keselman 1995,96 (c)
  Helped by Mr. DGI.
}

{$G+,X+}

Interface

Type
  Vector_Table      = Array[0..255] Of Pointer;
  Paltype           = Array [ 0..255 , 0..2 ] Of Byte;
  Direction         = (Right,Left);

Var
  keys    : array [ 1..127 ] of boolean;
  IntVec  : Vector_Table Absolute 0:0;

{KeyBoard}
Procedure KeyInit;
Procedure KeyDone;
Procedure CleanBuff;

{TextScreen}
Procedure SaveScreen;
Procedure UndoScreen;
Procedure SetTextMode;

{ Graphics Mode Procedures (And A Function) }
Procedure WaitRetrace;
procedure setshowfrom(x:word);
procedure showpage(x:word);
procedure setwritefrom(x:word);
procedure writepage(x:word);
{Procedure InitPix;}
procedure pixel(x,y:word;c:byte);
Function  GetPix(X,Y:Integer):Byte;
procedure setxmode;
Procedure PutImage(lngtx,lngty,X,Y : Word; Image : Pointer);
Procedure PrepareFlip;
Procedure CopyBox(PFrom,PX1,PY1,PX2,PY2,PTo,XT,YT : Word);
Procedure Flip   (Source,Dest : Word);
Procedure FlipDone;

{Cel}
Procedure LoadCEL (F : String; Var Lx,Ly : Word; Var Image : Pointer);

{Palette}
Procedure GetPal(Col : Byte; Var R,G,B : Byte);
Procedure CyclePal( StartPal, EndPal : byte; Way : Direction );
Procedure GetAllPal( Var P : PalType );
Procedure SetAllPal(Var Palette : PalType);
Procedure LoadPal (F : String; Var Pall : PalType );
Procedure Pal(Col,R,G,B : Byte);
Procedure Fade2Pal( Pall : PalType ; StartPal, EndPal, D : Word);
Procedure StepFade( Pall : PalType ; StartPal, EndPal, D , Times : Word);
Procedure FillPalType( Var Pall : PalType; R,G,B : Word);


Implementation

Uses Crt;

Var
  Old               : Procedure;
  showfrom,
  writefrom,
  keyseg,keyofs     : Word;
  SvdScr            : Pointer;


{KeyBoard}
Procedure keystatus; Interrupt;
{Begin
  Asm PushF End;
  Old;
  Keys[Port[$60] Mod $80]:= Port[$60]<$80;
End;}
Assembler;
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
    Call CleanBuff;
End;

Procedure Keyinit;
Var
  Count : Byte;
Begin
  For count:=1 to 127 do
    Keys[count]:=false;
  KeySeg:=Seg(Keys);
  KeyOfs:=Ofs(Keys);
  @Old:=IntVec[9];
  intvec[9]:=@keystatus;
End;

Procedure Keydone;
begin
  intvec[9]:=@old
end;

Procedure CleanBuff; Assembler;
Asm
  Mov Ax,040h
  Mov Es,Ax
  Mov Di,01ah
  Mov Al,Es:[Di]
  Mov Di,01ch
  Mov Es:[Di],Al
End;

{Screen}
procedure WaitRetrace; assembler;
Asm
  Mov Dx,03Dah
  @P: In al,dx
  Test al,8
  Jz @P
End;

Procedure SaveScreen;
Begin
  GetMem(SvdScr,8000);
  Move(Mem[$B800:000],SvdScr^,8000);
End;

Procedure UndoScreen;
Begin
  Move(SvdScr^,Mem[$B800:000],8000);
  FreeMem(SvdScr,8000);
End;

Procedure SetTextMode; Assembler;
Asm
  Mov Ax,03
  Int 10h
End;


{Xmode}
procedure setshowfrom(x:word); Assembler;
asm
  mov dx,03d4h
  mov al,0ch
  out dx,al
  mov ax,x
  and ax,0ff00h
  mov al,ah
  inc dx
  out dx,al
  dec dx
  mov al,0dh
  out dx,al
  mov ax,x
  and ax,000ffh
  inc dx
  out dx,al
End;

Procedure showpage(x:word);
Begin
  setshowfrom(x*80*240);
End;

procedure setwritefrom(x:word);
begin
  writefrom:=x;
end;

procedure writepage(x:word);
begin
  setwritefrom(x*80*240);
end;

procedure pixel(x,y:word;c:byte); Assembler;
asm
  mov dx,03c4h
  mov al,02h
  out dx,al
 {port[$3c5]:=1 shl (x and 3);}
  mov dx,03c5h
  mov al,1
  mov cx,x
  and cx,3
  shl al,cl
  out dx,al

 {mem[$a000:(80*y)+(x div 4)+writefrom]:=c;}
  mov es,sega000

 {(80*y)}
  mov di,y
  mov bx,di
  shl di,06
  shl bx,04
  add di,bx

 {+(X div 4)}
  mov cx,x
  shr cx,2
  add di,cx

 {+WriteFrom}
  mov ax,writefrom
  add di,ax
  mov al,c

 {Do IT}
  stosB
End;

Function GetPix(X,Y:Integer):Byte; Assembler;
Asm
{   Port[$3CE]:=$04;}
  mov dx,03ceH
  mov al,04
  out dx,al
{   Port[$3CE+1]:=x And 3;}
  mov ax,x
  and ax,03
  inc dx
  out dx,ax
{   GetPix:=mem[$A000:(80*y)+(x div 4) + WriteFrom];}
  mov es, SegA000
  mov ax,y
  mov bx,ax
  shl ax,6
  shl bx,4
  add ax,bx
  mov bx,x
  shr bx,2
  add ax,bx
  add ax,writefrom
  mov di,ax
  xor ax,ax
  mov al,es:[di]
End;

procedure setxmode; Assembler;
  asm
    mov ax,13h
    int 10h
    mov dx,03c4h
    mov ax,0604h
    out dx,ax
    mov ax,0100h
    out dx,ax
    mov dx,03c2h
    mov al,0e3h
    out dx,al
    mov dx,03c4h
    mov ax,0300h
    out dx,ax
    mov dx,03d4h
    mov al,11h
    out dx,al
    inc dx
    in al,dx
    and al,7fh
    out dx,al
    dec dx
    cld
    mov ax,00d06h
    out dx,ax
    mov ax,03e07h
    out dx,ax
    mov ax,04109h
    out dx,ax
    mov ax,0ea10h
    out dx,ax
    mov ax,0ac11h
    out dx,ax
    mov ax,0df12h
    out dx,ax
    mov ax,00014h
    out dx,ax
    mov ax,0e715h
    out dx,ax
    mov ax,00616h
    out dx,ax
    mov ax,0e317h
    out dx,ax
    mov dx,03c4h
    mov al,2h
    out dx,al
    inc dx
    mov al,0fh
    out dx,al
    mov ax,0a000h
    mov es,ax
    mov di,0
    mov cx,0ffffh
    mov al,0
    rep stosb
End;

Procedure PrepareFlip; Assembler;
Asm
  Mov Dx,03c4h+1
  Mov Al,0fh
  Out Dx,Al
  Mov Dx,03ceh
  Mov Ax,0000h+08h
  Out Dx,Ax
End;

Procedure CopyBox(PFrom,PX1,PY1,PX2,PY2,PTo,XT,YT : Word);
Var
    XC,YC : Word;
Begin
  For XC:=PX1 To (PX2-4) Do
    For YC:=PY1 To PY2 Do
      Mem[$A000:80*240*PTo+80*(YC-PY1+YT)+(XC+XT-PX1) Div 4]:=Mem[$A000:240*80*PFrom+80*YC+XC div 4];
End;

Procedure Flip(Source,Dest : Word); Assembler;
Asm
  push    ds
  Mov     Ax, 0A000h
  Mov     Es, Ax
  Mov     DS, Ax
  mov     DI, [Dest]
  mov     SI, [Source]
  mov     cx, 04800
  db $66
  rep     movsw
  pop     ds
End;

Procedure FlipDone; Assembler;
Asm
  Mov Dx,03CEh+1
  Mov Ax,0FFFFh
  Out Dx,Ax
End;

{Cel}
Procedure PutImage(Lngtx,lngty,X,Y : Word; Image : Pointer);
Var

  X1,Y1,
  Ofs1,
  Seg1    : Word;
Begin
  Ofs1:=Ofs(Image^);
  Seg1:=Seg(Image^);
  For X1:=X To X+LngtX Do
    For Y1:=Y To Y+LngtY Do
      If Mem[Seg1:Ofs1-LngtX+Y1*LngtX+X1]>0 Then
        Pixel(X1,Y1,Mem[Seg1:Ofs1-LngtX+Y1*LngtX+X1]);
End;

Procedure LoadCEL (F : String; Var LX,LY : Word; Var Image : Pointer);
Var
  Fn    : File;
  Size  : Word;
  Bt    : Byte;
Begin
  Assign (Fn, F);
  Reset (Fn, 1);
  Seek (Fn, 4);
  Blockread (Fn, Bt, 1);
  Size := (FileSize(Fn)-800) div Bt;
  Seek (Fn, 800);
  Getmem (Image,Size*Bt);
  Lx := Bt;
  Ly := Size;
  Blockread (Fn, Mem[Seg(Image^):Ofs(Image^)], Size * Bt);
  Close (Fn);
End;

{Palette}
Procedure GetPal(Col : Byte; Var R,G,B : Byte); Assembler;
  { This gets the Red, Green and Blue values of a certain color }
asm
   mov    dx,3c7h
   mov    al,col
   out    dx,al
   add    dx,2
   in     al,dx
   Les    BX,R
   mov    es:[bx],al
   in     al,dx
   Les    BX,g
   mov    es:[bx],al
   in     al,dx
   Les    BX,b
   mov    es:[bx],al
end;

Procedure GetAllPal( Var P : PalType ); Assembler;
Asm
  Mov Al, $FF
  Mov DX, $C6
  Out DX, Al
  Mov DX, $3C7
  Mov Al, 0
  Out DX, Al
  Mov DX, $3C9
  Les Di, P
  Mov CX, 768
@B2:
  In Al, DX
  Mov [ES:DI], Al
  Inc DI
  Loop @B2
End;

Procedure CyclePal( StartPal, EndPal : byte; Way : Direction );
Var
  Cp     : PalType;
  OnePal : Array [ 0..2 ] Of Byte;
  X,Y    : Word;
Begin
  GetAllPal(Cp);
  If Way = Right Then Begin
    For X:=0 To 2 Do OnePal[X]:=Cp[StartPal,X];
    WaitRetrace;
    For X:=StartPal To EndPal-1 Do Begin
      Pal(X,Cp[X+1,0],Cp[X+1,1],Cp[X+1,2]);
    End;
    Pal(EndPal,OnePal[0],OnePal[1],OnePal[2]);
  End
  Else
  Begin
    For X:=0 To 2 Do OnePal[X]:=Cp[StartPal,X];
    WaitRetrace;
    For X:=StartPal To EndPal-1 Do Begin
      Pal(X,Cp[X+1,0],Cp[X+1,1],Cp[X+1,2]);
    End;
    Pal(EndPal,OnePal[0],OnePal[1],OnePal[2]);
  End;
End;

Procedure SetAllPal(Var Palette : PalType); Assembler;
  { This dumps the pallette in our variable onto the screen, fast }
Asm
   push   ds
   lds    si, Palette
   mov    dx, 3c8h
   mov    al, 0
   out    dx, al
   inc    dx
   mov    cx, 768
   rep    outsb
   pop    ds
End;

Procedure LoadPal (F : String; Var Pall : PalType );
Var
  Fil : File;
Begin
  Assign (Fil, F);
  Reset (Fil, 1);
  If IOResult <> 0 then Exit;
  If FIlesize (Fil) < 768 then Exit;
  Blockread (Fil, Pall, 768);
  Close (Fil);
End;

Procedure Pal(Col,R,G,B : Byte); Assembler;
asm
  mov    dx,3c8h
  mov    al,[col]
  out    dx,al
  inc    dx
  mov    al,[r]
  out    dx,al
  mov    al,[g]
  out    dx,al
  mov    al,[b]
  out    dx,al
end;

Procedure Fade2Pal( Pall : PalType ; StartPal, EndPal, D : Word);
VAR
  loop2       : Byte;
  PalCount    : PalType;
  Exit        : Boolean;
BEGIN
  GetAllPal(PalCount);
  Repeat
    Delay(D);
    Exit :=True;
    WaitRetrace;
    For loop2:=StartPal to EndPal Do Begin
      If PalCount[Loop2,0]<Pall[loop2,0] then Begin Exit:=False; inc (PalCount[Loop2,0]); End;
      If PalCount[Loop2,0]>Pall[loop2,0] then Begin Exit:=False; Dec (PalCount[Loop2,0]); End;
      If PalCount[Loop2,1]<Pall[loop2,1] then Begin Exit:=False; inc (PalCount[Loop2,1]); End;
      If PalCount[Loop2,1]>Pall[loop2,1] then Begin Exit:=False; Dec (PalCount[Loop2,1]); End;
      If PalCount[Loop2,2]<Pall[loop2,2] then Begin Exit:=False; inc (PalCount[Loop2,2]); End;
      If PalCount[Loop2,2]>Pall[loop2,2] then Begin Exit:=False; Dec (PalCount[Loop2,2]); End;
      Pal (loop2,PalCount[Loop2,0],PalCount[Loop2,1],PalCount[Loop2,2]);
    End;
  Until Exit;
End;

Procedure StepFade( Pall : PalType ; StartPal, EndPal, D, Times : Word);
VAR
  Loop1,
  loop2,
  Loop3       : Byte;
  PalCount    : PalType;
  EPall       : Array[0..255,0..2] Of ShortInt;
  Exit        : Boolean;
BEGIN
  GetAllPal(PalCount);
  For Loop1:=0 To 255 Do
    For Loop2:=0 To 2 Do
      EPall[Loop1,Loop2]:=Round((Pall[Loop1,Loop2]-PalCount[Loop1,Loop2])/Times);
  For Loop1:=1 To Times Do Begin
    Delay(D);
    WaitRetrace;
    For loop2:=StartPal to EndPal Do Begin
      For Loop3:=0 To 2 Do
        If Abs(Pall[Loop2,Loop3]-PalCount[Loop2,Loop3])>EPall[loop2,Loop3] then PalCount[Loop2,Loop3]:=
	  PalCount[Loop2,Loop3]+EPall[Loop2,Loop3];
        Pal (loop2,PalCount[Loop2,0],PalCount[Loop2,1],PalCount[Loop2,2]);
    End;
  End;
  SetAllPal(Pall);
End;

Procedure FillPalType( Var Pall : PalType; R,G,B : Word);
Var
  Count : Byte;
Begin
  For Count:=0 To 255 Do
    Begin
      Pall[Count,0]:=R;
      Pall[Count,1]:=G;
      Pall[Count,2]:=B;
    End;
End;

End.