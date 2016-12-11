(***********************************************)
(*                                             *)
(* MCGA/VGA 13h Mode Graphic Library           *)
(* Revision 2.0                                *)
(* Copyright (c) 1998 by TMT Development Corp. *)
(* Author: Vadim Bodrov, TMT Development Corp. *)
(*                                             *)
(* Targets:                                    *)
(*   MS-DOS 32-bit protected mode              *)
(*                                             *)
(***********************************************)

{$ifndef __DOS__}
  The MCGALib unit can be compiled for MS-DOS target only
{$endif}

unit MCGALib;

{$w-,r-,q-,i-,t-,x+,v-}

interface

procedure mSetMode320x200;
procedure mSetTextMode;
function  mGetPixAddr (X, Y: Word): Pointer;
procedure mFillScr (Color: Byte);
procedure mPutScr (Buffer: Pointer);
procedure mGetScr (Buffer: Pointer);
procedure mSetScreenAddr (Addr: Pointer);
function  mGetScreenAddr: Pointer;
procedure mPutPixel (X, Y: DWord; Color: Byte);
procedure mPutPoint (X, Y: LongInt; Color: Byte);
procedure mDrawLine (X1, Y1, X2, Y2: LongInt; Color: Byte);
function  mGetPixel (X, Y: DWord): Byte;
procedure mSetPal (Color, R, G, B: Byte);
procedure mGetPal (Color: Byte; var R, G, B: Byte);
procedure mSetPalette (Buffer: Pointer; Start: Byte; Num: Word);
procedure mGetPalette (Buffer: Pointer; Start: Byte; Num: Word);
procedure mRotatePalette (Buffer: Pointer; Start, Num: Word);
function  mPaletteFadeIn (Buffer: Pointer; Start, Num: Word; Stop: Byte): Boolean;
function  mPaletteFadeOut (Buffer: Pointer; Start, Num: Word; Stop: Byte): Boolean;
procedure mRetrace;
procedure mCliRetrace;
procedure mBIOStext (X, Y: LongInt; Text: String; Color: Byte);
procedure mFilledBox (X1, Y1, X2, Y2: LongInt; Color: Byte);
procedure mDrawRectangle (X1, Y1, X2, Y2: LongInt; Color: Byte);
procedure mPutLine (X1, X2, Y: LongInt; Buffer: Pointer);
procedure mPutLineTransp (X1, X2, Y: LongInt; Msk: Byte; Buffer: Pointer);
procedure mGetLine (X1, X2, Y: LongInt; Buffer: Pointer);
procedure mStretch (Param: Byte);
procedure mOrPixel (X: DWord; Y: DWord; Color: Byte);
procedure mXorPixel (X: DWord; Y: DWord; Color: Byte);
procedure mAndPixel (X: DWord; Y: DWord; Color: Byte);
procedure mPutSprite (X1, Y1, X2, Y2: LongInt; Buffer: Pointer);
procedure mPutSpriteTransp (X1, Y1, X2, Y2: LongInt; Msk: Byte; Buffer: Pointer);
procedure mGetSprite (X1, Y1, X2, Y2: LongInt; Buffer: Pointer);
procedure mDrawHLine (X1, X2, Y: LongInt; Color: Byte);
procedure mFilledTriangle (X0, Y0, X1, Y1, X2, Y2: LongInt; Color: Byte);
procedure mFilledPolygon (var Vert; NumVert: DWord; Color: Byte);
procedure mBlur (ScrAddr: Pointer);
procedure mDrawEllipse (X, Y, A, B: LongInt; Color: Byte);
procedure mFilledEllipse (X, Y, A, B: LongInt; Color: Byte);
procedure mCircle (X,Y: LongInt; Radius: DWord; Color: Byte);
procedure mFilledCircle (X,Y: LongInt; Radius: DWord; Color: Byte);

implementation

(****************************************************
 * Size of memory buffer for ellipse/circle drawing *
 ****************************************************)
const BufferSize = $FFFF;

(**********************************
 * Internal variables declaration *
 **********************************)
var
  AdjUp:      DWord:= -2;
  AdjDown:    DWord:= -4;
  WholeStep:  DWord:= -6;
  XAdvance:   DWord:= -8;
  ScrAddr:    Pointer;
  Buffer:     Pointer;
  PixListLen: DWord;

procedure GetBuffer;
begin
 if Buffer=nil then GetMem(Buffer,BufferSize);
end;

procedure mSetMode320x200;
 assembler;
    asm
      mov       eax,0A0000h
      add       eax,_zero
      mov       [ScrAddr],eax
      mov       eax,13h
      int       10h
      call      GetBuffer
end;

procedure FreeBuffer;
begin
 if Buffer<>nil then FreeMem(Buffer,BufferSize);
end;

procedure mSetTextMode;
 assembler;
    asm
      mov       eax,03h
      int       10h
      call      FreeBuffer
end;

function  mGetPixAddr (X, Y: Word): Pointer;
 code;
    asm
      movzx     eax,[Y]
      shl       eax,6
      movzx     edi,[X]
      add       edi,eax
      shl       eax,2
      add       eax,edi
      add       eax,[ScrAddr]
      ret
end;

procedure mFillScr (Color: Byte);
 code;
     asm
      mov       edi,[ScrAddr]
      cld
      movzx     eax,[Color]
      push      ecx
      mov       ecx,3E80h
      mov       ah,al
      push      eax
      shl       eax,16
      pop       eax
      rep       stosd
      pop       ecx
      ret
end;

