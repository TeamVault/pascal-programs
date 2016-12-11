Program TABOrd;

Uses UABOrd, UDecl, UGen;

{$F+}

Procedure Inspecteaza(p: Pointer; i: Integer);
  begin
    Write('(',PNodArbore(p)^.el.Cheie:2, ',',PNodArbore(p)^.el.Info:2, '),')
  end; { Inspecteaza }

{$I processo.pas}

begin
  ProcessO
end.