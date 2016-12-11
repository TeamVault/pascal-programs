{************************************************}
{                                                }
{   Chess - Shared DLL Example                   }
{   CHESS.DLL Opening library managment.         }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit LOpenLib;

{$R-,Q-,S-,W-}

{$IFDEF WINDOWS}
{$R LOPENLIB.RES}
{$ENDIF}

interface

procedure CalcLibNo;
procedure FindOpeningMove;

implementation

uses

{$IFDEF WINDOWS}
  WinApi,
{$ENDIF}
  GameRec, LBoard, LMoveGen, LMoves;

const UnPlayMark = $3F;

type
  POpeningLib = ^TOpeningLib;
  TOpeningLib = array [0..31999] of byte;

var
  Openings : POpeningLib;

procedure PreviousLibNo(var Lib: Integer);
{ Sets LibNo to the previous Move in the block }
var   n : integer;
begin
  n := 0;
  repeat
    Dec(Lib);
    if Openings^[Lib] >= 128 then
      Inc(n);
    if (Openings^[Lib] and 64) <> 0 then
      Dec(n);
  until n = 0;
end; { PreviousLibNo }

procedure FirstLibNo(var Lib: Integer);
{ Sets LibNo to the First Move in the block }
begin { FirstLibNo }
  while (Openings^[Lib - 1] and 64) = 0 do
    PreviousLibNo(Lib);
end; { FirstLibNo }


procedure NextLibNo(var Lib: Integer; Skip : Boolean);
{ Sets LibNo to the Next Move in the block.
  Unplayable moves are skipped if skip is set }
var
  n : integer;
begin
  if Openings^[Lib] >= 128 then
    FirstLibNo(Lib)
  else
  begin
    n := 0;
    repeat
      if (Openings^[Lib] and 64) <> 0 then
        Inc(n);
      if Openings^[Lib] >= 128 then
        Dec(n);
      Inc(Lib);
    until n = 0;
    if Skip and (Openings^[Lib] = UnPlayMark) then
      FirstLibNo(Lib);
  end;
end; { NextLibNo }


procedure CalcLibNo;
{ Sets LibNo to the block corresponding to the position }

var
  LibDepth : DepthType;
  Found    : boolean;

   procedure FindNode;
   { Find the node corresponding to the correct block }
   begin
     with CC do
     begin
       Inc(LibNo);
       if Depth > LibDepth then
       begin
          Found := true;
          Exit;
       end;
       OpCount := -1;
       InitMovGen;
       repeat
          OpCount := OpCount + 1;
          MovGen;
       until (NextMove.MovPiece = Empty) or EqMove(NextMove,MovTab[Depth]);
       if NextMove.MovPiece <> Empty then
       begin
          while ((Openings^[LibNo] and 63) <> OpCount) and
                 (Openings^[LibNo] < 128) do
             NextLibNo(LibNo, False);
          if (Openings^[LibNo] and 127) = 64 + OpCount then
          begin
             MakeMove(MovTab[Depth]);
             FindNode;
             TakeBackMove(MovTab[Depth - 1]);
          end;
       end;
     end; { with }
   end; { FindNode }

begin { CalcLibNo }
  with CC do
  begin
    LibNo := 0;
    if Openings = nil then
    begin
      UseLib := 200;
      Exit;
    end;
    if MoveNo < UseLib then
    begin
       LibDepth := Depth;
       while MovTab[Depth].MovPiece <> Empty do
          TakeBackMove(MovTab[Depth]);
       Found := False;
       if MovTab[Depth].Content = King then
       begin
         Inc(Depth);
         FindNode;
         Dec(Depth);
       end;
       while Depth < LibDepth do
         MakeMove(MovTab[Depth + 1]);
       if Found then
          UseLib := 200
       else
       begin
          UseLib := MoveNo;
          LibNo := 0;
       end;
    end;
  end;
end; { CalcLibNo }


procedure FindOpeningMove;
{ Finds an opening move from the library }
const Weight : array[0..6] of byte = (7,10,12,13,14,15,16);
var
  Cnt, r, p, CountP : byte;
begin
  r := Random(17);      { Calculate weighted Random Number in 0..16 }
  p := 0;
  while r >= Weight[p] do
   Inc(p);
  with CC do
  begin
    for CountP := 1 to p do                 { Find corresponding node }
      NextLibNo(LibNo, True);
    OpCount := Openings^[LibNo] and 63;      { Generate the Move       }
    InitMovGen;
    for Cnt := 0 to OpCount do
      MovGen;
    MainLine[0] := NextMove;             { Store the Move in MainLine }
    MainLine[1] := ZeroMove;
    MainEvalu := 0;
    MaxDepth := 0;
    LegalMoves := 0;
    Nodes := 0;
  end;
end; { FindOpeningMove }

{$IFDEF WINDOWS}
var
  SaveExit : Pointer;

procedure ReleaseOpeningLib; far;
begin
  ExitProc := SaveExit;
  if Openings <> nil then
  begin
    UnlockResource(GlobalHandle(Seg(Openings^)));
    FreeResource(GlobalHandle(Seg(Openings^)));
  end;
end;

{ Read the opening library from the DLL resources here }
procedure LoadOpening;
begin
  SaveExit := ExitProc;
  ExitProc := @ReleaseOpeningLib;
  Openings := LockResource(LoadResource(hInstance,
    FindResource(hInstance, 'OPENINGMOVES', 'OPENINGLIB')));
end;

{$ELSE}

{ Read the opening library from OPENING.LIB }
procedure LoadOpening;
const
  LibFileName = 'OPENING.LIB';    { note: can edit and include a path }
var
  LibFile : file of TOpeningLib;
begin
  Assign(LibFile, LibFileName);
  {$I-}
  Reset(LibFile);
  if IOresult = 0 then
  begin
    New(Openings);
    Read(LibFile,Openings^);
    Close(LibFile);
    Openings^[0] := $FF;
  end;
end;

{$ENDIF}

begin
  LoadOpening;
end.

end.