procedure mPutScr (Buffer: Pointer);
 code;
    asm
      mov       edi,0A0000h
      mov       esi,[Buffer]
      push      ecx
      mov       ecx,3E80h
      cld
      rep       movsd
      pop       ecx
      ret
end;

procedure mGetScr (Buffer: Pointer);
 code;
    asm
      mov       esi,0A0000h
      mov       edi,[Buffer]
      push      ecx
      mov       ecx,3E80h
      cld
      rep       movsd
      pop       ecx
      ret
end;

procedure mSetScreenAddr (Addr: Pointer);
 code;
    asm
      mov       eax,[Addr]
      mov       [ScrAddr],eax
      ret
end;

function  mGetScreenAddr: Pointer;
 code;
    asm
      mov       eax,[ScrAddr]
      ret
end;

procedure mPutPixel (X, Y: DWord; Color: Byte);
 code;
    asm
      mov       eax,[Y]
      shl       eax,6
      mov       edi,[X]
      add       edi,eax
      shl       eax,2
      add       edi,eax
      add       edi,[ScrAddr]
      mov       al,[Color]
      mov       [edi],al
      ret
end;

procedure mPutPoint (X, Y: LongInt; Color: Byte);
 code;
    asm
      cmp       [X],0
      jl        @@Quit
      cmp       [X],319
      jg        @@Quit
      cmp       [Y],0
      jl        @@Quit
      cmp       [Y],199
      jg        @@Quit
      mov       eax,[Y]
      shl       eax,6
      mov       edi,[X]
      add       edi,eax
      shl       eax,2
      add       edi,eax
      add       edi,[ScrAddr]
      mov       al,[Color]
      mov       [edi],al
@@Quit:
      ret
end;

procedure DrawLine (X1, Y1, X2, Y2: LongInt; Color: Byte);
 assembler;
    asm
      cld
      xor       edi,edi
      mov       eax,[Y1]
      cmp       eax,[Y2]
      jle       @@TopBottom
      xchg      [Y2],eax
      mov       [Y1],eax
      mov       ebx,[X1]
      xchg      [X2],ebx
      mov       [X1],ebx
@@TopBottom:
      mov       dx,320
      mul       dx
      mov       esi,[X1]
      mov       edi,esi
      add       edi,eax
      mov       ecx,[Y2]
      sub       ecx,[Y1]
      mov       edx,[X2]
      sub       edx,esi
      jnz       @@NotVertical
      mov       al,[Color]
      add       edi,[ScrAddr]
@@VLoop:
      mov       [edi],al
      add       edi,320
      dec       ecx
      jns       @@VLoop
      jmp       @@Done
@@Horizontal:
      mov       al,[Color]
      mov       ah,al
      and       ebx,ebx
      jns       @@DirSet
      sub       edi,edx
@@DirSet:
      mov       ecx,edx
      inc       ecx
      shr       ecx,1
      add       edi,[ScrAddr]
      rep       stosw
      adc       ecx,ecx
      rep       stosb
      jmp       @@Done
@@Diagonal:
      mov       al,[Color]
      add       ebx,320
      add       edi,[ScrAddr]
@@DLoop:
      mov       [edi],al
      add       edi,ebx
      dec       ecx
      jns       @@DLoop
      jmp       @@Done
@@NotVertical:
      mov       ebx,1
      jns       @@LeftToRight
      neg       ebx
      neg       edx
@@LeftToRight:
      and       ecx,ecx
      jz        @@Horizontal
      cmp       ecx,edx
      jz        @@Diagonal
      cmp       edx,ecx
      jae       @@XMajor
      jmp       @@YMAjor
@@XMajor:
      and       ebx,ebx
      jns       @@DFSet
      std
@@DFSet:
      mov       eax,edx
      sub       edx,edx
      div       ecx
      mov       ebx,edx
      add       ebx,ebx
      mov       [AdjUp],ebx
      mov       esi,ecx
      add       esi,esi
      mov       [AdjDown],esi
      sub       edx,esi
      mov       esi,ecx
      mov       ecx,eax
      shr       ecx,1
      inc       ecx
      push      ecx
      add       edx,esi
      test      al,1
      jnz       @@XMajorDone
      sub       edx,esi
      and       ebx,ebx
      jnz       @@XMajorDone
      dec       ecx
@@XMajorDone:
      mov       [WholeStep],eax
      mov       al,[Color]
      add       edi,[ScrAddr]
      rep       stosb
      add       edi,320
      cmp       esi,1
      jna       @@XMajorDraw
      dec       edx
      shr       esi,1
      jnc       @@XMajorFullOdd
@@XMajorFullLoop:
      mov       ecx,[WholeStep]
      add       edx,ebx
      jnc       @@XMajorNoExtra
      inc       ecx
      sub       edx,[AdjDown]
@@XMajorNoExtra:
      rep       stosb
      add       edi,320
@@XMajorFullOdd:
      mov       ecx,[WholeStep]
      add       edx,ebx
      jnc       @@XMajorNoExtra2
      inc       ecx
      sub       edx,[AdjDown]
@@XMajorNoExtra2:
      rep       stosb
      add       edi,320
      dec       esi
      jnz       @@XMajorFullLoop
@@XMajorDraw:
      pop       ecx
      rep       stosb
      cld
      jmp       @@Done
@@YMajor:
      mov       [XAdvance],ebx
      mov       eax,ecx
      mov       ecx,edx
      sub       edx,edx
      div       cx
      mov       ebx,edx
      add       ebx,ebx
      mov       [AdjUp],ebx
      mov       esi,ecx
      add       esi,esi
      mov       [AdjDown],esi
      sub       edx,esi
      mov       esi,ecx
      mov       ecx,eax
      shr       ecx,1
      inc       ecx
      push      ecx
      add       edx,esi
      test      al,1
      jnz       @@YMajorDone
      sub       edx,esi
      and       ebx,ebx
      jnz       @@YMajorDone
      dec       ecx
