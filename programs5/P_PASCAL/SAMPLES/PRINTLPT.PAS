{$c+}
{ Program for copying a file with a `doc' suffix to }
{ the line printer `lpt1' (or subsititute `prn' or }
{ `com1' for `lpt1' in the PROGRAM line.) }
PROGRAM printer(lpt1,doc);
Const	ESC = #27;
	TAB = #9;
	PageSize = 50;
Var	Copies, index, PageNum, LineNum : integer;
	ch : char;
	doc, lpt1 : text;
	print_pnum : boolean;
FUNCTION ToLower(ch : char) : char;
Var	local : integer;
BEGIN
 local := Ord(ch) - Ord('A');
 IF local in [0 .. 25] THEN ToLower := Chr(local + Ord('a'))
 ELSE ToLower := ch
END;
FUNCTION ToOrd(ch : char) : integer;
BEGIN
 ToOrd := Ord(ToLower(ch)) - Ord('a') + 1
END;
BEGIN
 { UTILITY PROGRAM FOR COPYING A TEXT FILE TO THE LINE PRINTER, }
 { HERE DESIGNATED AS lpt1; YOUR PRINTER MAY BE lpt2 OR com1: }
 Rewrite(lpt1);
 Write(lpt1,ESC,'@');		{ Initialize the printer. }
 Write('Select proportional spacing (y/n)? '); Readln(ch);
 IF ToLower(ch) = 'y' THEN Write(lpt1,ESC,'p',CHR(1));
 Write('Use NLQ Printing? (y/n) ');  Readln(ch);
 IF ToLower(ch) = 'y' THEN
  BEGIN
   Write(lpt1,ESC,'x',CHR(1));
   Write('Automatic NLQ Justification? (y/n) '); Readln(ch);
   IF ToLower(ch) = 'y' THEN Write(lpt1,ESC,'a',CHR(3))
 				{ NLQ Automatic Justification: }
				{ 0 = Normal; 1 = Centered; }
				{ 2 = Right Aligned; }
				{ 3 = Left and right justified. }
  END
 ELSE
  BEGIN
   Write(
'Select Elite, Pica, Italic, Compressed, Expanded type: (e/p/i/c/x) '
   ); Readln(ch);
   IF ToOrd(ch) in [5{`e'},16{`p'},9{`i'},3{`c'},24{`x'}] THEN
    case ch of
     'e': Write(lpt1,ESC,'M');
     'p': Write(lpt1,ESC,'P');
     'i': Write(lpt1,ESC,'4');
     'c': Write(lpt1,ESC,CHR(15));
     'x': Write(lpt1,ESC,'E',CHR(14))
    END
  END;
 Write('Print Page numbers on Top of the Page (y/n)? '); Readln(ch);
 print_pnum := (ToLower(ch) = 'y');
 Write('Number of copies to print (1..9): '); Readln(Copies);
 Write(lpt1,ESC,'l',CHR(6)); 	{ Left Margin Set to Column 10 = 6+4. }
 WHILE Copies > 0 DO
  BEGIN
   PageNum := 2; LineNum := 1; Reset(doc);
   WHILE NOT Eof(doc) DO
    BEGIN
     WHILE NOT Eoln(doc) DO
      BEGIN
       Read(doc,ch); Write(lpt1,ch)
      END;
     LineNum := Succ(LineNum);
     Readln(doc);
     IF LineNum <= PageSize THEN Writeln(lpt1)
     ELSE
      BEGIN
       Page(lpt1);
       IF print_pnum THEN
        BEGIN
         FOR LineNum := 1 TO 5 DO Write(lpt1, TAB);
         Write(lpt1, '-', PageNum : 1, '-')
        END;
       Writeln(lpt1); Writeln(lpt1);
       LineNum := 1; PageNum := Succ(PageNum)
      END
   END;
   Copies := Pred(Copies)
 END;
 IF (LineNum > 1) AND (LineNum < PageSize) THEN Page(lpt1);
 Write(lpt1,ESC,'@')		{ Reset the printer. }
END.
