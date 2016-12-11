program prod_nr_el_neg_poz_imp;
uses crt;
var v: array [1..20] of integer;
    n,i,P,j:integer;
BEGIN
 clrscr;
 Write('Dati n: ');
 Readln(n);
 For i:=1 to n do
  Begin
   Write('Dati v[',i,']=');
   Readln(v[i]);
  end;
 P:=1;
 For i:=1 to n do
  If (v[i]<0) and (odd(i)) then
           Begin
            P:=P*v[i];
            j:=j+1;
           End;
 Writeln('Produsul este: ',P);
 Writeln('Nr este: ',j);
 Readln;
END.