@@YMajorDone:
      add       edi,[ScrAddr]
      mov       [WholeStep],eax
      mov       al,[Color]
      mov       ebx,[XAdvance]
      inc       ecx
@@YMajorFirstLoop:
      mov       [edi],al
      add       edi,320
      dec       ecx
      jnz       @@YMajorFirstLoop
      add       edi,ebx
      cmp       esi,1
      jna       @@YMajorDraw
      dec       edx
      shr       esi,1
      jnc       @@YMajorFullOdd
@@YMajorFullLoop:
      mov       ecx,[WholeStep]
      add       edx,[AdjUp]
      jnc       @@YMajorNoExtra
      inc       ecx
      sub       edx,[AdjDown]
@@YMajorNoExtra:
@@YMajorRunLoop:
      mov       [edi],al
      add       edi,320
      dec       ecx
      jnz       @@YMajorRunLoop
      add       edi,ebx
@@YMajorFullOdd:
      mov       ecx,[WholeStep]
      add       edx,[AdjUp]
      jnc       @@YMajorNoExtra2
      inc       ecx
      sub       edx,[AdjDown]
@@YMajorNoExtra2:
@@YMajorRunLoop2:
      mov       [edi],al
      add       edi,320
      dec       ecx
      jnz       @@YMajorRunLoop2
      add       edi,ebx
      dec       esi
      jnz       @@YMajorFullLoop
@@YMajorDraw:
      pop       ecx
@@YMajorLastLoop:
      mov       [edi],al
      add       edi,320
      dec       ecx
      jnz       @@YMajorLastLoop
@@Done:
end;

function ClipLine (var x1,y1,x2,y2: LongInt; left,top,right,bottom: LongInt): Boolean;
var outcode1,outcode2: LongInt:=0;     // Outcodes for the two endpoints
    outcodeOut: LongInt:=0;            // Outcode of endpoint outside
    x,y,dx,dy: Real;
 procedure SETOUTCODES(var outcode: LongInt; x,y: Real);
 begin
  outcode:= 0;
  if (y > bottom) then outcode:= outcode or 1;
  if (y < top) then outcode:= outcode or 2;
  if (x > right) then outcode:= outcode or 4;
  if (x < left) then outcode:= outcode or 8;
 end;
 begin
 { Set up the initial 4 bit outcodes }
  SETOUTCODES(outcode1,x1,y1);
  SETOUTCODES(outcode2,x2,y2);
  if (outcode1 and outcode2)<>0 then begin
   Result:=false;
   exit;
  end;
  if ((outcode1 or outcode2))=0 then begin
   Result:=true;
   exit;
  end;
  dx:= x2 - x1;  // Compute dx and dy once only
  dy:= y2 - y1;

  repeat
   (* Determine which endpoint is currently outside of clip rectangle *)
   (* and pick it to be clipped.                                      *)

   if (outcode2)<>0 then outcodeOut:= outcode2 else outcodeOut:= outcode1;

   (* Clip the endpoint to                    *)
   (* one of the appropriate boundaries...    *)

   if (outcodeOut and 1)<>0 then begin
    x:= x1 + dx*(bottom-1-y1)/dy;
    y:= bottom-1;
   end
   else if (outcodeOut and 2)<>0 then begin
    x:= x1 + dx*(top-y1)/dy;
    y:= top;
   end
   else if (outcodeOut and 4)<>0 then begin
    y:= y1 + dy*(right-1-x1)/dx;
    x:= right-1;
   end
   else begin
    y:= y1 + dy*(left-x1)/dx;
    x:= left;
   end;

   if (outcodeOut = outcode1) then begin
    x1:=Round(x); y1:=Round(y);
    SETOUTCODES(outcode1,x,y);
   end
   else begin
    x2:=Round(x); y2:=Round(y);
    SETOUTCODES(outcode2,x,y);
   end;

   if (outcode1 and outcode2)<>0 then begin
    Result:=false;
    exit;
   end;
   if ((outcode1 or outcode2))=0 then begin
    Result:=true;
    exit;
   end;
  until false;
end;

procedure mDrawLine (X1, Y1, X2, Y2: LongInt; Color: Byte);
begin
 if ClipLine(X1,Y1,X2,Y2,0,0,319,199) then DrawLine(X1,Y1,X2,Y2,Color);
end;

function mGetPixel (X, Y: DWord): Byte;
 code;
    asm
      mov       eax,[Y]
      shl       eax,6
      mov       edi,[X]
      add       edi,eax
      shl       eax,2
      add       edi,eax
      add       edi,[ScrAddr]
      mov       al,[edi]
      ret
end;

procedure mSetPal (Color, R, G, B: Byte);
 assembler;
    asm
      mov       al,[Color]
      mov       edx,03C8h
      out       dx,al
      inc       edx
      mov       al,[R]
      out       dx,al
      mov       al,[G]
      out       dx,al
      mov       al,[B]
      out       dx,al
end;

procedure mGetPal (Color: Byte; var R, G, B: Byte);
 assembler;
     asm
      mov       al,[Color]
      mov       dx,03C7h
      out       dx,al
      inc       dx
      inc       dx
      mov       esi,[R]
      in        al,dx
      mov       [esi],al
      mov       edi,[G]
      in        al,dx
      mov       [edi],al
      mov       edi,[B]
      in        al,dx
      mov       [edi],al
end;

