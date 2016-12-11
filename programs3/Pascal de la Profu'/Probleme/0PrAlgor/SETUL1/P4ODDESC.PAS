program ordabcd;
var a,b,c,aux:real;
begin
writeln('introduceti a,b,c,');
readln(a,b,c);
if b<a then begin
            aux:=b;
            b:=a;
            a:=aux;
            end;
if b>c then begin
               aux:=b;
               b:=c;
               c:=aux;
             end;
if a>c then begin
             aux:=a;
             a:=c;
             c:=aux;
            end;
            writeln(' ',a:5:2,' ',b:5:2,' ',c:5:2,' ');
readln;
end.