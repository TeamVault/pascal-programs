program rucsac;
uses crt;
var st:array[0..20] of integer;
     tip:array[1..20]of char;
     n,m,i:integer;
     f:text;

procedure initializari;
begin
     assign(f,'rucsac.dat'); reset(f);
     readln(f,n,m);
     for i:=1 to n do readln(f,tip[i]);
     st[0]:=0;
     close(f);
     for i:=1 to 20 do st[i]:=0;
end;

function valid(p:integer):boolean;
var k,c:integer;
begin
     valid:=true; c:=0;
     for k:=1 to p-1 do
       if tip[st[p]]=tip[st[k]] then c:=c+1;
       if(tip[st[p]]='i') or (tip[st[p]]='t') and (c>2) then valid:=false;
end;

function final(p:integer):boolean;
var a,k,i,t:integer;
begin
     final:=false;
     if p=m then
        begin
             final:=true;
             i:=0; a:=0; t:=0;
             for k:=1 to p do
                 case tip[st[k]] of
                      'i': i:=i+1;
                      'a': a:=a+1;
                      't': t:=t+1;
        end;
     if (i=0) or (i>2) or (a<3) or (t=0) or (t>2) then final:=false;
     end;
end;

procedure tipar(p:integer);
var k:integer;
begin
     for k:=1 to p  do
         write(st[k], tip[st[k]],' ');
     writeln;
end;

procedure bktr(p:integer);
var pval:integer;
begin
     for pval:=st[p-1]+1 to n do
         begin

         st[p]:=pval;
         if valid(p) then
            if final(p) then
               tipar(p)
            else
                bktr(p+1);
         end;
end;

{pp}
begin
clrscr;
initializari;
bktr(1);
readln;
end.

