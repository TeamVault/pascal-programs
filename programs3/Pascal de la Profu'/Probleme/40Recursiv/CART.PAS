{Produsul cartezian a doua multimi cu m si respectiv n elemente}
Uses crt;
var n,m:byte;
    x:array[1..20] of byte;
Procedure scriere;
var i:byte;
begin
 write('(',x[1]);
 for i:=2 to n do
  write(',',x[i]);
  write(')');
end;

Procedure cart(i:byte);
var j:byte;
begin
 for j:=1 to m do
  begin
   x[i]:=j;
   if i<n then cart(i+1)
          else scriere;
  end;
end;
Begin
 Clrscr;
  write('n=');readln(n);
  write('m=');readln(m);
  cart(1);
 Readkey;
End.