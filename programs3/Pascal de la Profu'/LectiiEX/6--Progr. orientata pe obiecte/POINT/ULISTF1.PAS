Unit UListF1;
  Interface
    Uses
      UPctD;
    Type
      PointerLaNod = ^Nod;
      ProcType = Procedure;
      Nod = Record
        Element : PointerLaPunct;
        Precedentul : PointerLaNod
      End;
      PointerLaLista = ^Lista;
      Lista = Object
        Constructor Init;
        Destructor Done; virtual;
        Procedure Adauga(Elem:PointerLaPunct);
        Procedure Listeaza;
        Procedure Deseneaza;
        Procedure Ascunde;
        Procedure Roteste(unghi:Integer);
        Procedure Translateaza(CuCit:Integer);
        Procedure Mareste(CuCit:Integer);
        Private
          Ultimul : PointerLaNod;
          Procedure Parcurge(var Metoda:ProcType);
      End;
  Implementation
    Uses
      UCercD,UArc,USeg;
    Constructor Lista.Init;
      Begin
        Ultimul := Nil
      End; { Init }
    Destructor Lista.Done;
      Var
        N : PointerLaNod;
      Begin
        While Ultimul <> Nil do
          Begin
            N := Ultimul;
            Ultimul := N^.Precedentul;
            Dispose(N^.Element,Done);
            Dispose(N)
          End;
      End; { Done }
    Procedure Lista.Adauga(Elem:PointerLaPunct);
      Var
        N : PointerLaNod;
      Begin
        New(N);
        N^.Element := Elem;
        N^.Precedentul := Ultimul;
        Ultimul := N
      End; { Adauga }
    Procedure Lista.Listeaza;
      Var
        N : PointerLaNod;
      Begin
        N := Ultimul;
        While N <> Nil do
          Begin
            N^.Element^.Listeaza;
            N := N^.Precedentul
          End;
      End; { Listeaza }
    Procedure Lista.Deseneaza;
      Var
        N : PointerLaNod;
      Begin
        N := Ultimul;
        While N <> Nil do
          Begin
            N^.Element^.Deseneaza;
            N := N^.Precedentul
          End;
      End; { Deseneaza }
    Procedure Lista.Ascunde;
      Var
        N : PointerLaNod;
      Begin
        N := Ultimul;
        While N <> Nil do
          Begin
            N^.Element^.Ascunde;
            N := N^.Precedentul
          End;
      End; { Ascunde }
    Procedure Lista.Roteste(unghi:Integer);
      Var
        N,U : PointerLaNod;
      Begin
        N := Ultimul;
        While N <> Nil do
          Begin
            If N^.Precedentul = Nil
              then U := Ultimul
              else U := N^.Precedentul;
            N^.Element^.Roteste(U^.Element^,unghi);
            N := N^.Precedentul
          End;
      End; { Roteste }
    Procedure Lista.Translateaza(CuCit:Integer);
      Var
        N : PointerLaNod;
      Begin
        N := Ultimul;
        While N <> Nil do
          Begin
            N^.Element^.Translateaza(CuCit);
            N := N^.Precedentul
          End;
      End; { Translateaza }
    Procedure Lista.Mareste(CuCit:Integer);
      Var
        N : PointerLaNod;
        PC : PointerLaCerc;
      Begin
        N := Ultimul;
        While N <> Nil do
          Begin
            If (TypeOf(N^.Element^) = TypeOf(Cerc)) or
               (TypeOf(N^.Element^) = TypeOf(Arc))
              then
                Begin
                  PC := PointerLaCerc(N^.Element);
                  PC^.Mareste(CuCit)
                End
              else N^.Element^.Deseneaza;
            N := N^.Precedentul
          End;
      End; { Mareste }
    Procedure Lista.Parcurge(var Metoda:ProcType);
      Var
        N : PointerLaNod;
      Begin
        N := Ultimul;
        While N <> Nil do
          Begin
            N^.Element^.Metoda^;
            N := N^.Precedentul
          End;
      End; { Parcurge }
End. { UListF1 }