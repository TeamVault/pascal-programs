(*$c+*)
PROGRAM File_copy(prd, prr);
{ prd AND prr must match command line file specifiers
  with "prr" and "prd" in their path names, either as
  suffixes (.prr, .prd), prefixes, or entire names. If
  you plan to copy long files with this program, or you
  do not want to view the copied file as it is copied,
  put comment markers around the `WRITE(current);' and
  `WRITELN;' statements. }
VAR	current : char;
	prr, prd : text;
BEGIN
RESET(prd); REWRITE(prr);
 WHILE NOT EOF(prd) DO
  BEGIN
   WHILE NOT EOLN(prd) DO
    BEGIN
     READ(prd, current);
     WRITE(current);
     WRITE(prr, current)
    END; {eoln loop}
   READLN(prd); WRITELN; WRITELN(prr)
  END {eof loop}
END. {File_copy}
