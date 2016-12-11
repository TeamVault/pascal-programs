Program DemoInt;
{ program demonstrativ pentru tipurile reale }

{$Q+}   { overflow checking - verifica depasirile }

Uses
  Crt;

procedure DemoReal(a,b: Real);
  begin
    WriteLn('Tipul Real');
    WriteLn(a, '+', b, '=', a+b);
    WriteLn(a, '-', b, '=', a-b);
    WriteLn(a, '*', b, '=', a*b);
    WriteLn(a, '/', b, '=', a/b);
    WriteLn('Abs(',a,')=', Abs(a));
    WriteLn('Sqr(',a,')=', Sqr(a));
    WriteLn('Sin(',a,')=', Sin(a));
    WriteLn('Cos(',a,')=', Cos(a));
    WriteLn('Ln(',a,')=', Ln(a));
    WriteLn('Exp(',1,')=', Exp(1));
    WriteLn('Sqrt(',a,')=', Sqrt(a));
    WriteLn('Int(',a,')=', Int(a));
    WriteLn('Frac(',a,')=', Frac(a));
    WriteLn('Trunc(',a,')=', Trunc(a));
    WriteLn('Round(',a,')=', Round(a));
    ReadLn
  end; { DemoReal }
Procedure DemoSingle(a, b: Single);
  begin
    WriteLn('Tipul Single');
    WriteLn(a, '+', b, '=', a+b);
    WriteLn(a, '-', b, '=', a-b);
    WriteLn(a, '*', b, '=', a*b);
    WriteLn(a, '/', b, '=', a/b);
    ReadLn
  end; { DemoSingle }
Procedure DemoDouble(a, b: Double);
  begin
    WriteLn('Tipul Double');
    WriteLn(a, '+', b, '=', a+b);
    WriteLn(a, '-', b, '=', a-b);
    WriteLn(a, '*', b, '=', a*b);
    WriteLn(a, '/', b, '=', a/b);
    ReadLn
  end; { DemoDouble }
Procedure DemoExtended(a, b: Extended);
  begin
    WriteLn('Tipul Extended');
    WriteLn(a, '+', b, '=', a+b);
    WriteLn(a, '-', b, '=', a-b);
    WriteLn(a, '*', b, '=', a*b);
    WriteLn(a, '/', b, '=', a/b);
    ReadLn
  end; { DemoExtended }
Procedure DemoComp(a, b: Comp);
  begin
    WriteLn('Tipul Comp');
    WriteLn(a, '+', b, '=', a+b);
    WriteLn(a, '-', b, '=', a-b);
    WriteLn(a, '*', b, '=', a*b);
    WriteLn(a, '/', b, '=', a/b);
    ReadLn
  end; { DemoComp }

var
  optiune: byte;
begin
  Repeat
    ClrScr;
    WriteLn('DEMOREAL - program demonstrativ pentru tipurile reale');
    WriteLn('1. Tipul Real');
    WriteLn('2. Tipul Single');
    WriteLn('3. Tipul Double');
    WriteLn('4. Tipul Extended');
    WriteLn('5. Tipul Comp');
    WriteLn('0. Terminare');
    Write('Dati optiunea: ');
    ReadLn(optiune);
    Case optiune of
      1: DemoReal(23.72, 12.3);
      2: DemoSingle(12.6456E23, -23.987E22);
      3: DemoDouble(100.811E20, 200.22E20);
      4: DemoExtended(200.76E40, 100.67E40);
      5: DemoComp(1.78E09, 1.23E15);
    end
  Until optiune = 0
end. { DemoReal }