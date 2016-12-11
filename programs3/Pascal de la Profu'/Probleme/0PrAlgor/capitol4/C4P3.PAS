program maxdincifre;
type sir=array[1..100] of byte;
var n,p,i:byte;
    nr, m:longint;
    a:sir;

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

Procedure bubble_sort (var a: sir; n: byte);
var cod:boolean;
begin
 repeat                     {Ordonarea cifrelor cu metoda}
     cod:=true;                 {bubble sort}
     for i:=1 to n-1 do
         if a[i]<a[i+1] then
            begin
            p:=a[i];
            a[i]:=a[i+1];
            a[i+1]:=p;
            cod:=false;
            end
     until cod;

end;
begin
     write('numarul=');readln(nr);
     cifre (nr,a,n);
     bubble_sort (a, n);
     m:=0;
     i:=1;
     repeat                        {formarea noului numar}
           m:=m*10+a[i];
           inc(i);
     until i>n;
     writeln(m);
readln;
end.
