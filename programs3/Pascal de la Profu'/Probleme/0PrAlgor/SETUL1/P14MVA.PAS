program tarani;
uses crt;
var  S1 ,S2,S3,r:real;
     gasit:boolean;
begin
clrscr;
     writeln('dati suma pe care o are Mihai');
     readln(S1);
     writeln('dati suma pe care o are Vasile');
     readln(S2);
     writeln('dati suma pe care o are Alin');
     readln(S3);
     writeln('dati suma rachetei nucleare ');
     readln(r);
     gasit:=false;

         if S1+S2=r then gasit:=true
                     else
                     if S1+S3=r then gasit:=true
                                else
                                if S2+S3=r then gasit:=true
                                            else
                                            if S1+S2+S3=r then gasit:=true;
      if gasit then
                    writeln('exista posibilitatea')
               else
                    writeln('nu exista posibilitatea');
      readln;
end.