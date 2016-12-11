{Se construieste un vector A cu n elem sir nr reale P,Q.Sa se scrie un program
care copiaza intr-un vector B toate elem din A in ordine inversa aparitiei
lor in A,elem care se gasesc in intervalul P,Q
       EX:A=(12,-4,9,7,-5,31,-74,515,-33,-8)
          P=-10   Q=9
          B=(-8,-5,7,-4)}
program p1;
type vector=array[1..50] of real;
var a,b:vector;
    m,n,i:integer;
    p,q:real;

begin
read(n);
read(p);
read(q);

for i:=1 to n do read(a[i]);
m:=0;

for i:=n downto 1 do
        if (p<a[i]) and(a[i]<q) then
                                begin
                                m:=m+1;
                                b[m]:=a[i];
                                end;

for i:=1 to m do write(b[i]:6:2);
end.