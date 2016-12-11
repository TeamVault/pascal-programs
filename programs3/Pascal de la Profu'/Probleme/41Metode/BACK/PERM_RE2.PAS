program generare_permutari_revursiv_varianta2;
uses crt;
type sir=array[1..100] of integer;
var n,i:integer;a,b:sir;
  procedure permutari (m:integer;var n:integer);
  var i,j:integer;
  begin
      if m<n then
           begin
         for i:=1 to m-1 do b[i]:=a[i];
         for i:=1 to m-1 do
                  begin
                    for j:=m-1 downto i do a[j+1]:=a[j];
                    a[i]:=m;
                    permutari(m+1,n);
                    if m=n then
                             begin
                                for j:=1 to m do write(a[j]:3);
                                writeln;
                             end;
                   for j:=1 to m-1 do a[j]:=b[j];
                end;
      end;
end;
begin
  write('dati n:');read(n);
  for i:=1 to n do a[i]:=i;
  permutari(,n);
end.