program generare_permutari_recursiv_varianta1;
uses crt;
var i,n:integer;
    p:array[1..100] of integer;
procedure scrie;
begin
  for i:=1 to n do write(p[i]:3);readln;
  writeln;
end;

procedure perm(n:byte);
var aux,j,i:integer;
begin
   if n=1 then scrie
          else begin
                  perm(n-1);
                  for i:=1 to n-1 do begin
                        aux:=p[i]; p[i]:=p[n]; p[n]:=aux;
                        perm(n-1);
                        aux:=p[i];p[i]:=p[n];p[n]:=aux;
                                     end;
                end;
end;
begin
   clrscr;
   write('n=');read(n);
   for i:=1 to n do p[i]:=i;
   perm(n);
end.