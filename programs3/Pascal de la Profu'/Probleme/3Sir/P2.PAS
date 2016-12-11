{Sa se scrie un program care citeste cele n nr care compun vectorul A,cele m
nr reale care compun vectorul B.Sa se afiseze pe ecran cate dintre elem lui A
sunt strict mai mici decat elem lui B.}
program p2;
type vector=array[1..50] of real;
var a,b:vector;
    m,n,i,k:integer;
    min:real;
begin
write('n=');readln(n);
for i:=1 to n do begin
                 write('a[',i,']=');
                 readln(a[i]);
                 end;
write('m=');readln(m);
for i:=1 to m do begin
                 write('b[',i,']=');
                 readln(b[i]);
                 end;
min:=b[1];
for i:=2 to m do
        if b[i]<min then min:=b[i];
k:=0;
for i:=1 to n do
        if a[i]<min then k:=k+1;
write('Elem din a strict mai mici decat cele din b:',k);
end.