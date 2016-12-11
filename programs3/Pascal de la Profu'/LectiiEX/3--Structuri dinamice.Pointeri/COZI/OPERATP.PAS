   { implementeaza procedura de test Operatii
    pentru diverse implementari procedurale de Coada }

procedure Operatii;
  var
    E: TElement;
    I: Integer;
  begin
    List;
    Adauga(3);
    List;
    Scoate(E);
    List;
    For I := 1 to 10 do Adauga(I);
    Adauga(5);
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    List;
    Primul(E);
    WriteLn('Primul element are valoarea: ', E);
    Ultimul(E);
    WriteLn('Ultimul element are valoarea: ', E);
    Scoate(E);
    List
  end;
