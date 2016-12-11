Program TLStack;

Uses ULStack, UDecl, UGen;

var
  e: ElementStandard;
begin
  MemoDisp('Inceput');
  Creeaza;
  Afiseaza('Stiva');
  CreeazaElementStandard(1, 2, e);
  Push(e);
  Afiseaza('Stiva');
  CreeazaElementStandard(2, 3, e);
  Push(e);
  Afiseaza('Stiva');
  CreeazaElementStandard(3, 4, e);
  Push(e);
  Afiseaza('Stiva');
  Pop(e);
  Afiseaza('Stiva');
  Elibereaza;
  Afiseaza('Stiva');
  MemoDisp('Sfarsit');
End.
