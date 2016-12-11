program generare_submultimi_de_k_elemente_recursiv;
uses crt;
type sir=array[0..100] of integer;
var n,k,i:integer;e:sir;
 procedure scrie;
 var l:integer;
 begin
     writeln('{',e[1]);
     for l:=2 to k do write(e[l]:3);
     writeln('}');
 end;
 procedure subm(i:byte);
 var j:integer;
 begin
   for j:=e[i-1]+1 to n-k+i do
            begin
              e[i]:=j;
              if i<n then subm(i+1)
                     else scrie;
             end;
   end;
begin
   write('dati numarul de elemente ale multimii: ');readln(n);
   write('dati numarul de elemente ale submultimilor de generat: ');readln(k);
   for i:=1 to k do begin e[i]:=i;write(i:2);end;
   e[0]:=0;
   subm(1);
end.
