Program ElempareREC;     {scrieti o functie care calculeaza
                          suma elem. pare dintr-un vector}
uses crt;
type vect=array[1..50] of integer;
var v:vect;
j,i,n:integer;
function suma (i:integer):integer;
   begin
if (i=0) then suma:=0
   else
if( v[i] mod 2=0) then suma:=v[i]+suma(i-1)
                  else suma:=suma(i-1);
   end;
       begin
 writeln ('dati n:');readln (n);
    for j:=1 to n do
 begin
 write ('dati v[',i,']=');readln (v[j]);
 end;
 write ('suma elem.pare este',suma(n));delay(1000)
        end.

