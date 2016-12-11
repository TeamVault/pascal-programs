{Afisati toate numrele patrate perfecte mai mici dacat un n dat.}
Program patrate_perfecte;
uses crt;
var n,i:integer;
begin
clrscr;textcolor(yellow);
write('Dati numarul ');read(n);
textcolor(cyan);
write('Patratele perfecte mai mici decat ',n,' sunt ');
for i:=1 to n do
begin
if frac(sqrt(i))=0 then write(i,';' );
end;
end.