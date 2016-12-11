Program TUList;

Uses UList, UDecl, UGen;

var
  e: ElementStandard;
begin
  MemoDisp('Inceput');
  Creeaza;
  Afiseaza('Lista');
  CreeazaElementStandard(1, 2, e);
  Insereaza(e);
  Afiseaza('Lista');
  CreeazaElementStandard(2, 3, e);
  Insereaza(e);
  Afiseaza('Lista');
  CreeazaElementStandard(3, 4, e);
  Insereaza(e);
  Afiseaza('Lista');
  Primul;
  Afiseaza('Lista');
  Elibereaza;
  Afiseaza('Lista');
  MemoDisp('Sfarsit');
End.
