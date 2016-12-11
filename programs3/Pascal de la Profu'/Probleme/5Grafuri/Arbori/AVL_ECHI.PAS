program arbore_avl_echilibrat;{pt. orice nod diferenta dintre inaltimea
subarborelui stang si a celui drept este -1, 0 sau 1}
type reper=^tip_elem;
     tip_elem=record
               info:integer;
               st,dr:reper;
              end;
     sir=array[1..100] of integer;
var arb:reper;
    i,n:integer;
    a:sir;

procedure citeste;
begin
write('n=');readln(n);
for i:=1 to n do
 begin
   write('a[',i,']=');
   readln(a[i]);
 end;
end;

procedure creare_nod(var arb:reper;x:integer);
begin
if arb<>nil then
 begin
   if x<arb^.info then creare_nod(arb^.st,x)
                  else if x>arb^.info then creare_nod(arb^.dr,x)
                                      else write
 end
 else begin
        new(arb);
        arb^.info:=x;
        arb^.st:=nil;
        arb^.dr:=nil;
      end;
end;

procedure creare(ls,ld:integer;x:integer);
var mijloc:integer;
begin
mijloc:=(ls+ld) div 2;
creare_nod(arb,x);
for i:=1 to n-1 do
if a[i]=x then creare(ls,mijloc-1,a[i+1]);
for i:=1 to n-1 do
if a[i]=x then creare(mijloc+1,ld,a[i+1]);
end;

procedure srd(arb:reper);
begin
if arb<>nil then
 begin
   srd(arb^.st);
   write(arb^.info);
   srd(arb^.dr);
 end;
end;

begin
citeste;
creare(1,n,a[1]);
srd(arb);
readln;
end.