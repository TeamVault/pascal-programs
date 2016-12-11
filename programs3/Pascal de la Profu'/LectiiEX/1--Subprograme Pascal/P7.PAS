program P7;
{ Proceduri mutual recursive }
  Uses Crt;

  Procedure Afiseaza_Titlu;
    Begin
      ClrScr;
      WriteLn('Apel recursiv - proceduri mutual recursive');
    End; { AfiseazaTitlu }

  Procedure Scrie_O_Linie(var Contor : Integer); Forward;

  Procedure Micsoreaza(var Indice : Integer);
    Begin
      Indice := Indice - 1;
      If Indice > 0 Then
         Scrie_O_Linie(Indice);
    End; { Micsoreaza }

  Procedure Scrie_O_Linie(var Contor : Integer);
    begin
       Writeln('Valoarea contorului este acum ',Contor:4);
       Micsoreaza(Contor);
    end; { Scrie_O_Linie }

  Procedure Scrie_Sfarsit;
    Begin
       Writeln('Programul s-a terminat');
       ReadLn
    End; { Scrie_Sfarsit }

  Var
    De_Cate_Ori : integer;

  Begin  { programul principal }
    Afiseaza_Titlu;
    De_Cate_Ori := 7;
    WriteLn('Apelez Micsoreaza');
    Micsoreaza(De_Cate_Ori);
    Writeln;
    De_Cate_Ori := 7;
    WriteLn('Apelez Scrie_O_Linie');
    Scrie_O_Linie(De_Cate_Ori);
    Scrie_Sfarsit
  End.  { P7 }
