Program test;
  Uses Graph,UGraph,UOPun,Crt,Dos;
  Const
    NrPuncte = 100;
  Var
    I : Integer;
    A : Array[1..NrPuncte] of PointerLaPunct;
    PP : PointerLaPunct;
    PC : PointerLaCerc;
Begin { ExOP2 }
  InitGr;
  Randomize;
  For I := 1 to NrPuncte do
    Begin
      If Odd(Random(10))
        then
          Begin
            New(PP);
            PP^.Init(Random(640),Random(380));
            A[I] := PP
          End
        else
          Begin
            New(PC);
            PC^.Init(Random(640),Random(380),Random(200));
            A[I] := PC
          End;
      A[I]^.Deseneaza;
    End;
  ReadLn;
  For I := 1 to NrPuncte do
    A[I]^.MutaIn(Random(640),Random(380));
  ReadLn;
  For I := 1 to NrPuncte div 10 do
    A[I]^.Translateaza(10);
  ReadLn;
  CloseGraph
End. { ExOP2 }