procedure mSetPalette (Buffer: Pointer; Start: Byte; Num: Word);
 assembler;
    asm
      movzx     ecx,[Num]
      or        ecx,0
      jz        @@Quit
      cld
      mov       esi,[Buffer]
      movzx     eax,[Start]
@@PalLp:
      mov       edx,03C8h
      out       dx,al
      inc       eax
      inc       edx
      outsb
      outsb
      outsb
      loop      @@PalLp
@@Quit:
end;

procedure mGetPalette (Buffer: Pointer; Start: Byte; Num: Word);
 assembler;
    asm
      movzx     ecx,[Num]
      or        ecx,0
      jz        @@Quit
      cld
      mov       edi,[Buffer]
      movzx     eax,[Start]
@@PalLp:
      mov       edx,03C7h
      out       dx,al
      mov       edx,03C9h
      inc       eax
      insb
      insb
      insb
      loop      @@PalLp
@@Quit:
end;

procedure mRotatePalette (Buffer: Pointer; Start, Num: Word);
var R,G,B: Byte;
    LastCol: Word;
begin
 LastCol:=Start+Num-1;
 if (Num<2) or (LastCol>255) then exit;
 R:=Byte((Buffer+LastCol*3)^);
 G:=Byte((Buffer+LastCol*3+1)^);
 B:=Byte((Buffer+LastCol*3+2)^);
 Move((Buffer+Start*3)^,(Buffer+Start*3+3)^,(Num-1)*3);
 Byte((Buffer+Start*3)^):=R;
 Byte((Buffer+Start*3+1)^):=G;
 Byte((Buffer+Start*3+2)^):=B;
 mSetPalette(Buffer+Start*3,Start,Num);
end;

function mPaletteFadeIn (Buffer: Pointer; Start, Num: Word; Stop: Byte): Boolean;
var R,G,B:   Byte;
    Counter: Word;
    EndCntr: Word;
    C:       Boolean;
begin
 C:=false;
 Counter:=Start*3;
 EndCntr:=Start+Num*3;
 repeat
  R:=Byte((Buffer+Counter)^);
  G:=Byte((Buffer+Counter+1)^);
  B:=Byte((Buffer+Counter+2)^);
  if R<Stop then begin inc(R); C:=true; end;
  if G<Stop then begin inc(G); C:=true; end;
  if B<Stop then begin inc(B); C:=true; end;
  Byte((Buffer+Counter)^):=R;
  inc(Counter);
  Byte((Buffer+Counter)^):=G;
  inc(Counter);
  Byte((Buffer+Counter)^):=B;
  inc(Counter);
 until Counter>=EndCntr;
 mSetPalette(Buffer+Start*3,Start,Num);
 Result:=C;
end;

function mPaletteFadeOut (Buffer: Pointer; Start, Num: Word; Stop: Byte): Boolean;
var R,G,B:   Byte;
    Counter: Word;
    EndCntr: Word;
    C:       Boolean;
begin
 C:=false;
 Counter:=Start*3;
 EndCntr:=Start+Num*3;
 repeat
  R:=Byte((Buffer+Counter)^);
  G:=Byte((Buffer+Counter+1)^);
  B:=Byte((Buffer+Counter+2)^);
  if R>Stop then begin dec(R); C:=true; end;
  if G>Stop then begin dec(G); C:=true; end;
  if B>Stop then begin dec(B); C:=true; end;
  Byte((Buffer+Counter)^):=R;
  inc(Counter);
  Byte((Buffer+Counter)^):=G;
  inc(Counter);
  Byte((Buffer+Counter)^):=B;
  inc(Counter);
 until Counter>=EndCntr;
 mSetPalette(Buffer+Start*3,Start,Num);
 Result:=C;
end;

procedure mRetrace;
 code;
    asm
      push      edx
      mov       edx,03DAh
@@VSync:
      in        al,dx
      test      eax,8
      jz        @@VSync
@@NoVSync:
      in        al,dx
      test      eax,8
      jnz       @@NoVSync
      pop       edx
      ret
end;

procedure mCliRetrace;
 code;
    asm
      pushf
      push      edx
      cli
      mov       edx,03DAh
@@VSync:
      in        al,dx
      test      eax,8
      jz        @@VSync
@@NoVSync:
      in        al,dx
      test      eax,8
      jnz       @@NoVSync
      pop       edx
      popf
      ret
end;

procedure mBIOStext (X, Y: LongInt; Text: String; Color: Byte);
 assembler;
    asm
      mov       eax,[X]
      mov       dl,al
      mov       eax,[Y]
      mov       dh,al
      mov       ah,02h
      xor       bh,bh
      int       10h
      cld
      mov       bl,[Color]
      mov       esi,[Text]
      xor       cx,cx
      mov       cl,[esi]
      and       cx,cx
      jz        @@Quit
      inc       esi
      mov       ah,0Eh
@@Cont:
      lodsb
      int       10h
      loop      @@Cont
@@Quit:
end;

procedure mFilledBox (X1, Y1, X2, Y2: LongInt; Color: Byte);
var i: DWord;
begin
 for i:=Y1 to Y2 do mDrawHLine(X1,X2,i,Color);
end;

procedure mDrawRectangle (X1, Y1, X2, Y2: LongInt; Color: Byte);
begin
 mDrawLine(X1,Y1,X2,Y1,Color);
 mDrawLine(X2,Y1,X2,Y2,Color);
 mDrawLine(X2,Y2,X1,Y2,Color);
 mDrawLine(X1,Y2,X1,Y1,Color);
end;

