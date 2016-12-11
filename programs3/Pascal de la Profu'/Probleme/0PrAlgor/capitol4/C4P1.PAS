program cifre_numar;
type sir=array[1..100] of integer;
var a:sir;
n:longint;
i, k:byte;
Procedure scrie_sir( a:sir; n:byte);
Var i: byte;
Begin
for i:= n downto 1 do 
writeln(a[i],'  ');
end;
Procedure cifre (n: longint; var a:sir; var m:byte);
begin
i:=1;
repeat
a[i]:=n mod 10;
n:=n div 10;
i:=i+1
until n=0;
m:=i-1;
end;
begin
write('dati n ');readln(n);
cifre (n, a, k);
scrie_sir (a, k);
end.

