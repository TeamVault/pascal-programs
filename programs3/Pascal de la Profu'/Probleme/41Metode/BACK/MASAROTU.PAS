program dusmani;
uses crt;
{ Un grup de n persoane fiecare avand numele de la 1 la n  sunt asezate pe
scaune.Intre oricare 2 persoane alaturate izbucneste un conflict.Acest
program aseaza persoanele astfel incat sa nu se mai certe.Conditia este ca
intre 2 persoane intre care a izbucnit un conflict sa fie cel putin una sau
cel mult 2 persoane.}
const n=10;
type vec=array[1..100] of byte;
var s:vec;k:byte;

function pr:byte;
begin pr:=1;
end;

function urm(k1:byte):byte;
begin
urm:=s[k1]+1;
end;

function ult(k1:byte):boolean;
begin
ult:=(s[k1]=n);
end;

function cond(k1:byte):boolean;
var i,j:integer;kod:boolean;
begin cond:=true;

for i:=1 to k1-1 do
if (s[i]=s[k1])  then begin cond:=false;break;end;
for i:=1 to k1 do
   if (abs(s[k1]-s[i])=1)and(abs(k1-i)<>2)and(abs(k1-i)<>3)then cond:=false;


end;




procedure tip;
var i:integer;
begin
 for i:=1 to n do
      write(s[i],' ');
 if readkey=#27 then halt else
 writeln;

end;

{procedure back(k:byte);
var i:integer;
begin
for i:=1 to n do
   begin
     s[k]:=i;
     if (k=n)and (cond(k))then tip;
     if (k<n)and (cond(k))then back(k+1);
   end;
end;  }
begin readln;
{programul principal};
k:=1;
s[k]:=pr;
repeat
while (k<n)and(cond(k))do
begin
k:=k+1;
s[k]:=pr;
end;
if (k=n)and(cond(k)) then tip;
while (k>0)and(ult(k))do
k:=k-1;
if k>0 then s[k]:=urm(k);;
until k=0;
end.























