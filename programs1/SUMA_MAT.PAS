Program suma_unei_matrici;
uses crt;
type matrice=array[1..20,1..30] of integer;

a=matrice;
S,n,i,m:integer;
begin
clrscr;
write ('dati nr liniilor n=');readln (n);
write ('dati nr coloanelor m=');readln (m);
Begin
write ('dati a[',i,',',j,']=');readln  ( a[i,j]);
end;
begin
for i:=1 to n do
for j:=1 to m do
S:=0
S:=S+a[i;j];
write (' suma elementelor este:',S);readln (S);
END;
readln;
END.

