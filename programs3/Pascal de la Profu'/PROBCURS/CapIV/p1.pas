type sir=array[1..10] of byte;
var x:sir;
    y:array[1..20] of string;
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
procedure aranj(i:byte);
var  k:byte;

begin
for k:=1 to n do
begin
  x[i]:=k;
  if valid(i) then
      if i<m then aranj(i+1)
         else solutie(x,m);

end;
end;
begin
Write('n,m=');readln(n,m);
aranj(1);
end.