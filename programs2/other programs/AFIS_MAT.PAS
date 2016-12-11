Program afisare_sub_forma_de_matrice;
uses crt;
type matrice=array [1..20,1..43] of integer;
 var   a:matrice;
       n,m,j,i:integer;
Begin
clrscr;
write ('dati n=');readln (n);
write ('dati m=');readln (m);
for i:=1 to n do
for j:=1 to m do
Begin
write ('dati a[',i,',',j,']=');readln  ( a[i,j]);
Writln a[i,j];
end;
End.