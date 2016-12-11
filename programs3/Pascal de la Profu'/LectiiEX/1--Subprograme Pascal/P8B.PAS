program P8b;
{ Tipuri functionale }
  Uses Crt;

{$F+} { Aceasta directiva forteaza apelurile far si este necesara
        cand dorim sa lucram cu tipuri procedurale sau functionale
        in Turbo Pascal }

Type
  Op_Aritm = Function(a, b, c : integer): Integer;

  Procedure Afiseaza_Titlu;
    Begin
      ClrScr;
      WriteLn('Program care foloseste tipuri functionale si');
      WriteLn('efectueaza operatii aritmetice cu trei numere')
    End; { AfiseazaTitlu }

   Function Adunare(In1, In2, In3: Integer): Integer;
     Var
       R: Integer;
     Begin
        R := In1 + In2 + In3;
        Writeln('Suma numerelor este     ', R:6);
        Adunare := R
     End; { Adunare }

   Function Inmultire(In1, In2, In3: Integer): Integer;
     Var
       R: Integer;
     Begin
        R := In1 * In2 * In3;
        Writeln('Produsul numerelor este ', R:6);
        Inmultire := R
     End; { Inmultire }

   Function Medie(In1, In2, In3: Integer): Integer;
     Var
       R: Integer;
     Begin
        R := (In1 + In2 + In3) div 3;
        Writeln('Media numerelor este    ', R:6);
        Medie := R
     End; { Medie }

  Procedure Scrie_Sfarsit;
    Begin
       Writeln('Programul s-a terminat');
       ReadLn
    End; { Scrie_Sfarsit }

  Var
    Numar1, Numar2, Numar3: Integer;
    Rezultat_Final: Integer;
    Operatie: Op_Aritm;

  Begin { Programul principal }

    Afiseaza_Titlu;
    Write('Introduceti primul numar: ');
    ReadLn(Numar1);
    Write('Introduceti al doilea numar: ');
    ReadLn(Numar2);
    Write('Introduceti al treilea numar: ');
    ReadLn(Numar3);

    Operatie := Adunare;
    Rezultat_Final := Operatie(Numar1, Numar2, Numar3);

    Operatie := Inmultire;
    Rezultat_Final := Operatie(Numar1, Numar2, Numar3);

    Operatie := Medie;
    Rezultat_Final := Operatie(Numar1, Numar2, Numar3);

    Scrie_Sfarsit
  end.  { P8b }