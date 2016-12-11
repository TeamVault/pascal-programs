Program Stiva2;

{ program de lucru cu stiva, varianta procedurala: stiva este
  implementata ca tip record: exista mecanismul type }

const
  MaxDim = 100;

type
  TElement = Integer;	{ tipul elementului stivei, redenumire }
  TIndice = 1..MaxDim;	{ tipul indicelui tabloului }
  TStiva = record	{ tipul stiva }
    Stiva: array[TIndice] of TElement;
    Virf: 0..MaxDim;
  end;

Procedure Eroare(M: String);	{ similara cu cea de la Stiva1 }
  begin
    Write('Eroare: ',M);
    ReadLn;
    Halt
  end; { Eroare }

{ implementarea operatiilor stivei }

Procedure Push(var S: TStiva; E: TElement);
  begin
    with S do begin
      if Virf = MaxDim then Eroare('stiva plina');
      Virf := Virf + 1;
      Stiva[Virf] := E
    end;
  end; { Push }

Procedure Pop(var S: TStiva; var E: TElement);
  begin
    with S do begin
      if Virf = 0 then Eroare('stiva vida');
      E := Stiva[Virf];
      Virf := Virf - 1;
    end;
  end; { Pop }

Function Top(var S: TStiva): TElement;
  begin
    With S do begin
      if Virf = 0 then Eroare('stiva vida');
      Top := Stiva[Virf]
    end;
  end; { Top }

procedure Operatii(var Stiva: TStiva);
  var
    E: TElement;
    I: Integer;
  begin
    For I := 1 to 10 do begin
      Push(Stiva, I);
      WriteLn(' S-a introdus elementul: ', Top(Stiva));
    end;
    While Stiva.Virf <> 0 do begin
      WriteLn(' Se scoate elementul: ', Top(Stiva));
      Pop(Stiva, E);
    end;
  end; { Operatii }

var
  A: TStiva;

Begin
  A.Virf := 0;           { initial stiva este vida }
  Operatii(A);
  ReadLn
End. { Stiva2 }

