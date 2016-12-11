program numar_prim;
var d,n:integer;
    prim,fals:boolean;
begin
write('dati n:');
readln(n);
prim:=true;
for d:=2 to trunc(sqrt(n)) do
      if n mod d=0 then begin
                      prim:=fals;
                      end;
if prim then writeln('prim')
              else writeln('neprim');
readln;
end.

