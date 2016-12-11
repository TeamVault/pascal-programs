(***********************************************)
(*                                             *)
(* The Hexagon 3D Graphic Demo                 *)
(* Copyright (c) 1998 by TMT Development Corp. *)
(* Copyright by Archmage (sigjol@ice.is)       *)
(*                                             *)
(* Targets:                                    *)
(*   MS-DOS 32-bit protected mode              *)
(*   Win32 application                         *)
(***********************************************)

{ DOS version of this program has been published in                     }
{ SWAG. Here is slightly changed original version with author comments. }

{ Very primitive 3d engine                                              }
{ features: convex vectors and lambert shading..                        }
{ Under construction                                                    }
{ Coded by Archmage (sigjol@ice.is)                                     }

uses CRT, Graph;

{$r-,q-}
const
  pntsnr     = 12;
  facenr     = 20;
  polyvertnr = 3;        // nr of points in each polygon
  distance   = 4000;
  enddist    = 600;
  xcenter    = 0;
  ycenter    = 0;        // the pos of object on the screen
  zcenter    = 0;
  xrotadd    = 3;        // rotations about x,y,z axis
  yrotadd    = 4;
  zrotadd    = -2;
  ytopclip   = 0;
  ybotclip   = 200;
  norm       = 90;       // set this to -1000 to make the object transparent...

  // Conventional x,y,z format...
  Verts: array [1..(pntsnr*3)] of Longint=
    (200, 0, -120, 62, -189, -120, -160, -119, -120, -163, 115, -120,
     58, 191, -120, 0, 0, -243, -200, -3, 79, -62, -189, 80, -65, 188,
     80, 160, -115, 79, 160, 118, 78, -1, 0, 202);

  // Format: nr of faces; face1,face2,face3...; color;texmap info
  // This format is compatible with 3ded
  connect: array [1..facenr*6] of Longint=
    (3,  4, 3, 8,  6, 0, 3,  6, 7, 11,  5, 0, 3,  6, 2, 7,  7, 0 ,
     3,  2, 1, 7,  7, 0 ,3,  7, 1, 9,   5, 0, 3,  7, 9, 11, 6, 0,
     3,  11, 9, 10,  24, 0,  3,  9, 0,  10, 26 ,0,  3, 9, 1,  0, 7, 0,
     3,  5, 0, 1,  7, 0, 3,  5, 1, 2,  8, 0, 3,  6, 3, 2,  6, 0,
     3,  5, 2, 3,  6, 0, 3,  4, 0, 5,  7, 0, 3,  5, 3, 4,  6, 0,
     3,  10, 0, 4,  26, 0, 3,  8, 6, 11,  6, 0, 3,  10, 8, 11,  23, 0,
     3,  10, 4, 8,  25, 0, 3,  8, 3, 6,  6, 0);

type
  VecVerts = record
    x: Real;
    y: Real;
    z: Real;
end;

screen_coords = record
  x: DWORD;
  y: DWORD;
end;

var
  polyxyz: array[1..pntsnr] of vecverts;
  polyxyzb: array[1..pntsnr] of vecverts;
  normxyz: array[1..facenr] of vecverts;
  normxyzb: array[1..facenr] of vecverts;
  scrcoords: array[1..pntsnr] of screen_coords;
  rotxyz: array[1..pntsnr] of vecverts;
  rotnxyz: array[1..facenr] of vecverts;
  xr, yr, zr: Longint := 0;
  v, i, a, offs: Longint := 0;
  loop2: Longint := 1;
  Dist: Longint := 2000;
  VecCol: DWORD := 0;
  xadd, yadd, zadd: Real := 0;
  precsin: array[0..360] of Real;
  preccos: array[0..360] of Real;
  poly: array[0..199, 1..2] of Longint;
  Page: Boolean := FALSE;
  Mode3D: Boolean := TRUE;
  Ch: Char;

procedure FillMenu;
begin
  Rectangle(1, 1, 639, 479, 235);
  SetColor(120);
  OutTextXY(190, 400, 'Use "M" key to define view mode');
  SetColor(215);
  OutTextXY(180, 420, 'Use "+" and "-" to adjust distance');
  SetColor(220);
  OutTextXY(260, 440, 'Use "ESC" to exit');
end;