procedure mPutLine (X1, X2, Y: LongInt; Buffer: Pointer);
 assembler;
    asm
      mov       esi,[Buffer]
      cmp       [Y],0
      jl        @@Quit
      cmp       [Y],199
      jg        @@Quit
      cmp       [X2],0
      jl        @@Quit
      cmp       [X1],319
      jg        @@Quit
      cmp       [X1],0
      jge       @@Next1
      mov       ebx,[X1]
      sub       esi,ebx
      mov       [X1],0
@@Next1:
      cmp       [X2],319
      jle       @@Next2
      mov       [X2],319
@@Next2:
      mov       eax,[Y]
      shl       eax,6
      mov       edi,[X1]
      add       edi,eax
      shl       eax,2
      add       edi,eax
      add       edi,[ScrAddr]
      mov       ecx,[X2]
      mov       ebx,[X1]
      sub       ecx,ebx
      inc       ecx
      push      ecx
      and       ecx,3
      cld
      rep       movsb
      pop       ecx
      shr       ecx,2
      rep       movsd
@@Quit:
end;

procedure mPutLineTransp (X1, X2, Y: LongInt; Msk: Byte; Buffer: Pointer);
 assembler;
    asm
      mov       esi,[Buffer]
      cmp       [Y],0
      jl        @@Quit
      cmp       [Y],199
      jg        @@Quit
      cmp       [X2],0
      jl        @@Quit
      cmp       [X1],319
      jg        @@Quit
      cmp       [X1],0
      jge       @@Next1
      mov       ebx,[X1]
      sub       esi,ebx
      mov       [X1],0
@@Next1:
      cmp       [X2],319
      jle       @@Next2
      mov       [X2],319
@@Next2:
      mov       eax,[Y]
      shl       eax,6
      mov       edi,[X1]
      add       edi,eax
      shl       eax,2
      add       edi,eax
      add       edi,[ScrAddr]
      mov       ecx,[X2]
      mov       ebx,[X1]
      sub       ecx,ebx
      inc       ecx
      mov       bl,[Msk]
      cld
@@Loop:
      lodsb
      cmp       bl,al
      jz        @@Next3
      mov       [edi],al
@@Next3:
      inc       edi
      loop      @@Loop
@@Quit:
 end;

procedure mGetLine (X1, X2, Y: LongInt; Buffer: Pointer);
 assembler;
    asm
      mov       edi,[Buffer]
      cmp       [Y],0
      jl        @@Quit
      cmp       [Y],199
      jg        @@Quit
      cmp       [X2],0
      jl        @@Quit
      cmp       [X1],319
      jg        @@Quit
      cmp       [X1],0
      jge       @@Next1
      mov       ebx,[X1]
      sub       edi,ebx
      mov       [X1],0
@@Next1:
      cmp       [X2],319
      jle       @@Next2
      mov       [X2],319
@@Next2:
      mov       eax,[Y]
      shl       eax,6
      mov       esi,[X1]
      add       esi,eax
      shl       eax,2
      add       esi,eax
      add       esi,[ScrAddr]
      mov       ecx,[X2]
      mov       ebx,[X1]
      sub       ecx,ebx
      inc       ecx
      push      ecx
      and       ecx,3
      cld
      rep       movsb
      pop       ecx
      shr       ecx,2
      rep       movsd
@@Quit:
 end;

procedure mStretch (Param: Byte);
 assembler;
    asm
      mov       bl,[Param]
      mov       al,09h
      mov       dx,3D4h
      out       dx,al
      mov       dx,3D5h
      in        al,dx
      and       al,0E0h
      add       al,bl
      out       dx,al
end;

procedure mOrPixel (X: DWord; Y: DWord; Color: Byte);
var Addr: Pointer;
begin
 addr:=mGetPixAddr (X,Y);
 byte(addr^):=byte(addr^) or Color;
end;

procedure mXorPixel (X: DWord; Y: DWord; Color: Byte);
var Addr: Pointer;
begin
 addr:=mGetPixAddr(X,Y);
 byte(addr^):=byte(addr^) xor Color;
end;

procedure mAndPixel (X: DWord; Y: DWord; Color: Byte);
var Addr: Pointer;
begin
 addr:=mGetPixAddr(X,Y);
 byte(addr^):=byte(addr^) and Color;
end;

procedure mPutSprite (X1, Y1, X2, Y2: LongInt; Buffer: Pointer);
var i: LongInt;
begin
 for i:=Y1 to Y2 do begin
  mPutLine(X1,X2,i,Buffer);
  inc(Buffer,X2-X1+1);
 end;
end;

procedure mPutSpriteTransp (X1, Y1, X2, Y2: LongInt; Msk: Byte; Buffer: Pointer);
var i: LongInt;
begin
 for i:=Y1 to Y2 do begin
  mPutLineTransp(X1,X2,i,Msk,Buffer);
  inc(Buffer,X2-X1+1);
 end;
end;

procedure mGetSprite(X1, Y1, X2, Y2: LongInt; Buffer: Pointer);
var i: LongInt;
begin
 for i:=Y1 to Y2 do begin
  mGetLine(X1,X2,i,Buffer);
  inc(Buffer,X2-X1+1);
 end;
end;

procedure mDrawHLine (X1, X2, Y: LongInt; Color: Byte);
 assembler;
      asm
        mov     ecx,[X2]
        mov     ebx,[X1]
        mov     edx,[Y]
        cmp     edx,0
        jl      @Quit
        cmp     edx,199
        jg      @Quit
        cmp     ecx,0
        jl      @Quit
        cmp     ebx,319
        jg      @Quit
        cmp     ebx,0
        jge     @Next1
        mov     ebx,0
@Next1: cmp     ecx,319
        jle     @Next2
        mov     ecx,319
