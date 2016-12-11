program P8a;
{ Tipuri procedurale }
  Uses Crt;

{$F+} { Aceasta directiva forteaza apelurile far si este necesara
        cand dorim sa lucram cu tipuri procedurale in Turbo Pascal }

Type
  Op_Aritm = Procedure(a, b, c : Integer;
                       var r   : Integer); { tip procedural }

  Procedure Afiseaza_Titlu;
    Begin
      ClrScr;
      WriteLn('Program care foloseste tipuri procedurale si');
      WriteLn('efectueaza operatii aritmetice cu trei numere')
    End; { AfiseazaTitlu }

   Procedure Adunare(In1, In2, In3: Integer;
                     var Rezultat : Integer);
     Begin
        Rezultat := In1 + In2 + In3;
        Writeln('Suma numerelor este     ', Rezultat:6);
     End; { Adunare }

   Procedure Inmultire(In1, In2, In3: Integer;
                       var Rezultat : Integer);
     Begin
        Rezultat := In1 * In2 * In3;
        Writeln('Produsul numerelor este ', Rezultat:6);
     End; { Inmultire }

   Procedure Medie(In1, In2, In3: Integer;
                   var Rezultat : Integer);
     Begin
        Rezultat := (In1 + In2 + In3) div 3;
        Writeln('Media numerelor este    ', Rezultat:6);
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
    Operatie(Numar1, Numar2, Numar3, Rezultat_Final);

    Operatie := Inmultire;
    Operatie(Numar1, Numar2, Numar3, Rezultat_Final);

    Operatie := Medie;
    Operatie(Numar1, Numar2, Numar3, Rezultat_Final);

    Scrie_Sfarsit
  end.  { P8a }
