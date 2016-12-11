Program DemoStr;
{ program demonstrativ pentru lucrul cu stringuri }
uses
  Crt;
var
  S1: String;
  S2: String[20];
  p: Integer;

Procedure WriteString(M, S: String);
  begin
    Write(M,': ');
    WriteLn(S);
    WriteLn('Lungimea stringului este: ', Length(S))
  end;

Procedure Demo1;
  begin
    WriteLn('Operatii simple pe stringuri');
    S2 := 'Unu';
    WriteString('Stringul S2', S2);
    S2 := 'Un string cu mai mult de 20 de caractere';
    WriteString('Stringul S2', S2);
    S1 := 'unu';
    WriteString('Stringul S1', S1);
    S2 := ' doi';
    WriteString('Stringul S2', S2);
    WriteString('Stringul S1 concatenat cu S2', S1+S2);
    WriteLn('S1 > S2:', S1 > S2);
    WriteLn('S1 = S2:', S1 = S2);
    WriteLn('S1 < S2:', S1 < S2);
    ReadLn
  end; { Demo1 }

Procedure Demo2;
  begin
    WriteLn('Functii standard Pascal de lucru pe stringuri');
    S1 := 'unu';
    WriteString('Stringul S1', S1);
    S2 := ' doi';
    WriteString('Stringul S2', S2);
    WriteString('Stringul S1 + S2', S1+S2);
    WriteString('Stringul Concat(S1, S2)', Concat(S1,S2));
    S1 := 'un string cu mai mult de 20 de caractere';
    WriteString('Stringul S1', S1);
    WriteString('Substringul din S1 incepand cu 12 si de lungime 18',
                 Copy(S1, 12, 18));
    WriteString('Substringul din S1 incepand cu 12 si de lungime 35',
                 Copy(S1, 12, 35));
    S2 := S1;
    WriteString('Stringul S2', S2);
    Delete(S2, 12, 8);
    WriteString('Sterge din S2 incepand cu 12 si de lungime 8', S2);
    p := Pos('cl', S2);
    if p > 0 then WriteLn('Stringul ', S2, ' contine stringul ''cl'' ',
                          'incepand de pe pozitia ', p)
    else WriteLn('Stringul ', S2, ' nu contine stringul ''cl'' ');
    ReadLn
  end; { Demo2 }

var
  optiune: byte;

begin
  Repeat
    ClrScr;
    WriteLn('DemoStr - program demonstrativ de lucru cu stringuri');
    WriteLn('1. Operatii simple pe stringuri');
    WriteLn('2. Functii standard Pascal de lucru pe stringuri');
    WriteLn('0. Terminarea programului');
    Write('Dati optiunea: ');
    ReadLn(optiune);
    Case optiune of
      1: Demo1;
      2: Demo2
    end
  Until optiune = 0
end. { DemoStr }
