{Determinati o zona dreptunghiulara de arie maxima, dintr-o matrice,
cu proprietatea ca toate elementele sale sunt egale
pentru simplitatea calculelor la matrice de dimensiuni mari}
{am scris o procedura care genereaza aleator tablouri de intrare}
program tablou;
uses crt;
type mat=array[1..100,1..100] of byte;
var a:mat;
    m,n,i,j,k,l,mi,mj,ml,mk:byte;
    fis:string;
    f:text;
    nr,max:word;
{secventa de citire a elementelor unei matrice dintr-un fisier text }
procedure cit_mat(m,n:byte; var a:mat; fis:string);
var f:text;
begin
     assign(f,fis);
     reset(f);
     readln(f,m,n);
     for i:=1 to m do
         begin
         for j:=1 to n do
             read(f,a[i,j]);
         readln(f);
         end;
     close(f);
end;
{secventa de generare a elementelor unei matrice intr-un fisier text }

procedure gen_mat(m,n:byte; fis:string);
var f:text;
begin
     assign(f,fis);
     rewrite(f);
     writeln(f,m,' ',n);
     randomize;
     for i:=1 to m do
         begin
         for j:=1 to n do
             write(f,random(2),' ');
         writeln(f);
         end;
     close(f);
end;

{functie de verificare pentru o zona dintr-o matrice, intre coordonate}
{i,j si m,n daca toate elementele din acea zona sunt egale}
function ver(i,j,m,n:byte; a:mat):boolean;
var p,q:byte;
begin
     ver:=true;
     nr:=0;
     for p:=i to m do
         for q:=j to n do
             if a[p,q]<>a[i,j] then
                ver:=false
                                else
                nr:=nr+1;
end;

{Cauta patru elemente asezate sub forma unui dreptunghi cu elementele}
{ din cele patru colturi avand valor egale }
procedure gasire(m,n:byte);
begin
     for i:=1 to m-1 do
         for j:=1 to n-1 do
             for l:=i+1 to m do
                 for k:=j+1 to n do
                     if a[i,j]=a[l,k] then
                        if ver(i,j,l,k,a) then
                           begin
                           if max<nr then
                              begin
                              max:=nr;
                              mi:=i;mj:=j;ml:=l;mk:=k;
                              end;
                           end;
end;
begin
     max:=1;
     mi:=1;mj:=1;ml:=1;mk:=1;
     write('m,n=');readln(m,n);
     write('f1=');readln(fis);
     gen_mat(m,n,fis);
     cit_mat(m,n,a,fis);
     gasire(m,n);
     write('f2=');readln(fis);
     assign(f,fis);
     rewrite(f);
     write(f,'dreptunghiul ',mi,',',mj,',',ml,',',mk,', cu ',max,' elemente');
     close(f);
end.