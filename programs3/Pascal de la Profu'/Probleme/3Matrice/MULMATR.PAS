{Program ce ridica la o putere o matrice patratica A
Matricea se afla in fisierul mat}
program mulmatr;
type matr=array[1..10,1..10] of integer;
var a,rez:matr;
    n,p:integer;

Procedure cit_matr(var a:matr; var n:integer);
var i,j:integer;
F:TEXT;
begin
     {write('Introduceti rangul matricii: ');}
     ASSIGN(F,'mat.');
     reset(f);
     readln(f,n);
     for i:=1 to n do
         for j:=1 to n do
             begin
             {write('A[',i,',',j,']= ');}read(f,a[i,j]);
             end;
     close(f);
     writeln('rangul este: ',n);
end;{cit_matr}

PROCEDURE afis_matr(a:matr;n:integer);
var i,j:integer;
begin
     for i:=1 to n do
     begin
     writeln;
         for j:=1 to n do
             write(a[i,j]:8);
     end;
end;{afis_matr}

{procedura de inmultire a 2 matrici patratice de acelasi rang}
PROCEDURE mul_matr(a,b:matr;n:integer;var rez:matr);
var i,j,m:integer;
begin
     for i:=1 to n do
         for j:=1 to n do
         begin
              rez[i,j]:=0;
             for m:=1 to n do
                 rez[i,j]:=rez[i,j]+a[i,m]*b[m,j];
         end;
end;{mulmatr}

{procedura de ridicare la putere a unei matrici
A - matricea
n - rangul matricii
put - puterea la care va fi ridicata matricea
rez - matricea rezultata}
PROCEDURE put_matr(a:matr;n:integer;put:integer;var rez:matr);
var i:integer;
begin
     rez:=a;
     writeln('suntem in put_matr');
     for i:=1 to put-1 do
     begin
         afis_matr(rez,n);
         writeln;
         mul_matr(a,rez,n,rez);
     end;
     afis_matr(rez,n);
     writeln('am iesit din put_matr');
end;{put_matr}


begin
     cit_matr(a,n);
     writeln('rangul este: ',n);
     writeln('puterea este: ');
     readln(p);
     put_matr(a,n,p,rez);
     writeln('Matricea la puterea ',p, ' este: ');
     afis_matr(rez,n);
     mul_matr(a,a,n,rez);
     writeln('Matricea a la p x a a la p este: ');
     afis_matr(rez,n);
end.