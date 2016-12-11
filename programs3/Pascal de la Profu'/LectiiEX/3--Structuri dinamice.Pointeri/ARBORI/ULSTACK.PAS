Unit ULStack;

Interface
  Uses UDecl;

  Procedure Push(e: ElementStandard);
  Procedure Pop(var e: ElementStandard);
  Function Vida: Boolean;
  Function Plina: Boolean;
  Procedure Creeaza;
  Procedure Elibereaza;
  Procedure Afiseaza(M: String);

Implementation
  Uses UList;

  Procedure Push(e: ElementStandard);
    begin
      UList.Insereaza(e)
    end; { Push }
  Procedure Pop(var e: ElementStandard);
    begin
      UList.Extrage(e);
      UList.Sterge
    end; { Pop }
  Function Vida: Boolean;
    begin
      Vida := UList.Vida
    end; { Vida }
  Function Plina: Boolean;
    begin
      Plina := False
    end; { Plina }
  Procedure Creeaza;
    begin
      UList.Creeaza
    end; { Creeaza }
  Procedure Elibereaza;
    begin
      UList.Elibereaza
    end; { Elibereaza }
  Procedure Afiseaza(M: String);
    begin
      UList.Afiseaza(M)
    end; { Afiseaza }
end.