Procedure Process2;
  var e: ElementStandard;
      f: boolean;
      i: integer;
  const
      v: array[1..11] of integer = (50, 25, 75, 10, 40, 60, 90,
                                    35, 45, 70, 42);
  begin
    MemoDisp('Inceput');
    Creeaza;
    for i := 1 to 11 do begin
      CreeazaElementStandard(v[i], i, e);
      Insereaza(e, f);
      Afiseaza;
      Readln
    end;
    ReadLn;
    CautaCheie(10, f);
    WriteLn('Modifica cheia 10 in 99');
    CreeazaElementStandard(99, 99, e);
    Modifica(e);
    Afiseaza;
    ReadLn;
    WriteLn('Parcurgere in preordine');
    Traverseaza(PreOrdine, Inspecteaza);
    ReadLn;
    Afiseaza;
    WriteLn('Parcurgere in inordine');
    Traverseaza(InOrdine, Inspecteaza);
    ReadLn;
    Afiseaza;
    WriteLn('Parcurgere in postordine');
    Traverseaza(PostOrdine, Inspecteaza);
    ReadLn;
  {$F-}
    Elibereaza;
    MemoDisp('Sfarsit')
  end; { Process2 }
