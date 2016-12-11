{Programul urmator realizeaza conversia unui numar
 natural din sistemul hexazecimal in cel zecimal}

Program conversia_hexa_zecimal;


var cifra: char;
    numar:0..maxlongint;
    val_cifra:byte;
    eroare:boolean;

begin
eroare:=false;
numar:=0;
val_cifra:=0;
write('Introduceti numarul in hexazecimal');
write('(cifre 0..9,A..F): ');
REPEAT
read (cifra);
case cifra of

    '0'..'9' : val_cifra:=ord(cifra)-ord('0');
    'A'..'F' : val_cifra:=ord(cifra)-ord('A')+10
    end;                                                                          
eroare:=Maxlongint div 16<numar;
if not eroare then numar:=numar*16+val_cifra;
until EOLN or eroare;
if eroare then writeln('Numarul depaseste ',Maxlongint)
          else writeln('Numarul in zecimal=',numar);
end.