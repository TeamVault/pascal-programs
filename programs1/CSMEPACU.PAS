Program calcularea_medarit_patratelor_cuburilor_a2nr_in_func_de_caz;
uses crt;
var  c,a,b,Ma,Sp,Sc:integer;
begin
clrscr;
write ('dati nr a');readln (a);
write ('dati nr b');readln (b);
write ('dati val lui c');readln (c);
case c of
1:Begin
Ma:=(a+b)/2;   write ('med arit este', Ma);end
2:Begin
Sp:=(a*a)+(b*b);write ('suma pat este',Sp);end
3:Begin
Sc:=(a^3)+(b^3);write ('suma cub este',Sc);end
else WRite ('date eronate');
End.