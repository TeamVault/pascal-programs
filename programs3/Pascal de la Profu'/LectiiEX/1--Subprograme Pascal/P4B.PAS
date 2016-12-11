Program P4b;
{ Apelul unei proceduri din alta procedura }

  Uses
    Crt;
  Procedure Afiseaza_Titlu;
    begin
      ClrScr;
      WriteLn('P4b - apelul unei proceduri din alta procedura');
    end; { Afiseaza_Titlu }

  Procedure Unu;
    Procedure Doi;     { este locala in Unu }
      Begin
        Writeln('Aceasta este procedura Doi din Unu');
      End; { Doi }

    Begin { Unu }
      Writeln('Aceasta este procedura Unu');
      Doi;   { corect! Doi este locala in Unu }
    End; { Unu }

  Procedure Trei;
    Begin
      Doi;     { eroare de compilare: Identificator necunoscut }
      Writeln('Aceasta este procedura Trei');
    End; { Trei }

  Procedure Scrie_Sfarsit;
    Begin
      Writeln('Programul s-a terminat');
      WriteLn
    End; { Scrie_Sfarsit }

  begin  { Programul principal }
    Afiseaza_Titlu;
    Unu;
    Writeln;
    Doi;      { eroare de compilare: Identificator necunoscut }
    Writeln;
    Trei;     { nu se poate compila Trei }
    Scrie_Sfarsit
  end.   { P4b }
