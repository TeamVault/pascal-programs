program nr_negative_inversate;
uses crt;
var  n:byte;
procedure inversare(i:byte);
var a:real;
begin
write('introduceti al ',i,' lea nr');read(a);
if i<n then inversare(i+1)
       else write('nr negative inversate sunt');
if a<0 then write(a:9:3);
end;
begin
clrscr;
textcolor(yellow);
textbackground(blue);
write('cate nr sunt:');read(n);
inversare(1);
readln;
end.

