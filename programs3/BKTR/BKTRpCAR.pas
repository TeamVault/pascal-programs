 Program ProdusCartezianDerNmultimi;
uses crt;
 var st,nr:array[1..100] of integer;
     n,p:integer;
    procedure initializare;
      var i:integer;
       begin
        for i:= 1 to 50 do st[i]:=0;
         write('Dati nr de multimi n=');readln(n);
         for i:=1 to n do
           begin
            writeln('NR. de elemente al multimi',i);{3 elem rezulta elementele sunt 1,2,3:2 elem,rezulta elem sunt1,2}
                readln(nr[i]);
           end;
       end;
    procedure tipar(p:integer);
    var i:integer;
     begin
     for i:=1 to p do write(st[i],',');
       writeln;
     end;
    function valid(p:integer):boolean;
    var i:integer;posibil:boolean;
      begin
        valid:=true;
      end;
    procedure bktr (p:integer);{implementeaza altgoritmul bktr}
     var  val:integer;
     begin
     if p=n+1 then {daca p a depasit nivelul de solutie finala}
              tipar(p-1)
              else
     for val:=1 to nr[p] do {in val. val trec pe rand toate valorile care ar putea fi incercate pe nivelul p al stivei}
         begin{in variabila val trec pe rand toate vaorile care ar putea fi incercate in nivelul p}
     st[p]:=val;
     if valid(p) then
         bktr(p+1);
         end;
      end;
      begin
      initializare;
      bktr(1);{plecam de la nivelul 1 de pe stiva}delay(3000);
      end.