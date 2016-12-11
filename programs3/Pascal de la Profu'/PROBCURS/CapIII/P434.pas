Program triunghi_echilateral;
uses crt;
TYPE punct=record
            a,o:real;
	   end;
Var A,B,C :^punct;
    Lab,Lac,Lbc :real;
Begin
clrscr;
New(A);
Write('A.a=');readln(A^.a);
Write('A.o=');readln(A^.o);
New(B);
Write('B.a=');readln(B^.a );
Write ('B.o=');readln(B^.o);
New(C);
Write('C.a=');readln(C^.a );
Write('C.o=');readln(C^.o);
LAB:=sqrt(sqr(A^.a-B^.a)+sqr(A^.o-B^.o));
LBC:=sqrt(sqr(B^.a-C^.a)+sqr(B^.o-C^.o));
LAC:=sqrt(sqr(A^.a-C^.a)+sqr(A^.o-C^.o));
Dispose(A);Dispose(b);Dispose(C);
If (LAB=LBC)and(LBC=LAC) then
	Writeln('ABC- echilateral')
                         Else
     Writeln('ABC- nu este echilateral');
Readln
End.
