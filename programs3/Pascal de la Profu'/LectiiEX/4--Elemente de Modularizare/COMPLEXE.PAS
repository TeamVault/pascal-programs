Program Complexe;

Uses UComplex;

 var
   c, c1, c2: TComplex;
 begin
   FaComplex(1, 2, c1);
   WriteLn('Numarul c1 este: ', ComplexToString(c1));
   FaComplex(2, 1, c2);
   WriteLn('Numarul c2 este: ', ComplexToString(c2));
   Aduna(c1, c2, c);
   WriteLn('Suma lor este: ', ComplexToString(c));
   Scade(c1, c2, c);
   WriteLn('Diferenta lor este: ', ComplexToString(c));
   Inmulteste(c1, c2, c);
   WriteLn('Produsul lor este: ', ComplexToString(c));
   WriteLn('Modulul produsului este: ', RealToString(Modul(c)));
   Imparteste(c1, c2, c);
   WriteLn('Catul lor este: ', ComplexToString(c));
   ReadLn
 end.