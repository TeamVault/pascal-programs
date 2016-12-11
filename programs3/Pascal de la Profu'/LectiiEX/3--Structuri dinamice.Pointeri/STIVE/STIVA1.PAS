Program Stiva1;
{ program de lucru cu stiva, varianta procedurala
  stiva este implementata ca tablou }

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
  end; { Eroare }

{ implementarea operatiilor stivei }

Function Vida(var S:Stiva): Boolean;
  begin
    Vida := S.Virf = 0
  end; { Vida }

Function Plina(var S:Stiva): Boolean;
  begin
    Plina := S.Virf = MaxDim
  end; { Vida }

Procedure Push(var S:Stiva; E:TElement);
  begin
    if Plina(S) then Eroare('stiva plina');
    With S do begin
      Inc(Virf);
      Spatiu[Virf] := E
    end;
  end; { Push }

Procedure Pop(var S:Stiva; var E:TElement);
  begin
    if Vida(S) then Eroare('stiva goala');
    With S do begin
      E := Spatiu[Virf];
      Dec(Virf);
    end;
  end; { Pop }

Procedure Top(var S:Stiva; var E:TElement);
  begin
    if Vida(S) then Eroare('stiva goala');
    With S do begin
      E := Spatiu[Virf];
    end;
  end; { Top }

Procedure Init(var S:Stiva);
  begin
    S.Virf := 0
  end; { Init }

Procedure Term(var S:Stiva);
  var
    E: TElement;
  begin
    while S.Virf > 0 do Pop(S,E);
  end; { Term }

Procedure List(var S:Stiva);
  var
    i : 1..MaxDim;
    E : TElement;
  begin
    if Vida(S) then WriteLn('Stiva vida')
    else begin
      for i := S.Virf downto 1 do Write(S.Spatiu[i],'  ');
      WriteLn
    end
  end; { List }

{$I operatm.pas}

{$I stivam.run}

Begin
  WriteLn('Stiva1 - Stiva varianta procedurala, tablou, parametru');
  Run
End.

