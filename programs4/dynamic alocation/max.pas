      program Lista_maxim_din_lista_liniara_simplu_inlantuita;
uses crt;
type pnod=^nod;
     nod=record
     info:integer;
     urm:pnod;
          end;
          var
             l,u:pnod;
             n,x,i:integer;
  procedure adcoada(var prim,ultim:pnod;x:integer);
  var nou:pnod;
  begin
if prim=nil then
   begin
   new(prim);
   prim^.info:=x;
   prim^.urm:=nil;
   ultim:=prim;
   end
            else
            begin
            new(nou);
            nou^.info:=x;
            nou^.urm:=nil;
            ultim^.urm:=nou;
            ultim:=nou;
            end;
    end;
    function maxim(prim:pnod):integer;
    var max:integer;
        p:pnod;
    begin
    p:=prim;
    max:=prim^.info;
    while p<>nil do
    begin
    if p^.info>max then max:=p^.info;
     p:=p^.urm;
     end;
     maxim:=max;
     end;
    procedure afisare(prim:pnod);
    var p:pnod;
    begin
    p:=prim;
    while P<>nil do
      begin
      writeln(p^.info:2);
      p:=p^.urm;
      end;
    end;
    begin
    l:=nil;u:=nil;
    write('Dati nr de elem. din lista n=');readln(n);
    for i:=1 to n do
      begin
      write('x=');readln(x);
      adcoada(l,u,x);
      end;
    writeln;
    afisare(l);
    writeln('Maximul este:',maxim(l));
    end.







