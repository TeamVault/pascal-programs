Program Eminescu;
 uses crt;
 var an:integer;
BEGIN
 clrscr;
 write('In ce an s-a nascut Eminescu?');
 readln(an);
 case an of
 1850:write('Foarte bine!');
 1849,1851:write('Aproape bine!');
 1845..1848:write('Cu',1850-an,'ani mai tarziu!');
 1852..1855:write('Cu',an-1850,'ani mai devreme!');
 1800..1844,1856..1899:write('Ati nimerit secolul!')
 else
 write('Ar trebui sa mai cititi biografia lui Eminescu!');
 end;
 readln;
END.
