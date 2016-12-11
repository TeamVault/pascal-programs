Program Stiva1P;
{ program de lucru cu stiva, varianta procedurala
  stiva este implementata ca tablou
  S este variabila globala }

const
  MaxDim = 100;
type
  TElement = Integer;
  Stiva = Record
    Spatiu: array[0..MaxDim] of TElement;
    Virf: 0..MaxDim;
  End;

Procedure Eroare(M: String);
  begin
    Write('Eroare: ',M);
    ReadLn;
    Halt
  end;

{ implementarea operatiilor stivei }

var
  S: Stiva;

Function Vida: Boolean;
  begin
    Vida := S.Virf = 0
  end; { Vida }

Function Plina: Boolean;
  begin
    Plina := S.Virf = MaxDim
  end; { Vida }

Procedure Push(E:TElement);
  begin
    if Plina then Eroare('stiva plina');
    With S do begin
      Inc(Virf);
      Spatiu[Virf] := E
    end;
  end;

Procedure Pop(var E:TElement);
  begin
    if Vida then Eroare('stiva goala');
    With S do begin
      E := Spatiu[Virf];
      Dec(Virf);
    end;
  end;

Procedure Top(var E:TElement);
  begin
    if Vida then Eroare('stiva goala');
    With S do E := Spatiu[Virf];
  end;

Procedure Init;
  begin
    S.Virf := 0
  end;

Procedure Term;
  var
    E: TElement;
  begin
    while not Vida do Pop(E);
  end;

Procedure List;
  var
    i : 1..MaxDim;
    E : TElement;
  begin
    if Vida then WriteLn('Stiva vida')
    else begin
      for i := S.Virf downto 1 do Write(S.Spatiu[i],'  ');
      WriteLn
    end;
  end;

{$I operatp.pas}

{$I stivap.run}

Begin
  WriteLn('Stiva1P - Stiva varianta procedurala, tablou, variabila globala');
  Run
End. { Stiva1P }

