Program Stiva2P;
{ program de lucru cu stiva, varianta procedurala
  stiva este implementata ca lista inlantuita in care
  inserarea si stergerea se fac in cap
  }

type
  TElement = Integer;
  Stiva = ^Nod;
  Nod = Record
    Spatiu : TElement;
    Prec : Stiva;     { nodul introdus anterior }
  End;

var S:Stiva;

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
  begin
    If Plina then Eroare('Stiva plina');
    New(p);                       { aloca p^ in heap }
    p^.Spatiu := E;
    p^.Prec := S;                 { pune p^ inaintea lui S^ }
    S := p                        { p^ devine capul listei }
  end;

Procedure Pop(var E:TElement);
  var
    p: Stiva;
  begin
    if Vida then Eroare('Stiva goala');
    E := S^.Spatiu;
    p := S;
    S := S^.Prec;                { sterge capul listei }
    Dispose(p)                   { dealoca p^ }
  end;

Procedure Top(E:TElement);
  begin
    if Vida then Eroare('stiva goala');
    E := S^.Spatiu;
  end;

Procedure Init;
  begin
    S := Nil;
  end;

Procedure Term;
  var
    E: TElement;
  begin
    while not Vida do Pop(E);
  end;

Procedure List;
  var
    E : TElement;
    p : Stiva;
  begin
    if Vida then WriteLn('Stiva vida')
    else begin
      p := S;
      while p <> Nil do begin
        Write(p^.Spatiu,'  ');
        p := p^.prec;
      end;
      WriteLn
    end;
  end;

{$I operatp.pas}

{$I stivap.run}

Begin
  WriteLn('Stiva2P - Stiva varianta procedurala, lista, variabila globala');
  Run
End. { Stiva2P }

