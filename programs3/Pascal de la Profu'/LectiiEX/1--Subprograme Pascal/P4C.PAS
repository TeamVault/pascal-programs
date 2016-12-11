Program P4b;
{ Apelul unei proceduri din alta procedura }

  Uses
    Crt;
  Procedure Afiseaza_Titlu;
    begin
      ClrScr;
      WriteLn('P4c - apelul unei proceduri din alta procedura');
    end; { Afiseaza_Titlu }

  Procedure Unu;
    Begin
      Writeln('Aceasta este procedura Unu');
    End; { Unu }

  Procedure Doi;
    Procedure Unu;
      Begin
        Writeln('Aceasta este procedura Unu din Doi');
      End; { Unu }
    Begin { Doi }
      Unu; { apelul procedurii locale Unu }
      Writeln('Aceasta este procedura Doi');
    End; { Doi }

  Procedure Trei;
    Procedure Doi;
      Procedure Unu;
        Begin
          Writeln('Aceasta este procedura Unu din Doi din Trei');
        End; { Unu }
      Begin { Doi }
         Unu; { apelul procedurii locale Unu }
         Writeln('Aceasta este procedura Doi din Trei');
      End; { Doi }
    Begin { Trei }
       Doi; { apelul procedurii locale Doi }
       Writeln('Aceasta este procedura Trei');
    End; { Trei }

  Procedure Scrie_Sfarsit;
    Begin
      Writeln('Programul s-a terminat');
      ReadLn
    End; { Scrie_Sfarsit }

  begin  { Programul principal }
    Afiseaza_Titlu;
    Unu;
    Writeln;
    Doi;
    Writeln;
    Trei;
    Scrie_Sfarsit
  end.   { P4c }
