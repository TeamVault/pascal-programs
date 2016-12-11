{************************************************}
{                                                }
{   Chess Demo                                   }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit MoveList;

interface

{$IFDEF DPMI}
uses Objects, ChessDLL;
{$ELSE}
{$IFDEF WINDOWS}
uses Objects, ChessDLL;
{$ELSE}
uses Objects, ChessInf;
{$ENDIF}
{$ENDIF}

type
  PMoveList = ^TMoveList;
  TMoveList = object(TCollection)
    UndoPos: Integer;
    constructor Init(ALimit, ADelta: Integer);
    constructor Load(var S: TStream);
    procedure AddMove(Move: TMove);
    procedure FreeItem(Item: Pointer); virtual;
    function GetItem(var S: TStream): Pointer; virtual;
    function GetNumMoves: Integer;
    procedure Purge;
    procedure PutItem(var S: TStream; Item: Pointer); virtual;
    procedure Redo(var Move: TMove);
    function RedoAvail: Boolean;
    procedure Store(var S: TStream);
    procedure Undo(var Move: TMove);
    function UndoAvail: Boolean;
  end;

const
  RMoveList: TStreamRec = (
    ObjType: 5000;
    VmtLink: Ofs(TypeOf(TMoveList)^);
    Load:    @TMoveList.Load;
    Store:   @TMoveList.Store);

function NewMove(Move: TMove): PMove;
procedure DisposeMove(Move: PMove);

implementation

constructor TMoveList.Init(ALimit, ADelta: Integer);
begin
  inherited Init(ALimit, ADelta);
  UndoPos := 0;
end;

constructor TMoveList.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(UndoPos, SizeOf(UndoPos));
end;

procedure TMoveList.AddMove(Move: TMove);
var
  I: Integer;
begin
  if UndoPos < Count - 1 then
    while UndoPos < Count - 1 do
      AtFree(UndoPos + 1);
  AtInsert(Count, NewMove(Move));
  UndoPos := Count - 1;
end;

procedure TMoveList.FreeItem(Item: Pointer);
begin
  DisposeMove(PMove(Item));
end;

function TMoveList.GetItem(var S: TStream): Pointer;
var
  Move: TMove;
begin
  S.Read(Move, SizeOf(Move));
  GetItem := NewMove(Move);
end;

function TMoveList.GetNumMoves: Integer;
begin
  GetNumMoves := (UndoPos + 1) div 2;
end;

procedure TMoveList.Purge;
begin
  FreeAll;
  UndoPos := 0;
end;

procedure TMoveList.PutItem(var S: TStream; Item: Pointer);
begin
  S.Write(PMove(Item)^, SizeOf(TMove));
end;

procedure TMoveList.Redo(var Move: TMove);
begin
  if RedoAvail then
  begin
    Inc(UndoPos);
    Move := PMove(At(UndoPos))^;
  end
  else FillChar(Move, SizeOf(Move), 0);
end;

function TMoveList.RedoAvail: Boolean;
begin
  RedoAvail := (Count > 0) and (UndoPos < Count - 1);
end;

procedure TMoveList.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(UndoPos, SizeOf(UndoPos));
end;

procedure TMoveList.Undo(var Move: TMove);
begin
  if UndoAvail then
  begin
    Move := PMove(At(UndoPos))^;
    Dec(UndoPos);
  end
  else FillChar(Move, SizeOf(Move), 0);
end;

function TMoveList.UndoAvail: Boolean;
begin
  UndoAvail := (Count > 0) and (UndoPos >= 0);
end;

function NewMove(Move: TMove): PMove;
var
  AMove: PMove;
begin
  GetMem(AMove, SizeOf(TMove));
  AMove^ := Move;
  NewMove := AMove;
end;

procedure DisposeMove(Move: PMove);
begin
  FreeMem(Move, SizeOf(TMove));
end;

end.
