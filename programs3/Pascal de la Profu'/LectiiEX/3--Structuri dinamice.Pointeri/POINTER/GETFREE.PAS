Program GetFree;
{ deonstrativ pentru GetMem, FreeMem
  un prim exemplu de tablou dinamic
}

Type
  VInteger = Array[1..1] of Integer;
  PVInteger = ^VInteger;

var
  P: PVInteger;
  i: integer;

begin
  { aloca spatiu pentru 5 intregi in heap si pune adresa de
    inceput in P }
  GetMem(P, 5 * SizeOf(Integer));
  For i := 1 to 5 do P^[i] := i*11;
  For i := 1 to 5 do WriteLn(i, ' --> ', P^[i]);
  FreeMem(P, 5 * SizeOf(Integer));
  ReadLn
end. { GetFree }