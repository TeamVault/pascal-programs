Program TUCList;

Uses UCList, UDecl, UGen;

var
  e: ElementStandard;
  f: Boolean;
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
  Urmatorul(f);
  Afiseaza('Lista');
  Sterge;
  Afiseaza('Lista');
  Elibereaza;
  Afiseaza('Lista');
  MemoDisp('Sfarsit');
End.
