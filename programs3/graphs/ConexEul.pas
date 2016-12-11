{program care determina daca un graf neorientata este sau nu conex si eulerian}
program GrafConexSIeulerian;
uses crt;
var m,n,pi,ps,prim,p,nc:integer;
    a:array[1..100,1..100] of integer;
    d,C,viz:array[1..100] of integer;
  procedure citire_Graf;
   {citeste nr. de muchii si muchiile de forma (x,y) si construieste matricea de adiacenta}
   var i,j,k,x,y:integer;
   begin
   write ('Numarul de varfuri:');readln(n);
   write('Numarul de muchii:');readln(m);
   {initializeaza cu 0 intreg vectorul gradelor d}
    for i:=1 to n do d[i]:=0;
    {initializeaza cu 0 toata matricea de adiacenta}
     for i:=1 to n do
      for j:=1 to n do
      a[i,j]:=0;
      {se citesc m perechi de numere de forma (x,y) }
        for k:=1 to m do
          begin
      write ('dati muchia cu nr. de ordine;',k);
           repeat
           readln(x,y);
           until (x>=1) and (x<=n) and (j>=1) and (j<=n);
          a[i,j]:=1; a[j,i]:=1;
          d[x]:=d[x]+1;d[j]:=d[j]+1;
          end;
   end;
  function nevizitat:word;
  {parcurge tabloul viz: returneaza primul nod nevizitat, sau -1 daca nu mai sunt noduri nevizitate}
  var prim_nev,j:integer;
   begin
    prim_nev:=-1;
    j:=1;
    while (j<=n) and (prim_nev=-1) do
      begin
       if viz[j]=0 then prim_nev=j;
        j:=j+1;
      end;
    nevizitat:=prim_nev;
   end;
 function conex:boolean;
  {verifica daca graful este sau nu conex returnand true sau false}
  var k,pi,ps,z:integer;
  begin
  {face o parcurgere a grafului prin altgoritmul BF(brith first) plecand din nodul de start prim}
   for k:=1 to 100 do C[k]:=0;
    for p:=1 to 100 do viz[p]:=0;
    write ('Dati varful de plecare ');readln(prim);
    pi:=1;ps:=1;
    C[1]:=prim;  viz[prim]:=1;
     while ps<=pi do
       begin
       z:=C[ps];
        for k:=1 to n do
         if (a[z,k]=1) and (viz[k]=0) then
           begin
          pi:=pi+1;  C[pi]:=k;   viz[k]:=1;
           end;
           ps:=ps+1;
       end;
     for k:=1 to pi do write(C[k]:2);
      if nevizitat=-1 then conex:=true
                       else conex:=false;
  end;
 function grade_pare:boolean;
 {verifica daca gradele tuturor varfurilor sunt nr. pare}
 var i:integer;  ok:boolean;
  begin
   ok:=true;
    for i:=1 to n do
     if d[i] mod 2 <>0 then ok:=false;
     grade_pare:=ok;
  end;

  begin
  writeln ('Afisam componentele conexe:');
   citire_graf;writeln;
    if conex=true then
      if grade_pare=true then writeln('Graful este conex si Eulerian')
                         else writeln('Graful este conex dar nu si Eulerian')
                         else writeln ('Graful nu este conex');
  end.