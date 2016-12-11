{*******************************************************}
{                                                       }
{       Copyright (C) 1996    T M T   Corporation       }
{                                                       }
{*******************************************************}

program lin_eq;

uses debug;

procedure print_vector (v: array (1) of double);
var i: integer;
begin
    for i := 0 to high (v) [0] do write (v [i]:10:6, ' ');
    writeln;
end;

procedure print_matrix (m: array (2) of double);
var i: integer;
begin
    for i := 0 to high (m) [0] do print_vector (m [i]);
    writeln;
end;

procedure solve (
        a: array (2) of double;
        b: array (1) of double;
    var x: array (1) of double);

var i, j, k, n: integer;

begin
    n := high (a) [1];

    for i := 0 to n - 1 do begin

        for j := i+1 to n do
            a [i,j] := a [i,j] / a [i,i];

        b [i] := b [i] / a [i,i];
        a [i,i] := 1;

        for j := i + 1 to n do begin
            b [j] := b [j] - b [i] * a [j, i];
            for k := n downto i do
                a [j, k] := a [j, k] - a [i, k] * a [j, i];
        end;
    end;

    for i := n downto 0 do declare
        var s: double;
    begin
        s := b [i];
        for j := n downto i + 1 do
            s := s - a [i,j] * x [j];
        x [i] := s / a [i, i];
    end
end;

const a: array [1..3, 1..3] of double = ((1,0,2),(2,1,0),(1,2,1));
      b: array [1..3] of double = (1, 1, 1);
var   x: array [1..3] of double;

begin
    solve (a, b, x);
    print_matrix (a); print_vector (b); writeln;
    writeln ('result is: ');
    print_vector (x);
end.