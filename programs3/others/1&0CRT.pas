 {program care umple instantaneu descktopul cu q0 si 1
{se va afisa pur si simplu ceva pe crt   13.1.2005 created}
program Umplerea_aleatoareAdescktopului;
uses crt;
var x,y,z,w,s,r,d,m,i,p:integer;
begin
gotoxy(12,12);
writeln('ecranul va fi inundat de 1 si 0!!!');delay(1500);
clrscr;
repeat
 TEXTcolor(x); textbackground(y+blink);
x:=random(80);y:=random(80);
gotoxy(x,y);write('0');
z:=random(80);w:=random(80);
gotoxy(z,w);write('1');
s:=random(80);r:=random(80);
gotoxy(s,r);write('0');
d:=random(80);m:=random(80);
gotoxy(d,m);write('1');
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
gotoxy(23,12);write('///---------------------------------------------\\\\\');
gotoxy(20,13);write('~~~created by the smartest boy alias MASTERCODS PaulMuntean: ~~~~~');
gotoxy(23,14);write('\\\---------------------------------------------/////');gotoxy(30,16);write('tyu@linuxtimes.net');
   delay(1000);delay(4000);
end.