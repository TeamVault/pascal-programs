{ PROGRAM SUBMITTED BY MAKOTO YAMAGIWA }
program pi(input, output);
{ TURNING THE LISTING ON AND OFF WITHIN A PROGRAM: }
(*$c+,l-*)
const
 maxsize = 200;
 size2 = 201;
 radix = 10;
 r1 = 1425;
 r2 = 419;
type
 dig = array[0 : size2] of integer;
 var
 s, p1, p2 : dig;
 i, q, npi, sz, sz1 : integer;

procedure zero(var a: dig);
var i : integer;
begin
  for i:=0 to size2 do a[i] := 0;
  a[sz1] := -1
end;

procedure add(var a, b : dig);
var i : integer;
 c, t : integer;
begin
 c := 0; i := sz;
 repeat
  t := a[i] + b[i] + c;
  if t >= radix then
   begin
    a[i] := t - radix;
    c := 1
   end
  else
   begin
    a[i] := t;
    c := 0
   end;
 i := i-1;
 until (i < q) and (c = 0);
end;

procedure sub(var a, b : dig);
var i : integer;
    c,t : integer;
begin
 c := 0; i := sz;
 repeat
  t := a[i] - b[i] - c;
  if t < 0 then
   begin
    a[i] := t + radix;
    c := 1
   end
  else
   begin
    a[i] := t;
    c := 0
   end;
  i := i - 1;
 until (i < q) and (c = 0)
end;

procedure divide(var a, b : dig; n : integer);
var i : integer;
 r, t : integer;
begin
 while p1[q] = 0 do
  begin
   p2[q] := 0;
   q := q + 1
  end;
 r := 0;
 for i:=q to sz do
  begin
   t := b[i] + r * radix;
   a[i] := t div n;
   r := t mod n
  end
end;

(*$l+*)
{ - TURNING THE LISTING ON AND OFF IN A PROGRAM - }
{ -- main routine -- }

begin
 writeln(
 'Calculate Pi to your specified precision (up to 200 digits);'
 ); write(
 'Enter the number of digits to follow the decimal point: ');
 read(sz);
 writeln('Working, please wait...');
 writeln; writeln;
 sz1 := sz + 1;
 zero(s); zero(p1);
 q := 0;
 p1[0] := 80;
 i := 1;
 while i < r1 do
  begin
   divide(p1,p1,25);
   divide(p2,p1,i);
   add(s,p2);
   i := i + 2;
   divide(p1,p1,25);
   divide(p2,p1,i);
   sub(s,p2);
   i := i + 2
  end;
 zero(p1); q := 0;
 p1[0] := 956; i := 1;
 while i < r2 do
  begin
   divide(p1,p1,239);
   divide(p1,p1,239);
   divide(p2,p1,i);
   sub(s,p2);
   i := i + 2;
   divide(p1,p1,239);
   divide(p1,p1,239);
   divide(p2,p1,i);
   add(s,p2);
   i := i + 2
  end;
 writeln;
 { loop to write out the computed value of PI: }
 writeln('The value of pi is:');
 write(' ' : 6);
 for i:=0 to 1 do
  begin if i > 0 then write('.'); write(s[i] : 1) end;
 for i:=2 to sz do
  begin
   if i mod 50 = 1 then begin writeln; write(' ' : 8) end
    else
     if (i - 1) mod 5 = 0 then write(' ');
   write(s[i] : 1)
  end;
 writeln;
end.