procedure ChangePage;
begin
  if Page then
  begin
    SetActivePage(0);
    SetVisualPage(1, TRUE);
    Page := FALSE;
  end else
  begin
   SetActivePage(1);
   SetVisualPage(0, TRUE);
   Page := TRUE;
  end;
  SetFillColor(clBlack);
  Bar(160, 56, 480, 352);
end;

// This routine defines the vertices of the cube
// They must be in this order for calculating normals
procedure SetuPoints;
begin
  i := 1;
  v :=1 ;
  repeat
    polyxyzb[v].x := Verts[i];
    i := i + 1;
    polyxyzb[v].y := Verts[i];
    i := i + 1;
    polyxyzb[v].z := Verts[i];
    i := i + 1;
    v := v + 1;
  until v = pntsnr + 1;
  for i := 1 to facenr * 6 do
    connect[i] := connect[i] + 1
end;

// This creates the lookup table
procedure SetUpsc;
var
  loop1: Longint;
  ax, ay, az, bx, by, bz: Real;
begin
  offs := 0;
  for loop1 := 0 to 360 do
  begin
    precsin[loop1] := sin(loop1 * pi / 180);
    preccos[loop1] := cos(loop1 * pi / 180);
  end;
  offs := 0;
  for i := 1 to facenr do
  begin
    // Here I precalculate the normals and then all
    // I have to do is rotate them for each frame
    ax := (polyxyzb[connect[3 + offs]].x) - (polyxyzb[connect[2 + offs]].x);
    ay := (polyxyzb[connect[3 + offs]].y) - (polyxyzb[connect[2 + offs]].y);
    az := (polyxyzb[connect[3 + offs]].z) - (polyxyzb[connect[2 + offs]].z);
    bx := (polyxyzb[connect[4 + offs]].x) - (polyxyzb[connect[2 + offs]].x);
    by := (polyxyzb[connect[4 + offs]].y) - (polyxyzb[connect[2 + offs]].y);
    bz := (polyxyzb[connect[4 + offs]].z) - (polyxyzb[connect[2 + offs]].z);
    normxyz[i].x := 0;
    normxyz[i].y := 0;
    normxyz[i].z := 0;
    normxyzb[i].x := 0;
    normxyzb[i].y := 0;
    normxyzb[i].z := 0;
    normxyzb[i].x := (ay * bz) - (by * az);
    normxyzb[i].y := (az * bx) - (bz * ax);
    normxyzb[i].z := (ax * by) - (bx * ay);
    offs := offs + 6;
  end;
end;

procedure RotatePoints(xrot, yrot, zrot: Longint);
var
  sinxr, cosxr, sinyr, cosyr, sinzr, coszr: Real;
begin
  // here are all rotations values updated and precalculated
  xr := xr + xrot;
  if xr > 360 then xr := 1;
  if xr < 0 then xr := 360;
  yr := yr + yrot;
  if yr > 360 then yr := 1;
  if yr < 0 then zr := 360;
  zr := zr + zrot;
  if zr > 360 then zr := 1;
  if zr < 0 then zr := 360;
  sinxr := precsin[xr];
  cosxr := preccos[xr];
  sinyr := precsin[yr];
  cosyr := preccos[yr];
  sinzr := precsin[zr];
  coszr := preccos[zr];
  for i := 1 to pntsnr do
  begin
   // this is the formula for vector rotations around all axis in 3d space }
    rotxyz[i].x := 0;
    rotxyz[i].y := 0;
    rotxyz[i].z := 0;
    polyxyz[i].x := 0;
    polyxyz[i].y := 0;
    polyxyz[i].z := 0;
    polyxyz[i].x := polyxyzb[i].x;
    polyxyz[i].y := polyxyzb[i].y;
    polyxyz[i].z := polyxyzb[i].z;
    rotxyz[i].y := polyxyz[i].y * cosxr - polyxyz[i].z * sinxr;
    rotxyz[i].z := polyxyz[i].z * cosxr + polyxyz[i].y * sinxr;
    polyxyz[i].y := rotxyz[i].y;
    polyxyz[i].z := rotxyz[i].z;
    rotxyz[i].z := polyxyz[i].z * cosyr - polyxyz[i].x * sinyr;
    rotxyz[i].x := polyxyz[i].x * cosyr + polyxyz[i].z * sinyr;
    polyxyz[i].x := rotxyz[i].x;
    rotxyz[i].x := polyxyz[i].x * coszr - polyxyz[i].y * sinzr;
    rotxyz[i].y := polyxyz[i].y * coszr + polyxyz[i].x * sinzr;
  end;
  for i := 1 to facenr do
  begin
    rotnxyz[i].x := 0;
    rotnxyz[i].y := 0;
    rotnxyz[i].z := 0;
    normxyz[i].x := normxyzb[i].x;
    normxyz[i].y := normxyzb[i].y;
    normxyz[i].z := normxyzb[i].z;
    rotnxyz[i].y := normxyz[i].y * cosxr - normxyz[i].z * sinxr;
    rotnxyz[i].z := normxyz[i].z * cosxr + normxyz[i].y * sinxr;
    normxyz[i].y := rotnxyz[i].y;
    normxyz[i].z := rotnxyz[i].z;
    rotnxyz[i].z := normxyz[i].z * cosyr - normxyz[i].x * sinyr;
    rotnxyz[i].x := normxyz[i].x * cosyr + normxyz[i].z * sinyr;
    normxyz[i].x := rotnxyz[i].x;
    rotnxyz[i].x := normxyz[i].x * coszr - normxyz[i].y * sinzr;
    rotnxyz[i].y := normxyz[i].y * coszr + normxyz[i].x * sinzr;
  end;
