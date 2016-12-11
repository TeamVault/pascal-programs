Program cerc;
uses crt;
Type vector=array[1..50] of integer;
 var v:vector;j,n:integer;
function suma (i:integer):integer;
    begin
 if( j=0) then suma:=0
 else if v[j] mod 2=0 then suma:=v[j]+suma(j-1)
 else suma:=suma(j-1);
     end;
 begin
 clrscr;
 write ('n=');readln (n);
 For j:=1 to n do
   begin
 write ('v[',j,']=');readln (v[j]);
   end;
 write ('suma elem pare este=',suma(n));
 end.