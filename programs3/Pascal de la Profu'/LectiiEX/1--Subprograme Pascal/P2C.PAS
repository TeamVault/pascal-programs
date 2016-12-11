Program P2c;

 { foloseste:
    - unit-ul Crt;
    - o procedura locala fara parametri, Afiseaza_Titlu
    - o functie locala cu parametri de intrare, ScrieSuma
    - o procedura locala fara parametri, Scrie_Sfarsit
 }

Uses
  Crt;

  Procedure Afiseaza_Titlu;
    begin
      ClrScr;
      WriteLn('P2c - folosirea procedurilor si functiilor');
    end; { Afiseaza_Titlu }

  Procedure Scrie_Sfarsit;
    begin
      WriteLn('Programul s-a terminat');
      ReadLn
    end; { Scrie_Sfarsit }

  Function CalculSuma(A, B, C: Integer): Integer;
    Begin
      CalculSuma := A + B + C;
      { schimba valorile parametrilor de intrare }
      A := 0;
      B := 0;
      C := 0
    End; {CalculSuma}
  Var
    N1, N2, N3: Integer;
  Begin {programul principal}
    { apelul unei proceduri fara parametri }
    Afiseaza_Titlu;
    N1 := 12;
    N2 := 23;
    N3 := 34;
    WriteLn('Se aduna numerele: ', N1:3, N2:3, N3:3);
    { apelul unei functii cu parametri de intrare si de iesire }
    WriteLn('Suma numerelor este', CalculSuma(N1, N2, N3):4);
    { verificam daca s-au modificat parametrii de intrare }
    WriteLn('S-au adunat numerele: ', N1:3, N2:3, N3:3);
    { apelul unei proceduri fara parametri }
    Scrie_Sfarsit
  End. { P2c }
