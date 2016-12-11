{Calculati minimul dintre elementele unui sir printr-o singura parcurgere a
elementelor sale.}
program p4;
type sir=array[1..100] of integer;{integer}
var a:sir;
    i,n:integer;
    min:integer;
    f:text;
begin
  assign(f,'sir.txt');
  reset(f);
  readln(f,n);
  for i:=1 to n do
      read(f,a[i]);
  min:=a[1];
  for i:=1 to n do
             if a[i]<min then min:=a[i];
  writeln('Minimul sirului este:',min);
end.


