{Se da un cuvant format din maxim 255 de caractere. }
{Din acest cuvant se obtine parola sa prin scrierea de la dreapta }
{la stanga acaracterelor de pe pozitii impare.}
{Exemplu: pentru cuvantul algoritm parola este trga}
program parola;
uses crt;
var cuv:string;
function invers(cuv:string):string;
var    i,n:byte;
    l:string;
begin
l:='';
i:=1;
while i<=length(cuv) do
begin
l:=cuv[i]+l;
i:=i+2;
end;
invers:=l;
end;
begin
clrscr;
textbackground(12);
textcolor(11);
write('dati cuv ');read(cuv);
write('parola este ',invers(cuv));
readln;
readln;
end.