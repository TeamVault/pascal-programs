Program Stiva2;
{ program de lucru cu stiva, varianta procedurala
  stiva este implementata ca lista inlantuita }

type
  TElement = Integer;
  Stiva = ^Nod;
  Nod = Record
    Spatiu : TElement;
    Prec : Stiva;
  End;

Procedure Eroare(M: String);
  begin
    Write('Eroare: ',M);
    ReadLn;
    Halt
  end;

{ implementarea operatiilor stivei }

Function Vida(var S:Stiva): Boolean;
  begin
    Vida := S = Nil
  end; { Vida }

Function Plina(var S:Stiva): Boolean;
  begin
    Plina := MemAvail = 0
  end; { Vida }

Procedure Push(var S:Stiva; E:TElement);
  var
    p: Stiva;
  begin
    If Plina(S) then Eroare('Stiva plina');
    New(p);
    p^.Spatiu := E;
    p^.Prec := S;
    S := p
  end;

Procedure Pop(var S:Stiva; var E:TElement);
  var
    p: Stiva;
  begin
    if Vida(S) then Eroare('Stiva goala');
    E := S^.Spatiu;
    p := S;
    S := S^.Prec;
    Dispose(p)
  end;

Procedure Top(S:Stiva; E:TElement);
  begin
    if Vida(S) then Eroare('stiva goala');
    E := S^.Spatiu;
  end;

Procedure Init(var S:Stiva);
  begin
    S := Nil;
  end;

Procedure Term(var S:Stiva);
  var
    E: TElement;
  begin
    while S <> Nil do Pop(S,E);
  end;

Procedure List(S:Stiva);
  var
    E : TElement;
    p : Stiva;
  begin
    if Vida(S) then WriteLn('Stiva vida')
    else begin
      p := S;
      while p <> Nil do begin
        Write(p^.Spatiu,'  ');
        p := p^.prec;
      end;
      WriteLn
    end
  end;

{$I operatm.pas}

{$I stivam.run}

Begin
  WriteLn('Stiva2 - Stiva varianta procedurala, lista inlantuita, parametru');
  Run
End.

