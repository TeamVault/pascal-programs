program combinari;
uses crt;
type vector=array[1..25] of integer;
var st:vector; n,k:integer;

procedure initializari;
var i:integer;
begin
     for i:=1 to 25 do st[1]:=0;
     repeat
           write('n='); readln(n);
           write('k='); readln(k);
     until n>=k;
end;

procedure tipar (p:integer);
var j:integer;
begin
     for j:=1 to p do
         write(st[j]:4,' ');
     writeln;
end;

function valid (p:integer):boolean;
var i:integer;
begin
if (p>1) and(st[p]<=st[p-1]) then valid:=false else valid:=true;
end;

procedure bktr (p:integer);
var pval:integer;
begin
     for pval:=1 to n do
       begin
        st[p]:=pval;
        if valid(p) then
           if p=k then
              tipar(p)
                 else
              bktr(p+1);
       end;
end;

begin
clrscr;
initializari;
bktr(1);
readln;
end.
