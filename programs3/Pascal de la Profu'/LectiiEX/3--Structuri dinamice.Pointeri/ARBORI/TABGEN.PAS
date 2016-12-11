Program TABGen;

Uses UABGen, UDecl, UGen;

{$F+}
Procedure Inspecteaza(p: Pointer; i: Integer);
  begin
    Write('(',PNodArbore(p)^.el.Cheie:2, ',',PNodArbore(p)^.el.Info:2, '),')
  end; { Inspecteaza }

{$I process.pas}

begin
  WriteLn('TABGen');
  Process
end. { TABGen }