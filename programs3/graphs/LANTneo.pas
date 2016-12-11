{program care descopera toate lanturile dintr-un graf neorientat,
un lant apare odata ce are mai mult de 3 elemente
toate lanturile pornesc din varful 1}
program determinareaDElanturiIntr_unGraf_neorintata;
uses crt;
var n:integer;
    a:array[1..100,1..100] of integer;
    st:array[1..100] of integer;
     i,j:integer;
         k,p:integer;
        f:text;
    procedure citireMATfis;
    var i,j:integer;
    begin
    assign(f,'graflant.txt');reset(f);
     readln(f,n);
     for i:=1 to n do
        begin
         for j:=1 to n do
           read(f,a[i,j]);{ readln(f);<-si cu el si fara merge ,nu merge cu if j=n then readln;}
        end;
       close(f);
     end;
     procedure initializre;
     var i:integer;
     begin
     for i:=1 to n do st[i]:=0;
     end;
     procedure tipar(p:integer);
     var k:byte;
      begin
     for k:=1 to p do write(st[k]:1,',');writeln;
      end;
     function valid(p:integer):boolean;
      var nr,i:integer;ok:boolean;
        begin
        ok:=true;
        if a[st[p],st[p-1]]=0 then ok:=false;
           if ok then
            for i:=2 to p-1 do
              if st[p]=st[i] then ok:=false;
              valid:=ok;
        end;
      procedure bktr(p:integer);
       var val:word;
        begin
        for val:=1 to n do
          begin
          st[p]:=val;
           if valid(p)  then
              if (st[p]=st[1]) and (p>=3) then tipar(p)
                                         else bktr(p+1);
          end;
        end;

        begin
         initializre;
         citireMATfis;
         bktr(1);
         delay(3000);write('paul m');
        end.