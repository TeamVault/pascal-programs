
program QSort;
{$R-,S-}
uses Crt;

{ Acest program aplica metoda Quicksort pentru un sir de 1000 de}
{ numere alese aleator, cu valori intre 0 si 29999. Reyultatul  }
{ este afisat direct la ecran pentru a observa viteza de executie}

const
  Max = 1000;

type
  List = array[1..Max] of Integer;

var
  Data: List;
  I: Integer;

procedure QuickSort(var A: List; Lo, Hi: Integer);

{Procedura QuickSort contine o procedura recursiva }
{care ordoneaza efectiv elemnetele.                }

procedure Sort(l, r: Integer);
var
  i, j, x, y: integer;
begin
  i := l; j := r; x := a[(l+r) DIV 2];
  repeat
    while a[i] < x do i := i + 1;
    while x < a[j] do j := j - 1;
    if i <= j then
    begin
      y := a[i]; a[i] := a[j]; a[j] := y;
      i := i + 1; j := j - 1;
    end;
  until i > j;
  if l < j then Sort(l, j);
  if i < r then Sort(i, r);
end;

begin {QuickSort};
  Sort(Lo,Hi);
end;

begin {QSort}
  Write('Generare 1000 numere ...');
  Randomize;
  for i := 1 to Max do Data[i] := Random(30000);
  Writeln;
  Write('Sortarea numerelor ...');
  QuickSort(Data, 1, Max);
  Writeln;
  for i := 1 to 1000 do Write(Data[i]:8);
end.
