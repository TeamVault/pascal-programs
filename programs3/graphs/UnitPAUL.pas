{program care creaza un unit hibrid pe nume paul m}

 unit paulM;
  interface
     type   complex=object
            re,im:real;
            constructor init(a,b:real);
            constructor generare (x:real);
            function modul:real;
            procedure afisare;
            end;
  implementation
     constructor complex.init(a,b:real);
        begin re:=a; im:=b; end;
     constructor complex.generare(x:real);
        begin re:=x; im:=0; end;
     function complex.modul:real;
        begin modul:=sqrt(sqr(re)+sqr(im)); end;
     procedure complex.afisare;
        begin writeln (re:5:2,'+',im:5:2,'*i');end;

begin
end.