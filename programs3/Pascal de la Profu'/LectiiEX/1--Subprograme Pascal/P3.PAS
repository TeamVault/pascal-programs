Program P3;
{ Domeniul de vizibilitate al variabilelor - variabile locale si globale }

  Uses
    Crt;
  Var
    Contor : Integer; { globala }
    Indice : Integer; { globala }

  Procedure Afiseaza_Titlu;
    begin
      ClrScr;
      WriteLn('P3 - Domeniu de vizibilitate, variabile globale si locale');
    end; { Afiseaza_Titlu }

  Procedure Afiseaza_Date;
    Var
      Contor,           { locala }
      Alta : Integer;   { locala }
    Begin
      Contor := 7;
      Writeln('In Afiseaza_Date Contor =', Contor:5,
                             '  Indice =',Indice:5);
    End; { Afiseaza_Date }

  Procedure Scrie_Sfarsit;
    Begin
       Writeln('Programul s-a terminat');
       ReadLn
    End; { Scrie_Sfarsit }

  Begin   { Programul principal P3}
    Afiseaza_Titlu;
    For Indice := 1 to 3 do Begin
      Contor := Indice;
      Writeln('In programul principal Contor =',Contor:5,
                                   '  Indice =',Indice:5);
      Afiseaza_Date;
      Writeln('In programul principal Contor =',Contor:5,
                                   '  Indice =',Indice:5);
      Writeln;
    End; { For }
    Scrie_Sfarsit
  End. { Programul P3 }
