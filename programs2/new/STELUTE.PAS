Program tringhi_de_stelute;
uses crt;
var n,i:integer;
function linie (L:integer):string;
var j:integer; s:string;
begin
s:=' ';
for j:=1 to n do s:=s+'*';
linie:=s;
end;
begin
clrscr;
write ('dati nr de linii=');readln (n);
for i:=1 to n do
writeln (linie(i));
readln;
end.