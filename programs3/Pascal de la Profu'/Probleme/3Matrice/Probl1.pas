{Se dau numerele x,y si z si matricea a de dimensiuni m linii si n coloame.
 Sa se formeze  matricea b cu m linii si  n coloane unde:

                  / 0,   a[i,j]<x
                /   1,x<=a[i,j]<x
     b[i,j] =   \   2,y<=a[i,j]<z
                  \ 3,   a[i,j]>=z    .
}
program functie;
    {0, a[i,j]<x
     1, x<=a[i,j]<y
     2, y<=a[i,j]<z
     3, a[i,j]>=z}
 uses crt;
  var a,b:array[1..99, 1..99] of integer;
     n,m,i,j,x,y,z:integer;
  begin
 clrscr;
 write('Introduceti marginea m a matricei a:');
 readln(m);
 write('Introduceti marginea n a matricei a:');
 readln(n);
  for i:=1 to m do
  for j:=1 to n  do
  begin
  gotoxy(i*4,j*3);read(a[i,j]);
  end;
  writeln;
  write('Introduceti x: '); readln(x);
  write('Introduceti y, x<y: '); readln(y);
  write('Introduceti z, y<z: '); readln(z);
      for i:=1 to m do
   for j:=1 to n do
    begin
     if a[i,j]<x then b[i,j]:=0 ;
     if (x<=a[i,j]) and (a[i,j]<y) then b[i,j]:=1;
     if (y<=a[i,j]) and (a[i,j]<z) then b[i,j]:=2;
     if a[i,j]>=z then b[i,j]:=3;
     end;
   for i:=1 to m do
    for j:=1 to n do
     begin
    write('b[',i,',',j,']=',b[i,j]);
   end;
      repeat until keypressed;
  end.

