{Descompuneti un numar natural intr-o suma de numere Fibonacci}
program descompunere_n_in_suma_de_numere_fibonacci;
type natural=0..15000;
var n:natural;
    a,b,c:natural;
    fibo:boolean;
    nr,i:integer;
Begin
     write('Introduceti numarul ,n>0 ,n=');
     readln(n);
     write(n,'=');
     fibo:=true;
   Repeat
      a:=0;b:=1;c:=a+b;
      While c<n do
            begin
                 a:=b;b:=c;c:=a+b;
            end;
      If c=n then
                Begin
                  if Fibo then writeln('numarul ',n,' este numar fibonacci')
                          else writeln(c);
                  n:=0;
                end
             else
                Begin
                  fibo:=false;
                  write(b,'+');
                  n:=n-b;
                end
   until n=0;
readln;
End.
