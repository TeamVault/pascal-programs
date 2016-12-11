program Mana_Pnuelli;
uses crt;
var n:integer;
function pnuelli(x:integer):integer;
begin
if x<12  then pnuelli:=pnuelli(pnuelli(x+2))
       else pnuelli:=x-1;
end;
begin
clrscr;
write('n= ');read(n);
write( pnuelli(n));
readln;
end.