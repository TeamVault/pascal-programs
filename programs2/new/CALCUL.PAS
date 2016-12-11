Program calcul;
uses crt;
var x,y:integer;
function f(x,y:integer):integer;
  begin
if x>y then f:=0
       else
            f:=1+f(x,y-x);
  end;
   begin
   writeln ('dati cele doua valori:');
   readln(x,y);
   writeln ('rezultatul este',f(x,y));readln;
   readln;
   end.