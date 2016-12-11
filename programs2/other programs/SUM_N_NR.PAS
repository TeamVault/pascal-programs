Program suma_a_n_nr;
uses crt;
var n,x,S,i:real;
Begin
clrscr;
write ('dati nr de nr');readln (n);
S:=0;i:=1;
repeat
begin
write ('dati x');
readln (x);
S:=S+x;
i:=i+1;
Until i<=n;
end
write ('suma e:' S:5:2);
readln (S);
End.
