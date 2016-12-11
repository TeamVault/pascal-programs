{Programul realizeaza media aritmetica intre doua elemente ale unui sir si
introducerea ei intre cele doua elemente}
Program IntroduceMedie;
var
  x:array[1..20] of real;
  y:array[1..20] of real;
  i,j,k:word;
  r:char;
procedure calcul;{Procedura face calculele si afisarea}
  begin
   write('Dati numarul de elemente al sirului: ');
   readln(k);
   writeln('Elementele sirului sunt');
    for i:=1 to k do
      readln(x[i]); { Se citesc elementele sirului}
      j:=1;
    for i:=1 to k-1 do  {Se face introducerea mediei }
  begin
      y[j]:=x[i];
      y[j+1]:=(x[i]+x[i+1])/2;
      Inc(j,2)
  end;
   y[j]:=x[k];
   writeln('Noul sir este');
    for i:=1 to j do
       writeln(y[i]:9:2);{Se afiseaza noul sir}
  end;
begin   {Aici incepe programul principal}
   repeat
   calcul;{Apelul procedurii}
   writeln('Mai calculati?[D/N]');
   readln(r);
   until
   (r='N') or (r='n');
   writeln('Copyright(c)2000-2001,Miron Gheorghe Alin student anul I grupa2');
   readln;
end.
  {Bibliografie:Curs Algoritmica-Domsa Ovidiu
              Initiere in Turbo Pascal-V.Cristea si I.Athanasiu,Ed.Teora,1995}
