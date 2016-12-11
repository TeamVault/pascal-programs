{Reuninea a doua multimi.}
program reuniune;
uses crt;
type sir=array[1..10] of real;
var a,b,z:sir;
    c:boolean;
    i,j,k,n,m:integer;
procedure citire(nrel:integer;var s:sir);
begin
     for i:=1 to nrel do
         begin
              write('Dati elementul cu nr. ',i,': ');
              readln(s[i]);
         end;
end;
procedure reuni(n,m:integer;s1,s2:sir);
begin
z[1]:=a[1];
k:=1;
for j:=1 to n do {parcurgem primul tablou si trecem in tabloul rezultat
doar elementele convenabile }
    begin
         c:=true;
         for i:=1 to k do
             if z[i]=a[j] then
                               c:=false;

             if  c then
                               begin
                                    k:=k+1;
                                    z[k]:=a[j];
                               end;
                                end;
{se procedeaza la fel cu cel de-al doilea tablou adaugand la vectorul z 
doar elementele convenabile}
     for j:=1 to m do
       begin
         c:=true;
         for i:=1 to k do
             if z[i]=b[j] then
                               c:=false;

             if  c then
                               begin
                                    k:=k+1;
                                    z[k]:=b[j];
                               end;
      end;
end;
begin
clrscr;
writeln('**********Implementare de reuniune cu ajutorul tablourilor******');
write('Dati numarul de elemente ale primei multimi:  ');
readln(n);
citire(n,a);

write('Dati numarul de elemente ale celei de a doua multime:  ');
readln(m);
citire(m,b);
reuni(n,m,a,b);
{urmeaza afisarea multimii rezultat}
for i:=1 to k do
    write(z[i]:3:2,' ');
    readln;
end.

