Program verificaresuma;
uses crt;
var a,b,c:real;
begin
clrscr;
    writeln('dati a=');
    readln(a);
    writeln('dati b=');
    readln(b);
    writeln('dati c=');
    readln(c);
    if a=b+c then
                 write('nr',a:9:0,'este suma lui' ,b:9:0,'+',c:9:0);
    if b=a+c then
                 write('nr',b:9:0,'este suma lui',a:9:0,'+',c:9:0);
     if c=a+b then
                 write('nr',c:9:0,'este suma lui',a:9:0,'+',b:9:0);
     if (a<>b+c) and (b<>a+c)and (c<>a+b) then
              write('nici un numar nu este suma celorlalte doua');
readln;
end.