{Sa se afiseze cuvintele continute de o fraza in ordine alfabetica.Fraza se
gaseste pe prima linie a fisierului fraza.in terminata cu '.',iar cuvintele
sunt separate prin 1 sau mai multe spatii}
program p7;
var f:text;
    a,aux:string;
    cuv:array[1..20] of string;
    k,n,i,j,nr:byte;
begin
writeln('Sa se afiseze cuvintele in ordine alfabetica.Fraza se');
writeln('se va scrie de utilizator cuvant cu cuvant si se va termina cu  . iar cuvintele');
writeln('sunt separate prin 1 sau mai multe spatii');
writeln('Dati nr de cuvinte din care este alcatuita fraza');readln(n);
writeln('Dati fraza!!!');
for i:=1 to n do
begin
writeln('Dati cuvantul  ',i,'-al frazei');
readln(cuv[i]);
end;
for i:=1 to n-1 do
   for j:=i+1 to n do
           if cuv[i]>cuv[j] then begin
                                 aux:=cuv[i];
                                 cuv[i]:=cuv[j];
                                 cuv[j]:=aux;
                                 end;
    writeln('Fraza sortata alfabetic este');
for i:=1 to n do write(cuv[i],' ');readln;
end.