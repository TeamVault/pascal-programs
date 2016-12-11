(***********************************************)
(*                                             *)
(* Graph Unit Demo                             *)
(* Copyright (c) 1998 by TMT Development Corp. *)
(* Author: Vadim Bodrov, TMT Development Corp. *)
(* Based on original code by Ryan Jones        *)
(*                                             *)
(* Targets:                                    *)
(*   MS-DOS 32-bit protected mode              *)
(*   Win32 application                         *)
(***********************************************)

uses Crt, Graph;

const
  ZInc   = 25;
  ZOfs   = 256;
  ZScale = 400;
  Sc     = 0.7;

type
  ABType = record
    LSide, RSide: Longint;
  end;

  Triangle = record
    X1, Y1, Z1,
    X2, Y2, Z2,
    X3, Y3, Z3: Extended;
    Color: DWORD;
  end;

var
  Tris: array [0..100] of Triangle;
  Trin, l, i, hn: DWORD;
  Ch: Char;
  Page: Boolean := false;
  Color: DWORD;

procedure ChangePage;
begin
  if Page then begin
    SetActivePage(0);
    SetVisualPage(1,true);
    Page:=false;
  end else begin
    SetActivePage(1);
    SetVisualPage(0,true);
    Page:=true;
  end;
  ClearPage;
  OutTextXY(500, 468, 'Fractal-3D demo');
end;

procedure AddTris(i: DWORD);
var
  OX1, OY1, OZ1,
  OX2, OY2, OZ2,
  OX3, OY3, OZ3: Extended;
  OC: DWORD;
begin
  with Tris[i] do begin
    OX1 := X1; OY1 := Y1; OZ1 := Z1;
    OX2 := X2; OY2 := Y2; OZ2 := Z2;
    OX3 := X3; OY3 := Y3; OZ3 := Z3;
    OC  := Color + 24;
  end;
  with Tris[Trin] do begin
    X1 := OX1;
    Y1 := OY1;
    Z1 := OZ1 + ZInc;
    X2 := OX1 * 2 / 3 + OX2 / 3;
    Y2 := OY1 * 2 / 3 + OY2 / 3;
    Z2 := OZ2 + ZInc;
    X3 := OX1 * 2 / 3 + OX3 / 3;
    Y3 := OY1 * 2 / 3 + OY3 / 3;
    Z3 := OZ3 + ZInc;
    Color := OC;
  end;
  with Tris[Trin+1] do begin
    X1 := OX2 * 2 / 3 + OX1 / 3;
    Y1 := OY2 * 2 / 3 + OY1 / 3;
    Z1 := OZ1 + ZInc;
    X2 := OX2;
    Y2 := OY2;
    Z2 := OZ2 + ZInc;
    X3 := OX2 * 2 / 3 + OX3 / 3;
    Y3 := OY2 * 2 / 3 + OY3 / 3;
    Z3 := OZ3 + ZInc;
    Color := OC;
  end;
  with Tris[Trin+2] do begin
    X1 := OX3 * 2 / 3 + OX1 / 3;
    Y1 := OY3 * 2 / 3 + OY1 / 3;
    Z1 := OZ1 + ZInc;
    X2 := OX3 * 2 / 3 + OX2 / 3;
    Y2 := OY3 * 2 / 3 + OY2 / 3;
    Z2 := OZ2 + ZInc;
    X3 := OX3;
    Y3 := OY3;
    Z3 := OZ3 + ZInc;
    Color := OC;
  end;
  inc(Trin, 3);
end;

procedure DrawTris;
var SX1, SY1, SX2, SY2, SX3, SY3, i: DWORD;
begin
  i := 0;
  repeat
    with Tris[i] do begin
      SX1 := Round((ZScale * X1) / (Z1 - ZOfs));
      SY1 := Round((ZScale * Y1) / (Z1 - ZOfs));
      SX2 := Round((ZScale * X2) / (Z2 - ZOfs));
      SY2 := Round((ZScale * Y2) / (Z2 - ZOfs));
      SX3 := Round((ZScale * X3) / (Z3 - ZOfs));
      SY3 := Round((ZScale * Y3) / (Z3 - ZOfs));
      SetFillColor(Color);
      FillTriangle(320 + SX1, 200 + SY1, 320 + SX2, 200 + SY2, 320 + SX3, 200 + SY3);
    end;
    inc(i);
  until i = Trin;
  ChangePage;
