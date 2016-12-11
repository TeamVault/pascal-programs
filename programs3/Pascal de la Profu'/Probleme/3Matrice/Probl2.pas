{Enuntul problemei
=>Se considera o matrice patrtica A de dimensiuni n*n.Matricea este citita din
fisierul de intrare Input.txt.Fiecare linie a fisierului contine cate o linie
a matricei.Nu este specificata valoarea lui n.
Se cere:
1-sa se calculeze media aritmetica a elementelor impare a matricei;
2-sa se afiseze toate elementele matricei situate deasupra diagonalei(inclusiv
a diagonalei sub forma unui triunghi si sa se calc. suma lor(afisare pe ecran);
3-sa se reaseze elementele matricei a.i. ele sa apara in ordine crescatoare;
matricea astfel obtinuta se va afisa intr-un fisier de iesire Output.txt}
program matrice_probleme;
uses crt;
type matrice=array[1..5,1..5]of integer;
     vector=array[1..9]of integer;
var a:matrice;
    n,i,j:byte;
    Ma:real;
    f,g:text;
    vaux:vector;
    S,buc:integer;
procedure citeste_matricea(var a:matrice;var n:byte);
var i,j:byte;

begin assign(f,'input.txt');
      reset(f);
      i:=0;
    while not(eof(f)) do begin
                           i:=i+1;
                           j:=0;
                          while not eoln(f) do begin
                                                  j:=j+1;
                                                  read(f,a[i,j]);
                                                end;
                                             readln(f);
                          end;
     n:=i;
     close(f);
end;

procedure suma_el(var a:matrice; var n:byte;var S:integer);
var i,j:byte;
begin
   S:=0;
    for i:=1 to n do begin
       for j:=1 to n do begin
                           if i<=j then begin write(a[i,j]);
                                              S:=S+a[i,j];
                                         end
                                   else write(' ');
                            write(' ');
                          end;
                        writeln;
                   end;
{writeln('Suma elementelor de deasupra diag. principale si ale diag este:',S);
readln;}
end;

procedure ordonarea_el(var a:matrice;var vaux:vector; var n:byte);
var i,j,k:byte; aux:integer;
    gasit:boolean;
begin k:=1;
     for i:=1 to n do begin
       for j:=1 to n do begin   vaux[k]:=a[i,j];
                                k:=k+1;
                             end;
                         end;
     repeat gasit:=false;
             for k:=1 to (n*n)-1 do
                                if vaux[k]>vaux[k+1] then  begin

                                                             gasit:=true; aux:=vaux[k];
                                                             vaux[k]:=vaux[k+1];
                                                             vaux[k+1]:=aux;
                                                            end;

      until not gasit;
                      k:=0;
                      for i:=1 to n do begin
                         for j:=1 to n do  begin k:=k+1;
                                                a[i,j]:=vaux[k];

                                              end;end;


end;
procedure afisarea_el(a:matrice; n:byte);
var i,j:byte;
begin assign(g,'output.txt');
      rewrite(g);
    for i:=1 to n do
            for j:=1 to n do  begin
                                     write(g,a[i,j],' ');
                                     writeln;{cand afis in fis text rezultatul}
                                 end;        {     nu-l afis sub forma de matrice}

      close(g);
end;
begin
citeste_matricea(a,n);
Ma:=0;buc:=0;
 for i:=1 to n do
   for j:=1 to n do
                 if (a[i,j] mod 2 <>0) then begin
                                                 Ma:=Ma+a[i,j];
                                                 buc:=buc+1;end;
clrscr;
writeln('Rezolvarea problemei date are solutiile');
readln;
writeln('1.Media aritmetica a elementelor impare a matricei este:',Ma/buc:3:2);
readln;
suma_el(a,n,S);
writeln('2.Suma elementelor de deasupra diag. principale si ale diag este:',S);
readln;
ordonarea_el(a,vaux,n);
afisarea_el(a,n);
writeln('3.Matricea obtinuta in urma ordonarii elementelor se gaseste in Output.txt');
readln;
end.