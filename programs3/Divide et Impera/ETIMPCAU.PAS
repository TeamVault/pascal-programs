program CautarebinaraIntrunSIRcareTrebuieSAfieCRESCATORsauDESCRESCAROR;
uses crt;
 var v:array[1..100] of integer;
     n,x,i:byte;
     function cautare(p,q:word):integer;
     {cauta o val. x in subvectori}
     var mij:integer;
     begin
      if (p=q) or (q<p) then
         cautare:=0
             else
             begin
             mij:=(p+q) div 2;
             if v[mij]=x then
             cautare:=x
                         else{daca x < decat elem. din mijloc atunci cauta
                              in subvect.v[p],..v[mij] else in v[mij],..v[q]}
                          if x< v[mij] then cautare:=cautare(p,mij-1)
                                       else cautare:=cautare(mij,q);
              end;
     end;
     begin
     clrscr;
       write('n=');readln(n);
       write ('v[1]=');readln(v[1]);
        for i:=2to n do
          repeat
         write ('v[',i,']=');readln(v[i]); {prin repeat...until se asigura ca sa fie un sir crescator introdus ,de
         atatea ori citeste dar nu memoreaza val numai daca se indeplineste cond}
         until v[i] > v[i-1];
         writeln ('Dati val. pe care o cautati x:');readln(x);
         writeln ('val.cautata exista daca apare -',x,'- si nu eista daca apare val.-0-"',cautare(1,n),'"');readln;

     end.