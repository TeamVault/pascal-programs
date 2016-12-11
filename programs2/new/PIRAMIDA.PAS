program piramida;
uses crt;
var n,i,j:integer;
begin
Write ('dati val lui n=');readln (n); clrscr;
for i:=1 to n do
begin
for j:=1 to i do     {daca se inlocuieste in for-ul 2 "1" cu i si "i"
                     se va genera 1 2 3 4
                                  2 3 4
                                  2 3
                                  4}

{  write (j:2);readln ;
  for i:=1 to n do
  begin                    " in suspensie"
  for j:=1to i do  }
  write( j:2);readln
  end
  end.