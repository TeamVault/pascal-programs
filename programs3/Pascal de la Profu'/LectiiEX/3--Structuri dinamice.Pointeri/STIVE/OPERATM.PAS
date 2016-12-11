   { implementeaza procedura de test Operatii
    pentru diverse implementari de module Stiva }

procedure Operatii(var S:Stiva);
  var
    E: TElement;
    I: Integer;
  begin
    List(S);
    Push(S,3);
    List(S);
    Pop(S,E);
    List(S);
    For I := 1 to 10 do Push(S, I);
    Push(S, 5);
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    List(S);
    Pop(S, E);
    List(S)
  end;