@Next2: push    ecx
        shl     edx,6
        mov     edi,ebx
        add     edi,edx
        shl     edx,2
        add     edi,edx
        cld
        pop     ecx
        mov     al,byte ptr [Color]
        mov     ah,al
        push    ax
        shl     eax,16
        pop     ax
        add     edi,[ScrAddr]
        sub     ecx,ebx
        inc     ecx
        push    ecx
        and     ecx,3
        rep     stosb
        pop     ecx
        shr     ecx,2
        rep     stosd
@Quit:
 end;

procedure mFilledTriangle(X0,Y0,X1,Y1,X2,Y2: LongInt; Color: Byte);
 assembler;
  var DX01,DY01,DX02,DY02,DX12,DY12,DP01,DP02,DP12,XA01,XA02,XA12: DWord;
      asm
        mov     eax,[X0]
        mov     ebx,[Y0]
        mov     ecx,[X1]
        mov     edx,[Y1]
        cmp     ebx,edx
        jl      @Y0lY1
        je      @Y0eY1
        xchg    eax,ecx
        xchg    ebx,edx
@Y0lY1: cmp     edx,[Y2]
        jg      @Skip1
        jmp     @sorted
@Skip1: xchg    ecx,[X2]
        xchg    edx,[Y2]
        cmp     ebx,edx
        jge     @Skip2
        jmp     @sorted
@Skip2: je      @bot
        xchg    eax,ecx
        xchg    ebx,edx
        jmp     @sorted
@Y0eY1: cmp     ebx,[Y2]
        jl      @bot
        jg      @Next
        jmp     @Quit
@Next:  xchg    eax,[X2]
        xchg    ebx,[Y2]
        jmp     @sorted
@bot:   cmp     eax,ecx
        jl      @botsorted
        jg      @bota
        jmp     @Quit
@bota:  xchg    eax,ecx
@botsorted:
@boty0ok:
        mov     esi,[Y2]
@boty2ok:
        mov     [X0],eax
        mov     [Y0],ebx
        mov     [X1],ecx
        mov     [Y1],edx
        mov     ebx,[Y2]
        sub     ebx,[Y0]
        mov     [DY02],ebx
        mov     eax,[X2]
        sub     eax,[X0]
        mov     [DX02],eax
        mov     ecx,eax
        cdq
        idiv    ebx
        cmp     ecx,0
        jge     @bot02
        dec     eax
@bot02: mov     [XA02],eax
        imul    ebx
        sub     ecx,eax
        mov     [DP02],ecx
        mov     ebx,[Y2]
        sub     ebx,[Y1]
        mov     [DY12],ebx
        mov     eax,[X2]
        sub     eax,[X1]
        mov     [DX12],eax
        mov     ecx,eax
        cdq
        idiv    ebx
        cmp     ecx,0
        jge     @bot12
        dec     eax
@bot12: mov     [XA12],eax
        imul    ebx
        sub     ecx,eax
        mov     [DP12],ecx
        xor     eax,eax
        xor     ebx,ebx
        mov     ecx,[Y0]
        mov     esi,[X0]
        mov     edi,[X1]
        dec     edi
@botloop:
        inc     ecx
        add     eax, [DP02]
        jle     @botshortl
        sub     eax, [DY02]
        inc     esi
@botshortl:
        add     esi,[XA02]
        add     ebx,[DP12]
        jle     @botshortr
        sub     ebx,[DY12]
        inc     edi
@botshortr:
        add     edi,[XA12]
        push    edi
        push    esi
        cmp     ecx,[Y2]
        jl      @botloop
        jmp     @lineloop
@sorted:
@y0ok:  mov     esi,[Y2]
@y2ok:  mov     [X0],eax
        mov     [Y0],ebx
        mov     [X1],ecx
        mov     [Y1],edx
        mov     ebx,edx
        sub     ebx,[Y0]
        mov     [DY01],ebx
        mov     eax,[X1]
        sub     eax,[X0]
        mov     [DX01],eax
        mov     ecx,eax
        cdq
        idiv    ebx
        cmp     ecx,0
        jge     @psl01
        dec     eax
@psl01: mov     [XA01],eax
        imul    ebx
        sub     ecx,eax
        mov     [DP01],ecx
        mov     ebx,[Y2]
        sub     ebx,[Y0]
        mov     [DY02],ebx
        mov     eax,[X2]
        sub     eax,[X0]
        mov     [DX02],eax
        mov     ecx,eax
        cdq
        idiv    ebx
        cmp     ecx,0
        jge     @psl02
        dec     eax
@psl02: mov     [XA02],eax
        imul    ebx
        sub     ecx,eax
        mov     [DP02],ecx
        mov     ebx,[Y2]
        sub     ebx,[Y1]
        jle     @constcomputed
        mov     [DY12],ebx
        mov     eax,[X2]
        sub     eax,[X1]
        mov     [DX12],eax
        mov     ecx,eax
        cdq
        idiv    ebx
        cmp     ecx,0
        jge     @psl12
        dec     eax
@psl12: mov     [XA12],eax
        imul    ebx
        sub     ecx,eax
        mov     [DP12],ecx
@ConstComputed:
        mov     eax,[DX01]
        imul    [DY02]
        mov     ebx,eax
        mov     eax,[DX02]
        imul    [DY01]
        cmp     ebx,eax
        jg      @pt1rt
        jl      @pt1lt
        jmp     @Quit
@pt1lt: xor     eax,eax
        xor     ebx,ebx
        mov     ecx,[Y0]
        mov     esi,[X0]
        mov     edi,esi
        dec     esi
