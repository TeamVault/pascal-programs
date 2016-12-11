Program Arie_lat;
uses crt;
var a,b,c,x,p:real;
BEGIN
clrscr;
write('dati latura1:');
readln(a);
write('dati latura2:');
readln(b);
write('dati latura3:');
readln(c);
 if (a<=0) or (b<=0) or (c<=0) or (a+b<=c) or (a+c<=b) or (b+c<=a)
             then
            write('solutie imposibila')
            else
            begin
   p:=(a+b+c)/2;
   x:=sqrt(p*(p-a)*(p-b)*(p-c));
   write('aria este:',x:4:1);
   end;
   readln;
   read
   END.
