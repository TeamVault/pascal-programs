type sir=array[1..10] of byte;
var x:sir;
    y:array[1..20] of string;
    i,n,m:byte;
    cod :boolean;
procedure solutie(x:sir;n:byte);
var i:byte;
begin
cod:=true;
for i:=1 to n-1 do
    if y[x[i]]>y[x[i+1]] then cod:=false;
if cod then
   begin
   for i:=1 to n do
       write(y[x[i]],',');
   writeln;
   end;
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
for i:=1 to n do
       begin
       write('titlul cartii ');
       readln(y[i]);
       end;
aranj(1);
end.