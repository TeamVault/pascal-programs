   program piramida;
   uses crt;
var i,j,n:integer;
procedure afisare2;
begin
for i:=1 to n do
 begin
 for j:=1 to (n-i) do
  write(j:2);writeln
  end;
 end;
procedure afisare1;
begin
for i:=1 to n do
 begin
 for j:=1 to i do
  write(j:2);writeln;
 end;afisare2;
 end;
   procedure afisare21;
begin
for i:=1 to n do
 begin
 for j:=1 to (n-i) do
  gotoxy (n+n+i+2,n+i);  write(j,' ');writeln
  end;
 end;
procedure afisare11;
begin
for i:=1 to n do
 begin
 for j:=1 to i do
 gotoxy (n+n+n+1-j+1,j); write(j,' ');writeln;
 end;afisare21;
 end;
 begin
    n:=0;clrscr; write('APASA ENTER'); READLN;
 repeat
 textbackground(yellow);clrscr;
 textcolor(red);
 inc(n);
{ write('Dati valoarea lui n:');}{readln(N);}clrscr;afisare1;
 afisare11;readln; sound(n*100);
 until n=12;
 end.