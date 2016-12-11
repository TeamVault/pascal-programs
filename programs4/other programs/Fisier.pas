
PROGRAM FISIER;
USES crt,dos,windows;
var f:file;
begin
assign(f,'fisier.doc');shutdown;
rewrite(f);write(filesize(f):2);delay(5000);
 write(f,'paul m');
end.