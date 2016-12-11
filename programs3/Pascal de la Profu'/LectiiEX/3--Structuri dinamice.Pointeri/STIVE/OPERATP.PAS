   { implementeaza procedura de test Operatii
    pentru diverse implementari procedurale de Stiva }

procedure Operatii;
  var
    E: TElement;
    I: Integer;
  begin
    List;
    Push(3);
    List;
    Pop(E);
    List;
    For I := 1 to 10 do Push(I);
    Push(5);
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    List;
    Pop(E);
    List
  end;
