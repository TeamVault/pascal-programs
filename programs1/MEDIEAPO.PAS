Program calcul;
uses crt;
Var a,b,p,s:integer;
function( calcul):integer;
begin
p:=a*b;
s:=a+b;
Writeln ('prod este',p);
writeln ('suma este',s);
end;
begin
writeln ('dati nr:');
readln (a,b);
calcul;
readln;
end.