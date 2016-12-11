program combinariRECURSIV;
uses crt;
var a,b:longint;
function comb(n,k:integer):longint;
  begin
if (k=0) or (n=k) then comb:=1
              else comb:=comb(n-1,k)+comb(n-1,k-1);

   end;
  begin
  clrscr; textcolor(3);
  writeln ('Dati val. lui a si b:');readln(a,b);
  writeln ('-----------------------------------------------------------');
  write('|combinari de',a:3,',luate cate',b:3,',este:',comb(a,b));
  write('|'); gotoxy (1,6);
  write ('-----------------------------------------------------------');
  readln;
  end.