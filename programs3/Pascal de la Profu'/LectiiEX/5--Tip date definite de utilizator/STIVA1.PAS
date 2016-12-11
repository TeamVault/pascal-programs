Program Stiva1;
{ program de lucru cu stiva, varianta procedurala;
  stiva este implementata ca tablou + varf:
  nu exista mecanism type }

Procedure Eroare(M: String);
  begin
    Write('Eroare: ',M);
    ReadLn;
    Halt
  end; { Eroare }

{ implementarea operatiilor pe stiva }

Procedure Push(var S:array of Integer; var V: Integer; E:Integer);
  begin
    if V = High(S) then Eroare('stiva plina');
    V := V + 1;
    S[V] := E
  end;

Procedure Pop(var S:array of Integer; var V: Integer; var E:Integer);
  begin
    if V = Low(S) then Eroare('stiva vida');
    E := S[V];
    V := V - 1;
  end; { Pop }

Function Top(var S:array of Integer; V: Integer): Integer;
  begin
    if V = Low(S) then Eroare('stiva goala');
    Top := S[V];
  end; { Top }

procedure Operatii(var S:array of Integer; var V: Integer);
  var
    E, I: Integer;
  begin
    For I := 1 to 10 do begin
      Push(S, V, I);
      WriteLn(' S-a introdus elementul: ', Top(S, V));
    end;
    While V <> Low(S) do begin
      WriteLn(' Se scoate elementul: ', Top(S, V));
      Pop(S, V, E);
    end;
  end; { Operatii }

const
  MaxDim = 100;

var
    Stiva: array[1..MaxDim] of Integer;
    Virf: Integer;

Begin
  Virf := 0;            { initial stiva este vida }
  Operatii(Stiva, Virf);
  ReadLn
End. { Stiva1 }
