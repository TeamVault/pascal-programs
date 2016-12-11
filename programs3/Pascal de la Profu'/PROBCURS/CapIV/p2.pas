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


procedure comb(i:byte);
var  k:byte;

begin
for k:=x[i-1]+1 to n do
begin
  x[i]:=k;
      if i<m then comb(i+1)
         else solutie(x,m);

end;
end;
begin
Write('n,m=');readln(n,m);
comb(1);
end.