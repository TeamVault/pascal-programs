
program generare_permutari_nerecursiv;
uses crt;
var p:array [1..10] of byte;
    n,i,k,aux:byte;
begin
   clrscr;
   write('n=');read(n);
   for i:=1 to n do
        begin
           p[i]:=i;
           write(i:2);
           readln;
        end;
   k:=1;
   repeat
       aux:=p[k];
       for i:=k to n-1 do p[i]:=p[i+1];
       p[n]:=aux;
       if p[k]=k then k:=k+1
                 else begin
                        writeln;
                        k:=1;
                        for i:=1 to n do write(p[i]:2);
                        readln;
                      end;
    until k=n;
end.