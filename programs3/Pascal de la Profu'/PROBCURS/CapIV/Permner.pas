program bktr_nerecursiv;
uses crt;
type vector=array[1..25] of integer;
var st, v:vector;
    n:integer;

procedure initializari;
var i:integer;
begin
     write('n='); readln(n);
     for i:=1 to 25 do st[i]:=0;
     writeln;
end;

procedure tipar(p:integer);
var i:integer;
begin
     for i:=1 to p do write(st[i]:4,' ');
     writeln;
end;

function valid(p:integer):boolean;
var i:integer; ok:boolean;
begin
     ok:=true;
     for i:=1 to p-1 do
         if st[p]=st[i] then ok:=false;
     valid:=ok;
end;

procedure back; {implementeaza algoritmul nerecursiv de backtracking}
var p:integer;  {varful stivei}
begin
     p:=1; st[p]:=0; {initializam primul nivel}
     while p>0 do    {cat timp stiva nu devine din nou vida}
      begin
         if st[p]<n then
           begin
                st[p]:=st[p]+1; {punem pe nivelul p urmatoarea valoare}
                if valid(p) then {daca solutia(st[1],st[2],...,st[p]) este valida}
                   if p=n then  {daca solutia este si finala}
                      tipar(p)
                     else
                      begin
                       p:=p+1; st[p]:=0;{trecem la nivelul urmatoor, pe care il reinitializam}
                      end;
           end
             else
          p:=p-1; {pasul inapoi la nivelul anterior}
      end;
end;

begin
     clrscr;
     initializari;
     back;
     readln;
end.