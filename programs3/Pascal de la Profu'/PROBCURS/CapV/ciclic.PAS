const ni='graf.in';
      no='graf.out';
var v:array[1..200] of set of byte;
    n,i,k,l:byte;
    m:word;
    sw:boolean;
procedure citeste1;
begin
     assign(input,ni);reset(input);
     readln(n,m);
end;
procedure da;
begin
     write('Graful este ciclic.');
end;
procedure nu;
begin
     write('Graful este aciclic.');
end;
procedure vezi;
begin
     for i:=1 to n do v[i]:=[];
     for i:=1 to m do begin
         readln(k,l);
        v[k]:=v[k]+[l]+v[l];
        v[l]:=v[l]+[k]+v[k];
     end;
     sw:=false;
     for i:=1 to n do if i in v[i] then sw:=true;
     if sw then da
           else nu;
end;
begin
   citeste1;
   assign(output,no);rewrite(output);
   if m>=n then da
           else vezi
end.