{Suma cu monede date.
Se dau mai multe monede de valori diferite. Se cunoaste numarul monedelor din fiecare.
Daca se da o suma S, determinati toate modurile de plata a sumei cu monedele date}
program suma_monede;
uses crt;
type moneda=record
             val,nr:integer;
            end;
     sir=array[1..100] of integer;
var a:array[1..24] of moneda; x:sir;
    n,k,i,s:integer; f:text;
function posibil(k:integer):boolean;
var i:byte; cod:boolean; c:integer;
begin
 cod:=true; c:=0;
 for i:=1 to k do
  c:=c+(x[i]*a[i].val);
 if c>s then cod:=false;
 posibil:=cod;
end;
procedure solutie(x:sir);
var i:byte;  cod:boolean; c:integer;
begin
 cod:=false;c:=0;
 for i:=1 to n do
  c:=c+(x[i]*a[i].val);
 if c=s then cod:=true;
 if cod then
 begin
  for i:=1 to n do
    write(f,x[i],' ');
  writeln(f);
   end;

end;
procedure back(k:integer);
var i,j:byte;
begin

   for j:=0 to a[k].nr do
  begin
   x[k]:=j;
   if posibil(x[k]) then
    if k<n then back(k+1)
    else solutie(x);
  end;
end;
begin
 clrscr;
 writeln('cate monede sunt?');
 readln(n);
 for i:=1 to n do
  begin
   write('dati valoarea  ');
   readln(a[i].val);
   write('cate monede sunt?  ');
   readln(a[i].nr);
  end;
 writeln('dati suma');
 assign(f,'fisier2.txt'); rewrite(f);
 readln(s);
 for i:=1 to n do
  write(f,a[i].val,' ');
 writeln(f);
 back(1);
 readln;close(f);
end.