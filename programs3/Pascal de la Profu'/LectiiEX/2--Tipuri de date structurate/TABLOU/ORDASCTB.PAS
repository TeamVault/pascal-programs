Program ordtab;
{Acesta este un program de ordonare a unui tablou prin
metoda bulelor...}
type vector = array [1..100] of integer;
var  x:vector;
     i,n:integer;

PROCEDURE Ordonare(var a:vector; n:integer);
var j,tmp:integer;
    cod:boolean;
begin
repeat
           cod:=TRUE;
           for j:=1 to n-1 do
               if a[j]>a[j+1]
               then
                  begin
                  tmp:=a[j];
                  a[j]:=a[j+1];
                  a[j+1]:=tmp;
                  cod:=FALSE;
                  end;
until cod=TRUE;
end;

begin
     write('Introduceti rangul maxim:');readln(n);
     for i:=1 to n do
     begin
         write('Introduceti a[',i,']=');readln(x[i]);
     end;
     writeln('Tabloul ordonat este: ');
     ordonare(x,n);
     for i:=1 to n do
         writeln('a[',i,']=',x[i]);
end.