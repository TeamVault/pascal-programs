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

program Test2;

uses MCGAlib,CRT;

type
 Vertex= record
 X,Y: LongInt;
end;

const
 Num1= 6;
 Num2= 3;

var V1: array[0..Num1] of Vertex;
    V2: array[0..Num1] of Vertex;
    V3: array[0..Num2] of Vertex;
    k,a1,a2,i,j,l,m: LongInt;
    Virt: Pointer;

begin
 mSetMode320x200;
 GetMem(Virt,64000);
 mSetScreenAddr(Virt);
 l:=360; m:=180;
 a1:=360 div Num1;
 a2:=360 div Num2;
 mFillScr(0);
 for i:=0 to 149 do mSetPal(i,i div 3, i div 7, i div 7);
 for i:=150 to 199 do  mSetPal(i,i div 8, i div 4, i div 8);
 for i:=200 to 250 do  mSetPal(i,i div 10, i div 10, i div 6);
 j:=0;
 repeat
  k:=0;
  j:=j+2; if j>360 then j:=j-360;
  l:=l-2; if l<0 then l:=l+360;
  m:=m+1; if m<0 then m:=m+360;
  for i:=0 to Num1-1 do begin
   V1[i].X:=159+Trunc(sin((k-j)*pi/180)*080);
   V1[i].Y:=105+Trunc(cos((k+j)*pi/180)*080);
   V2[i].X:=159+Trunc(sin((k+l)*pi/180)*070);
   V2[i].Y:=105+Trunc(cos((k+l)*pi/180)*070);
   k:=k+a1;
  end;
  for i:=0 to Num2-1 do begin
   V3[i].X:=159+Trunc(sin((k+m)*pi/180)*090);
   V3[i].Y:=105+Trunc(cos((k+m)*pi/180)*090);
   k:=k+a2;
  end;
  mFilledPolygon(V1,Num1,149);
  mFilledPolygon(V2,Num1,249);
  mFilledPolygon(V3,Num2,199);
  mBlur(Virt);
  mDrawHLine(0,319,199,0);
  mCLIRetrace;
  mPutScr(Virt);
 until KeyPressed;
 ReadKey;
 mSetTextMode;
end.