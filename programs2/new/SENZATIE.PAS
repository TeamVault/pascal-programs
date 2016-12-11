      Program calculariecerc;
{ programul demonstreaza posibilitatile bibliotecilor CRT }
uses crt;
const pi=3.1415926; var raza, aria: Real;nr:integer;
begin
TextBackground(lightblue+182); Clrscr;
Gotoxy (28,12);textcolor (4) ;writeln ('Calcul Arie Cerc');
delay(1000);
textcolor(yellow);
gotoxy(28,13);textbackground(blue);
write ('Dati raza : ');
readln (raza);
sound(700);
delay(2000);sound(600);delay(100);nosound;
aria:=pi*sqr(raza);
TextBackground(magenta); Textcolor(white);
gotoxy(28,14);delay(3000);
writeln('aria este ',aria:7:3); delay (500);
sound(400);
delay(200);nosound ;
textbackground (00);
textcolor (02);
Repeat
gotoxy(28,15);writeln('tastai nr 0 pt. a iesi');read (nr);
until nr=0;
end.







