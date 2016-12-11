   { implementeaza procedura de test Operatii
    pentru diverse implementari de module Stiva }

procedure Operatii(var C:Coada);
  var
    E: TElement;
    I: Integer;
  begin
    List(C);
    Adauga(C,3);
    List(C);
    Scoate(C,E);
    List(C);
    For I := 1 to 10 do Adauga(C, I);
    Adauga(C, 5);
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    List(C);
    Primul(C, E);
    WriteLn('Primul element are valoarea: ', E);
    Ultimul(C, E);
    WriteLn('Ultimul element are valoarea: ', E);
    Scoate(C, E);
    List(C)
  end;
