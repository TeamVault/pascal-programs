{program sa se afiseze in ordine invesa caracterele unui cuvant citit de la
tastatura caracter cu caracter pana la intalnirea spatiului}
program invesare_cuvant;
uses crt;
type
  vector=array [1..50] of char;
var
  v:vector ;n,i:integer;
begin
clrscr;
writeln ('dati nr de caractere din care este alcatuit cuvantul!');readln(n);
for i:=1 to n do
  begin
     writeln('dati caracterele',i,': ');
     readln (v[i]);
  end; writeln ('acesta este stringul in ordine inversa :'); 
for i:=n downto 1 do

write (v[i]);
readln;
end.