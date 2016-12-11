{Pentru numere cu mai mult de 10 cifre (date sub forma de sir de cifre) sa se
scrie proceduri pentru adunare si scadere.}
program numere;
type cifre=array[0..100] of integer;
var x,y,a,b:cifre;
procedure adun(x,y:cifre;z:cifre);
var  i,r,s:byte;
begin
  r:=0;
  for i:=1 to 100 do
            begin
            s:=x[i]+y[i]+r;
            if s>=10 then
                    begin
                    r:=1;
                    z[i]:=s mod 10;       {r:=s div 10;z[i]:=s mod 10}
                    end
                     else
                    begin
                    r:=0;
                    z[i]:=s;
                    end;
            end;
  end;
Procedure scad(x,y:cifre;d:cifre);
var i:byte;
begin
  for i:=1 to 100 do
       begin
       if x[i]<y[i] then
                 begin
                 d[i]:=x[i]*10-y[i];
                 if x[i+1]=0 then
                             x[i+1]:=9
                             else
                             x[i+1]:=x[i+1]-1;
                 end
                    else d[i]:=x[i]-y[i];
end;
begin
  write('Introduceti primul numar');readln(x);{sir}
  write('Introduceti al doilea numar');readln(y);
  adun(x,y,a);
  write(a);
end.



