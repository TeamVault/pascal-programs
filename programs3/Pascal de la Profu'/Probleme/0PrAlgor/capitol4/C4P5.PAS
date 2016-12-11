program fara_o_cifra;
var nr,n,x,y,c,i: longint;
    a:array[1..20] of byte;
    cod:boolean;
begin
     write('Introduceti numarul ');readln(nr);
     i:=1;
     x:=nr;
     repeat
           a[i]:=x mod 10;
           inc(i);
           x:=x div 10;
     until x=0;
     n:=i-1;
     i:=n;
     cod:=false;
     repeat
         if (a[i]<a[i-1]) or (i=1) then
                         begin
                         a[i]:=10;
                         cod:=true;
                         end;
         i:=i-1;
     until cod or (i<1);
     y:=0;
     for i:=n downto 1 do
         if a[i]<>10 then
            y:=y*10+a[i];
writeln('numarul maxim este ',y);
readln;
end.




