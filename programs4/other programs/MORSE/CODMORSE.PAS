{   Alfabet fonetic ICAO
A   Alpha  N   November
B   Bravo  O   Oscar
C   Charlie  P   Papa
D   Delta  Q   Quebec
E   Echo  R   Romeo
F   Foxtrot  S   Sierra
G   Golf  T   Tango
H   Hotel  U   Uniform
I   India  V   Victor
J   Juliet  W   Whiskey
K   Kilo  X   X-ray
L   Lima  Y   Yankee
M   Mike  Z   Zulu

   Codul Morse
A  .-     N  -.     0  -----
B  -...     O  ---     1  .----
C  -.-.     P  .--.     2  ..---
D  -..     Q  --.-     3  ...--
E  .     R  .-.     4  ....-
F  ..-.     S  ...     5  .....
G  --.     T  -     6  -....
H  ....     U  ..-     7  --...
I  ..     V  ...-     8  ---..
J  .---     W  .--     9  ----.
K  -.-     X  -..-
L  .-..     Y  -.--
M  --     Z  --..

Full-stop (period)  .-.-.-
Comma  --..--
Colon  ---...
Question mark  ..--..
Apostrophe  .----.
Hyphen  -....-
Fraction bar  -..-.
Brackets  -.--.-

Daca durata unui punct este o unitate de timp, atunci durata unei linii este de trei unitati. Pauza dintre componentele unui caracter este de o unitate, intre caractere de trei unitati si intre cuvinte de sapte unitati. Pentru a indica ca s-a facut o greseala si ca ultimul cuvant nu trebuie luat in considerare,trebuie transmise ........ (8 puncte)

                             }

   program cod_morse;
   uses crt;
   type vec=record
           cod:string;
           carac:char;
           end;
    var v:array[1..46] of vec;
        i,j:integer;
        s:string;
        f:text;
   procedure trans_cod_morse1;
      begin
   for i:=1 to length(s) do
        begin
   for j:=1 to 46 do
    if s[i]=v[j].carac  then
    write('   ',v[j].cod);
        end;
   end;
      procedure trans_cod_morse2;
      begin
   for i:=1 to length(s) do
        begin
   for j:=1 to 46 do
    if s[i]=v[j].carac  then
    write(f,'    ',v[j].cod);
        end;  WRITELN(F,' ');
   end;
   procedure citire;
   begin
 v[1].carac:='A'; v[1].cod:='.-';
 v[2].carac:='B';v[2].cod:='-...';
 v[3].carac:='C';v[3].cod:='-.-.';
 v[4].carac:='D';v[4].cod:='-..';
 v[5].carac:='E';v[5].cod:='.';
 v[6].carac:='F';v[6].cod:='..-.';
 v[7].carac:='G';v[7].cod:='--.';
 v[8].carac:='H';v[8].cod:='....';
 v[9].carac:='I';v[9].cod:='..';
 v[10].carac:='J';v[10].cod:='.---';
 v[11].carac:='K';v[11].cod:='-.-';
 v[12].carac:='L';v[12].cod:='.-..';
 v[13].carac:='M';v[13].cod:='--';
 v[14].carac:='N';v[14].cod:='-.';
 v[15].carac:='O';v[15].cod:='---';
 v[16].carac:='P';v[16].cod:='.--.';
 v[17].carac:='Q';v[17].cod:='--.-';
 v[18].carac:='R';v[18].cod:='.-.';
 v[19].carac:='S';v[19].cod:='...';
 v[20].carac:='T';v[20].cod:='-';
 v[21].carac:='U';v[21].cod:='..-';
 v[22].carac:='V';v[22].cod:='...-';
 v[23].carac:='W';v[23].cod:='.--';
 v[24].carac:='X';v[24].cod:='-..-';
 v[25].carac:='Y';v[25].cod:='-.--';
 v[26].carac:='Z';v[26].cod:='--..';
 v[27].carac:='0';v[27].cod:='-----';
 v[28].carac:='1';v[28].cod:='.----';
 v[29].carac:='2';v[29].cod:='..---';
 v[30].carac:='3';v[30].cod:='...--';
 v[31].carac:='4';v[31].cod:='....-';
 v[32].carac:='5';v[32].cod:='.....';
 v[33].carac:='6';v[33].cod:='-....';
 v[35].carac:='7';v[34].cod:='--...';
 v[34].carac:='8';v[35].cod:='---..';
 v[36].carac:='9';v[36].cod:='----.';
 v[37].carac:='.';v[37].cod:='.-.-.-';
 v[38].carac:=',';v[38].cod:='--..--';
 v[39].carac:=':';v[39].cod:='---...';
 v[40].carac:='?';v[40].cod:='..--..';
 v[41].carac:=chr(41);v[1].cod:='.----.';
 v[42].carac:='-';v[42].cod:='-....-';
 v[43].carac:='/';v[43].cod:='-..-.';
 v[44].carac:=chr(40);v[44].cod:='-.--.-';
 v[45].carac:=chr(41);v[45].cod:='-.--.-';
 v[46].carac:=' ';v[46].cod:='    ';
end;
   begin
      citire;    textbackground(BLUE);
      write('Codul Morse');
   for i:=1 to 46 do
       begin  textbackground(BLUE);
   writeln(v[i].carac,'       ',v[i].cod);
       end;READLN;clrscr;
   TEXTCOLOR(GREEN);WRITEln('Va rog itroduceti litere mari!!!');
   writeln('Dati caractele pe care  doriti sa le transformati in cod morse');
   readln(s);  trans_cod_morse1;
readln;
 ASSIGN(F,'paul.doc');rewrite(f);
 writeln(f,'Textul tastat:',s);WRITEln(F,'Codul morse aferent textului:');
  trans_cod_morse2;
  writeln(f,'Codul morse');
     for i:=1 to 46 do
       begin
   writeln(f,v[i].carac,'       ',v[i].cod);
       end;READLN;close(f);
   end.