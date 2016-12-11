type sir=array[1..10] of byte;
var x:sir;
    n,m,pp,p:byte;

procedure solutie(x:sir;n:byte);
var i:byte;
begin
for i:=1 to n do
write(x[i],',');
writeln;
end;

Function verif(x:sir;n:byte):boolean;
var i,l:byte;
begin
l:=0;
for i:=1 to n do
    if x[i]<=pp then l:=l+1;
if l=p then verif:=true
       else verif:=false;
end;


Function valid(i:byte):boolean;
var cod:boolean;
    j:byte;
begin
cod:=true;
for j:=1 to i-1 do
    if x[i]=x[j] then cod:=false;
valid:=cod;
end;

procedure comb(i:byte);
var  k:byte;

begin
for k:=x[i-1]+1 to n do
begin
  x[i]:=k;
      if i<m then comb(i+1)
         else if verif(x,m) then solutie(x,m);

end;
end;
begin
Write('n,m,femei init,femei in grup=');readln(n,m,pp,p);
comb(1);
end.