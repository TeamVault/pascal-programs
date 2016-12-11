
{Program ce ridica la o putere o matrice patratica A}
program mulmatr;
type matr=array[1..10,1..10] of integer;
var a,rez:matr;
    n:integer;

FUNCTION cit_matr(var a:matr):integer;
var n,i,j:integer;
begin
     write('Introduceti rangul matricii: ');readln(n);
     for i:=1 to n do
         for j:=1 to n do
             begin
             write('A[',i,',',j,']= ');readln(a[i,j]);
             end;
     cit_matr:=n;
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
         mul_matr(a,rez,n,rez);
     end;
     afis_matr(rez,n);
     writeln('am iesit din put_matr');
end;{put_matr}


begin
     n:=cit_matr(a);
     writeln('rangul este: ',n);
     put_matr(a,n,2,rez);
     afis_matr(rez,n);
     mul_matr(a,a,n,rez);
     afis_matr(rez,n);
end.