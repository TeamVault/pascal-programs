{Se da o secventa de paranteze rotunde. Sa se dermine daca }
{parantezarea este corecta}

program paranteze;
uses crt;
var a:array[1..20] of byte;
f:text;
k,i,d,e,w:byte;
procedure citire;
var  c:char;
begin
assign(f,'f.txt');
reset(f);
i:=0;
while not eof(f) do begin
                      i:=i+1;
                      read(f,c);
                      if c='(' then begin
                                   a[i]:=1;
                                   d:=d+1;
                                   end
                             else begin
                                   a[i]:=0;
                                   e:=e+1;
                                   end;
                   end;
writeln(d,' ',e);      {cand numarul de paranteze descise<>inchise}
if d<>e then writeln('parantezare incorecta');
close(f);
end;
procedure parant;
var n:byte;
begin
d:=0;
e:=0;
w:=0;
n:=1;
repeat
                  if a[n]=1 then d:=d+1
                            else e:=e+1;
                 if d<e-1 then begin
                                  w:=1;
                                  write('parantezare incorecta');
                                  n:=i+1;
                                  end;

n:=n+1;
until n>i;
if w=0 then writeln('parantezare corecta');
end;
begin
clrscr;
citire;
for k:=1 to i do
         if a[k] = 1 then write('(')
                     else write(')');
parant;
readkey;
end.
