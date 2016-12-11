Unit UCoada1;
{ implementeaza o stiva de intregi
  stiva este implementata ca tablou }
interface
const
  MaxDim = 100;
type
  TElement = Integer;
  Coada = Record
    Spatiu: array[1..MaxDim] of TElement;
    Inceput, Sfarsit: 0..MaxDim;
  End;

Function Vida(var C: Coada): Boolean;
Function Plina(var C: Coada): Boolean;
Procedure Adauga(var C: Coada; E:TElement);
Procedure Scoate(var C: Coada; var E:TElement);
Procedure Primul(var C: Coada; var E:TElement);
Procedure Ultimul(var C: Coada; var E:TElement);
Procedure Init(var C: Coada);
Procedure Term(var C: Coada);
Procedure List(var C: Coada);

implementation

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

Function Vida(var C: Coada): Boolean;
  begin
    Vida := Avanseaza(C.Sfarsit) = C.Inceput
  end; { Vida }

Function Plina(var C: Coada): Boolean;
  begin
    Plina := Avanseaza(Avanseaza(C.Sfarsit)) = C.Inceput
  end; { Plina }

Procedure Adauga(var C: Coada; E:TElement);
  begin
    if Plina(C) then Eroare('coada plina');
    With C do begin
      Sfarsit := Avanseaza(Sfarsit);
      Spatiu[Sfarsit] := E
    end;
  end; { Adauga }

Procedure Scoate(var C: Coada; var E:TElement);
  begin
    if Vida(C) then Eroare('coada goala');
    With C do begin
      E := Spatiu[Inceput];
      Inceput := Avanseaza(Inceput);
    end;
  end; { Scoate }

Procedure Primul(var C: Coada; var E:TElement);
  begin
    if Vida(C) then Eroare('coada goala');
    With C do begin
      E := Spatiu[Inceput];
    end;
  end; { Primul }

Procedure Ultimul(var C: Coada; var E:TElement);
  begin
    if Vida(C) then Eroare('coada goala');
    With C do begin
      E := Spatiu[Sfarsit];
    end;
  end; { Ultimul }

Procedure Init(var C: Coada);
  begin
    C.Inceput := 1;
    C.Sfarsit := MaxDim
  end; { Init }

Procedure Term(var C: Coada);
  var
    E: TElement;
  begin
    while not Vida(C) do Scoate(C, E);
  end; { Term }

Procedure List(var C: Coada);
  var
    i : 1..MaxDim;
    E : TElement;
  begin
    if Vida(C) then WriteLn('coada vida')
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