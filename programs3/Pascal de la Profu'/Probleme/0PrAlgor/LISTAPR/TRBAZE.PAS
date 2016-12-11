program tranformari;
{acest program transforma un numar dat in baza 10 intr-o baza mai mica}
uses crt;
var n,k:integer;
procedure transf(n,k:integer);
var rest:integer;
begin {rest:=n mod k;
if n>k then transf(n div k,k);
write(rest); }

if (n mod k>0) or (n div k>0) then
   begin transf(n div k,k);
         write(n mod k);
   end
end;
begin
writeln('introduceti numarul de transformat');
read(n);
writeln('introduceti baza in care doriti sa-l transformati :');
readln(k);
transf(n,k);readln;
end.
