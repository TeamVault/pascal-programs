Program PtrDemo1;
{ program demonstrativ pentru semantica atribuirii in
  lucrul cu pointeri }

Uses Crt;
{ declaratii de tipuri pointer }
type
  PInteger = ^Integer;  { variabilele de tip PInteger vor fi pointeri la
                          intregi, adica vor contine adresa unor
                          variabile de tip Integer }
  TVector = Array[1..10] of Real;
  PVector = ^TVector;   { TVector a fost definit inainte de PVector }
  PMatrice = ^TMatrice; { TMatrice este definit dupa }
  TMatrice = Array[1..5, 1..10] of Integer;

{ declaratii de variabile de tipurile de mai sus }

var
  pi1, pi2: PInteger;
  pi3, pi4: PInteger;
  v: PVector;
  m: PMatrice;
  i: Integer;

Procedure Demo1;
begin
  i := 5;
  pi3^ := i;                      { atribuire de valori }
  pi4^ := pi3^;
  WriteLn('Atribuirea: i := 5');
  WriteLn('Atribuirea: pi3^ := i');
  WriteLn('Atribuirea: pi4^ := pi3^');
  WriteLn('Variabila globala i are valoarea: ', i);
  WriteLn('Variabila dinamica referita de pi3 are valoarea: ', pi3^);
  WriteLn('Variabila dinamica referita de pi4 are valoarea: ', pi4^);
end; { Demo1 }

Procedure Demo2;
begin
  i := 5;
  pi3^ := i;                      { atribuire de valori }
  pi4^ := pi3^;
  pi4 := pi3;                     { atribuire de pointeri }
  { pi4 si pi3 refera acum aceeasi variabila dinamica }
  WriteLn('Atribuirea: i := 5');
  WriteLn('Atribuirea: pi3^ := i');
  WriteLn('Atribuirea: pi4^ := 0');
  WriteLn('Atribuirea: pi4 := pi3');
  WriteLn('Variabila globala i are valoarea: ', i);
  WriteLn('Variabila dinamica referita de pi3 are valoarea: ', pi3^);
  WriteLn('Variabila dinamica referita de pi4 are valoarea: ', pi4^);
  WriteLn('Expresia pi3 = pi4 are valoarea: ', pi3 = pi4);
  WriteLn;
end; { Demo2 }

Procedure Demo3;
begin
  i := 5;
  pi3^ := i;
  pi4^ := 0;
  pi4 := pi3;   { atribuire de pointeri }
  pi3^ := 7;    { atribuire de valori }
  { variabila dinamica referita de pi3 primeste valoarea 7 }
  WriteLn('Atribuirea: i := 5');
  WriteLn('Atribuirea: pi3^ := i');
  WriteLn('Atribuirea: pi4^ := 0');
  WriteLn('Atribuirea: pi4 := pi3');
  WriteLn('Atribuirea: pi3^ := 7');
  WriteLn('Variabila dinamica referita de pi3 are valoarea: ', pi3^);
  WriteLn('Variabila dinamica referita de pi4 are valoarea: ', pi4^);
  WriteLn('Expresia pi3 = pi4 are valoarea: ', pi3 = pi4);
  WriteLn;
end;

Procedure Demo4;
begin
  i := 5;
  pi3^ := i;
  pi4^ := 0;
  pi4 := pi3;      { atribuire de pointeri }
  pi3^ := 7;       { atribuire de valori }
  pi3 := Addr(i);  { atribuire de pointeri }
  WriteLn('Atribuirea: i := 5');
  WriteLn('Atribuirea: pi3^ := i');
  WriteLn('Atribuirea: pi4^ := 0');
  WriteLn('Atribuirea: pi4 := pi3');
  WriteLn('Atribuirea: pi3^ := 7');
  WriteLn('Atribuirea: pi3 := Addr(i)');
  WriteLn('Variabila globala i are valoarea: ', i);
  WriteLn('Variabila dinamica referita de pi3 are valoarea: ', pi3^);
  WriteLn('Variabila dinamica referita de pi4 are valoarea: ', pi4^);
  WriteLn('Expresia pi3 = pi4 are valoarea: ', pi3 = pi4);
end; { Demo4 }

var
  rasp: Byte;
begin
  Repeat
    ClrScr;
    WriteLn('PTRDEMO1 - declaratii, atribuiri de pointeri, atribuiri de valori');
    WriteLn('Optiuni:');
    WriteLn('1. Atribuire de valori');
    WriteLn('2. Atribuire de pointeri');
    WriteLn('3. Modificarea valorii unei variabile prin pointer');
    WriteLn('4. Exemplu complex');
    WriteLn('0. Terminare');
    WriteLn;
    Write('Selectati optiunea: ');
    ReadLn(rasp);
    Case rasp of
      1:   Demo1;
      2:   Demo2;
      3:   Demo3;
      4:   Demo4;
      0:   Break
    End;
    ReadLn
  Until rasp = 0
end.
