{intr-un grup sunt n elevi care de la 1 la n, fiecare elev cunoaste o parte din ceilalti elevi
 relatia de cunostinta nu este reciproca daca x il cunoaste pe y asta nu inseamna ca y trebuie neaparat sa-l cunoasca pe x
 Fiecare elev vrea acel CD ,transmiterea acelui CD se va  face doar intre elevi care se cunosc.
 se pune problema daca acel CD poate trece pe la fiecare copil 1 data si sa ajunga din nou la stapan.
 Se cere afisarea unui circuit elementar care trece prin toate nodurile grafului (intr-un graf orintat)
 rezolvarea consta in afisarea unui ciclu, circuit elementar daca exista, in functie datele introduse in matrice pg 51 info. veche}
  program Afisare_unui_circuit_intre_toti_elevi_unui_grup;
  uses crt;
  var n,x:integer;
      st:array[1..100] of integer;
      a:array[1..100,1..100] of integer;
   procedure citirea_matice;
   var i,j:integer;
     begin
     write('Numarul de noduri');readln(n);
     for i:=1 to n do
      for j:= 1 to n do
        begin
        write ('[',i,',',j,']=');readln(a[i,j]);
        end;
     end;

    procedure initializari;
      {initializeaza stiva si citeste adtele problemei}
      var i:integer;
        begin
        write ('Cine este propritarul:');readln(x);
         for i:=1 to 25 do st[i]:=0;
        end;
    procedure tipar (p:integer);
     var k:integer;
     begin
      write(x,' ');
      for k:=1 to p do write(st[k]:2,' ');
       writeln;
     end;
    function valid (p:integer):boolean;
    {testeaza dac aval. pusa pe stiva a generat o solutie valida}
     var nr,i:integer;ok:boolean;
        begin
        {CD-ul circula doar intre elevii care se cunosc deci st[i-1] trebuie sa-l cunoasca pe sr[i]}
        ok:=true;
        if a[st[p-1],st[p]]=0 then ok:=false;
         if ok then
         {propritarul x nu se poate pe un nivelanterior ultimului}
           if (p<n) and (st[p]=x) then ok:=false;
          if ok then
          {elevul st[p] nu trebuie sa se mai gaseasca pe nivele anterioare}
           for i:=1 to p-1 do
             if st[p]=st[i] then ok:=false;
             valid:=ok;
         end;
      procedure bktr (p:integer);
      {implementeza altgoritnul de backtracking recursiv}
      var val:integer;
       begin
       {in var val trec pe rand toate val.care ar putea fi incercate pe nivelul p al stivei}
         for val:=1 to n do
          begin
          st[p]:=val;
          if valid (p)then
           if (p=n) and(st[n]=x) then tipar(p)
                                 else bktr(p+1);
          end;
        end;

       begin
        initializari;
        citirea_matice;
        bktr(1);
       end.