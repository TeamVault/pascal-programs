program ceas;
uses crt;
var i,j,k:byte;
    s,m,o:array[1..60] of integer;
   procedure minut;
   begin
    for j:=101 to 159 do
      begin
     gotoxy(5,8);
     m[j]:=(j mod 100);
     write(m[j]:2);
      end;
   end;
procedure sec;  forward;
begin
  for i:=100 to 159 do
   begin
gotoxy(7,8); delay(1000);
s[i]:=(i mod 100);
write(s[i]:2);
   end;
end;

begin
sec;
end.
