Program P4a;
{ Apelul unei proceduri din alta procedura }

  Uses
    Crt;
  Procedure Afiseaza_Titlu;
    begin
      ClrScr;
      WriteLn('P4a - apelul unei proceduri din alta procedura');
    end; { Afiseaza_Titlu }

  Procedure Unu;
    Begin
      Writeln('Aceasta este procedura Unu');
    End; { Unu }

  Procedure Doi;
    Begin
      Unu;
      Writeln('Aceasta este procedura Doi');
    End; { Doi }

  Procedure Trei;
    Begin
      Doi;
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
  end.   { P4a }
