
var x:array[1..200] of boolean;
i,k,t,n:integer;


function verif:boolean;
var w:integer;
begin
 w:=0;
 verif:=false;
 for i:=1 to n do
   if x[i] =false then w:=1;
   if w=0 then verif:=true;
end;
 procedure schimba(var poz:boolean);
    begin
      poz:=not(poz);
    end;
 procedure config(t:integer);
 begin
    for k:=1 to t do
       if k mod 2 <>0 then
            begin
               i:=1;
            repeat
              schimba(x[i]);
              i:=i+k;
            until i>n;
            end
        else
         begin
            i:=n;
         repeat
             schimba(x[i]);
             i:=i-k;
         until i<0;
         end;
  end;
 procedure tiparire;
 begin
   for i:=1 to n do write(x[i],' ');
 end;
begin
   writeln;
   write('da nr de usi');
   read(n);
   write('da nr de treceri');
   read(t); config(t);tiparire;
   readln;
   readln;
end.