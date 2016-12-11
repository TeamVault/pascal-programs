(***********************************************)
(*                                             *)
(* Mouse Unit Demo                             *)
(* Copyright (c) 1998 by TMT Development Corp. *)
(* Author: Vadim Bodrov, TMT Development Corp. *)
(*                                             *)
(* Targets:                                    *)
(*   MS-DOS 32-bit protected mode              *)
(*   Win32 application                         *)
(***********************************************)

uses Mouse, CRT, Graph;

const
  MousePtr: array [0..255] of Byte =
  ($0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$00,$00,$00,
   $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$00,$00,$00,$00,
   $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$00,$00,$00,$00,$00,
   $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$00,$00,$00,$00,$00,$00,
   $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$00,$00,$00,$00,$00,$00,$00,
   $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$00,$00,$00,$00,$00,$00,
   $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$00,$00,$00,$00,$00,
   $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$00,$00,$00,$00,
   $0F,$0F,$0F,$0F,$00,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$00,$00,$00,
   $0F,$0F,$0F,$00,$00,$00,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$00,$00,
   $0F,$0F,$00,$00,$00,$00,$00,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$00,
   $0F,$0F,$00,$00,$00,$00,$00,$00,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,
   $0F,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$0F,$0F,$0F,$0F,$0F,$0F,
   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$0F,$0F,$0F,$0F,$00,
   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$0F,$0F,$00,$00,
   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,$00,$00);

var
  X, Y, LX, LY, GX, GY: Word;
  DrawFlag: Boolean := false;
  Color: DWord;

procedure DrawMouse(X,Y: Word);
begin
 PutSprite(X, Y, X + 15, Y + 15, MousePtr);
end;

procedure DrawPalette;
var
  i: DWord;
  k: Real := 0;
  s: Real;
begin
 s := GetMaxColor / GetMaxX;
 for i := 0 to GetMaxX do begin
  SetColor(Trunc(k));
  Line(i, GetMaxY - 20, i, GetMaxY);
  k := k + s;
 end;
end;

begin
 SetSVGAMode(640, 480, 8, LfbOrBanked);
 if GraphResult <> grOk then begin
  Writeln('Required video mode is not supported..');
  Halt(0);
 end;
 SetFillColor(clWhite);
 DrawPalette;
 InitMouse;
 HideMouse;
 SetMouseRange(0, 0, GetMaxX, GetMaxY);
 SetWriteMode(XorPut);
 SetMousePos(GetMaxX div 2, GetMaxY div 2);
 DrawMouse(LX, LY);
 Color := clWhite;
 repeat
  X := GetMouseX;
  Y := GetMouseY;
  if (X <> LX) or (Y <> LY) then begin
   if (LeftButtonPressed) and (Y < GetMaxY - 20) then begin
    DrawMouse(LX, LY);
    if DrawFlag then begin
     SetColor(Color);
     SetWriteMode(NormalPut);
     Line(GX, GY, X, Y);
     SetWriteMode(XORPut);
    end;
    DrawMouse(X, Y);
    GX := X;
    GY := Y;
    DrawFlag := true;
   end else begin
    DrawFlag := false;
    DrawMouse(LX, LY);
    DrawMouse(X, Y);
   end;
    LX := X;
   LY := Y;
  end;
  if (LeftButtonPressed) and (Y > GetMaxY - 20) then begin
   DrawMouse(X, Y);
   Color := GetPixel(X, Y);
   DrawMouse(X, Y);
  end;
  if (RightButtonPressed) and (Y < GetMaxY - 20) then begin
   DrawMouse(X, Y);
   SetFillColor(Color);
   ExpandFill(X, Y);
   DrawMouse(X, Y);
  end;
 until KeyPressed;
 ReadKey;
 DoneMouse;
 RestoreCRTMode;
end.