   {la un con curs hipic sunt n obstacole numerotate 1,2,3..n traseul pe care calareti trebuie sa-l urmeze trebuie sa tina cont de:
   se poate incepe cu orice obstacol,trebuie sarite toate obstacolele 1 data fiecare
   distanta intre obstacole poate fi parcursa doar intr-un singur sens, fara bktr
   practic trebuie afisat un drum elementar care trece toate nodurile grafului, apare graful turneu pg52 cartea info 11-a vechea}
   program concurs_hipic_drum_elementar_care_trece_prin_toate_noduril_grafului;
   var a:array[1..50,1..50]of byte;
       L:array[1..50] of integer;
       n:integer;
     procedure citire_matrice;
      var i,j:integer;
       begin
        write('n=');readln(n);
        {initializarea cu 0 a diag prin.}
        for i:=1 to n do a[i,i]:=0;
          for i:=1 to n-1 do
             for j:=i+1 to n do
             begin
             {citeste elementele deasupra diag. principale}
              repeat
              write ('exista acces de la ',i,'la',j,' sau invers [1/0]?');
              readln(a[i,j]);
              until a[i,j] in [0,1] ;{daca a[i,j] =1 atunci a[j,i] va fi 0 si invers marcand faptul ca intre 2 noduri exista un singur nod}
                a[j,i]:=1-a[i,j];
              end;
        end;

       procedure generare_drum;
        var k,i,j,p,m:integer; g:boolean;
        begin
        {introducerea in vector primele 2 noduri in ordinea data de nodurile muchiei directe}
         if a[1,2]=1 then
           begin
           L[1]:=1; L[2]:=2;
           end
                     else
           begin
            L[1]:=2; L[2]:=1;
           end;
           m:=2;{m nr. de noduri adaugate in vectorul L care deocamdata este 2}
             for k:=3 to n do
             {adauga pe rand fiecare nod k in vect. L}
               begin
               {daca exista arc de la nodul k la L[1] atunci nodul k se va adauga la inceputul drumului deja existent}
                if a[k,L[1]]=1 then p:=1  {p= pozitia pe care se va insera nodul k in vect}
                               else
                               {in caz contrar va insera nodul k in interiorul vectorului sau la sfarsit}
                             begin
                             {cauta pozitia p pe care se va insera k}
                             i:=1;g:=false;
                             while (i<m) and (not g) do
                              if (a[L[i],k]=1) and (a[k,L[i+1]]=1) then g:=true
                                                                   else
                                                                   i:=i+1;
                                                                   p:=i+1;
                              end;
     {pt a insera nodul k pe pozitia p mutam cu opozitie mai la dreapta toare elementele aflate dupa pozitia p inclusiv}
     for j:=m downto p do L[j+1]:=L[j];
     L[p]:=k;  m:=m+1;


               end;
           end;
    procedure afisare_drum;
    var i:integer;
    begin
    writeln;
    for i:=1 to n do write(L[i]:2);
    end;

     begin
     citire_matrice;
     generare_drum;
     afisare_drum ;
     end.