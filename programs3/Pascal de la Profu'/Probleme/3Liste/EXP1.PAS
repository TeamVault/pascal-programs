{Sa se creeze o stiva care contine numele si media unor elevi
 Sa se afiseze lelevii in ordinea inversa a introducerii}
type lista=^element;
     element=record
                   nume:string[20];
                   medie:real;
                   leg:lista;
             end;
var p,q,stiva:lista;
    f:text;
    elev:element;
    fis:string[10];
procedure   adaug;
      begin
      new(p);
      p^.nume:=elev.nume;
      p^.medie:=elev.medie;
      p^.leg:=stiva;
      stiva:=p;
      end;
begin
     readln(fis);
     assign(f,fis);
     reset(f);
     stiva:=nil;
     while not eof(f) do
      begin
      readln(f,elev.nume);
      readln(f,elev.medie);
      adaug;
      end;
     repeat
      writeln(p^.nume,p^.medie);
      stiva:=p^.leg;
      dispose(p);
      p:=stiva;
     until p=nil
end.