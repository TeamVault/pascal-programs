{program care umple instantaneu descktopul cu caractere}
{se va afisa pur si simplu ceva pe crt   13.1.2005 creadted}
program Umplerea_aleatoareAdescktopului;
uses crt;
var x,y,z,w,s,r,d,m,i,p,l:integer;
begin
gotoxy(30,17);TEXTCOLOR(WHITE);
writeln('ECRANUL VA FI INUNDAT!!!');delay(3000);
clrscr;
repeat
 TEXTcolor(x); textbackground(y+blink);
x:=random(80);y:=random(56);l:=random(256);
gotoxy(x,y);write(char(l));
z:=random(80);w:=random(80);
gotoxy(z,w);write(char(l));
s:=random(80);r:=random(l);
gotoxy(s,r);write(char(p));
d:=random(80);m:=random(80);
gotoxy(d,m);write(Char(l));
until keypressed;
      clrscr;
   gotoxy(23,14);
   write('what are you thinking now?');delay(3000);
    delay(1100);clrscr;
      textbackground(red+181);
  for i:= 1 to 25 do
   begin
gotoxy(i,i);write('$ PM $');
   end;p:=0;
    for i:= 25 downto 1 do
       begin
       inc(p);
gotoxy(i,p);write('$ PM $');
       end;
gotoxy(23,12);write(' /////---------------------------------------------\\\\\');
gotoxy(23,13);write('~~~~~created by the smartest boy alias MASTERCODS PM ~~~~~');
gotoxy(23,14);write(' \\\\\---------------------------------------------/////');
gotoxy(30,16);write('PaulMuntean@gmail;email adress of paul muntean'); delay(4000);
     end.