{program pt aranjarea alfabetice a unei liste dintr-un fisier text}
Program AranjareaAlfabeticaAuneiListeCuNume;

var v:array[1..250] of string;
    i,j,n,p:integer;aux:string;   {fisierele sunt in bp7.0\bin}
    f,g:text;
    procedure citirea;
    var p:byte;
     begin
     p:=1;
     while not eof(f) do
       begin
     readln(f,v[p]);inc(p);
       end;n:=p;
     end;
    procedure aranjare_afisare;
     begin
    for i:=1 to n-1 do {ordonarea vectorului}
     for j:=1 to n do
       if v[j]<v[i] then
         begin{schimbarea}
         aux:=v[i];
         v[i]:=v[j];
         v[j]:=aux;
         end;textcolor(magenta);
         writeln('Ordinea alfabetica a listei cu',n-2,'elemente este:');textcolor(green);
        for i:=n-2 downto 1 do
            writeln('#',v[i]);
            readln;
     end;
     procedure completareFIS;
      begin
      writeln(g,'Ordinea alfabetica a listei compusa din-',n-2,'-elemente este:');
      for i:=n-2 downto 1 do
       begin
      writeln(g,'#:',v[i]);
       end;
      end;
         begin
         clrscr;
         assign(f,'E:\PaulMuntean\Programarea\ZonaPascal\10-A\NOI\date.txt');reset(f);
         assign(g,'E:\PaulMuntean\Programarea\ZonaPascal\10-A\NOI\rezultat.txt');rewrite(g);
          citirea;
          aranjare_afisare;
          completareFIS;
          close(f);
          close(g);
         end.