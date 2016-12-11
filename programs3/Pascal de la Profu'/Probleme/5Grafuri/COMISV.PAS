program comisvoiajor;
uses crt;
const NMaxOrase=20;
type Oras=1..NMaxOrase;
     Harta=array[Oras, Oras] of real;
     Traseu=array[Oras] of Oras;
var A:Harta; n:Oras;
    T, Tmin: Traseu; Lg, LgMin:real;
    v:array[Oras] of 0..1;

procedure Citire;
var i,j:Oras; f:text; d:real;
begin
assign(f, 'comis.in'); reset(f);
readln(f,n);
while not seekeof(f) do
      begin {de pe fiecare linie citesc doua orase
      intre care exista legatura directa, precum si
      distanta dintre ele}
      readln(f,i,j,d);
      A[i,j]:=d; A[j,i]:=d;
      end;
close(f);
end;

function Infinit:real;
{intoarce un nr suficient de mare, pe a putea fi utilizat
ca valoare de initializare pt LgMin}
var s:real; i,j:Oras;
begin
s:=0;
for i:=1 to n do
    for j:=1 to n do s:=s+A[i,j];
Infinit:=s+1;
end;

procedure Afisare;
var i:Oras;
begin
if LgMin=Infinit then writeln('Nu exista solutii')
else
    begin
    write('Traseul cel mais curt are lungimea',LgMin:10:2);
    write('Traseul este');
    for i:=1 to n do write(Tmin[i],',');
    writeln(Tmin[1]);
    end;
readln;
end;

procedure ConstrTraseu(k:oras);
var i:Oras;
begin
if k-1=n then            {traseul este complet}
   if A[1,T[n]]<>0 then  {poate reveni in orasul 1}
      if Lg+A[1,T[n]]<LgMin then
         begin            {am obtinut un traseu mai scurt}
            Tmin:=T;
            LgMin:=Lg+A[1,T[n]];
         end
         else
      else
   else               {construiesc in continuare traseul}
   for i:= 2 to n do   {verific daca se poate deplasa in orasul i}
       if (A[i,T[k-1]]<>0) and (v[i]=0) then
          begin
               T[k]:=i; v[i]:=1; Lg:=Lg+A[i,T[k-1]];
               if Lg<=LgMin then ConstrTraseu(k+1);
               v[i]:=0; Lg:=Lg-A[i,T[k-1]];
          end;
end;

{pp}
begin
clrscr;
Citire;
T[1]:=1; v[1]:=1; LgMin:=Infinit;
ConstrTraseu(2);
Afisare;
readln;
end.

