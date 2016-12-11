program Sum;
var
   Sum1 : real;
   Sum2 : real;
   i    : integer;
   j    : integer;
begin
   Sum1 := 0.0;
   FOR i := -30 to 30 DO
     begin
       writeln(i:3, '  ',Sum1:12);
       Sum1 := Sum1 + exp(i*ln(10));
     end;

   writeln;
   Sum2 := 0.0;
   FOR j:= 30 DOwnto -30 DO
     begin
       writeln(j:3, '  ',Sum2:12);
       Sum2 := Sum2 + exp(j*ln(10));
     end;

   writeln('Sum1 = ',Sum1:12);
   writeln('Sum2 = ',Sum2:12);
   writeln('Difference = ', abs(Sum1 - Sum2):12 );
end.
