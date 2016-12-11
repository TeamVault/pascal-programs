{$c+,y+}
program prfnparm;
const vert_bar = #240;
      horz_bar = #254;
procedure writer(procedure pen(var arg : text));
begin
 pen(Output)
end;
procedure writex(var pfp : text);
begin
 write(pfp,vert_bar)
end;
procedure writey(var pfp : text);
begin
 write(pfp,horz_bar)
end;
procedure wrln(var pfp : text);
begin
 writeln(pfp)
end;
procedure trig (function trigfun(arg : real) : real);
var i, j, k : real;
    l : integer;
    break : boolean;
begin
 i := 0.0; l := 0; break := false;
 while not break and (i < 10.0) do
  begin
   l := succ(l); k := trigfun(i) + 1.1; j := 0.0;
   if k > 8.0 then break := true
   else
    begin
     while j < k do
      begin
       if odd(l) then writer(writex) else writer(writey);
       j := j + 0.1
      end;
     writer(wrln);
     i := i + 0.35
    end
  end;
 writer(wrln)
end;
begin
 trig(sin);
 trig(cos);
 trig(exp)
end.

