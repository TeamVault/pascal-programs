program SUMAvectorREC;
uses crt;
type vect=array[1..50] of integer;
var n,i:integer;v:vect;
function suma(i:integer):longint;
    begin
if i=0 then suma:=0
 else
 if (v[i] mod 2=0) then  suma:=v[i]+suma(i-1)
                 else  suma:=suma(i-1);
    end;
 begin
 writeln ('Dati val. lui n:');readln (n);
 for i:= 1 to n do
 begin
 writeln ('dati v[',i,']=');readln (v[i]);
 end;
writeln ('suma elem. pare ale vectoruluiesre', suma(n));
 readln;
 end.