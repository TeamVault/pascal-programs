{Calculul functiei recursive Aackerman definita prin relatiile:}
{Ack(m,n)=     n+1 , daca m=0 }
{              Ack(m-1,1) ,daca m>0 si n=0    }
{              Ack(m-1, ack(m,n-1)) daca n>0, m>0}
{Este un exemplu de functie recursiva implementat prin Function ac}
Program functia_Ackerman;
uses crt;
type  natural=0..maxlongint;
var a,b:natural;
function Ac(m,n:natural):natural;
begin
if m=0 then ac:=n+1
       else if n=0 then ac:=ac(m-1,1)
                   else ac:=ac(m-1,ac(m,n-1));
end;
begin
clrscr;
textcolor(yellow);
textbackground(red);
writeln('a= ');read(a);
writeln('b= ');read(b);
writeln('Ackerman din ',a,' si ',b,'=',ac(a,b));
readln;
readln;
end.
