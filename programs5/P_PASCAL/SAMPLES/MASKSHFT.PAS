{$c+,y+}
program test;
const	y = #3;		{ HEART SYMBOL- }
	z = $aff;	{ HEXADECIMAL aff }
	w = 0677;	{ OCTAL 677 }
var	x, c : char;
	i : integer;
begin
 for i:= 1 to 16 do
  begin
   c := chr(ord('a') + i);
   x := chr(ord(y) + i);
   writeln('Some characters, i == ', i:2,
		' ':1, c:1, ' ':1, x:1);
   { MASKING OPERATORS: and, or, xor, not, shl, and shr }
   { THESE ARE 'BITWISE' (I. E. ONES COMPLEMENT) OPERATORS }
   { FOR INTEGER OPERANDS: shl == 'SHIFT LEFT'; }
   { shr == 'SHIFT RIGHT'; xor == 'EXCLUSIVE OR'; }
   { ALSO AVAILABLE ARE THE ISO STANDARD PASCAL BOOLEAN }
   { OPERATORS '<>' (EXCLUSIVE OR), '<=',(IMPLICATION), }
   { AND '=' (EQUIVALENCE) FOR BOOLEAN OPERANDS. }
   c := chr((ord(c) and z) xor w + i);
   x := chr(ord(c) xor not (w + i) or 3);
   if odd(i) then
    c := chr(ord(c) shl 1)
     else x := chr(ord(x) shr 1);
   writeln('Some characters, i == ', i:2,
		' ':1, c:1, ' ':1, x:1)
  end
end.
