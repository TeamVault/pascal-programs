Program TABGenAI;

Uses UABGenAI, UDecl, UGen;

{$F+}
Procedure Inspecteaza(p: Muchie; i: Integer);
  var e: ElementStandard;
  begin
    GetElem(p, e);
    Write('(',e.Cheie:2, ',',e.Info:2, '),')
  end; { Inspecteaza }

{$I process.pas}

begin
  WriteLn('TABGenAI');
  Process
end. { TABGenAI }