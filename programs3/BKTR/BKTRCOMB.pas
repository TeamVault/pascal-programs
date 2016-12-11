Program CombinariDeNelementeLuateCateK;{permutari=aranjamente}
uses crt;
 var st:array[1..100] of integer;
     n,k:integer;
    procedure initializare;
      var i:integer;
      begin
       repeat
      write('n=');readln(n); write('k=');readln(k);
       until n>=k;
       for i:= 1 to 50 do st[i]:=0;
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
      posibil:=true;
       for i:=1 to p-1 do
       if st[p]<=st[i] then posibil:=false;
       valid:=posibil;
      end;
    procedure bktr (p:integer);
     var  val:integer;
     begin
      if n=1 then writeln('Combinari de n luate cate 0 sau 1 =',1)
             else
     for val:=1 to n do
        begin{in variabila val trec pe rand toate vaorile care ar putea fi incercate in nivelul p}
     st[p]:=val;
     if valid(p) then
      if p=k then tipar (p)
             else bktr(p+1);
         end;
      end;
      begin
      initializare;
      bktr(1);{plecam de la nivelul 1 de pe stiva}delay(3000);
      end.