{************************************************}
{                                                }
{   Turbo Vision Chess Demo                      }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit TVChstat;

interface

{$IFDEF DPMI}
uses Objects, Views, Menus, Drivers, ChessDLL;
{$ELSE}
uses Objects, Views, Menus, Drivers, ChessInf;
{$ENDIF}

type
  PChessStatusLine = ^TChessStatusLine;
  TChessStatusLine = object(TStatusLine)
    ChessStatus: TChessStatus;
    MateInMoves: Longint;
    procedure Draw; virtual;
    function Hint(Ctx: Word): String; virtual;
    procedure SetStatus(AChessStatus: TChessStatus; Count: Integer);
  end;

implementation

procedure TChessStatusLine.Draw;
var
  B: TDrawBuffer;
  CNormal: Word;
  StatBuf: String;
begin
  CNormal := GetColor($0301);
  MoveChar(B, ' ', Byte(CNormal), Size.X);
  StatBuf := Hint(0);
  if Length(StatBuf) > Size.X then StatBuf[0] := Char(Size.X);
  MoveStr(B, StatBuf, Byte(CNormal));
  WriteLine(0, 0, Size.X, 1, B);
end;

function TChessStatusLine.Hint(Ctx: Word): String;
var
  S: String;
begin
  case ChessStatus of
    csNormal: Hint := '';
    csCheck: Hint := ' Check!';
    csCheckMate: Hint := ' Checkmate!';
    csStaleMate: Hint := ' Stalemate!';
    csResigns: Hint := ' Resigns!';
    csMateFound:
      begin
        FormatStr(S, ' Checkmate in %d moves', MateInMoves);
        Hint := S;
      end;
    csFiftyMoveRule: Hint := ' Fifty move rule!';
    csRepetitionRule: Hint := ' Repetition rule!';
  end;
end;

procedure TChessStatusLine.SetStatus(AChessStatus: TChessStatus; Count: Integer);
begin
  ChessStatus := AChessStatus;
  MateInMoves := Count;
  DrawView;
end;

end.