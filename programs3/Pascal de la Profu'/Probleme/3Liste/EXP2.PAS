{Sa se ceeze o lista ordonata dupa mediile unor elevi}
type lista=^element;
     element=record
                   nume:string[20];
                   medie:real;
                   leg:lista;
             end;
var p,q,prim,ultim:lista;
    f:text;
    elev:element;
    fis:string[10];
procedure   inserare;
      begin
      new(q);
      q^.nume:=elev.nume;
      q^.medie:=elev.medie;
      q^.leg:=p^.leg;
      p^.leg:=q;
      if p=ultim then ultim:=q;
      end;
procedure parcurg;
begin
     p:=prim;
     q:=p;
     while (q^.medie>elev.medie) and (q<>nil)  do
      begin
      p:=q;
      q:=q^.leg;
      end
end;
begin
     write ('numele fisierului de intrare');
     readln(fis);
     assign(f,fis);
     reset(f);
     readln(f,elev.nume);
     readln(f,elev.medie);
     new(p);
     p^.leg:=nil;
     p^.nume:=elev.nume;
     p^.medie:=elev.medie;
     prim:=p;
     ultim:=p;
     while not eof(f) do
     begin
      readln(f,elev.nume);
      readln(f,elev.medie);
      if elev.medie> prim^.medie then
         begin
         new(q);
         q^.leg:=prim;
         q^.nume:=elev.nume;
         q^.medie:=elev.medie;
         prim:=q;
         end
                        else
                        begin
                        parcurg;
                        inserare;
                        end;
      end;
      p:=prim;
      repeat
      writeln(p^.nume,p^.medie);
      p:=p^.leg;
     until p=nil;
end.