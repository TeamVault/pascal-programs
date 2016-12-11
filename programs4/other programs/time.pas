program time;
uses dos,crt,graph;
var h,m,s,s100:word;
procedure timp;
 begin
gettime(h,m,s,s100);
 end;
 begin
 timp; writeln(h,' ',m,' ',s,' ',s100);

{settime(12,12,12,44) }
 end.
