program generarea_submultimilor_de_k_elemente_nerecursiva;
uses crt;
type sir=array[1..100] of integer;
var i,n,k:integer;e:sir;
begin
   clrscr;
   write('dati numarul de elemente ale multimii : ');read(n);
   write('numarul de elemente ale submultimilor : ');read(k);
   for i:=1 to k do begin
                      e[i]:=i;
                      write(i,'  ');
                    end;
   readln;
   writeln;
   i:=k;
   repeat
       while e[i]<n-k+i do
            begin
               e[i]:=e[i]+1;
               while i<k do
                   begin
                      i:=i+1;
                      e[i]:=e[i-1]+1;
                   end;
               for i:=1 to k do write(e[i],'  ');readln;writeln;
               i:=k;
             end;
        i:=i-1;
   until i=0;
   writeln;
end.