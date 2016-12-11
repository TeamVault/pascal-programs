             program mine(output);
  var i : integer;

  procedure print(var j: integer);

    function next(k: integer): integer;
    begin
      next := k + 1
    end;

  begin
    writeln('The total is: ', j);
    j := next(j)
  end;

begin
  i := 1;
  while i <= 10 do print(i)
end.