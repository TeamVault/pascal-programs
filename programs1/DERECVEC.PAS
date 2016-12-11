Program pt_rec_unui_nr_daca_se_afla_in_vector;
uses crt;
Type vector=array[1..40] of integer;
var v:vector;
i,n,x:integer;
gasit:boolean;
Begin
clrscr;
write ('dati n=');readln (n);
write ('dati x=');readln (x);
for i:=1 to n do
begin
write ('dati v[',i,']=');readln (v[i]);
End;
write ('datix=');readln (x);
gasit:=false;
for i:=1 to n do
if gasit=v[i] write ('gasit:=true');
if gasit then write ('elementul este in sir');
         else write ('nu e in sir ');
Readln;
End.
