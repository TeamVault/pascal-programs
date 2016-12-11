Unit UCoada1M;
{ implementeaza o coada de intregi
  coada este implementata ca tablou circular
  C este variabila globala interna modulului }
interface
const
  MaxDim = 100;
type
  TElement = Integer;

Function Vida: Boolean;
Function Plina: Boolean;
Procedure Adauga(E:TElement);
Procedure Scoate(var E:TElement);
Procedure Primul(var E:TElement);
Procedure Ultimul(var E:TElement);
Procedure Init;
Procedure Term;
Procedure List;

implementation

type
  Coada = Record
    Spatiu: array[1..MaxDim] of TElement;
    Inceput, Sfarsit: 0..MaxDim;
  End;

var
  C: Coada;

Procedure Eroare(M: String);
  begin
    Write('Eroare: ',M);
    ReadLn;
    Halt
  end;

{ implementarea operatiilor cozii: coada circulara }

Function Avanseaza(i: Integer): Integer;
  begin
    Avanseaza := (i mod MaxDim) + 1
  end; { Avanseaza }
Function Vida: Boolean;
  begin
    Vida := Avanseaza(C.Sfarsit) = C.Inceput
  end; { Vida }

Function Plina: Boolean;
  begin
    Plina := Avanseaza(Avanseaza(C.Sfarsit)) = C.Inceput
  end; { Plina }

Procedure Adauga(E:TElement);
  begin
    if Plina then Eroare('coada plina');
    With C do begin
      Sfarsit := Avanseaza(Sfarsit);
      Spatiu[Sfarsit] := E
    end;
  end; { Adauga }

Procedure Scoate(var E:TElement);
  begin
    if Vida then Eroare('coada goala');
    With C do begin
      E := Spatiu[Inceput];
      Inceput := Avanseaza(Inceput);
    end;
  end; { Scoate }

Procedure Primul(var E:TElement);
  begin
    if Vida then Eroare('coada goala');
    With C do begin
      E := Spatiu[Inceput];
    end;
  end; { Primul }

Procedure Ultimul(var E:TElement);
  begin
    if Vida then Eroare('coada goala');
    With C do begin
      E := Spatiu[Sfarsit];
    end;
  end; { Ultimul }

Procedure Init;
  begin
    C.Inceput := 1;
    C.Sfarsit := MaxDim
  end; { Init }

Procedure Term;
  var
    E: TElement;
  begin
    while not Vida do Scoate(E);
  end; { Term }

Procedure List;
  var
    i : 1..MaxDim;
    E : TElement;
  begin
    if Vida then WriteLn('coada vida')
    else with C do begin
      i := Inceput;
      while i <> Sfarsit do begin
        Write(Spatiu[i], '  ');
        i := Avanseaza(i)
      end;
      WriteLn(Spatiu[i], '  ');
    end;
  end; { List }


End.