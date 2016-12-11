(***********************************************)
(*                                             *)
(* Splines (Graph Unit Demo)                   *)
(* Copyright (c) 1998 by TMT Development Corp. *)
(* Author: Vadim Bodrov, TMT Development Corp. *)
(*                                             *)
(* Targets:                                    *)
(*   MS-DOS 32-bit protected mode              *)
(*   Win32 application                         *)
(***********************************************)

uses CRT, Graph, Use32;

const MaxNodes = 6;

var i: Word;
    Points: array[0..255] of PointType;
    Page: Boolean;
    DX,DY: array [0..MaxNodes] of Integer;

procedure SwapPage;
begin
 if Page then begin
  SetVisualPage(1,true);
  SetActivePage(0);
 end else begin
  SetVisualPage(0,true);
  SetActivePage(1);
 end;
  Page:=not Page;
  ClearPage;
end;

begin
 SetSVGAMode(640,480,8,LFBorBanked);
 if GraphResult<>grOk then begin
  Writeln('Mode not supported..');
  Halt(0);
 end;
 SetLineStyle(SolidLn,0,ThickWidth);
 SetViewport(0,0,639,479,true);
 for i:=0 to MaxNodes do begin
  Points[i].X:=random(GetMaxX);
  Points[i].Y:=random(GetMaxY);
  DX[i]:=Random(4)+1;
  DY[i]:=Random(4)+1;
 end;
 SetFillColor(clLightBlue);
 repeat
  SwapPage;
  for i:=0 to MaxNodes-1 do begin
   Points[i].X:=Points[i].X+DX[i];
   if (Points[i].X>=GetMaxX) or (Points[i].X<=0) then DX[i]:=-DX[i];
   Points[i].Y:=Points[i].Y+DY[i];
   if (Points[i].Y>=GetMaxY) or (Points[i].Y<=0) then DY[i]:=-DY[i];
   SetColor(clLightCyan);
   FillCircle(Points[i].X,Points[i].Y,5);
  end;
  SetColor(clWhite);
  Spline(MaxNodes,Points);
 until KeyPressed;
 ReadKey;
 CloseGraph;
end.