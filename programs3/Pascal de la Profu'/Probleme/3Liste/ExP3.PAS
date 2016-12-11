{Sa se creeze o lista liniara simplu inlantuita cu numele si media elevilor.
Sa se afiseze toti elevii cu medii intere 9 si 10, respectiv cei cu medii sub 9}
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
procedure   adaug;
      begin
      new(p);
      p^.nume:=elev.nume;
      p^.medie:=elev.medie;
      p^.leg:=nil;
      if ultim<>nil then ultim^.leg:=p
                    else prim:=p;
      ultim:=p;
      end;
procedure parcurg(med1,med2:real);
begin
     p:=prim;
     repeat
      if (p^.medie>med1) and (p^.medie<=med2) then
         writeln(p^.nume,p^.medie);
      p:=p^.leg;
     until p=nil

end;
begin
     write ('numele fisierului de intrare');
     readln(fis);
     assign(f,fis);
     reset(f);
     ultim:=nil;
     prim:=nil;
     while not eof(f) do
      begin
      readln(f,elev.nume);
      readln(f,elev.medie);
      adaug;
      end;
     parcurg(9.00,10);
     parcurg(1.0,9);
end.