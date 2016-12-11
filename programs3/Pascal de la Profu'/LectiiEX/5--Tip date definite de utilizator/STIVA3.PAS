Program Stiva3;

{ implementeaza o clasa stiva de intregi;
  stiva este implementata ca tip obiect (fara mostenire) }

const
  MaxDim = 100;
type
  TElement = Integer;
  TIndice = 1..MaxDim;
  TStiva = Object
    Procedure Push(E: TElement);
    Procedure Pop(var E: TElement);
    Function Top: TElement;
    Constructor Init;             { construieste o stiva vida }
    Destructor Done;                  { goleste stiva }
    Function Vida: Boolean;       { operatie noua }
    private
      Stiva: array[TIndice] of TElement;
      Virf: 0..MaxDim;
  end;

Procedure Eroare(M: String);  { similara cu cea de la Stiva1 }
  begin
    Write('Eroare: ',M);
    ReadLn;
    Halt
  end; { Eroare }

{ implementarea clasei TStiva }

Procedure TStiva.Push(E: TElement);
  begin
    if Virf = MaxDim then Eroare('stiva plina');
    Virf := Virf + 1;
    Stiva[Virf] := E
  end; { Push }

Procedure TStiva.Pop(var E: TElement);
  begin
    if Vida then Eroare('stiva vida');
    E := Stiva[Virf];
    Virf := Virf - 1;
  end; { Pop }

Function TStiva.Top: TElement;
  begin
    if Vida then Eroare('stiva vida');
    Top := Stiva[Virf];
  end; { Top }

Constructor TStiva.Init;
  begin
    Virf := 0
  end; { Init }

Destructor TStiva.Done;
  var
    E: TElement;
  begin
    while not Vida do Pop(E);
  end; { Done }

Function TStiva.Vida: Boolean;
  begin
    Vida := Virf = 0
  end; { Vida }
procedure Operatii(var Stiva: TStiva);
  var
    E: TElement;
    I: Integer;
  begin
    For I := 1 to 10 do begin
      Stiva.Push(I);
      WriteLn(' S-a introdus elementul: ', Stiva.Top);
    end;
    While not Stiva.Vida do begin
      WriteLn(' Se scoate elementul: ', Stiva.Top);
      Stiva.Pop(E);
    end;
  end; { Operatii }

var
  A: TStiva;

Begin
  A.Init;                   { ini_ial stiva este vid_ }
  Operatii(A);
  ReadLn
End. { Stiva3 }