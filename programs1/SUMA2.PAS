Program SUMA2;
uses crt;
var n,x,i,S:integer;
BEGIN
clrscr;
write('dati numarul numerelor:');
readln(n);
      S:=0;i:=1;
 while i<=n do
   begin
     write('dati x:');
     readln(x);
          S:=S+x;
          i:=i+1;
   end;
write('suma este:',S);
readln
END.