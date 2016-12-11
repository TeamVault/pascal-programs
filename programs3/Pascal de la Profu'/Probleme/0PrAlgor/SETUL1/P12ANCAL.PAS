program bisect;
uses crt;
var an :0..3000;
    bis:boolean;
begin
clrscr;
     writeln('dati anul');
     readln (an);
     bis:=false;
     if(an=1000)or(an=2000)or(an=3000) then bis:=true
     else
     if (an mod 4=0)and(an mod 100<>0) then  bis:=true;
     if bis
               then
               writeln('este an bisect')
               else
               writeln('nu este an bisect');
readln;
end.