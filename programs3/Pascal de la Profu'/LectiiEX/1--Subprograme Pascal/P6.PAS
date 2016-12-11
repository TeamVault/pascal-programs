program P6;
{ Functii recursive }
  Uses Crt;

  Procedure Afiseaza_Titlu;
    Begin
      ClrScr;
      WriteLn('Program care determina CMMDC a doua numere');
    End; { AfiseazaTitlu }

  Function CMMDC_Rec(a, b: LongInt): LongInt;
  { determina cmmdc al numerelor a si b folosind formula:
    cmmdc(a, b) = cmmdc(b, a mod b) daca b <> 0
                = a                 daca b = 0
    Preconditie: a > b > 0
  }
    Begin
      WriteLn('CMMDC(',a:11, ',', b:11, ')=');
      If b = 0
	  then CMMDC_Rec := a
        else CMMDC_Rec := CMMDC_Rec(b, a mod b);
    End; { CMMDC_Rec }

  Procedure Scrie_Sfarsit;
    Begin
       Writeln('Programul s-a terminat');
       ReadLn
    End; { Scrie_Sfarsit }

  Var
    Numar1: LongInt;   { primul numar citit }
    Numar2: LongInt;   { al doilea numar citit }

  Begin   { Programul principal }
    Afiseaza_Titlu;
    Write('Introduceti primul numar: ');
    ReadLn(Numar1);
    Write('Introduceti al doilea numar: ');
    ReadLn(Numar2);
    If Numar1 >= Numar2
      Then WriteLn(CMMDC_Rec(Numar1, Numar2))
    	Else WriteLn(CMMDC_Rec(Numar2, Numar1));
    Scrie_Sfarsit
  End. { P6 }
