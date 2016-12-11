 program componenteTareConex;
uses crt;
type multime=set of byte;
var n,m,nc,i,j:integer;
L:set of byte;
    a:array[1..100,1..100] of integer;
    S,P,C:array[1..100] of multime;
    procedure citire_mat;
    var i,j,k,x,y:integer;
     begin
     writeln ('Dati nr. de varfuri si muchii');readln(n,m);
     for i:=1 to n do
       for j:=1 to n do
         a[i,j]:=0;
      for k:=1 to m do
       begin
       writeln ('Dati varfurile intre care sa format muchia',k);
        repeat
       readln(x,y);{valorile x si y vor fi citite numai daca fac parte din intervalul [1,n]}
        until (x>=1) and (x<=n)and (j>=1)and(j<=n) ;
       a[x,y]:=1;   a[y,x]:=1
       end;
     end;
      procedure afisareMAT;
     begin
       for i:=1 to n do
        begin
         for j:=1 to n do
           write(a[i,j]);readln;
        end;
     end;
     procedure  Mat_drumuri;{se aplica altgoritmul Roy-Warshall }
      var i,j,k:integer;
      begin
        for i:=1 to n do
         for j:=1 to n do
           for k:=1 to n do
           if a[i,j]=0 then a[i,j]:=a[i,k]*a[k,j];
      end;
     procedure det_s(i:integer);{det multimea s}
     var k:integer;
     begin
     s[i]:=[];
      for k:=1 to n do
       if a[i,k]=1 then S[i]:=S[i]+[k];
       end;
      procedure det_p(i:integer);{det multimea p}
     var k:integer;
     begin
     s[i]:=[];
      for k:=1 to n do
       if a[i,k]=1 then P[i]:=P[i]+[k];
       end;
      procedure det_tare_conexe;{descompunerea grafului in componenete conexe}
       var i,k:integer;
        begin
        L:=[];
        nc:=0;
         for i:=1 to n do
          if not (i in L) then
           begin
           nc:=nc+1;
           det_S(i);
           det_P(i);
           C[i]:=(S[i]*P[i]+[1]);
           L:=L+C[i];
           writeln('Componenta conexa',nc,'este');
            for k:=1 to n do
             if k in C[i] then write(k:2);
             writeln;
           end;
         end;

            begin
            citire_mat;
            afisareMAT;
            Mat_drumuri;
            afisareMAT;
            det_tare_conexe;
            end.