
program prb_mixta;
type lista=^camp;
     camp=record
                inf:longint;
                ls,ld:lista;
     end;
var cifre,a,b,li,ls,apart,corect,xx,yy:array [1..9] of longint;
    k,kk,aux,grupa,dist,s,m,i,cifra,gr,j:longint;
    prim,ant,x:lista;
    dis:boolean;
    f:text;

procedure scrie;
begin
     for i:=1 to m do
                 write(f,b[yy[i]],' ');
     writeln(f);
end;

procedure recurs(lng:integer);
{obtine permutarile elementelor din vectorul b in vectorul yy}
  var i:integer;
      begin
           if lng=m then scrie
                    else
                        for i:=1 to m do
                            begin
                            dis :=true;
                            for j:=1 to lng do
          {verifica daca elementul nu se afla deja pus}
                             if yy[j]=i then dis:=false;
          {daca dis=true si grupa careia ii apartine elementul i,apart[i]}
          {este aceeasi cu grupa valida la nivelul lng+1 conform}

        {permutarii curente a grupelor scrisa in xx,adica corect[lng+1]}
          {se reapeleaza pentru noul nivel}
                              if dis and (apart[i]=corect[lng+1]) then
                              begin
                              yy[lng+1]:=i;
                              recurs(lng+1);
                              end;
                             end;
          end;
  procedure bkt     {construieste vectorul corect cu semnificatia:};
  begin            {corect[i] - grupa din care trebuie sa faca}
  s:=0;            {parte elementul aflat pe poz i in}
  for i:=1 to gr do {permutarea numerelor construita in yy}
  begin
  grupa:=xx[i];
  dist:=ls[grupa]-li[grupa];
  for j:=(s+1) to (s+dist)  do
  corect[j]:=grupa;
  s:=s+dist;
                end;
  recurs(0);
  end;

  procedure rec(l:integer);     {construieste permutarile}
  var i:integer                 {numerelor 1..gr in vectorul xx,adica obtine};
  begin                         {permutarile grupelor}
  if l=gr then bkt
  else
   for i:=1 to gr do begin
   dis:=true;
   for j:=1 to l  do
   if xx[j]=i then dis:=false;
   if dis then
      begin
      xx[l+1]:=i;
      rec(l+1);
      end;
          end;
   end;

  begin
  write('M= ');readln(m);
  for i:=1 to m do
  begin
  write('a[',i,']=');readln(a[i]);
  end;
  for i:=1 to m do       {generez ficare numar in vectorul b}
  begin
  b[i]:=a[i];
  cifra:=a[i];
  while (b[i] mod 10) <>i do
         begin
         b[i]:=b[i]*10+a[cifra];
         cifra:=a[cifra];
         end;
  end;
  for i:=1 to m-1 do   {ordonam crescator elementele                                                 vectorului b}
  for j:=i+1 to m do
      if b[i]>b[j] then
      begin
      aux:=b[i];
      b[i]:=b[j];
      b[j]:=aux;
      end;
  new(prim);      {se creeaza lista dublu inlantuita}
  prim^.inf:=b[1];
  prim^.ls:=nil;
  prim^.ld:=nil;
  ant:=prim;
  for i:=2 to m do
  begin
  new(x);
  x^.inf:=b[i];
  x^.ls:=ant;
  x^.ld:=nil;
  ant^.ld:=x;
  ant:=x;
  end;

 assign(f,'out.txt');rewrite(f); {se tiparesc elementele  listei}
                                 {in fisierul de iesire}
 x:=prim;
 while x<>nil do
 begin
 write(f,x^.inf,' ');
 x:=x^.ld;
 end;
 writeln(f);
 for i:=1 to m do
 begin
 j:=b[i];
 cifre[i]:=0;
 while j>0 do
 begin
 cifre[i]:=cifre[i]+1;
 j:=j div 10 ;
 end;
 end;
 {am construit vectorul cifre in care elementul cifre[i] indica}
 {numarul de cifre al lui b[i]}
 gr:=0;
 k:=1;
 repeat
 kk:=k;
 while (cifre[kk]=cifre[k]) and (kk<=m) do kk:=kk+1;
 gr:=gr+1;
 li[gr]:=k;
 ls[gr]:=kk;
 k:=kk;
 until k>m;
 {am calculat numarul gr de grupe}
 {fiecare grupa contine numerele cu indicii de la li[k] la ls[k]}
 for i:=1 to gr do
   for j:=li[i] to ls[i] do
   apart[j]:=i;
 {am construit vectorul apart in care elementele au urmatoarea}
 {semnificatie:}
 {apart[i] indica numarul grupei careia ii apartine numarul de pe }
 {pozitia i din vectorul b}
 rec(0);
 close(f);
 end.
