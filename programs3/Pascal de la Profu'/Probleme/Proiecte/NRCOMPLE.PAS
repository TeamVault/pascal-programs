{Scrieti un program,folosind proceduri sau functii care sa permita calcule cu
numere complexe.}
program calcul_cu_nr_complexe;
uses crt;
type nrcomplex=record
               r:real;
               im:real;
               end;
var x,y,z:nrcomplex;
    c:char;
    n:byte;
procedure citire(var x:nrcomplex);
begin
  writeln('Introduceti un numar complex x=');
  write('re=');readln(x.r);
  write('im=');readln(x.im);
end;
procedure scrie(x:nrcomplex);
begin
  write('(',x.r:4:1,')+(',x.im:4:1,')*i');
end;
procedure adun(x,y:nrcomplex;var z:nrcomplex);
begin
  z.r:=x.r+y.r;
  z.im:=x.im+y.im;
end;
function modul(x:nrcomplex):real;
begin
  modul:=sqrt(sqr(x.r)+sqr(x.im));
end;
procedure inmultire(x,y:nrcomplex;var z:nrcomplex);
begin
  z.r:=x.r*y.r-x.im*y.im;
  z.im:=x.r*y.im+x.im*y.r;
end;
Procedure conjugat(x:nrcomplex;var y:nrcomplex);
begin
  y.r:=x.r;
  y.im:=-x.im;
end;
procedure impartire(x,y:nrcomplex;var z:nrcomplex);
var a,b:nrcomplex;
begin
  conjugat(y,a);
  inmultire(x,a,b);
  z.r:=b.r/sqr(modul(y));
  z.im:=b.im/sqr(modul(y));
end;
begin
  c:='D';
  while c='D' do
         begin
           clrscr;
           writeln('Alegeti:');
           writeln('1 Adunare');
           write('2 Scadere');
           write('3 Inmultire');
           write('4 Impartire');
           write('5 Modul');
           write('6 Conjugat');
           write('7 Iesire');
           readln(n);
          case n of
             1: begin
                citire(x);citire(y);
                adun(x,y,z);
                scrie(x);write('+');scrie(y);
                write('=');scrie(z);
                end;
             2:begin
                citire(x);citire(y);
                adun(x,y,z);
                scrie(x);write('-');scrie(y);
                write('=');scrie(z);
                end;
             3:begin
                citire(x);citire(y);
                inmultire(x,y,z);
                scrie(x);write('*');scrie(y);
                write('=');scrie(z);
                end;
             4:begin
                citire(x);citire(y);
                impartire(x,y,z);
                scrie(x);write('/');scrie(y);
                write('=');scrie(z);
                end;
             5:begin
                citire(x);
                write('I');scrie(x);
                write('I=',modul(x));
                end;
             6:begin
                citire(x);
                conjugat(x,y);
                write('x conjugat este ');
                scrie(y);
                end;
             7: c:='N';
           end;
         readln;
         end;
end.

























































