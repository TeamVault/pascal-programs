Program ComplexP;

Uses
  Crt, UCompl_P;

 var
   c, c1, c2: PComplex;
   i: Integer;
 begin
   i := 0;
   Repeat
     i := i + 1;
     ClrScr;
     WriteLn('ComplexP - demo pentru unit-ul UCompl_P');
     WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
     c1 := FaComplex(1, 2);
     WriteLn('Numarul c1 este: ', ComplexToString(c1));
     c2 := FaComplex(2, 1);
     WriteLn('Numarul c2 este: ', ComplexToString(c2));
     c := Aduna(c1, c2);
     WriteLn('Suma lor este: ', ComplexToString(c));
     Dispose(c);                                     { dealoca pe c^ }
     c := Scade(c1, c2);
     WriteLn('Diferenta lor este: ', ComplexToString(c));
     Dispose(c);                                     { dealoca pe c^ }
     c := Inmulteste(c1, c2);
     WriteLn('Produsul lor este: ', ComplexToString(c));
     WriteLn('Modulul produsului este: ', RealToString(Modul(c)));
     Dispose(c);                                     { dealoca pe c^ }
     c := Imparteste(c1, c2);
     WriteLn('Catul lor este: ', ComplexToString(c));
  {   Dispose(c);                                     { dealoca pe c^ }
     Dispose(c1);                                    { dealoca pe c1^ }
     Dispose(c2);                                    { dealoca pe c2^ }
     WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
     ReadLn
   Until i = 3;
 end.