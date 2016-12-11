Program TABOrd2A;

Uses UABGenA, UABOrdA, UDecl, UGen;

{$F+}
Procedure Inspecteaza(p: Muchie; i: Integer);
  var e: ElementStandard;
  begin
    GetElem(p, e);
    Write('(',e.Cheie:2, ',',e.Info:2, '),')
  end; { Inspecteaza }

{$I process2.pas}

begin
  Process2
end.