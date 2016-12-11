uses crt;
type persoana= record
     nume: string[30];
     prenume: string[30];
     varsta: integer;
     end;
     ppersoana=^persoana;
var p: ppersoana;
begin
clrscr;
writeln('inainte de alocare...');
writeln('memorie heap: ',memavail);
writeln('blocul maxim de heap: ', maxavail);
new(p);
writeln('marime pointer: ',sizeof(persoana));
writeln('memorie heap: ',memavail);
writeln('blocul maxim de heap: ', maxavail);
dispose(p);
writeln('dupa  dealocare...');
writeln('memorie heap: ',memavail);
writeln('blocul maxim de heap: ', maxavail);
readln;
end.