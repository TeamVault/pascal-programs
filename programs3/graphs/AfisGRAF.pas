{program citirea unei matrici , unui graf neorintat dintr-un fisier text si de la tasta tura si afisarea celor 2 matrici}
{+explicatii si pentru graf orintata , diferentele}
program  citireaAdouaMatriciDeLaTastaturaSiFisTextSiAfisareaLor;
uses crt;
type mat=array[1..100,1..100] of integer;
var  a,a2:mat;
     i,j:integer;
     k,n2,m,n:integer;
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
    procedure citireMATtastatura;
     var x,y:integer;
     begin
     write ('dati nr de linii si nr de muchii');readln(n2,m);{nu se cere si numarul de coloane deoarece avem de-a face
      cu un graf neorintata care nr de linii = cu cel de coloane}
       for i:=1 to n2 do
        for j:=1 to n2 do
           begin
           a2[i,j]:=0;
           end;
      for k:=1 to m do
       begin
      write ('muchia', k:2 ,'are extremitatile intre varfurile');{valoarea varfurilor este cuprinsa intre 1 si n2,vf in [1,n2]}
      readln(x,y);a2[x,y]:=1;a2[y,x]:=1;{daca ar fi graf orientat nu ar exista a2[y,x]:=1 si nr de linii ar fi diferit de cel de coloane
      graful neorientat nu este simetric fata de diagonala principala}
       end;
     end;
     procedure afisareMAT(A:mat;n:integer);
     begin
       for i:=1 to n do
        begin
         for j:=1 to n do
           write(A[i,j]);readln;
        end;
     end;
     begin
    citireMATfis;
   citireMATtastatura;textcolor(green);
   write('matricea din fisierul text');readln;textcolor(white);
   afisareMAT(a,n);textcolor(green);
   write('matricea de la tastatura');readln;textcolor(white);
   afisareMAT(a2,n2);
  end.