end;

procedure Rotate(var X,Y: Extended; Ang: Extended);
var XX, YY: Extended;
begin
  XX := X * Cos(Ang / 180 * pi) + Y * Sin(Ang / 180 * pi);
  YY := Y * Cos(Ang / 180 * pi) - X * Sin(Ang / 180 * pi);
  X := XX;
  Y := YY;
end;

procedure RotateTris(Ang: Extended);
var i: DWORD;
begin
  i := 0;
  repeat
    with Tris[i] do begin
      Rotate(X1, Z1, Ang);
      Rotate(X2, Z2, Ang);
      Rotate(X3, Z3, Ang);
    end;
    inc(i);
  until i = Trin;
end;

procedure RotateTrisb(Ang: Extended);
var i: DWORD;
begin
  i := 0;
  repeat
    with Tris[i] do begin
      Rotate(X1, Y1, Ang);
      Rotate(X2, Y2, Ang);
      Rotate(X3, Y3, Ang);
    end;
    inc(i);
  until i = Trin;
end;

procedure RotateTrisc(Ang: Extended);
var i: DWORD;
begin
  i := 0;
  repeat
    with Tris[i] do begin
      Rotate(Y1, Z1, Ang);
      Rotate(Y2, Z2, Ang);
      Rotate(Y3, Z3, Ang);
    end;
    inc(i);
  until i = Trin;
end;

procedure ExpandTris;
const
  Scd = 0.95;
var
  i: DWORD;
begin
  i := 0;
  repeat
    with Tris[i] do begin
      X1 := X1 * Scd;
      Y1 := Y1 * Scd;
      X2 := X2 * Scd;
      Y2 := Y2 * Scd;
      X3 := X3 * Scd;
      Y3 := Y3 * Scd;
    end;
  inc(i);
  until i = Trin;
end;

begin
  SetSVGAMode(640, 480, 8, LfbOrBanked);
  OutTextXY(270, 230, 'Please wait...');
  for i := 1 to 254 do
    SetRGBPalette(i, i div 3 + 25, 2, i div 3 + 30);
  SetRGBPalette(255, 63, 63, 63);
  SetColor(255);
  DrawBorder := false;
  with Tris[0] do begin
    X1 :=  0;      Y1 :=  86;      Z1 := 0;
    X2 :=  100;    Y2 := -86;      Z2 := 0;
    X3 := -100;    Y3 := -86;      Z3 := 0;
    X1 := X1 * Sc; Y1 := Y1 * Sc;  Z1 := Z1 * Sc;
    X2 := X2 * Sc; Y2 := Y2 * Sc;  Z2 := Z2 * Sc;
    X3 := X3 * Sc; Y3 := Y3 * Sc;  Z3 := Z3 * Sc;
    Color := 24;
  end;
  Trin := 1;
  l := 3;
  repeat
    i := 0;
    hn := Trin;
    repeat
      AddTris(i);
      inc(i);
    until i = hn;
    dec(l);
  until l = 0;
  Tris[0].Color := 24;

  repeat // main loop
    i := 0;
    repeat
      DrawTris;
      RotateTris(4);
      inc(i);
    until (KeyPressed) or (i = 45);
    i := 0;
    repeat
      DrawTris;
      RotateTrisb(4);
      inc(i);
    until (KeyPressed) or (i = 45);
    i := 0;
    repeat
      DrawTris;
      RotateTrisc(4);
      inc(i);
    until (KeyPressed) or (i = 45);
  until KeyPressed;
  repeat
    Ch := ReadKey
  until not KeyPressed;
  i := 100;
  repeat // outro
    DrawTris;
    ExpandTris;
    RotateTris(4);
    RotateTrisb(4);
    RotateTrisc(4);
    dec(i);
  until (i = 0) or (KeyPressed);
  if KeyPressed then
    repeat
      Ch:=ReadKey
    until not KeyPressed;
  RestoreCrtMode;
end.