@ltloop:
        inc     ecx
        add     eax,[DP02]
        jle     @ltshortl
        sub     eax,[DY02]
        inc     esi
@ltshortl:
        add     esi,[XA02]
        add     ebx,[DP01]
        jle     @ltshortr
        sub     ebx,[DY01]
        inc     edi
@ltshortr:
        add     edi,[XA01]
        push    esi
        push    edi
        cmp     ecx,[Y1]
        jl      @ltloop
        jmp     @lbstart
@lbloop:
        inc     ecx
        add     eax,[DP02]
        jle     @lbshortl
        sub     eax,[DY02]
        inc     esi
@lbshortl:
        add     esi,[XA02]
        add     ebx,[DP12]
        jle     @lbshortr
        sub     ebx,[DY12]
        inc     edi
@lbshortr:
        add     edi,[XA12]
        push    esi
        push    edi
@lbstart:
        cmp     ecx,[Y2]
        jl      @lbloop
        jmp     @lineloop
@pt1rt: xor     eax,eax
        xor     ebx,ebx
        mov     ecx,[Y0]
        mov     esi,[X0]
        mov     edi,esi
        dec     edi
@rtloop:
        inc     ecx
        add     eax,[DP02]
        jle     @rtshortl
        sub     eax,[DY02]
        inc     esi
@rtshortl:
        add     esi,[XA02]
        add     ebx,[DP01]
        jle     @rtshortr
        sub     ebx, [DY01]
        inc     edi
@rtshortr:
        add     edi,[XA01]
        push    edi
        push    esi
        cmp     ecx,[Y1]
        jl      @rtloop
        jmp     @rbstart
@rbloop:
        inc     ecx
        add     eax,[DP02]
        jle     @rbshortl
        sub     eax,[DY02]
        inc     esi
@rbshortl:
        add     esi,[XA02]
        add     ebx,[DP12]
        jle     @rbshorts
        sub     ebx,[DY12]
        inc     edi
@rbshorts:
        add     edi,[XA12]
        push    edi
        push    esi
@rbstart:
        cmp     ecx,[Y2]
        jl      @rbloop
@lineloop:
        pop     eax
        pop     edx
        cmp     eax,edx
        jg      @drawnext
        push    eax
        push    edx
        push    dword ptr [Y2]
        mov     al,[Color]
        push    eax
        call    mDrawHLine
@drawnext:
        dec     [Y2]
        dec     [DY02]
        jnz     @lineloop
@Quit:
end;

(*****************************************************
 * Only convex polygones will be displayed correctly *
 *****************************************************)
procedure mFilledPolygon (var Vert; NumVert: DWord; Color: Byte);
 assembler;
  var X, Y, Count: DWord;
      asm
        mov     eax,[NumVert]
        cmp     eax,3
        jl      @@Quit
@@Pass: sub     eax,3
        mov     [Count],eax
        mov     edi,[Vert]
        mov     eax,[edi]
        mov     [X],eax
        mov     eax,[edi+4]
        mov     [Y],eax
@@Next: add     edi,8
        push    edi
        push    [X]
        push    [Y]
        push    dword ptr [edi+8]
        push    dword ptr [edi+12]
        push    dword ptr [edi]
        push    dword ptr [edi+4]
        movzx   eax,[Color]
        push    eax
        call    mFilledTriangle
        pop     edi
        dec     [Count]
        jns     @@Next
@@Quit:
 end;

(**************************************************************
 * Size of virtual screen must be 320 * 201 + 1 = 64321 bytes *
 **************************************************************)
procedure mBlur (ScrAddr: Pointer);
 assembler;
      asm
        mov     edi,[ScrAddr]
        inc     edi
        mov     ecx,0F9FFh
        xor     ebx,ebx
@lp1:   movzx   eax,byte ptr [edi]
        mov     bl,byte ptr [edi-1]
        add     eax,ebx
        mov     bl,byte ptr [edi+1]
        add     eax,ebx
        mov     bl,byte ptr [edi+320]
        add     eax,ebx
        shr     eax,2
        jz      @lp2
        dec     eax
@lp2:   mov     [edi],al
        inc     edi
        loop    @lp1
end;

procedure GenerateEOctant (MinorAjast,Threshold,MajorSquared,MinorSquared:
                            LongInt);
 code;
      asm
        mov     [PixListLen],0
        mov     eax,[MajorSquared]
        shl     eax,1
        mov     edx,eax
        mov     eax,[MinorSquared]
        shl     eax,1
        mov     esi,eax
        mov     edi,[Buffer]
        xor     ecx,ecx
        mov     ebx,[Threshold]
@@GenLoop:
        add     ebx,ecx
        mov     byte ptr [edi],0
        add     ebx,[MinorSquared]
        js      @@MoveMajor
        mov     eax,edx
        sub     [MinorAjast],eax
        sub     ebx,[MinorAjast]
        mov     byte ptr [edi],1
@@MoveMajor:
        inc     edi
        inc     [PixListLen]
        mov     eax,BufferSize
        cmp     eax,[PixListLen]
        jle     @@Quit
@@Cont: add     ecx,esi
        cmp     ecx,[MinorAjast]
        jb      @@GenLoop
@@Quit: ret
 end;

function CalcSquared(A,B: LongInt; var Aq,Bq,ABq,BAq: DWord): Boolean;
 assembler;
      asm
        mov     ebx,2
        mov     eax,[A]
        mul     eax
        jc      @@Error
        mov     edi,[Aq]
        mov     [edi],eax
        mul     dword ptr [B]
        jc      @@Error
        mul     ebx
        jc      @@Error
        mov     edi,[ABq]
        mov     [edi],eax
        mov     eax,[B]
        mul     eax
        jc      @@Error
        mov     edi,[Bq]
        mov     [edi],eax
        mul     dword ptr [A]
        jc      @@Error
        mul     ebx
        jc      @@Error
        mov     edi,[BAq]
        mov     [edi],eax
        mov     eax,1
        jmp     @@Quit
