{program care nr componentele negative , pozitive si zero dintr-un vector alocat dinamic}
program negZEROpoz;
uses crt;
var v:array[1..100] of ^integer;
     n,neg,poz,zero:^integer;i:integer;
procedure alocare;
  BEGIN                {prog merge si fara dispose la variabile se disaloca
                        automat dupa terminarea programului}
 clrscr; new(n);
 Write('Dati n: ');
 Readln(n^);
 For i:=1 to n^ do
  Begin
 new(v[i]);
  End;
  end;
 procedure citire;
   BEGIN
 For i:=1 to n^ do
  Begin
writeln('Dati val lui v[',i,']=');readln(v[i]^);
  End;
  end;
  procedure eliberare;
   BEGIN
 For i:=1 to n^ do
  Begin
dispose(v[i]);
  End;dispose(n);dispose(neg); dispose(poz);dispose(zero);
  end;
  procedure aflare;
  begin
  new(poz);new(neg);new(zero);poz^:=0;neg^:=poz^;zero^:=poz^;
  for i:=1 to n^ do
    begin
    if v[i]^>0 then inc(poz^)
               else
         if v[i]^<0 then inc(neg^)
                    else
                 inc(zero^);
    end;
  end;
  begin
    alocare;
     citire;
     aflare;
     write('nr elem poz este ', poz^ ,' negative ', neg^ ,' zero ', zero^,' din vector'); readln;
  eliberare;
  end.