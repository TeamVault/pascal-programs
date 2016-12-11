(*$c+*)
PROGRAM primes;
VAR n, nd, odd, p, pc : INTEGER;
BEGIN
 write('How many primes? ');
 read(n); writeln(2 : 1); writeln(3 : 1);
 pc := 2; p := 3;
 WHILE pc < n DO
  BEGIN
   REPEAT
    nd := 0; p := p + 2; odd := 3;
    WHILE odd < p DO
     BEGIN
      IF p DIV odd * odd = p THEN
       nd := nd + 1;
      odd := odd + 2
     END;
   UNTIL nd <= 0;
   writeln(p : 1);
   pc := pc + 1
  END
END.

