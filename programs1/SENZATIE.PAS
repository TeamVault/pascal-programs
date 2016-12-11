      Program calculariecerc;
{ programul demonstreaza posibilitatile bibliotecilor CRT }
uses crt;
const pi=3.1415926; var raza, aria: Real;nr:integer;
begin
TextBackground(lightblue); Clrscr;
Gotoxy (6,4);textcolor (4) ;writeln ('Calcul Arie Cerc');
delay(1000);
textcolor(yellow);
gotoxy(15,12);textbackground(blue);
write ('Dati raza : ');
readln (raza);
sound(700);
delay(2000);sound(600);delay(100);nosound;
aria:=pi*sqr(raza);
TextBackground(magenta); Textcolor(white);
gotoxy(30,15);delay(3000);
writeln('aria este ',aria:7:3); delay (500);
sound(400);
delay(200);nosound ;
textbackground (00);
textcolor (02);Repeat
gotoxy(54,17);writeln('Dati nr 8 pt. a iesi');readln (nr);
until nr=8;
end.