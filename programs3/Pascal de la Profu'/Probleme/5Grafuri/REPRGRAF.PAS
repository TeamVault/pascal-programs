{ Memorarea grafurilor sub forma de perechi de varfuri si }
{crearea matricei de adiacenta a varfurilor. Matricea de adiacenta}
{ este matricea cu n lini si n coloane, n numarul varfuri, in care}
{elementul a(i,j) este 1 daca intre i si exista muchie  si }
{ 0 in caz contrar. Observati diferenta intre grafuri orientate si}
{neorientate!}
{Problema de mai jos exemplifica citirea unui graf ca perechi de }
{ varfuri si transcrierea sa in matricea de adiacenta (graf neorientat)}
Program graf;

uses crt;
type matrice=array[1..10,1..10] of byte;
var a,b:matrice;
    i,j,n,m:byte;
 begin
 clrscr;
 textbackground(12);
 textcolor(11);
 write('dati nr de varfuri'); read(n);
 write('dati nr de muchii '); read(m);
 for i:=1 to m do
   begin
  writeln('perechea : ',i);
  write('Varf initial ');read(a[i,1]);
  write('Varf final ');read(a[i,2]);
   end;
  for i:=1 to n do
  for j:=1 to n do
  b[i,j]:=0;
  for i:=1 to m do
    begin
  b[a[i,1],a[i,2]]:=1;
  b[a[i,2],a[i,1]]:=1;
  end;
  for i:=1 to n do
  begin
  writeln;
  for j:=1 to n do
  write(' ', b[i,j]);
  end;
  readkey;
  end.