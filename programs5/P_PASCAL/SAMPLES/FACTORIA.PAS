{$c+}
program factorial;
var r,s : real;
      i : integer;
{ TWO VERSIONS OF FACTORIAL: FACT1.P IS FACTORIAL WITH }
{ REAL ARITHMETIC, AND FACT2.P IS FACTORIAL DONE WITH }
{ INTEGERS. AND, READINT.P IS A 'HOME MADE' PROCEDURE )
{ FOR READING IN INTEGERS. }
{ INCLUDE FACT1, FACT2, & READINT: }
{$i+'a:\samples\fact1.p'}
{$i+'a:\samples\fact2.p'}
{$i+'a:\samples\readint.p'}
begin
 { CLEAR THE SCREEN: }
 if system('cls') = 0 then ;
 { NOTE THAT, FOR 8086/8087 LIKE ARCHITECTURES, DOING A }
 { SYSTEM CALL MAY AFFECT THE FLOATING-POINT ARITHMETIC }
 { SYSTEM.  SO, THE CODE THAT IMPLEMENTS 'system(...)' }
 { INCLUDES A CALL TO RESET THE FLOATING-POINT SYSTEM; }
 { THIS _fpreset() CALL MAY NOT BE NECESSARY FOR OTHER }
 { CHIP OR MAINFRAME COMPUTERS. }
 write('Factorial(n); Enter n: ');
 readint(Input, i); readln; writeln;
 writeln('Value of i from readint: ', i:1, '.');
 { CONVERT FROM INTEGER TO REAL: }
 r := i;
 { REAL FACTORIAL: }
 s := fact1(r);
 writeln('Real factorial of ', trunc(r):1,' is ',
		s:1, '.');
 { INTEGER FACTORIAL DOES NOT WORK FOR r > 8: }
 i := fact2(trunc(r));
 write('Integer factorial of ', trunc(r) : 1, ' is ');
 { 'maxint' IS THE ISO STANDARD PASCAL PREDEFINED CONSTANT: }
 if s > maxint then
  writeln('greater than maxint = ', maxint:1, '.')
   else writeln(i:1, '.');
 { REAL TO INTEGER CONVERSION: }
 i := round(s);
 writeln('Rounded value of real factorial of ',
		trunc(r):1, ' is ', i:1, '.')
 { THIS WILL ALSO WORK (CONSULT YOUR FAVORITE PASCAL }
 { TEXTBOOK FOR DETAILS AND VARIATIONS): }
 { writeln(real_number : WIDTH : PRECISION ); }
end.
