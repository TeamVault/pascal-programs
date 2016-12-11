program P5;
{ Proceduri recursive }
  Uses Crt;

  Procedure Afiseaza_Titlu;
    Begin
      ClrScr;
      WriteLn('Program care foloseste o procedura recursiva');
    End; { AfiseazaTitlu }

  Procedure Afiseaza_Si_Micsoreaza(Indice : integer);
    Begin
      Writeln('Valoarea indicelui este ',Indice:3);
      Indice := Indice - 1;
      If Indice > 0 Then
         Afiseaza_Si_Micsoreaza(Indice);
    End; { Afiseaza_Si_Micsoreaza }

  Procedure Scrie_Sfarsit;
    Begin
       Writeln('Programul s-a terminat');
       ReadLn
    End; { Scrie_Sfarsit }

  Var
    Contor: Integer;

  Begin  { programul principal }
    Afiseaza_Titlu;
    Contor := 7;
    Afiseaza_Si_Micsoreaza(Contor);
    Scrie_Sfarsit
  End.  { P5 }
