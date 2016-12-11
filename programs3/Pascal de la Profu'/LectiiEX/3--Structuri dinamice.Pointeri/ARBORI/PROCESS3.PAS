Procedure Process3;
  var e: ElementStandard;
      f: boolean;
      i: integer;
      c: integer; { cheia }
  begin
    MemoDisp('Inceput');
    Creeaza;
    for i := 1 to 20 do begin
      Write('Cheia: ');
      ReadLn(c);
      CreeazaElementStandard(c, i, e);
      Insereaza(e, f);
      Afiseaza;
      Readln
    end;
    ReadLn;
    Repeat
      Write('Cheia care se sterge (0 = gata): ');
      ReadLn(c);
      if c > 0 then begin
        StergeCheie(c, f);
        Afiseaza;
        ReadLn;
      end;
    Until c = 0;
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
  end; { Process3 }
