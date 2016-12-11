program inversarea_unui_vect_in_altul;
uses crt;
var j,v:array [1..50] of integer;
    n,i:integer;
    begin
    write ('dati val lui n=');readln (n);
    for i:=1 to n do
    begin
    writeln ('dati v[',i,']');
    readln;
    end;
    for i:=1 to n do
    j[i]:=v[n-1];
    for i:=1 to n do
    write (j[i]);readln;

    end.