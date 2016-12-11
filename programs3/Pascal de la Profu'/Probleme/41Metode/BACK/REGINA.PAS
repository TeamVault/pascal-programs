{Sa se aseze in toate modurile posibile 8 regine pe o tabla de sah}
{astfel incat sa nu existe doua care sa se atace.}

Program Problema_celor_opt_regine;
var R:array[1..8] of byte;
    nsol:byte;
Function ataca(i:byte):boolean;
var j:byte;
begin
  for j:=1 to i-1 do
   if (R[i]=R[j]) or (i-j=Abs(R[i]-R[j]))
   then begin
   ataca:=false;Exit
   end;
   ataca:=true
   end;

Procedure Scrie;
var i,j:byte;
begin
inc(nsol);
writeln('solutia: ',nsol);
for i:=1 to 8 do
begin
   for j:=1 to 8 do
       if R[i]=j then write('R')
                 else write('*');
  writeln
  end;
  readln
  end;

  Procedure regina(i:byte);
  var j:byte;
  begin
  for j:=1 to 8 do
    begin
    R[i]:=j;
    if ataca(i) then
               if i<8 then Regina(i+1)
                       else Scrie
                       end
                      end;

     Begin
     Regina(1);
     end.

