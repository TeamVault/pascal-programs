Unit UStiva5M;
{ implementeaza o stiva de intregi
  stiva este implementata ca tablou alocat dinamic si flexibil
  de pointeri la intreg }
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
  MaxDim = 1;
  Delta = 1;             { cu cat creste tabloul }

type
  AElement = array[1..1] of PElement;
  PAElement = ^AElement;
  Stiva = Record
    Spatiu: PAElement;
    Virf: Integer;
    Dim: Integer;
  End;

var
  S: Stiva;

Procedure Eroare(M: String);
  begin
    Write('Eroare: ',M);
    ReadLn;
    Halt
  end;

Procedure Aloca;             { procedura locala }
  var
    SS, p: PAElement;
  Begin
    { aloca memorie pentru noua adresa a campului Spatiu
      dimensiune: vechea dimensiune + Delta }
    GetMem(SS, (S.Dim + Delta) * SizeOf(PElement));
    { muta vechiul Spatiu la noua adresa }
    Move(S.Spatiu^, SS^, S.Dim * SizeOf(PElement));
    { pune adresa vechiului spatiu in p }
    p := S.Spatiu;
    { seteaza noua adresa a lui S.Spatiu }
    S.Spatiu := SS;
    { sterge vechiul spatiu }
    FreeMem(p, S.Dim * SizeOf(PElement));
    { calculeaza noua dimensiune a spatiului alocat }
    S.Dim := S.Dim + Delta;
  End; { Aloca }

Function Vida: Boolean;
  begin
    Vida := S.Virf = 0
  end; { Vida }

Function Plina: Boolean;
  begin
    Plina := MemAvail = 0
  end; { Vida }

Procedure Push(E:TElement);
  var
    p: PElement;
  begin
    if Plina then Eroare('stiva plina');
    if S.Virf = S.Dim
      then Aloca;
    New(p);
    p^ := E;
    With S do begin
      Inc(Virf);
      Spatiu^[Virf] := p
    end;
  end; { Push }

Procedure Pop(var E:TElement);
  begin
    if Vida then Eroare('stiva goala');
    With S do begin
      E := Spatiu^[Virf]^;
      Dispose(Spatiu^[Virf]);
      Dec(Virf);
    end;
  end;

Procedure Top(var E:TElement);
  begin
    if Vida then Eroare('stiva goala');
    With S do begin
      E := Spatiu^[Virf]^;
    end;
  end;

Procedure Init;
  begin
    GetMem(S.Spatiu, MaxDim * SizeOf(PElement));
    S.Virf := 0;
    S.Dim := MaxDim;
  end;

Procedure Term;
  var
    E: TElement;
  begin
    while S.Virf > 0 do Pop(E);
    FreeMem(S.Spatiu, S.Dim * SizeOf(PElement));
  end;

Procedure List;
  var
    i : 1..MaxDim;
    E : TElement;
  begin
    if Vida then WriteLn('Stiva vida')
    else begin
      for i := S.Virf downto 1 do Write(S.Spatiu^[i]^,'  ');
      WriteLn
    end;
  end;

End.