Unit UStiva2;
{ implementeaza o stiva de intregi
  stiva este implementata ca lista inlantuita
  S este parametru al fiecarei operatii }
interface

type
  TElement = Integer;
  Stiva = ^Nod;
  Nod = Record
    Spatiu : TElement;
    Prec : Stiva;
  End;

Function Vida(var S:Stiva): Boolean;
Function Plina(var S:Stiva): Boolean;
Procedure Push(var S:Stiva; E:TElement);
Procedure Pop(var S:Stiva; var E:TElement);
Procedure Top(S:Stiva; var E:TElement);
Procedure Init(var S:Stiva);
Procedure Term(var S:Stiva);
Procedure List(S:Stiva);

implementation

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
    If Plina(S) then Eroare('stiva plina');
    New(p);
    p^.Spatiu := E;
    p^.Prec := S;
    S := p
  end;

Procedure Pop(var S:Stiva; var E:TElement);
  var
    p : Stiva;
  begin
    if Vida(S) then Eroare('stiva goala');
    E := S^.Spatiu;
    p := S;
    S := S^.Prec;
    Dispose(p)
  end;

Procedure Top(S:Stiva; var E:TElement);
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
    end;
  end;

End.