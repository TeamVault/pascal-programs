Unit ULStackE;

Interface
  Uses UDecl;

  Procedure Push(e: Muchie);
  Function Pop: Muchie;
  Function Vida: Boolean;
  Function Plina: Boolean;
  Procedure Creeaza;
  Procedure Elibereaza;
  Procedure Afiseaza(M: String);

Implementation
  Uses UListE;

  Procedure Push(e: Muchie);
    begin
      UListE.Insereaza(e)
    end; { Push }
  Function Pop: Muchie;
    var e: Muchie;
    begin
      UListE.Extrage(e);
      UListE.Sterge;
      Pop := e
    end; { Pop }
  Function Vida: Boolean;
    begin
      Vida := UListE.Vida
    end; { Vida }
  Function Plina: Boolean;
    begin
      Plina := False
    end; { Plina }
  Procedure Creeaza;
    begin
      UListE.Creeaza
    end; { Creeaza }
  Procedure Elibereaza;
    begin
      UListE.Elibereaza
    end; { Elibereaza }
  Procedure Afiseaza(M: String);
    begin
      UListE.Afiseaza(M)
    end; { Afiseaza }
end.