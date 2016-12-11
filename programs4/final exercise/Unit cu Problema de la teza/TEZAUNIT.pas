unit TEZAUNIT;
interface
   procedure adaugare;
   procedure afisare;
   procedure citireMAT;
implementation
  var a:array[1..30,1..30] of integer;
    i,j:integer;
    n,m,S,P,L:integer;
   procedure adaugare;
    begin
     for i:=1 to m do
     begin         { S:=0;sau aici pus tot aia ii}
     for j:=1 to n do
         S:=S+a[j,i];
         a[m+1,i]:=S; S:=0;
     end;readln;
     for i:=1 to m do
        begin
     for j:=1 to n do
         P:=P+a[i,j];
         a[i,n+1]:=P;  P:=0;
        end;readln;
           L:=0;n:=n+1;m:=m+1;
               for i:=1 to n do
             begin
            L:=L+a[m,i];
              end;
             a[m,n]:=L
   end;
    procedure afisare;
    begin
     for i:=1 to m do
      begin
       for j:=1 to n do
    write(a[i,j]:2);
    writeln;
      end;
    end;
     procedure citireMAT;
     begin
     writeln ('dati nr de linii ');readln(m);
    writeln ('dati nr de coloane');readln(n);
   for i:=1 to m do
    for j:=1 to n do
         begin
     write('dati v[',i,',',j,']=');readln(a[i,j]);
         end;
     end;

end.