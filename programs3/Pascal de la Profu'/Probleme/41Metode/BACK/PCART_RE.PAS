program produsul_cartezian_M_la_n;
var n:byte;
    x:array[1..20] of byte;

  procedure scrie;
  var i:byte;
  begin
     write('(',x[1]);
     for i:=2 to n do write(',', x[i]);
     writeln(')');
  end;

  procedure cart(i:byte);
  var j:byte;
  begin
     for j:=1 to 2 do
        begin
          x[i]:=j;
          if i<n then cart(i+1)
                 else scrie;
        end;
  end;

 begin
    write('n=');read(n);
    cart(1);readln;
 end.