Program EcGr2;

{ rezolva ecuatia de gradul II: a*x^2 + b*x + c = 0
  versiunea 2:
  modificari fata de versiunea 1
    DateCorecte se transforma din procedura in functie
    programul principal
}

uses Crt;

Procedure AfiseazaTitlu;
  begin
    ClrScr;
    WriteLn('Program pentru rezolvarea ecuatiei de gradul II: a*x^2 + b*x + c = 0')
  end; { AfiseazaTitlu }

Procedure CitesteDate(var a, b, c: Real);
  begin
    Write('Dati valoarea lui a: ');
    ReadLn(a);
    Write('Dati valoarea lui b: ');
    ReadLn(b);
    Write('Dati valoarea lui c: ');
    ReadLn(c);
  end; { CitesteDate }

Function DateCorecte(a: Real): Boolean;
  begin
    if a = 0 then
      DateCorecte := False
    else
      DateCorecte := True
  end; { DateCorecte }

Procedure Prelucreaza(a, b, c: Real;
                      var x1, x2: Real;
                      var cod: Byte);
  var      { variabile locale }
    delta, r: Real;

  begin
    delta := b * b - 4 * a * c;
    if delta > 0 then begin
      cod := 2;
      r := Sqrt(delta);
      x1 := (-b + r)/(a + a);
      x2 := (-b - r)/(a + a)
    end else if delta = 0 then begin
      cod := 3;
      x1 := -b/(a + a)
    end else begin          { delta < 0 }
      cod := 4;
      r := Sqrt(-delta);
      x1 := (-b)/(a + a);   { partea reala }
      x2 :=    r/(a + a)    { partea imaginara }
    end;
  end; { Prelucreaza }

Procedure AfiseazaRezultate(x1, x2: Real; cod: Byte);
  begin
    Case cod of
      1: WriteLn('Ecuatia nu este de gradul II');
      2: WriteLn('Radacini reale diferite: x1 = ', x1:7:2,
                                        ', x2=  ', x2:7:2);
      3: WriteLn('Radacini reale egale: x1 = x2 = ', x1:7:2);
      4: WriteLn('Radacini complexe: x1 = ', x1:7:2, '+ i*', x2:7:2,
                                  ', x2=  ', x1:7:2, '- i*', x2:7:2)
    end; { Case }
  end; { Afiseaza rezultate }

  Procedure Asteapta;
    var
      c: Char;
    begin
      Write('Apasati o tasta ...');
      c := ReadKey
    end; { Asteapta }

var                     { variabile globale }
   a, b, c,             { coeficientii ecuatiei }
   x1, x2: Real;        { solutia }
   cod: Byte;           { specifica urmatoarele:
                          cod = 1 - ecuatia nu este de gradul II (a = 0)
                          cod = 2 - radacini reale diferite (delta > 0)
                          cod = 3 - radacini reale egale    (delta = 0)
                          cod = 4 - radacini complexe       (delta < 0)
                        }

begin                   { programul principal }
  AfiseazaTitlu;
  CitesteDate(a, b, c);
  If DateCorecte(a)
    then Prelucreaza(a, b, c, x1, x2, cod)
    else cod := 1;
  AfiseazaRezultate(x1, x2, cod);
  Asteapta
end.
