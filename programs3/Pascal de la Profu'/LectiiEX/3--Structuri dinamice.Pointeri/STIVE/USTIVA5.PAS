Unit UStiva5;
{ implementeaza o stiva de intregi
  stiva este implementata ca tablou alocat dinamic si flexibil
  de pointeri la intreg
  S este parametru al fiecarei operatii }
interface
const
  MaxDim = 1;
  Delta = 1;
type
  TElement = Integer;
  PElement = ^TElement;
  AElement = array[1..1] of PElement;
  PAElement = ^AElement;
  Stiva = Record
    Spatiu: PAElement;
    Virf: Integer;
    Dim: Integer;
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

Procedure Aloca(var S:Stiva);      { procedura locala }
  var
    SS, p: PAElement;
  Begin
    GetMem(SS, (S.Dim + Delta) * SizeOf(PElement));
    Move(S.Spatiu^, SS^, S.Dim * SizeOf(PElement));
    p := S.Spatiu;
    S.Spatiu := SS;
    FreeMem(p, S.Dim * SizeOf(PElement));
    S.Dim := S.Dim + Delta;
  End;

Function Vida(var S:Stiva): Boolean;
  begin
    Vida := S.Virf = 0
  end; { Vida }

Function Plina(var S:Stiva): Boolean;
  begin
    Plina := MemAvail = 0
  end; { Vida }

Procedure Push(var S:Stiva; E:TElement);
  var
    p: PElement;
  begin
    if Plina(S) then Eroare('stiva plina');
    if S.Virf = S.Dim
      then Aloca(S);
    New(p);
    p^ := E;
    With S do begin
      Inc(Virf);
      Spatiu^[Virf] := p
    end;
  end;

Procedure Pop(var S:Stiva; var E:TElement);
  begin
    if Vida(S) then Eroare('stiva goala');
    With S do begin
      E := Spatiu^[Virf]^;
      Dispose(Spatiu^[Virf]);
      Dec(Virf);
    end;
  end;

Procedure Top(S:Stiva; var E:TElement);
  begin
    if Vida(S) then Eroare('stiva goala');
    With S do begin
      E := Spatiu^[Virf]^;
    end;
  end;

Procedure Init(var S:Stiva);
  begin
    GetMem(S.Spatiu, MaxDim * SizeOf(PElement));
    S.Virf := 0;
    S.Dim := MaxDim;
  end;

Procedure Term(var S:Stiva);
  var
    E: TElement;
  begin
    while S.Virf > 0 do Pop(S,E);
    FreeMem(S.Spatiu, S.Dim * SizeOf(PElement));
  end;

Procedure List(S:Stiva);
  var
    i : 1..MaxDim;
    E : TElement;
  begin
    if Vida(S) then WriteLn('Stiva vida')
    else begin
      for i := S.Virf downto 1 do Write(S.Spatiu^[i]^,'  ');
      WriteLn
    end;
  end;

End.