type sir=array[1..10] of byte;
var x:sir;
    n,m:byte;

procedure solutie(x:sir;n:byte);
var i:byte;
begin
for i:=1 to n do
write(x[i],',');
writeln;
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

procedure permut(j:byte);
var  i:byte;

begin
for i:=1 to n do
begin
  x[j]:=i;
  if valid(j) then
    if j<n then permut(j+1)
         else solutie(x,n);

end;
end;


begin
Write('n');readln(n);
permut(1);
end.