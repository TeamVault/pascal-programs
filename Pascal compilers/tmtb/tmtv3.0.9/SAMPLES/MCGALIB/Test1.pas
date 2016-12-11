(***********************************************)
(*                                             *)
(* Demo program for MCGALib Unit               *)
(* Copyright (c) 1998 by TMT Development Corp. *)
(* Author: Vadim Bodrov, TMT Development Corp. *)
(*                                             *)
(* Targets:                                    *)
(*   MS-DOS 32-bit protected mode              *)
(*                                             *)
(***********************************************)

{$ifndef __DOS__}
  This program can be compiled for MS-DOS target only
{$endif}

program TEST1;

uses MCGALib,CRT;

var i,j:       Word;         // Loop variables
    Pal1,Pal2: Pointer;      // Memory for VGA Palette storage
    X,Y:       Integer:= 0;  // Coordinates of the sprite
    SX,SY:     Integer:= 1;  // X and Y increment variables
    S,F:       Pointer;      // Memory for Sprite (S) and BackGround (F)
    Scr:       Pointer;      // Virtual (shadow) screen address

procedure Animate1;
begin
 mRotatePalette(Pal2,101,62);
 mRotatePalette(Pal2,1,99);
 mPutSprite(X,Y,X+100,Y+100,F);
 inc(X,SX); inc(Y,SY);
 if (X=0) or (X=219) then SX:=-SX;
 if (Y=0) or (Y=99) then SY:=-SY;
 mGetSprite(X,Y,X+100,Y+100,F);
 mPutSprite(X,Y,X+100,Y+100,S);
end;

procedure Animate2;
begin
 mPutSprite(X,Y,X+100,Y+100,F);
 inc(X,SX); inc(Y,SY);
 if (X=-30) or (X=259) then SX:=-SX;
 if (Y=-30) or (Y=129) then SY:=-SY;
 mGetSprite(X,Y,X+100,Y+100,F);
 mPutSpriteTransp(X,Y,X+100,Y+100,0,S);
end;

procedure DrawSprite;
begin
 mFilledBox(0,0,30,30,12);
 mFilledBox(0,70,30,100,12);
 mFilledBox(70,0,100,30,12);
 mFilledBox(70,70,100,100,12);
 mDrawRectangle(20,20,80,80,9);
 mDrawRectangle(5,5,95,95,14);
 mFilledBox(30,30,70,70,3);
end;

begin
 mSetMode320x200;
 mBIOSText(4,12,'PRESS ANY KEY FOR PALETTE TEST...',15);
 ReadKey;
 GetMem(Scr,64000);
 mSetScreenAddr(Scr);
 GetMem(Pal1,768);
 mGetPalette(Pal1,0,256);
 GetMem(Pal2,768);
 GetMem(S,101*101);
 GetMem(F,101*101);
 for i:=0 to 31 do begin
  mSetPal(101+i,0,i,i*2);
  mSetPal(131+i,0,(31-i),(31-i)*2);
  mFilledBox(i*10,0,i*10+10,199,i+101);
 end;
 mGetSprite(0,0,100,100,F);
 for i:=50 downto 1 do begin
  mSetPal(i,10+i,0,i div 2);
  mSetPal(50+i,10+(50-i),0,(50-i) div 2);
  mFilledBox(50-i,50-i,50+i,50+i,i);
 end;
 mGetSprite(0,0,100,100,S);
 mGetPalette(Pal2,0,256);
 repeat
  Animate1;
  mCliRetrace;
  mPutScr(Scr);
 until KeyPressed;
 repeat
  Animate1;
  mCliRetrace;
  mPutScr(Scr);
 until not mPaletteFadeOut(Pal2,0,163,0);
 ReadKey;
 mFillScr(0);
 mPutScr(Scr);
 mBIOSText(2,12,'PRESS ANY KEY FOR TRANSPARENT BLT...',15);
 mSetPalette(Pal1,0,256);
 ReadKey;
 DrawSprite;
 mGetSprite(0,0,100,100,S);
 for i:=0 to 9 do
  for j:=0 to 31 do
   mFilledBox(j*20,i*20,j*20+19,i*20+19,((i+j) and 1)*15);
 mDrawRectangle(0,0,319,199,15);
 mGetSprite(X,Y,X+100,Y+100,F);
 repeat
  Animate2;
  mCliRetrace;
  mPutScr(Scr);
 until KeyPressed;
 Move(Pal1^,Pal2^,768);
 repeat
  Animate2;
  mCliRetrace;
  mPutScr(Scr);
 until not mPaletteFadeIn(Pal2,0,256,63);
 repeat
  Animate2;
  mCliRetrace;
  mPutScr(Scr);
 until not mPaletteFadeOut(Pal2,0,256,0);
 ReadKey;
 mSetTextMode;
 FreeMem(Scr,64000);
 FreeMem(Pal1,768);
 FreeMem(Pal2,768);
 FreeMem(S,101*101);
 FreeMem(F,101*101);
end.