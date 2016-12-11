   Program CMMDCsiCMMMC;
uses crt;
var a,b,x,y:^integer;
begin
new(a);new(b);new(x);new(y);
write ('dati a,b=');readln(a^,b^);x^:=a^;y^:=b^;
if( a^>0) and ( b^>0) then
begin
while ( a^<>b^) do             {progamele merg si fara "new" si "dispose" ,sunt alocate imediat ce apar in program }
if (a^>b^) then a^:=a^-b^
           else b^:=b^-a^;
write ('cmmdc este', a^);
writeln('cmmmc este',(x^*y^) div a^);
end;dispose(a);dispose(b);dispose(x);dispose(y);
End.