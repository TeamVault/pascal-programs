{Proiectul rezolva trei probleme a alese pe baza unui meniu:
1. Numarul cifrelor unui numar natural dat.
2. Produsul a n numere date
3. Impartirea unui polinom prin x-a 
}
program proiect;
uses crt;
type sir=array[1..100] of integer;
     cifre=0..9;
var   n,i:byte;
      nr,p,y,m:longint;
      x,c:sir;
      d:char;

 {inceput primul program}
  procedure nrcifre(nr:longint;var x:sir;var n:byte);
   var i:byte;
     begin
        i:=0;
        while nr<>0 do
         begin
           i:=i+1;
           x[i]:=nr mod 10;
             nr:=nr div 10;
         end;
             n:=i;
    for i:=1 to n do
     writeln(x[i],',');

for i:=1 to n do
  c[x[i]]:=c[x[i]]+1;
  for i:=0 to 9 do
     if c[i]<>0 then
        writeln('cifra ',i,'apare de ',c[i],'ori');{frecventa caracterelor}
  writeln;
  end;
procedure calcul;{procedure calcul produs}
 begin
 clrscr;
 writeln('introduceti m'); {nr de nr pentru care se calculeaza produsul}
 readln(m);
 p:=1;
  for i:=1 to m do
      begin
        readln(y);
        p:=p*y;
      end;
   write(p);
end;
procedure schema;
var x,y:array[1..100]of integer;
    c:char;
    i,n,a,nr:integer;
begin
clrscr;
write('introdu x');
read(a);
write('se dau nr coeficienti:');
readln(nr);
for i:=1 to nr do
     begin
      writeln('introdu coeficienti  ',i);
      readln(x[i]);
     end;
      writeln;
       for i:=1 to nr do y[i]:=0;
       i:=1;
       y[i]:=x[i];
       for i:=2 to nr do y[i]:=a*y[i-1]+x[i];
       writeln('catul este: ');
       for i:=1 to nr-1 do
         writeln(y[i],'*x la puterea',nr-i-1,'+');
         write('restul este: ',y[nr]);
         readln;
         writeln;
end;
procedure iesire;
begin
halt;
end;
{program principal}
begin
 clrscr;
 writeln('optati pentru:');
 writeln ('alegeti 1 ptr a calcula numarul de cifre ');
 writeln ('alegeti 2 ptr a calc produsul a n numere ');
 writeln ('alegeti 3 ptr a calcula impatrtirea de polinoame ');
 writeln('alegeti 4 ptr parasire program');
 readln(d);
 case d of
  '1' :begin
       write('introduceti nr');
       readln(nr);
       nrcifre(nr,x,n);
       end;
  '2' :calcul;
  '3' :schema;
  '4' :iesire;
  end;

   readln;
   end.
