Unit UStiva1m;
{ implementeaza o stiva de intregi
  stiva este implementata ca tablou
  S este variabila globala interna modulului }
interface
const
  MaxDim = 100;
type
  TElement = Integer;

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
  Stiva = Record
    Spatiu: array[0..MaxDim] of TElement;
    Virf: 0..MaxDim;
  End;
var S:Stiva;

Procedure Eroare(M: String);
  begin
    Write('Eroare: ',M);
    ReadLn;
    Halt
  end;

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
    With S do begin
      E := Spatiu[Virf];
    end;
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

End.