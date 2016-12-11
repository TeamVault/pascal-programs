Program afisare_sub_forma_de_matrice;
uses crt;
type matrice=array [1..20,1..43] of integer;
 var   a:matrice;
       n,m,j,i:integer;
Begin
 write ('dati n=');readln (n);
 write ('dati m=');readln (m);
  for i:=1 to n do
   for j:=1 to m do
         Begin
    write ('dati a[',i,',',j,']=');readln  ( a[i,j]);
        end;
   for i:=1 to n do
   for j:=1 to m do
      begin 
         write(a[i,j]);
      if j=n then writeln; 
      end;
End.