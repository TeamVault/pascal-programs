{Algoritm de sortare a unei multimi de 3 elemente}
var x:array[1..50] of real;
    i,n:byte;
    aux:real;
    ok:boolean;
begin
    {write ('dati numarul elementelor de sortat, n = ');}
    {readln(n);}
    writeln('dati elementele sirului: ');
    n:=3; {sorteaza doar 3 elemente}
    for i:=1 to n do
        readln(x[i]);
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
    until ok;
          writeln('sirul ordonat este: ');
         for i:= 1 to n do
                writeln(x[i]:8:2,' ');
         readln;
    end.