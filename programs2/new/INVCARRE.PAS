program inversare_recursiv;
uses crt;
var c:string;
procedure inversare;
begin
read(c);
if c<>' ' then inversare;
writeln(c);
{readln;  }
end;
begin
writeln ('dati cuv:');
readln(c);
inversare;
end.