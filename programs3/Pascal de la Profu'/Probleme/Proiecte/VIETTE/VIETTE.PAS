program Formule_Viette;

{$N+}

uses crt;

var x:array[1..1000] of real; {Coeficientii}
    s1,s2:array[1..1000]of extended; {vectori care in momentul i contin :
                                       s1 : sumele Viette cu primele i-1 r†d†cini
                                       s2 : sumele Viette cu primele i r†d†cini}
    n,i,j,k,l:integer; { n : gradul;
                         i,j,k : contori}

    f:text;            {fisierul de intrare/iesire}
    nf:string;         {numele fisiierului de intrare/iesire}


begin
clrscr; { Citirea datelor }
write('nf = ');
readln(nf);
assign(f,nf);
reset(f);
readln(f,n);
for i:=1 to n do begin
                  read(f,x[i]);
                  if eoln(f) then readln(f);
                 end;
close(f);
for i:=1 to n do begin
                  s1[i]:=0;
                  s2[i]:=0;
                 end;
s1[1]:=x[1]+x[2];
s1[2]:=x[1]*x[2];
for i:=3 to n do
 begin
  s2[1]:=0;
  for k:=1 to i do s2[1]:=s2[1]+x[k];
  s2[i]:=1;
  for k:=1 to i do s2[i]:=s2[i]*x[k];
  for j:=2 to i-1 do s2[j]:=s1[j]+s1[j-1]*x[i];
  s1:=s2;
 end;
write('Fisierul de iesire : ');
readln(nf);
assign(f,nf);
rewrite(f);
for i:=1 to n do
 begin
  writeln(f,'S',i,' = ',s1[i]);
 end;
close(f);
end.


{

  Rezolvarea foloseste o definire recurenta a formulelor Viette.
  Pentru aceasta se simuleaza folosirea unei matrici A(NXN) in care elementul
Ai,j reprezint† a j-a suma Viette care foloseste primele i r†d†cini.
  Relatia de recurenta este : A[i,j]=A[i-1,j]+x[i]*A[i-1,j-1].
  Pentru a reduce memoria folosita se folosesc vectorii S1 si S2.

}
