Program PermutariDeNElementeRECURSIVA;{permutari=aranjamente}
uses crt;
 var st:array[1..100] of integer;
     n:integer;
    procedure initializare;
      var i:integer;                                                   {dwcfjsdcjk}
       begin
      write('n=');readln(n);
      for i:= 1 to 50 do st[i]:=0;
       end;
    procedure tipar(p:integer);
    var i:integer;
     begin
     for i:=1 to p do write(st[i]:4,',');
       writeln;
     end;
    function valid(p:integer):boolean;
    var i:integer;posibil:boolean;
      begin
      posibil:=true;
       for i:=1 to p-1 do
       if st[p]=st[i] then posibil:=false;
       valid:=posibil;
      end;
    procedure bktr (p:integer);{implementeaza altgoritmul bktr}
     var  val:integer;
     begin
     for val:=1 to n do
        begin{in variabila val trec pe rand toate vaorile care ar putea fi incercate in nivelul p}
     st[p]:=val;
     if valid(p) then
      if p=n then tipar (p)
             else bktr(p+1);
         end;
      end;
      begin
      initializare;
      bktr(1);{plecam de la nivelul 1 de pe stiva}delay(3000);
      end.