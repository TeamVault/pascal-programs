Program SumaSiProdus;
var
   a,b,c,d:array[1..50,1..50] of real;
   i,j,k,n:integer;
Begin
     write('n=');
     readln(n);
     for i:=1 TO n DO
         for j:=1 TO n DO
         Begin
              write('elementul a (',i,',',j,')=');
              readln(a[i,j]);
              write('elementul b (',i,',',j,')=');
              readln(b[i,j]);
              c[i,j]:=a[i,j]+b[i,j];
         End;
      for i:=1 TO n DO
         for j:=1 TO n DO
             begin
                  d[i,j]:=0;
                  for k :=1 TO n DO
                  d[i,j]:=d[i,j]+a[i,k]*b[k,j];
             end;
                 writeln('Suma                                  Produsul');
                 writeln('     c                                         d');
                 for I:=1 TO n DO
                     begin
                          for j :=1 TO n DO
                          write (c[i,j]:7:2,'');
                 write('                     ');
                          for j :=1 TO n DO
                          write (d[i,j]:7:2,'');
                          writeln;
                      end;
                      readln;
end.