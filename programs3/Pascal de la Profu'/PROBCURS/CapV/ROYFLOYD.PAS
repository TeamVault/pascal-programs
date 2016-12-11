type multime=set of 1..50;
     matrice=array[1..100,1..100] of word;
     matricee=array[1..50,1..50] of multime;
var a,c:matrice;
    d:matricee;
    dr:array[1..100] of 1..100;
    n,m,i,j,k,t,p,s,h,r:word;
    f:text;
    timp:longint absolute $000:$046C;
    timpinit:longint;

Procedure citire;
begin
assign(f,'royfloyd.in');
reset(f);
readln(f,n,r);
for i:=1 to n do
    begin
    for j:=1 to n do
        c[i,j]:=30000;
    c[i,i]:=0;
    end;
while not eof(f) do
      begin
      readln(f,i,j,k);
      c[i,j]:=k;
      end;
close(f);
for i:=1 to n do
    for j:=1 to n do
        if (c[i,j]<30000) and (not(i=j)) then d[i,j]:=[i]
                                         else d[i,j]:=[];
a:=c;
assign(f,'royfloyd.out');
rewrite(f);
end;

Procedure drum(k:word);
begin
if timp-timpinit>18*1 then
   begin
   close(f);
   halt;
   end;
   if k<>r then begin
j:=0;
repeat
j:=j+1;
until ((c[r,k]-a[j,k]=c[r,j]) and (j<>i)) or (j=n);
if c[r,k]-a[j,k]=c[r,j] then
   begin
   drum(j);
   write(f,k,'  ');
   end;
   end
   else write(f,k,'  ');
end;

Procedure cost;
begin
for k:=1 to n do
    for i:=1 to n do
        for j:=1 to n do
            if c[i,j]>c[i,k]+c[k,j] then
               c[i,j]:=c[i,k]+c[k,j];
end;

begin
timpinit:=timp;
writeln('timpinit: ',timpinit);
citire;
cost;
for i:=1 to n do
    if i<>r then
       begin
       write(f,'Lungimea drumului intre nodurile ',r,' si ',i,' este ',c[r,i],': ');
       drum(i);
       writeln(f);
       end;
close(f);
writeln('timp: ',timp);
writeln;
end.