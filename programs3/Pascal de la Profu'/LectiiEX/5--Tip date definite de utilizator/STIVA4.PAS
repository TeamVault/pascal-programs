Program Stiva4;

{ implementeaz_ o ierarhie de clase stiva de intregi
  cu doua strategii de reprezentare:
    TStiva   - clasa abstracta, radacina arborelui de mostenire
    AStiva   - tablou de intregi
    LStiva   - lista inlantuita de intregi }

uses Objects;	{ necesara pentru apelul metodei Abstract }
const
  MaxDim = 100;

type
  TElement = Integer;
  TIndice  = 1..MaxDim;

{ declaratia clasei abstracte TStiva }

  PtrTStiva = ^TStiva;
  TStiva = Object                         { clasa abstracta }
    Procedure Push(E:TElement); virtual;
    Procedure Pop(var E:TElement); virtual;
    Function Top: TElement; virtual;
    Function Vida: Boolean; virtual;
    Function Plina: Boolean; virtual;     { noua }
    Function ClassType: string; virtual;  { noua }
    Destructor Done; virtual;
  end;

{ declaratia clasei AStiva }

  PtrAStiva = ^AStiva;
  AStiva = Object(TStiva)
    private
      Stiva: array[TIndice] of TElement;
      Virf: 0..MaxDim;
    public
      Procedure Push(E:TElement); virtual;
      Procedure Pop(var E:TElement); virtual;
      Function Top: TElement; virtual;
      Function Vida: Boolean; virtual;
      Function Plina: Boolean; virtual;
      Function ClassType: string; virtual;
      Constructor Init;
      Destructor Done; virtual;
  end;

{ declaratia clasei LStiva }

  PLNod = ^LNod;
  LNod = Record
    Info  : TElement;
    Prec : PLNod;
  End;
  PtrLStiva = ^LStiva;
  LStiva = Object(TStiva)
    private
      Stiva : PLNod;
    public
      Procedure Push(E:TElement); virtual;
      Procedure Pop(var E:TElement); virtual;
      Function Top: TElement; virtual;
      Function Vida: Boolean; virtual;
      Function Plina: Boolean; virtual;
      Function ClassType: string; virtual;
      Constructor Init;
      Destructor Done; virtual;
  end;

Procedure Eroare(M: String);	{ similara cu cea de la Stiva1 }
  begin
    Write('Eroare: ',M);
    ReadLn;
    Halt
  end; { Eroare }

{ implementarea clasei TStiva }

Procedure TStiva.Push(E:TElement);
  begin
    Abstract
  end; { Push }

Procedure TStiva.Pop(var E:TElement);
  begin
    Abstract
  end; { Pop }

Function TStiva.Top: TElement;
  begin
    Abstract
  end; { Top }

Function TStiva.Vida: Boolean;
  begin
    Vida := True
  end; { Vida }

Function TStiva.Plina: Boolean;
  begin
    Plina := True
  end; { Plina }

Function TStiva.ClassType: String;
  begin
    ClassType := 'Stiva abstracta'
  end; { ClassType }

Destructor TStiva.Done;
  begin
  end; { Done }

{ implementarea clasei AStiva }

Procedure AStiva.Push(E:TElement);
  begin
    if Plina then Eroare('stiva tablou plina');
    Virf := Virf + 1;
    Stiva[Virf] := E
  end; { Push }

Procedure AStiva.Pop(var E:TElement);
  begin
    if Vida then Eroare('stiva tablou vida');
    E := Stiva[Virf];
    Virf := Virf - 1;
  end; { Pop }

Function AStiva.Top: TElement;
  begin
    if Vida then Eroare('stiva tablou vida');
    Top := Stiva[Virf];
  end; { Top }

Function AStiva.Vida: Boolean;
  begin
    Vida := Virf = 0
  end; { Vida }

Function AStiva.Plina: Boolean;
  begin
    Plina := Virf = MaxDim
  end; { Plina }

Function AStiva.ClassType: String;
  begin
    ClassType := 'stiva tablou'
  end; { ClassType }

Constructor AStiva.Init;
  begin
    Virf := 0
  end; { Init }

Destructor AStiva.Done;
  var
    E: TElement;
  begin
    while Virf > 0 do Pop(E);
    inherited Done
  end; { Done }

{ implementarea clasei LStiva }

Procedure LStiva.Push(E: TElement);
  var
    p: PLNod;
  begin
    If Plina then Eroare('stiva lista plina');
    New(p);	        { aloca un nou element LNod referit de p }
    p^.Info := E;	{ completeaza campurile lui p^ }
    p^.Prec := Stiva;	{ precedentul este fostul cap al listei }
    Stiva := p	        { p devine capul listei }
  end; { Push }

Procedure LStiva.Pop(var E:TElement);
  var
    p : PLNod;
  begin
    if Vida then Eroare('stiva lista goala');
    E := Stiva^.Info;	      { extrage informatia din capul listei }
    p := Stiva;	              { este necesar pentru dealocare }
    Stiva := Stiva^.Prec;     { sterge elementul din capul listei }
    Dispose(p)	              { dealoca elementul LNod care a fost in cap }
  end; { Pop }

Function LStiva.Top: TElement;
  begin
    if Vida then Eroare('stiva lista goala');
    Top := Stiva^.Info;
  end; { Top }

Function LStiva.Vida: Boolean;
  begin
    Vida := Stiva = Nil
  end; { Vida }

Function LStiva.Plina: Boolean;
  begin
    Plina := MemAvail < SizeOf(PtrTStiva)
  end; { Plina }

Function LStiva.ClassType: String;
  begin
    ClassType := 'stiva lista'
  end; { ClassType }

Constructor LStiva.Init;
  begin
    Stiva := Nil;
  end; { Init }

Destructor LStiva.Done;
  var
    E: TElement;
  begin
    while Stiva <> Nil do Pop(E);
    inherited Done
  end; { Done }

procedure Operatii(var Stiva: TStiva);
  var
    E: TElement;
    I: Integer;
  begin
    For I := 1 to 10 do begin
      Stiva.Push(I);
{      Stiva.Insereaza; }
      WriteLn(' S-a introdus in ', Stiva.ClassType, ': ', Stiva.Top);
    end;
    While not Stiva.Vida do begin
      WriteLn(' Se scoate din ', Stiva.ClassType, ': ', Stiva.Top);
      Stiva.Pop(E);
    end;
  end; { Operatii }

var
  A: AStiva;
  L: LStiva;
  T: Array[1..2] of PtrTStiva;	{ T[1]^ si T[2]^ de tipul static TStiva }
  I: Integer;

Begin
  A.Init;                   { initial stiva (tablou) este vida }
  Operatii(A);
  ReadLn;

  L.Init;                   { initial stiva (lista) este vida }
  Operatii(L);
  ReadLn;

  T[1] := New(PtrLStiva, Init);	{ T[1]^ cu tipul dinamic LStiva}
  T[2] := New(PtrAStiva, Init);	{ T[2]^ cu tipul dinamic AStiva}
  For I := 1 to 2 do begin
    Operatii(T[I]^);
    ReadLn
  end;
End. { Stiva4 }

