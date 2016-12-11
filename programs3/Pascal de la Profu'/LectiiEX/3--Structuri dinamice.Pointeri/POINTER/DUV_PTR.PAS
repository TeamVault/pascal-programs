Program DuV_Ptr;
{ program demonstrativ pentru durata de viata a variabilelor dinamice }

Type
  PInteger = ^Integer;

  function CitesteIntreg(M: String): PInteger;
    var
      p: PInteger;
    begin
      New(p);               { alocarea lui p^ se face aici }
      Write(M);
      ReadLn(p^);
      WriteLn('S-a citit numarul: ', p^);
      CitesteIntreg := p
    end; { CitesteIntreg }  { DoV al lui p se termina aici }
                            { DuV a lui p^ inca nu s-a terminat }
var
  a: PInteger;

begin
  { a^ si p^ din CitesteIntreg sunt aceeasi variabila dinamica }
  a := CitesteIntreg('Dati un intreg: '); { atribuire de pointer }
  WriteLn('Valoarea variabilei dinamice referite de a este: ', a^);
  Dispose(a);               { DuV a lui a^ s-a terminat }
  a := Nil;                 { initializeaza pe a cu Nil }
  WriteLn('Valoarea variabilei dinamice referite de a este: ', a^);
  ReadLn
end. {DuV_Ptr }