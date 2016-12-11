Program M_magazineSI_N_produse;
uses crt;

   var v:array[1..100,1..100]of integer;
       n,m,i,j,p,aux:integer; gata:boolean;
   begin
      writeln('dati nr de magazine si nr de produse');readln(m,n);
      for i:=1 to n do
      for j:=1 to m do
       begin
       write('dati pretul prod',i,'din magazinul',j);readln(v[i,j]);
       readln;
       end;
       begin
      repeat
gata:=true;
for i:=1 to n-1 do
for j:=1 to n do
if v[i+1,j]< v[i,j] then
  begin
gata:=false;
aux:=v[i,j];
v[i,j]:=v[i+1,j];
v[i+1,j]:=aux;
  end
until gata;
        end;
for i:=1 to n-1 do
for j:=1 to n do
begin
write(v[i,j]);
end;

                    P:=0;
            for i:=1 to n do
            begin
            inc(p);
            writeln ('prod',p,'pretul este',v[i,j],' din magazinul',j:2);
            end;
     end.