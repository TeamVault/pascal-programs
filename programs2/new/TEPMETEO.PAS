Program Tmeteo;
uses crt;
type meteo=record
nume:string;
temp,pres:real;
end;
vect=array[1..20] of meteo;
var b:vect;
 i,n:integer;
 m:real;
 procedure afisare (b:vect;n:integer;x:real);
 begin
 for i:=1 to n do
 if b[i].temp=x then
 writeln ('ziua',i,'meteorolog:',b[i].nume);
 end;
 function dettempmax (b:vect;n:integer):real;
 var max:real;
 begin
 max:=b[1].temp;
 for i:=1 to n do
 if b[i].temp>max then
 max:=b[i].temp;
 dettempmax:=max;
 end;
 begin
 clrscr;
 writeln ('dati nr de zile');readln(n);
 for i:= 1 to n do
 with b[i] do
 begin
 writeln ('ziua',i);
 write (' si numele meteorologului');readln (nume);
 writeln ('temp si pres');readln(temp,pres);
 end;
 m:=dettempmax (b,n);
 writeln ('temp maxima',m:3:2);
 afisare (b,n,m);
 readln;
 end.
