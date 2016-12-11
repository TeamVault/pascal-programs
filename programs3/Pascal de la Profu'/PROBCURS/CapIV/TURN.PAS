{Problema turnurilor, tratata in curs}
{Daca doriti intreruperea afisarii tastati CTRL+C}
Program turnuri;
var T:array[1..8] of byte;
    nsol:byte;
Function nu_se_ataca(i:byte):boolean;
var j:byte;
begin
  for j:=1 to i-1 do
   if (T[i]=T[j])
   then begin
  nu_se_ataca:=false; Exit
   end;
  nu_se_ataca:=true;
   end;
Procedure Scrie;
var i,j:byte;
begin
Inc(nsol);
writeln('solutia: ',nsol);
for i:=1 to 8 do
begin
   for j:=1 to 8 do
       if T[i]=j then write('T')
                 else write('*');
  writeln
  end;
  readln
  end;
  Procedure turn(i:byte);
  var j:byte;
  begin
  for j:=1 to 8 do
    begin
    T[i]:=j;
    if nu_se_ataca(i) then
               if i<8 then turn(i+1)
                       else Scrie
                       end
                      end;
     Begin
     turn(1);
     end.


