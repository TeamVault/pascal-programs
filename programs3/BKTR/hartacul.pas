Program colorarea_hartilor;
Type
stiva = array [1..100] of integer;
var
  st : stiva;
  i, j, n, k : integer;
  as, ev : boolean;
  a: array [1..20,1..20] of integer;

procedure init(k:integer; var st:stiva);
begin
  st[k]:=0;
end;

procedure succesor(var as:boolean; var st:stiva; k:integer);
begin
  if st[k] < 4
    then
      begin
        st[k]:=st[k]+1;
        as:=true
      end
    else
      as:=false
end;

procedure valid (var ev:boolean; st:stiva; k:integer);
var
  i:integer;
begin
  ev:true;
  for i:=1 to k-1 do
    if (st[i]=st[k]) and (a[i,k]=1)
      then
        ev:=false
end;

function solutie(k:integer):integer;
begin
  solutie:=(k-n);
end;

procedure tipar;
var
  i:integer;
begin
  for i:= 1 to n do
    writeln('Tara =', i,'; culoarea=',st[i]);
    writeln('===================');
end;

begin
  write('Numarul de tari = ');
  readln(n);
  for i:= 1 to n do
    for j:=1 to i-1 do
      begin
        write('a[',i,',',j,']=');
        readln(a[i,j])
      end;
  k:=1;
  init(k,st);
  while k>0 do
begin
      repeat
        succesor(as,st,k);
        if as
then
            valid(ev,st,k);
      until (not as) or (as and ev);
      if as
then
          if solutie(k)
then
  tipar
else
  begin
    k:=k+1;
    init(k,st)
  end
        else
          k:=k-1
    end
end.
