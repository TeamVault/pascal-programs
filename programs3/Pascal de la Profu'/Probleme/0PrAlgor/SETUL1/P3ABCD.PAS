PROGRAM maxabcd;
var a,b,c,d,max:real;
begin
     writeln('introduceti a,b,c,d');
     readln(a,b,c,d);
IF (A>B) AND (A>C) AND(A>D) THEN
                              MAX:=A
                            ELSE
                              IF (B>A) AND (B>C) AND(B>D) THEN
                                                            MAX:=B
                                                          ELSE
                                                          IF (C>A) AND (C>B) AND(C>D) THEN
                                                                                       MAX:=C
                                                                                      ELSE
                                                                                      MAX:=D;
WRITELN('MAXIMUL ESTE :',MAX:5:0);
READLN
END.

