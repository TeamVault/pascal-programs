program LstCapCd;

uses
  Crt, ULstCCD;

  var
    i: Integer;
    N: PNod;

  begin
    ClrScr;
    WriteLn('LstCapCoada - implementarea listei simplu inlantuite cu inserare in coada');
    WriteLn('Elementele listei se listeaza de la cap spre coada');
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    Creeaza;
    For I := 1 to 10 do begin
      N := GenereazaNod(I);
      Insereaza(N);
      Write('Lista dupa inserarea nodului cu Info = ', I:2, ' este: ');
      Traverseaza;
    end;
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    N := Cauta(7);
    If N <> Nil
      then WriteLn('Exista un nod cu informatia utila 7, ',
                   'iar nodul urmator are informatia utila ', N^.Urm^.Info)
      else WriteLn('Nu exista un nod cu informatia utila 7');
    For I := 1 to 5 do begin
      Sterge;
      Write('Lista dupa stergerea nodului din coada este:    ');
      Traverseaza
    end;
    N := Cauta(7);
    If N <> Nil
      then WriteLn('Exista un nod cu informatia utila 7, ',
                   'iar nodul urmator are informatia utila ', N^.Urm^.Info)
      else WriteLn('Nu exista un nod cu informatia utila 7');
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    Elibereaza;
    Write('Lista dupa operatia Eliberare este: ');
    Traverseaza;
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    ReadLn
  end. { LstCapCd }
