{Algoritmul de sortare prin metoda bolelor - bubble sort}
var x:array[1..50] of real;
    i,j,n:byte;
    aux:real;
    ok:boolean;
    f,g:text;
Begin
     assign(f,'date.in');
     assign(g,'date.out');
     rewrite(g);
     reset(f);
     writeln('');
     readln(f,n);
     for i:=1 to n do
         read(f,x[i]);
     repeat
     ok:=true;
     for i:=1 to n-1 do
         if x[i]>x[i+1] then
                begin
                     aux:=x[i];
                     x[i]:=x[i+1];
                     x[i+1]:=aux;
                     ok:=false;
                end;
      until  ok;

     for i:=1 to n do
         writeln(g,x[i]:8:2,' ');
readln;
close(f);
close(g);
end.