{************************************************}
{                                                }
{   Turbo Vision Chess Demo                      }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit TVChsUtl;

interface

{$IFDEF DPMI}
uses ChessDLL, Objects, Views;
{$ELSE}
uses ChessInf, Objects, Views;
{$ENDIF}

procedure SquareToLocal(ALocation: TLocation; var P: TPoint; Size: Integer);
procedure PointInSquare(P: TPoint; var ALocation: TLocation);

implementation

function MaxI(I1, I2: Integer): Integer; inline (
  $58/$5B/$3B/$C3/$7D/$01/$93
  );

function MinI(I1, I2: Integer): Integer; inline (
  $58/$5B/$3B/$C3/$7E/$01/$93
  );

procedure SquareToLocal(ALocation: TLocation; var P: TPoint; Size: Integer);
begin
  P.X := (ALocation.X - 1) * 6 + 2;
  P.Y := Size - ALocation.Y * 3;
end;

procedure PointInSquare(P: TPoint; var ALocation: TLocation);
begin
  ALocation.X := MinI(MaxI(1, ((P.X - 2) div 6) + 1), 8);
  ALocation.Y := MinI(MaxI(1, 8 - ((P.Y - 1) div 3)), 8);
end;

end.
