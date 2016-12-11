{Intr-un fisier sunt litere mici si mari. Sa se afiseze intr-un fisier de
iesire literele mici transformate in mari si in alt fisier cela mari tran-
sformate in mici.}
uses crt;
var a:char;
    f,g,h:text;
begin
 clrscr;
 assign(f,'intrare.in');
 reset(f);
 assign(g,'litmici.out');
 rewrite(g);
 while not eof(f) do
   begin
     while not eoln(f) do
        begin
          read(f,a);
          case a of
            'a'..'z' :write(g,chr(ord(a)-32));
            'A'..'Z' :write(g,chr(ord(a)+32));
          end;
       end;
     readln(f);
     writeln(g);
   end;
   close(f);
   close(g);
 readkey;
end.
