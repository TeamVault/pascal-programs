{Sa se calculeze
-suma a lui m si n, tasta 1
-produsul tasta 2
-catul si restul tasta 3
-sa iese din program daca se apasa tasta 4
-proceduri si functii}
Program calcul;
uses crt;
 var m,n,S,opt:integer; C,P,R,ss:real;
Procedure suma;
  begin
Writeln ('dati nr');readln (m,n);
S:=m+n;
writeln ('suma este:',S);readln (S);
   end;
procedure produs;
  begin
 writeln ('dati nr.');readln (m,n);
P:=m*n;
writeln ('prod este:',P:5:3);
  end;
Procedure catsirest;
  begin
writeln ('Dati nr!');readln (m,n);
C:=m div n;
R:=m mod n;
writeln ('rezultatele sunt:Rest=',R:4:555,' Cat=',C:4:2);
end;
begin
        repeat
                  writeln ('Daca apesi tasta 1 se va executa suma!');TextColor (15);
                  writeln ('Daca tastati tasta 2 se va executa produsul!');textcolor (red);
                  writeln ('Daca apasati tasta 3 se va executa catul si restul!');textcolor  (06);
                  writeln ('Daca apasati tasra 4 se iasa din program!');textcolor (brown+1);
                  writeln ('Daca  alegeti un nr. va rog!');readln (opt);textcolor (02); clrscr;
 case opt of
1:suma;
2:produs;
3:catsirest;
 end;
        until opt=4;
 end.