end;

procedure ScrProject(xc, yc, zc: Longint);
begin
  for i := 1 to pntsnr do
  begin
    scrcoords[i].x := trunc((320 * (rotxyz[i].x + xc) / (dist - (rotxyz[i].z + zc))) + 320);
    scrcoords[i].y := trunc(200 - (320 * (rotxyz[i].y + yc) / (dist - (rotxyz[i].z + zc))));
  end;
end;

procedure Draw;
begin
  offs := -6;
  a := 1 ;
  for i := 1 to facenr do
  begin
    offs := offs + 6;
    VecCol := trunc(rotnxyz[i].z / 400);
    if rotnxyz[i].z > 10000 then
    begin
      SetColor(VecCol); SetFillColor(VecCol);
      if Mode3D then
        FillTriangle(scrcoords[connect[2 + offs]].x, scrcoords[connect[2 + offs]].y,
          scrcoords[connect[3 + offs]].x, scrcoords[connect[3 + offs]].y,
          scrcoords[connect[4 + offs]].x, scrcoords[connect[4 + offs]].y)
      else
        Triangle(scrcoords[connect[2 + offs]].x, scrcoords[connect[ 2+ offs]].y,
          scrcoords[connect[3 + offs]].x, scrcoords[connect[3 + offs]].y,
          scrcoords[connect[4 + offs]].x, scrcoords[connect[4 + offs]].y);
    end;
  end;
end;

// Here is the main program
begin
  // global variables initialized
  loop2 := 1;
  SetuPoints;                                  // define vector vertices
  SetupSc;
  Dist := 2000;
  SetSVGAMode(640, 480, 8, LFBorBanked);
  if GraphResult <> 0 then
  begin
    ClrScr;
    Writeln(GraphErrorMsg(GraphResult));
    exit;
  end;
  DrawBorder := FALSE;
  ClearDevice;
  SetColor(125);
  OutTextXY(270, 230, 'Please wait...');
  SetActivePage(0);
  FillMenu;
  SetActivePage(1);
  FillMenu;
  for i := 1 to 126 do
    SetRGBPalette (i, i div 5, i div 3, (20 + i) div 3);
  repeat
    if dist < enddist then dist := enddist;
    rotatepoints(xrotadd, yrotadd, zrotadd);   // rotate around x,y,z axis
    scrproject(xcenter, ycenter, zcenter);
    Draw;
    ChangePage;
    if KeyPressed then
    begin
      ch := ReadKey;
      if UpCase(ch) = 'M' then Mode3D := not Mode3D;
      if (ch = '+') then Dist -:= 50;
      if (ch = '-') then Dist +:= 50;
       if Dist > Distance then Dist := Distance;
      if Dist < EndDist then Dist := EndDist;
    end;
  until ch = #27;
  CloseGraph;
end.