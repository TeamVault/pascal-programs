{rezolvarea unui sistem de 2 ecuatii cu 2 necunoscute}
program sistemec;
uses crt;
type matrice=array[1..2,1..3] of integer;
var x,y:real;
    i,j,m,dx,dy,ds:integer;
    a,d:matrice;
procedure deter;
begin
  m:=d[1,1]*d[2,2]-d[1,2]*d[2,1]
  end;
begin
  clrscr;
 writeln(' sisteme de doua ecuatii');
 { notarea coeficientiilor sistemului}
 {a(11)    a(12)   a(13)
 a(21)     a(22)   a(23)
 se foloseste metoda determinantilor}
 for i:= 1 to 2 do
 begin
 for j:= 1 to 3 do
 begin
    write ('a[',i,',',j,']= ');
    read (a[i,j]);
    d[i,j]:=a[i,j]
end
    end;
 writeln('REZULTATE');
 writeln('ecuatiile ale caror rezolvari se cer');
 writeln(' ',a[1,1],'x+',a[1,2], 'y=',a[1,3]);
 {determinantul sistemului}
 deter;
 ds:=m;
 {calculul determinantilor pentru aflarea necunoscutelor}
 for i:=1 to 2 do d[i,1]:=a[i,3];
 deter;
 dx:=m;
 for i:=1 to 2 do
 begin
   d[i,1]:=a[i,1];
   d[i,2]:=a[i,3];
  end;
 deter;
 dy:=m;
 {rezolvarea sistemului de ecuatii}
 if (ds=0) and (dx<>0) then writeln('sistem incompatibil')
 else if (ds=0) and (dx=0) then
 begin
  writeln('sistem nedeterminat');
  writeln('cateva solutii posibile');
  for i:=1 to 5 do
  begin
    x:=i;
    y:=(a[1,3]-a[1,1]*x)/a[1,2];
    writeln('x= ',x,';y=',y:2:3,';');
    {verificarea solutiilor}
    writeln(a[1,1]*i+a[1,2]*y,'=',a[1,3]);
    writeln(a[2,1]*i+a[2,2]*y,'=',a[2,3]);
   end;
 end;
 if (ds<>0) and (dy<>0) then
 begin
   x:=dx/ds;
   y:=dy/ds;
   writeln('solutiile sistemului sunt:');
   writeln('x=',x:2:3, 'si y=',y:2:3);
   {verificarea solutiilor}
   writeln(a[1,1],'*',x:2:3,'+',a[1,2],'*',y:2:3,'=',a[1,3]);
   writeln(a[2,1],'*',x:2:3,'+',a[2,2],'*',y:2:3,'=',a[2,3]);
   writeln(a[1,1]*x+a[1,2]*y,'=',a[1,3]);
   writeln(a[2,1]*x+a[2,2]*y,'=',a[2,3]);
 end;
end.
