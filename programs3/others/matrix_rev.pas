   {program care este la fe ca si CRTful dar afiseaza doar 0 si 1 ca in matrix
   in culoare verde}
   program matrix_revolution2005BYpaul_m;
     uses crt;
var x,y,z,w,s,r,d,m,i,p:integer;
begin
gotoxy(12,12);
writeln('ecranul va fi inundat!!!'); delay(1500);
clrscr;
textcolor(green);
repeat
x:=random(80);y:=random(80);
gotoxy(x,y);write('1');
z:=random(80);w:=random(80);
gotoxy(z,w);write('0');
until keypressed;clrscr;textcolor(magenta);
begin
writeln('what is your sugestion?');delay(4000);
end;
end.