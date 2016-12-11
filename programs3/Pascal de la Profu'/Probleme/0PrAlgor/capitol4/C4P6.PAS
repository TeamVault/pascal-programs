program suma;
var n1,n2:longint;
s1,s2,x:real;
begin
     s1:=0;
     s2:=0;
     read(x);
     while x<>0 do
     begin
          if x>0 then
             begin
             s1:=x+s1;
             inc(n1);
             end
                 else
             begin
             s2:=x+s2;
             inc(n2);
             end;
          readln(x);
     end;
     writeln('suma celor ',n1,' nr pozitive este ',s1:7:1);
     writeln('suma celor ',n2,' nr negative este ',s2:7:1);
readln;
end.
