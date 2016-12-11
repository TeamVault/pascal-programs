PROGRAM maxabc;
VAR A,B,C,MAX:REAL;
BEGIN
WRITELN('INTRODUCTI A,B,C:');
READLN(A,B,C);
IF (A>B) AND (A>C) THEN
                      MAX:=A
                   ELSE
                   IF (B>A) AND (B>C) THEN
                                        MAX:=B
                                      ELSE
                                      MAX:=C;
WRITELN('MAXIMUL ESTE :',MAX:5:0);
READLN
END.
