(*$c+,d+*)
PROGRAM example(input,output);
VAR x, y : integer;
FUNCTION gcd(a, b: integer) : integer;
BEGIN
 {GREATEST COMMON DENOMINATOR PROGRAM:}
  CASE b = 0 OF
   true: gcd := a;
  false: gcd := gcd(b, a MOD b)
  END
END;
BEGIN
  write('type x = ');
  readln(x);
  writeln('x = ', x : 2);
  write('type y = ');
  readln(y);
  writeln('y = ', y : 2);
  writeln('gcd = ', gcd(x,y) : 2, '.')
END.
