program det_max_din_sir_prin_divide_et_impera;
{uses crt;}
var x:array[1..100]of integer;
    n,i:integer;
function max(p,q:integer):integer;
var a,b:integer;
begin
  if p=q then max:=x[p]
     else
     begin a:=max(p,(p+q)div 2);
           b:=max((p+q)div 2+1,q);
           if a>b then max:=a {b pentru determinarea minimului}
           else max:=b{a pentru determinarea minimului};
     end;
end;
begin
writeln('introduceti ne elementelor sirului n=');
read(n);
writeln('introduceti elementele sirului');
for i:=1 to n do
begin
write('x[',i,']=');
readln(x[i]);
end;
write('maximul este:',max(1,n));
readln;
end.

