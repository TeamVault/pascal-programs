Unit UStiva4M;
{ implementeaza o stiva de intregi
  stiva este implementata ca lista inlantuita
  un nod contine doi pointeri:
    - un pointer la element
    - un pointer la precedentul nod
  S este variabila globala interna modulului }
interface

type
  TElement = Integer;
  PElement = ^TElement;

Function Vida: Boolean;
Function Plina: Boolean;
Procedure Push(E:TElement);
Procedure Pop(var E:TElement);
Procedure Top(var E:TElement);
Procedure Init;
Procedure Term;
Procedure List;

implementation

type
  Stiva = ^Nod;
  Nod = Record
    Spatiu : PElement;
    Prec : Stiva;
  End;
var
  S: Stiva;

Procedure Eroare(M: String);
  begin
    Write('Eroare: ',M);
    ReadLn;
    Halt
  end;

{ implementarea operatiilor stivei }

Function Vida: Boolean;
  begin
    Vida := S = Nil
  end; { Vida }

Function Plina: Boolean;
  begin
    Plina := MemAvail = 0
  end; { Vida }

Procedure Push(E:TElement);
  var
    p: Stiva;
    q: PElement;
  begin
    If Plina then Eroare('stiva plina');
    New(p);
    New(q);
    q^ := E;
    p^.Spatiu := q;
    p^.Prec := S;
    S := p
  end;

Procedure Pop(var E:TElement);
  var
    p : Stiva;
  begin
    if Vida then Eroare('stiva goala');
    E := S^.Spatiu^;
    Dispose(S^.Spatiu);
    p := S;
    S := S^.Prec;
    Dispose(p)
  end;

Procedure Top(var E:TElement);
  begin
    if Vida then Eroare('stiva goala');
    E := S^.Spatiu^;
  end;

Procedure Init;
  begin
    S := Nil;
  end;

Procedure Term;
  var
    E: TElement;
  begin
    while S <> Nil do Pop(E);
  end;

Procedure List;
  var
    p : Stiva;
  begin
    if Vida then WriteLn('Stiva vida')
    else begin
      p := S;
      while p <> Nil do begin
        Write(p^.Spatiu^,'  ');
        p := p^.prec;
      end;
      WriteLn
    end;
  end;

End.