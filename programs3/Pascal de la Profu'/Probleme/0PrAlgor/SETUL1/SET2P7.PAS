program cel_mai_mare_divizor_comun;
type natural=0..maxlongint;
     sir= array[1..10] of longint;
var x,y,cod:natural;
    a:sir;
    i,n:byte;
function cmmdc(m,n:natural):natural;
var r:natural;
begin
r:=m mod n;
if r=0 then cmmdc:=n
       else cmmdc:=cmmdc(n,r);
end;
begin
write('dati nr de nr');read(n);
for i:=1 to n do
   begin
   write('dati al',i,'lea nr ');read(a[i]);
   end;
   i:=1;
repeat
x:=a[i];
i:=i+1;
y:=a[i];
cod:=cmmdc(x,y);
x:=y;
y:=cod;
until i=n;
write('cmmdc a ',n,'nr este: ',y);
readln;
end.
