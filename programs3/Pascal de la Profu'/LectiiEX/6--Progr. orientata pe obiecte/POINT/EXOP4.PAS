Program ExOP4;
  Uses Graph,UGraph,UOPunct2,Crt,Dos;
  Const
    NrPuncte = 3;
  Var
    I : Integer;
    A : Array[1..NrPuncte] of PointerLaPunct;
    PP : PointerLaPunct;
    PC : PointerLaCerc;
    Gata : Boolean;
Begin { ExOP4 }
  InitGr;
  Randomize;
  New(PC,Init(300,190,2));
  A[1] := PC;
  A[1]^.Deseneaza;
  New(PC,Init(200,100,30));
  A[2] := PC;
  A[2]^.Deseneaza;
  New(PP,Init(250,120));
  A[3] := PP;
  A[3]^.Deseneaza;
  ReadLn;
  Gata := False;
  Repeat
    Repeat
      A[1]^.Roteste(A[3]^,1);
      A[3]^.Roteste(A[2]^,-1);
      A[2]^.Roteste(A[1]^,1);
      Delay(100);
    Until KeyPressed;
    A[1]^.Translateaza(10);
    A[2]^.Translateaza(10);
    A[3]^.Translateaza(10);
    Gata := ReadKey in [#27];
  Until Gata;
  ReadLn;
  CloseGraph
End. { ExOP4 }
