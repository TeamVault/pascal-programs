Program C;

uses B, A;

begin
  writeLn(parte);  { se considera parte din A - ultimul din Uses }
  writeLn('A- ', A.parte);
  writeLn('B- ', B.parte);
  readln
end.