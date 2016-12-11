Program Complexe;

Uses UComplex;

 var
   c, c1, c2: CComplex;
   a: Real;
 begin
   c1.Fa(1, 2);
   a := c1.ParteReala;
   WriteLn('Numarul c1 este: ', c1.ToString);
   c2.Fa(2, 1);
   WriteLn('Numarul c2 este: ', c2.ToString);
   c.Aduna(c1, c2);
   WriteLn('Suma lor este: ', c.ToString);
   c.Scade(c1, c2);
   WriteLn('Diferenta lor este: ', c.ToString);
   c.Inmulteste(c1, c2);
   WriteLn('Produsul lor este: ', c.ToString);
   WriteLn('Modulul produsului este: ', RealToString(c.Modul));
   c.Imparteste(c1, c2);
   WriteLn('Catul lor este: ', c.ToString);
   ReadLn
 end.
