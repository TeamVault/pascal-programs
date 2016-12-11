(*$c+*)
PROGRAM Something(input,output);

{Original version of this program submitted
 by Sten Ljungkvist of SAAB-SCANIA, Sweden.
 This is a demonstration of European ASCII
 letters in Pascal identifiers.  To type these
 letters, use a "copy con yourfile", and hold
 down the "alt" key while typing the three-digit
 ASCII value of the letter on the numeric keypad.
 When you release the "alt" key, the letter will
 appear on your screen. }

CONST
	lÑgsta = 0;	{Ñ = alt 132}
	fîrsta = 0;	{î = alt 148}
	hîgsta = 9999;
TYPE
	èngstrîm = 2000 .. 10000; {è = alt 143; î = alt 148}
	intword = lÑgsta .. hîgsta;
VAR
	Åáà§ : èngstrîm; {These are some sample letters:
			  Å = alt 129; á = alt 135;
			  à = alt 136; § = alt 164}
	index : intword;
BEGIN
	{Note that specifying output in a WRITE is optional:}
	writeln(output,'Something or another!'); writeln;
	FOR index := hîgsta-10 TO hîgsta DO
	BEGIN
	 Åáà§ := index;
	 writeln(' This is the value of Åáà§[',
		(hîgsta-index) : 2, ']: ', Åáà§ : 5)
	END
END.
