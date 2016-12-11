Program matrice;
uses crt;
var a:array[1..30,1..30] of integer;
    i,j:integer;
    n,m,P,S,L:integer;
    procedure adaugare;
    begin
     for i:=1 to m do
     begin         { S:=0;sau aici pus tot aia ii}
     for j:=1 to n do
         S:=S+a[j,i];
         a[m+1,i]:=S;S:=0;
     end;readln;
     for i:=1 to m do
     begin
     for j:=1 to n do
         P:=P+a[i,j];
         a[i,n+1]:=P;P:=0;
     end;readln;
   end;
procedure afisare;
begin
for i:=1 to m do
 begin
for j:=1 to n do
  write (a[i,j]:3);
  writeln;
 end;
end;
begin
S:=0;P:=0;L:=0;
writeln ('dati nr de linii ');readln(m);
writeln ('dati nr de coloane');readln(n);
for i:=1 to m do
 for j:=1 to n do
  begin
  write('dati v[',i,',',j,']=');readln(a[i,j]);
  end;  clrscr;
afisare;
adaugare;
 n:=n+1;m:=m+1;
for i:=1 to n do
begin
L:=L+a[m,i];
end;
a[m,n]:=L;readln;
afisare;readln;
end.