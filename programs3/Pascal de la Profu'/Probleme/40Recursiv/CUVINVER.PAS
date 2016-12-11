program inversarea_unui_sir_de_cuvinte;
var n,i:byte;
    cuv :string;
Procedure inverseaza(i:byte);
var l:char;
begin
l:=cuv[i];
if i<=length(cuv) then inverseaza(i+1)
                  else writeln('sir inversat: ');
write(l);
end;
begin
write(' n=');
readln(n);
for i:=1 to n do
begin
writeln('cuvintele:');readln(cuv);
inverseaza(1);
end;
readln;
writeln;
end.

