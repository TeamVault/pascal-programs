program Media_para;
uses crt;
var v:array[1..20] of integer;
    n,i,S,j:integer;
    Ma:real;
 BEGIN
 clrscr;
write('dati n:');
readln(n);
For i:=1 to n do
      Begin
  write('dati v[',i,']=');
  readln(v[i]);
      End;
  writeln('Elementele vectorului sunt:');
 For i:=1 to n do
 writeln(v[i],' ');
      S:=0;
 For i:=1 to n do
 If v[i] mod 2=0 then
      begin
     S:=S+v[i];
     j:=j+1;
     end;
     Ma:=S/j;
write('Media aritmetica a nr pare este:',Ma:6:3);
readln;
END.