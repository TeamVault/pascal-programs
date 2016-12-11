(*$c+*)
program sines;
var i, j, k : real;
begin
 i := 0.0;
 while i < 10.0 do
  begin
   k := sin(i) + 1.1;
   j := 0.0;
   while j < k do
    begin write('x'); j := j + 0.1 end;
   writeln;
   i := i + 0.35
  end
end.
