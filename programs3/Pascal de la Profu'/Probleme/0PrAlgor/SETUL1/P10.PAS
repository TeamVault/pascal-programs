program Nicoara_Alina;
var a,b,c:integer;
begin
writeln('a,b,c');
read(a,b,c);
if (a>b) and (a>c) then
   if a*a=b*b+c*c  then
   writeln('laturile determ un triunghi dreptunghic')
                    else
   writeln('laturile nu determ un triunghi dreptunghic');
if (b>a) and (b>c) then
    if b*b=a*a+c*c then
    writeln('laturile determ un triunghi dreptunghic')
                    else
   writeln('laturile nu determ un triunghi dreptunghic');
if (c>a) and (c>b) then
    if c*c=b*b+a*a then
      writeln('laturile determ un triunghi dreptunghic')
                    else
      writeln('laturile nu determ un triunghi dreptunghic');
   readln;
end.