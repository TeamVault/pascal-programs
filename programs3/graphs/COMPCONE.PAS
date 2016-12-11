{{se da un graf neorientat si sa sew afiseze toate comp conexe precum si nr acestora 7.5.20005}
program componenteConexeSinrLOR;
uses crt;
var m,n,pi,ps,prim,p,nc,x,y:integer;
    a:array[1..100,1..100] of integer;
    C,viz:array[1..100] of integer;
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
    function nevizitat:integer;{parcurge tabloul viz si returneaza primul nod nevizitat
    sau -1 daca numai sunt noduri nevizitate}
    var prim_nev,j:integer;
     begin
     prim_nev:=-1;  j:=1;
     while(j<=n) and (prim_nev=-1) do
       begin
       if viz[j]=0 then prim_nev:=j;
       j:=j+1;
       end;
       nevizitat:=prim_nev;
     end;
    procedure parcurgereBF(prim:integer);{face o parcurgere BF di nodul de start prim}
     var k,pi,ps,z,i:integer;
     begin
     for k:=1 to 100 do C[k]:=0;
      pi:=1; ps:=1;
      C[i]:=prim; viz[prim]:=1;
      while ps<=pi do
       begin
       z:=C[ps];
       for k:= 1 to n do
        if (a[z,k]=1) and(viz[k]=0) then
          begin
          pi:=pi+1; C[pi]:=k; viz[k]:=1;
          end;
         ps:=ps+1;
       end;
       for k:=1 to pi do write(C[k]:3);
     end;

    begin
    write('Afisam componentele conexe');
      citire_mat;
      for p:=1 to 100 do viz[p]:=0;
      writeln('Dati varful de plecare ');readln(prim);
      nc:=0;{in nc se nr. componentele conexe}
       repeat
       nc:=nc+1;
       parcurgereBF(prim);writeln;
       prim:=nevizitat;
       until prim=-1;
     writeln('Sunt ',nc,'componente conexe');
     if nc=1 then writeln('graful este conex')
             else
                  writeln('graful nu este conex');delay(4000);
     end.