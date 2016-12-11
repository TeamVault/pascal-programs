 {Se da o matrice patratica,se cere sa se formeze doua siruri cu elementele
matricii,parcurgand-o pe linii si respectiv pe coloane}
 program de_formare_sir_din_matricea_patratica_A;
 uses crt;
 var a:array[0..100,0..100] of integer;
     b,c:array[0..100] of integer;
    k,i,j,n:integer;
 begin
 clrscr;
 write('Introduceti lungimea matricei n=');readln(n);
  for i:=1 to n do
  for j:=1 to n do
  begin
 gotoxy(8*i,j*3);
 readln(a[i,j])
  end;
 for i:=1 to n do
    for j:=1 to n do
       b[n*(i-1)+j]:=a[i,j];
   for k:=1 to n*n do
       write('b[',k,']=',b[k],',') ;
  for i:=1 to n do
   for j:=1 to n do
      c[n*(j-1)+i]:=a[i,j];
   writeln;
  for k:=1 to n*n do
  write('c[',k,']=' ,c[k],',');
   repeat until keypressed;
 end.
