Unit UStiva3;
{ implementeaza o stiva de intregi
  stiva este implementata ca tablou
  de pointeri la intreg
  S este parametru al fiecarei operatii }
interface
const
  MaxDim = 100;
type
  TElement = Integer;
  PElement = ^TElement;
  Stiva = Record
    Spatiu: array[0..MaxDim] of PElement;
    Virf: 0..MaxDim;
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

Function Vida(var S:Stiva): Boolean;
  begin
    Vida := S.Virf = 0
  end; { Vida }

Function Plina(var S:Stiva): Boolean;
  begin
    Plina := S.Virf = MaxDim
  end; { Vida }

Procedure Push(var S:Stiva; E:TElement);
  var
    p: PElement;
  begin
    if Plina(S) then Eroare('stiva plina');
    New(p);
    p^ := E;
    With S do begin
      Inc(Virf);
      Spatiu[Virf] := p
    end;
  end;

Procedure Pop(var S:Stiva; var E:TElement);
  begin
    if Vida(S) then Eroare('stiva goala');
    With S do begin
      E := Spatiu[Virf]^;
      Dispose(Spatiu[Virf]);
      Dec(Virf);
    end;
  end;

Procedure Top(S:Stiva; var E:TElement);
  begin
    if Vida(S) then Eroare('stiva goala');
    With S do begin
      E := Spatiu[Virf]^;
    end;
  end;

Procedure Init(var S:Stiva);
  begin
    S.Virf := 0
  end;

Procedure Term(var S:Stiva);
  var
    E: TElement;
  begin
    while S.Virf > 0 do Pop(S,E);
  end;

Procedure List(S:Stiva);
  var
    i : 1..MaxDim;
    E : TElement;
  begin
    if Vida(S) then WriteLn('Stiva vida')
    else begin
      for i := S.Virf downto 1 do Write(S.Spatiu[i]^,'  ');
      WriteLn
    end;
  end;

End.