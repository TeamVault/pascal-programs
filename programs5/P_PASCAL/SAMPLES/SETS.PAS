(*$c+*)
PROGRAM test(input, output);
TYPE	r_v = 1 .. 20;
	r_i = SET OF r_v;
	c_v = ARRAY[r_v] OF r_i;
VAR	pt, bt, wp : r_i;
	crr : r_v;
	ng : c_v;
BEGIN
	pt := [1, 5 .. 7, 12, 14, 19];
	bt := [3, 4, 8, 11, 13, 15 .. 17];
	wp := [18];
	ng[1] := [3, 4, 9, 13];
	ng[2] := [8, 9, 12, 20];
	ng[3] := [1, 5, 14, 17];
   FOR crr := 1 TO 20 DO
     BEGIN
	WRITE(' Crr =', crr : 3,':  ');
	IF crr IN pt THEN WRITE('Crr in pt; ');
	IF crr IN bt THEN WRITE('Crr in bt; ');
	IF crr IN wp THEN WRITE('Crr in wp; ');
	IF crr IN pt+bt THEN WRITE('Crr in pt+bt; ');
	IF crr IN bt+wp THEN WRITE('Crr in bt+wp; ');
	IF crr IN pt+bt+wp THEN
	  WRITE('Crr is in pt+bt+wp. ');
	WRITELN;
	IF crr < 4 THEN IF (ng[crr] * bt) <> [] THEN
	  WRITELN('ng[', crr : 1, '] * bt <> []')
      END
END.
