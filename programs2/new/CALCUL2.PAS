Program calcul;
uses crt;
var n,i:integer;
procedure T(i,n:integer);
  begin
if (i<=n) then
     begin
     write ('#');
     T(i+1,n);
     write ('*');
     end;
  end;
   begin
   writeln ('dati  valoarea:');
   readln(n);
   writeln ('dati val, lui i:');
   readln (i);
   T(i,n);readln;
   readln;
   end.