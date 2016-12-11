Program P2a;

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
      WriteLn('P2a - folosirea procedurilor cu parametri de intrare');
    end; { Afiseaza_Titlu }

  Procedure Scrie_Sfarsit;
    begin
      WriteLn('Programul s-a terminat');
      ReadLn
    end; { Scrie_Sfarsit }

  Procedure ScrieSuma(A, B, C: Integer);
    Var
      S: Integer;
    Begin
      S := A + B + C;
      WriteLn('Suma numerelor este', S:4);
      { schimba valorile parametrilor de intrare }
      A := 0;
      B := 0;
      C := 0
    End; {ScrieSuma}
  Var
    N1, N2, N3: Integer;
  Begin {programul principal}
    { apelul unei proceduri fara parametri }
    Afiseaza_Titlu;
    N1 := 12;
    N2 := 23;
    N3 := 34;
    WriteLn('Se aduna numerele: ', N1:3, N2:3, N3:3);
    { apelul unei proceduri cu parametri de intrare }
    ScrieSuma(N1, N2, N3);
    { verificam daca s-au modificat parametrii de intrare }
    WriteLn('S-au adunat numerele: ', N1:3, N2:3, N3:3);
    { apelul unei proceduri fara parametri }
    Scrie_Sfarsit
  End. { P2a }
