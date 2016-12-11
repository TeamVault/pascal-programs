{program care construieste arborele partial de cost minim
se da un graf neorintata cu n varfuri in care fiecare muchie este caracterizata printr-un cost atasat
se cunoaste matricea costurilor, sa s eafiseze arborele partial de cost minim}
program afisarea_unui_arbore_de_cost_minim_dupa_ce_sa_creat_matrice_costurilor;
{matricea costurilor=intre oricare 2 varfuri exista un cost adica o val care caracterizeaza acea muchie}
uses crt;
type vect=array[1..100] of integer;
var a :array[1..100,1..100] of integer;
    n:integer;
    S,T,C:vect;{S-vect. caracteristic, T- a parintilor,C-costurilor}
 procedure citireMat;
 var i,j:integer;
  begin
  write ('dati nr de var linii');readln(n);
  for i:=1 to n do
  a[i,i]:=0;
   for i:=1 to n do
   for j:=1+1 to n do
    begin
    write ('dati costul muchiei ce are extremitatile intre',i,',j,');readln(a[i,j]);
     a[j,i]:=a[i,j];
    end;
  end;
 procedure afisareMat;
 var i,j:integer;
 begin
 write ('graful are ',n,'varfuri');
 write('Mat. costurilor este ');
   for i:=1 to n do
        for j:=1 to n do
           begin
           a[i,j]:=0;
           end;
 end;
 procedure afisareARBORE(mesaj:string;v:vect;n:integer);
 var i:integer;
   begin
 writeln(mesaj);
   for i:=1 to n do write (v[i]:3);
 writeln;
   end;
 procedure FORMAREarbore;{construirea arborelui partial de cost minim};
  var K,i,j,start,cost_min,n1,n2:integer;
  begin
    for i:=1 to n do
     begin
      S[i]:=0; T[i]:=0; C[i]:=0;
  {citirea varfului de start si adaugarea in arborele initial gol}
     write ('dati varful de start');readln(start);S[start]:=1;
     {intr-un ciclu se adauga pe rand celelalte n-1 varfuri, k-contor}
      for k:=1 to n-1 do
        begin
        {cauta muchia de cost minim cu o extremitate in arbore si cealalta in afara,in n1 si n2 se memoreaza extremitatile acesteor muchii}
        cost_min:=MaxInt; n1:=-1;n2:=-1;
        for i:=1 to n do
         for j:=1 to n do
          if (S[i]=1) and (S[j]=0)then
            if(a[i,j]<>0 ) then
             if (a[i,j]< cost_min) then
               begin
               cost_min:=a[i,j];n1:=i;n2:=j;
               end;
 {adauga in arbore muchia gasita (n1,n2) prin actualizarea vectorilot S,T,C}
           S[n2]:=1; T[n2]:=n1; C[n2]:=a[n1,n2];
        end;
    end;
  end;
   begin
    citireMat;
    afisareMat;
    FORMAREarbore;
   afisareARBORE('vectorul S este',S,n);
   afisareARBORE('vectorul parintilor T este',T,n);
   afisareARBORE('vectorul  costurilor C este',C,n);
  END.