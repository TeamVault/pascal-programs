program cel_mai_mare_divizor_comun;
type natural=0..maxlongint;
var m,n:natural;
function cmmdc(m,n:natural):natural;
var r:natural;
begin
r:=m mod n;
if r=0 then cmmdc:=n
       else cmmdc:=cmmdc(n,r);
end;
begin
write('dati m ');readln(m);
write('dati n ');readln(n);
write('cmmdc a nr',m,',',n,'este: ',cmmdc(m,n));
readln;
end.

