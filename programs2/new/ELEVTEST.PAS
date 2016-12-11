Program elevCLasare;
uses crt;
type elev=record
     nume,liceu:string;
     nota:integer;
    end;
   vect=array[1..20] of elev;
var v:vect;
   M,max,i,n:integer;
  procedure citire;
  begin
  for i:=1 to n do
  with v[i] do
  begin
  writeln ('Dati numele si liceul');readln (nume,liceu);
  writeln ('dati nota ');readln (nota);
  end;
  end;
  procedure afisare;
  begin
  max:=v[1].nota;
  M:=0;
  for i :=1 to n do
  begin
  if v[i].nota >max then
  max:=v[i].nota;
  M:=M+v[i].nota;
  end;
  writeln ('nota cea mai mare este',max,'iar lui este',v[i].nume);
  readln;
  writeln ('media generala este',M/n);readln;
  end;
  begin
  writeln ('dati val lui n');
  readln (n);
  citire ;
  afisare;
  end.
