Program DemoCst;
{ program demonstrativ pentru constante }

Uses
  Crt;
Const
  Alfa = 2.14;  { constanta reala cu numele Alfa si valoarea 2.14 }
  Nume = 'INTREGI.DAT';  { constanta sir de caractere cu numele Nume
                           si valoarea 'INTREGI.DAT' }
  CR = #13;     { constanta caracter cu numele CR si valoarea
                  egala cu caracterul ASCII cu codul 13 - Carriage Return }
  Hexa15 = $F;  { constanta intreaga cu numele Hexa15 si valoarea 15 in
                  zecimal }
  LiniiPePagina = 60; { constanta intreaga cu numele LiniiPePagina si
                        valoarea asociata 60 }
var
  I: Integer;  { intreg pe 2 octeti: are domeniul -32768..32767 }
  L: LongInt;  { intreg pe 4 octeti: are domeniul -2147483648..2147483647 }
  R: Real;     { real pe 6 octeti: are domeniul 2.9e-39..1.7e38 }
  E: Extended; { real pe 10 octeti: are domeniul 3.4e-4932..1.1e4932 }
  C: Char;     { caracter: are domeniul #0..#255 }
  S: String;   { sir de caractere }
  B: Boolean;  { boolean: are domeniul True, False }

begin
  ClrScr;
  WriteLn('DEMOCST - program demonstrativ pentru lucrul cu constante');
  
{ constante intregi }
  I := 15846;
{ I := 10000000;     { mesaj de eroare: constant out of range }
  L := 10000000;
{ I := -10000000;    { mesaj de eroare: constant out of range }
  L := -10000000;
  I := $FF;
  I := $100;
{ I := $10000;       { mesaj de eroare: constant out of range }
  L := $10000;

{ constante reale }
  R := 14;           { corect; lipseste partea fractionara si punctul }
  R := 14.;          { corect: lipseste partea fractionara }
  R := 14.0;         { corect: partea fractionara este 0 }
  R := 0;            { corect: partea intreaga si partea fractionara 0 }
{ R := .0;           { incorect: partea intreaga trebuie sa apara }
  R := -0;           { corect: partea fractionara este 0 }
  R := MaxInt;       { corect: se face automat conversia
                       de la intreg la real }
{ R := 12.23.4;      { mesaj de eroare: invalid qualifier }
{ R := 14E66;        { mesaj de eroare: constant out of range }
  E := 14E66;        { corect: notatie exponentiala sau stiintifica }
  E := -15677E-56;   { corect: notatie exponentiala sau stiintifica }

{ constante siruri de caractere }
  S := '';           { sirul de caractere vid }
  S := 'sir de caractere;';
  S := 'm''am dus acasa';
  Writeln(S);        { daca-l afisam, unul dintre apostroafe dispare }
  S := ' ';          { spatiu }
  { sir de caractere prea lung: mesajul de eroare este 'line too long'
    cursorul se opreste acolo unde deja lungimea depaseste 255
       '0         0         0         0         0         0         0         0         0         0         1
       '0         1         2         3         4         5         6         7         8         9         0}
  S := '01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890' +
        '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890' +
        '12345678901234567890123456789012345678901234567890123456789';
  WriteLn(S);    { s se trunchiaza la 255 de caractere }

{ constante caracter }
  C := #32;      { spatiul are codul ASCII 32 }
  C := ' ';      { la fel }
  C := 'a';      { litera a mic }
  C := 'A';      { litera A mare }
  C := #13;      { caracterul special Carriage Return }
  Write('inainte de scrierea lui Carriage Return');
  Write(C);
  C := #10;      { caracterul special Line Feed }
  Write('inainte de scrierea lui Line Feed');
  Write(C);
  C := #9;      { caracterul special Tab }
  Write('inainte de scrierea lui Tab');
  Write(C);
  Write('dupa scrierea lui Tab');
  ReadLn
end. { DemoCst }
