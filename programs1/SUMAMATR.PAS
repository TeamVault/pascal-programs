Program MATRICI;
uses crt;
var a:array [1..20,1..30] of integer;
    s,m,n,i,j:integer;
BEGIN
    clrscr;
    write('Dati nr de linii:');
    readln(m);
    write('dati nr de coloane:');
    readln(n);
for i:=1 to m do
for j:=1 to n do
  Begin
    write('Dati a[',i,',',j,']=');
    readln(a[i,j]);
  end;
  S:=0;
for i:=1 to m do
for j:=1 to n do
     S:=S+a[i,j];
     write('Suma este:',S);
     readln;
END.