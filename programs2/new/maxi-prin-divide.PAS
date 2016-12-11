Program maxim_din_sir;
uses crt;
type vect=array[1..20] of integer;
var v:vect; n,i:integer;
function maxim (p,q:integer):integer;
var mij :integer; max1,max2:integer;
begin
if p=q then
maxim:=v[p]
else
               begin
mij:=(p+q) div 2;
max1:=maxim (p,mij);
max2 :=maxim (mij+1.q);
if (max1>max2) then maxim:=max1:
               else maxim:=max2;
               end;
end;
begin
writeln ('dati val lui n ')readln (n);
for i:=1 to n do
        begin
writeln ('dati v[',i,']=);teadln (v[i]);
        end;
writeln 'max din sir este',maxim (1,n))'readln;
        end.
Program maxim_din_sir;
uses crt;
type vect=array[1..20] of integer;
var v:vect; n,i:integer;
function maxim (p,q:integer):integer;
var mij :integer; max1,max2:integer;
begin
if p=q then
maxim:=v[p]
else
               begin
mij:=(p+q) div 2;
max1:=maxim (p,mij);
max2 :=maxim (mij+1.q);
if (max1>max2) then maxim:=max1:
               else maxim:=max2;
               end;
end;
begin
writeln ('dati val lui n ')readln (n);
for i:=1 to n do
        begin
writeln ('dati v[',i,']=);teadln (v[i]);
        end;
writeln 'max din sir este',maxim (1,n))'readln;
        end.