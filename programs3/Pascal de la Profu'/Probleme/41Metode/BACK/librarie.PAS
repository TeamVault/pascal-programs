{   La o librarie se detin urmatoarele informatii despre carti:nume autor,
data aparitiei, nr.pagini, nr.bucati.sa se afiseze cartile in
ordine alfabetica a autorilor si, pentru acelasi autor, in ordinea anilor
de aparitie..
}
program librarie;
uses crt;
type carte=record
             autor:string[20];
             data_ap:record
                       zi,luna,an:integer;
                     end;
             pag:byte;
           end;
var
  a:array[1..100] of carte;
  n,anul:byte;

procedure citeste; {se realizeaza citirea cartilor, cu toate datele necesare}
var
  i:integer;
begin
  write('Numarul de carti:');readln(n);
  for i:=1 to n do
    with a[i],data_ap do
      begin
        write('Nume autor: ');readln(autor);
        write('Data aparitiei: (zi luna an) ');readln(zi,luna,an);
        write('Numarul de pagini: ');readln(pag);

      end
end;

procedure ordoneaza_dupa_autor_si_an;
  {ordoneaza cartile alfabetic dupa autor si, pentru acelasi autor
   dupa anul aparitiei cartii folosind metoda bulelor}
var
  ordonat:boolean;
  i:integer;
  aux:carte;
begin
  repeat
    ordonat:=true;
    for i:=1 to n-1 do
      if ( a[i].autor>a[i+1].autor ) or
         ( a[i].autor=a[i+1].autor ) and (a[i].data_ap.an>a[i+1].data_ap.an)
        then
          begin
            ordonat:=false;
            aux:=a[i];a[i]:=a[i+1];a[i+1]:=aux
          end
  until ordonat;
end;

procedure afiseaza;
  {se realizeaza afisarea cartilor}
var
  i:integer;
begin
  for i:=1 to n do
    with a[i],data_ap do
      begin
        write(autor:20);
        write(zi:3,luna:3,an:5);
        writeln( pag:4)
      end
end;
begin
  clrscr;
  citeste;
  ordoneaza_dupa_autor_si_an;
  writeln('Cartile, in ordinea autorilor si anilor');
  afiseaza;
  readln;
end.