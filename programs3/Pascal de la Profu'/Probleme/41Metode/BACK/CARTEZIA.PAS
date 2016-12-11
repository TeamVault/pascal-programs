program cartezian;
uses crt;
type vector =array[1..50] of integer;
     propoz=array[1..50] of string;
var st, nr:vector;
    cuv:propoz;
    n,l:integer;
    sol, ok:boolean;

procedure initializari;
var i:integer;
begin
     write('n='); readln(n);
     for i:=1 to 50 do
         st[i]:=0;
     for i:= 1 to n do
         begin
              write('nr de elem al multimii ',i,':' );
              readln(nr[i]);
              readln(cuv[i]);
         end;
 end;

function valid(p:integer):boolean;
var i:integer;
     posibil:boolean;
     begin
          valid:=true;
     end;

procedure tipar(p:integer);
var i:integer;
begin
     for i:=1 to p do write(cuv[i,st[i]]);
     writeln;
end;

procedure bktr(p:integer);
var pval:integer;
begin
     if p=n+1 then
        tipar(p-1)
     else
     for pval:=1 to nr[p] do
          begin
               st[p]:=pval;
               if valid(p) then bktr(p+1);
          end;
end;

{program principal}
begin
     clrscr;
     initializari;
     bktr(1);
     readln;
end.
