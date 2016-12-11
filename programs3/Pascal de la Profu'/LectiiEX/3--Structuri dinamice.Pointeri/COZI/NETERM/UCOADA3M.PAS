Unit UStiva3M;
{ implementeaza o stiva de intregi
  stiva este implementata ca tablou
  de pointeri la intreg
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
const
  MaxDim = 100;
type
  Stiva = Record
    Spatiu: array[0..MaxDim] of PElement;
    Virf: 0..MaxDim;
  End;
var
  S: Stiva;
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
  var
    p: PElement;
  begin
    if Plina then Eroare('stiva plina');
    New(p);
    p^ := E;
    With S do begin
      Inc(Virf);
      Spatiu[Virf] := p
    end;
  end;

Procedure Pop(var E:TElement);
  begin
    if Vida then Eroare('stiva goala');
    With S do begin
      E := Spatiu[Virf]^;
      Dispose(Spatiu[Virf]);
      Dec(Virf);
    end;
  end;

Procedure Top(var E:TElement);
  begin
    if Vida then Eroare('stiva goala');
    With S do begin
      E := Spatiu[Virf]^;
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
    while S.Virf > 0 do Pop(E);
  end;

Procedure List;
  var
    i : 1..MaxDim;
    E : TElement;
  begin
    if Vida then WriteLn('Stiva vida')
    else begin
      for i := S.Virf downto 1 do Write(S.Spatiu[i]^,'  ');
      WriteLn
    end;
  end;

End.