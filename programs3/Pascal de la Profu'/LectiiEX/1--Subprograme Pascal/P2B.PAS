Program P2b;

 { foloseste:
    - unit-ul Crt;
    - o procedura locala fara parametri, Afiseaza_Titlu
    - o procedura locala cu parametri de intrare, ScrieSuma
    - o procedura locala fara parametri, Scrie_Sfarsit
 }

Uses
  Crt;

  Procedure Afiseaza_Titlu;
    begin
      ClrScr;
      WriteLn('P2b - folosirea procedurilor cu parametri de intrare si de iesire');
    end; { Afiseaza_Titlu }

  Procedure Scrie_Sfarsit;
    begin
      WriteLn('Programul s-a terminat');
      ReadLn
    end; { Scrie_Sfarsit }

  Procedure CalculSuma(A, B, C: Integer; var S: Integer);
    Begin
      S := A + B + C;
      { schimba valorile parametrilor de intrare }
      A := 0;
      B := 0;
      C := 0
    End; {CalculSuma}
  Var
    N1, N2, N3, Suma: Integer;
  Begin {programul principal}
    { apelul unei proceduri fara parametri }
    Afiseaza_Titlu;
    N1 := 12;
    N2 := 23;
    N3 := 34;
    WriteLn('Se aduna numerele: ', N1:3, N2:3, N3:3);
    { apelul unei proceduri cu parametri de intrare si de iesire }
    CalculSuma(N1, N2, N3, Suma);
    WriteLn('Suma numerelor este', Suma:4);
    { verificam daca s-au modificat parametrii de intrare }
    WriteLn('S-au adunat numerele: ', N1:3, N2:3, N3:3);
    { apelul unei proceduri fara parametri }
    Scrie_Sfarsit
  End. { P2b }
