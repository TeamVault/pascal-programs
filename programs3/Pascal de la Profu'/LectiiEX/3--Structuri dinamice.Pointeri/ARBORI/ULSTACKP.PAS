Unit ULStackP;

Interface
  Uses UDecl;

  Procedure Push(e: Pointer);
  Function Pop: Pointer;
  Function Vida: Boolean;
  Function Full: Boolean;
  Procedure Creeaza;
  Procedure Elibereaza;
  Procedure Afiseaza(M: String);

Implementation
  Uses UListP;

  Procedure Push(e: Pointer);
    begin
      UListP.Insereaza(e)
    end; { Push }
  Function Pop: Pointer;
    var e: Pointer;
    begin
      UListP.Extrage(e);
      UListP.Sterge;
      Pop := e
    end; { Pop }
  Function Vida: Boolean;
    begin
      Vida := UListP.Vida
    end; { Vida }
  Function Full: Boolean;
    begin
      Full := False
    end; { Full }
  Procedure Creeaza;
    begin
      UListP.Creeaza
    end; { Creeaza }
  Procedure Elibereaza;
    begin
      UListP.Elibereaza
    end; { Elibereaza }
  Procedure Afiseaza(M: String);
    begin
      UListP.Afiseaza(M)
    end; { Afiseaza }
end.