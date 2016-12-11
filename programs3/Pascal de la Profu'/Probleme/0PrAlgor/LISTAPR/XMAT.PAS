  {Programul realizeaza inmultirea a doua matrici ce are elemente nr intregi.
  Programul avertizeaza asupra compatibilitati matricelor ce trebuiesc inmulti
  te si afiseaza fiecare matrice.  }
  program inmultire_matrici;
 type
     matrice= array[1..100,1..100] of integer;
   var
      A,B,C:matrice;
    h,g,i,j,m,n,p,s,w,k,y,z:integer;
 procedure cit_matri( var x:matrice;m,n:integer);
     begin
    for i:= 1 to m do
     begin
      writeln;
      for j:= 1 to n do
        begin
        write('x[',i,',',j,']= ');
        readln(x[i,j]);
        end;
      end;
   end;
 procedure scrie_matri( var x:matrice;m,n:integer);
   begin
   for i:= 1 to m do
     begin
     writeln;
      for j:= 1 to n do
       write(x[i,j],' ');
     end;
      writeln;
  end;
 procedure matrice_zero( var x:matrice; m,n:integer);
   begin
    for i:= 1 to m do
     for j:= 1 to n do
       x  [i,j]:= 0
   end;
 begin
  repeat
   write('Nr de linii a matricei A: ');readln(m);
   write('Nr de coloane a matricei A: ');readln(n);
   write('Nr de linii a matricei B: ');readln(k);
   write('Nr de coloane a matricei B: ');readln(p);
   if k<>n then writeln('Atentie nr de coloane a lui A = nr linii a lui B !');
  until n=k;
   cit_matri(A,m,n);
   write('Matricea A este : ');
   scrie_matri(A,m,n);
   cit_matri(B,k,p);
   write('Matricea B este : ');
   scrie_matri(B,k,p);
   matrice_zero(C,m,p);
     for s:=1 to m do
      for w:=1 to p do
        for j:= 1 to n do
          c[s,w]:= c[s,w]+(a[s,j]*b[j,w]);
   write('MATRICEA CE REZULTA ESTE : ');
   scrie_matri(C,m,p);
   readln;
end.