@@Error:xor     eax,eax
@@Quit:
end;

procedure mDrawEllipse (X, Y, A, B: LongInt; Color: Byte);
var ASquared,BSquared,ABSquared,BASquared: DWord;
    TempPtr: Pointer;
procedure DrawVOctant(X,Y: LongInt; DrawLen: DWord; YDir,
                      HMoveDir: LongInt; Buffer: Pointer);
var CX,CY,I: LongInt;
    DrawList: Pointer;
begin
 DrawList:=Buffer;
 CX:=X; CY:=Y;
 for I:=1 to DrawLen do begin
  mPutPoint(CX,CY,Color);
  if Byte(DrawList^)=1 then Inc(CX,HMoveDir);
  Inc(CY,YDir);
  Inc(DrawList);
 end;
end;
procedure DrawHOctant (X,Y: LongInt; DrawLen: DWord; YDir,
                      HMoveDir: LongInt; Buffer: Pointer);
var CX,CY,I: LongInt;
    DrawList: Pointer;
begin
 DrawList:=Buffer;
 CX:=X; CY:=Y;
 for I:=1 to DrawLen do begin
  mPutPoint(CX,CY,Color);
  if Byte(DrawList^)=1 then Inc(CY,YDir);
  Inc(CX,HMoveDir);
  Inc(DrawList);
 end;
end;
begin
 if (A=0) or (B=0) then exit;
 if not CalcSquared(A,B,ASquared,BSquared,ABSquared,BASquared) then exit;
 TempPtr:=Buffer;
 Inc(TempPtr);
 GenerateEOctant(ABSquared,ASquared div 4 - ASquared*B,ASquared,BSquared);
 DrawHOctant(X,Y-B,PixListLen,1,-1,Buffer);
 DrawHOctant(X+1,Y-B+Byte(Buffer^),PixListLen-1,1,1,TempPtr);
 DrawHOctant(X,Y+B,PixListLen,-1,-1,Buffer);
 DrawHOctant(X+1,Y+B-Byte(Buffer^),PixListLen-1,-1,1,TempPtr);
 GenerateEOctant(BASquared,BSquared div 4 - BSquared*A,BSquared,ASquared);
 DrawVOctant(X-A,Y,PixListLen,-1,1,Buffer);
 DrawVOctant(X-A+Byte(Buffer^),Y+1,PixListLen-1,1,1,TempPtr);
 DrawVOctant(X+A,Y,PixListLen,-1,-1,Buffer);
 DrawVOctant(X+A-Byte(Buffer^),Y+1,PixListLen-1,1,-1,TempPtr);
end;

procedure mFilledEllipse (X, Y, A, B: LongInt; Color: Byte);
var ASquared,BSquared,ABSquared,BASquared: DWord;
    TempPtr: Pointer;
procedure FilledVOctant(X,Y: LongInt; DrawLen: DWord; YDir,
                      HMoveDir: LongInt; Buffer: Pointer);
var CX,CL,CY,I: LongInt; DrawList: Pointer;
begin
 DrawList:=Buffer;
 CX:=X; CY:=Y; CL:=CX+A shl 1;
 for I:=1 to DrawLen do begin
  mDrawHLine(CX,CL,CY,Color);
  if Byte(DrawList^)=1 then begin Inc(CX,HMoveDir); dec(CL,1); end;
  Inc(CY,YDir);
  Inc(DrawList);
 end;
end;
procedure FilledHOctant (X,Y: LongInt; DrawLen: DWord; YDir,
                      HMoveDir: LongInt; Buffer: Pointer);
var CX,CY,CL,I: LongInt;
    DrawList: Pointer;
begin
 DrawList:=Buffer;
 CX:=X; CY:=Y; CL:=CX;
 mDrawHLine(CX,CL,CY,Color);
 for I:=1 to DrawLen do begin
  if Byte(DrawList^)=1 then begin
   inc(CY,YDir); mDrawHLine(CX,CL,CY,Color);
  end;
  Inc(CX,HMoveDir);
  Inc(CL,1);
  Inc(DrawList);
 end;
end;
begin
 if (A=0) or (B=0) then exit;
 if not CalcSquared(A,B,ASquared,BSquared,ABSquared,BASquared) then exit;
 TempPtr:=Buffer;
 Inc(TempPtr);
 GenerateEOctant(ABSquared,ASquared div 4 - ASquared*B,ASquared,BSquared);
 FilledHOctant(X,Y-B,PixListLen,1,-1,Buffer);
 FilledHOctant(X,Y+B,PixListLen,-1,-1,Buffer);
 GenerateEOctant(BASquared,BSquared div 4 - BSquared*A,BSquared,ASquared);
 FilledVOctant(X-A,Y,PixListLen,-1,1,Buffer);
 FilledVOctant(X-A+Byte(Buffer^),Y+1,PixListLen-1,1,1,TempPtr);
end;

procedure mCircle (X,Y: LongInt; Radius: DWord; Color: Byte);
begin
 mDrawEllipse(X,Y,Radius,Round(Radius*0.82),Color);
end;

procedure mFilledCircle (X,Y: LongInt; Radius: DWord; Color: Byte);
begin
 mFilledEllipse(X,Y,Radius,Round(Radius*0.82),Color);
end;

begin
 Buffer:=nil;
end.