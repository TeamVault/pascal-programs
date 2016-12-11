program ordonare;
{Realizeaza ordonarea crescatoare a unui sir de numere intregi}
uses crt;
type
    sir=array[1..100] of integer; {tipul sirului luat ca tablou}
var n,i:integer;
    a:sir;
function SchimbaElemente(var a,b:integer):integer;
{schimba doua elemente consecutive 'a' si 'b' al sirului dat}
var aux:integer; {element auxiliar}
begin
     aux:=a;
     a:=b;
     b:=aux;
end; {SchimbaElemente}
Function Sortat (var x:sir;n:integer):integer;
{Functia realizeaza sortarea sirului 'x' de 'n' elemente}
var i,a,b:integer;
    sortare:boolean;
begin
     repeat {structura repetitiva}
            sortare:=True;
            for i:=1 to n-1 do
                begin
                     if x[i]>x[i+1] then {structura conditionala}
                        begin
                             schimbaelemente(x[i],x[i+1]);
                             sortare:=false
                        end
                end
     until sortare=true;
end; {sortare}
begin {program principal}
      clrscr;
      write('Dati numarul de elemente ale sirului: ');
      readln(n);
      for i:=1 to n do {Citirea sirului de n elemente}
          begin
               write('a[',i,']= ');
               readln(a[i]);
          end;
      sortat(a,n); {realizarea sortarii sirului 'a' de 'n' elemente}
      write('Sirul sortat este:');
      for i:=1 to n do {Citirea sirului sortat}
          begin
               write(' ',a[i]);
          end;
      writeln;
      write('Programul s-a terminat cu bine. Sirul a fost sortat ');
      readln
end. {Ordonare}