program hiphop;
uses crt;
var x,p:byte; i,j:integer;
begin
repeat

for i:=1 to 15 do
  begin   textcolor(p+1+blink);
for j:=100 to 1 do
    x:=random (15);
  textcolor(p+blink);   textcolor(x+blink);
 {textbackground(2);} textcolor(x-1+blink);
p:=random (80); window(15,7,70,25);
 {window(x-cloana1,y-linia1,z-coloana2,k-linia2}
 gotoxy(i,x);  textcolor(p);
 write('HipHop!!!'); x:=random (15);
 end;
 until keypressed
end.