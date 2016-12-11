Program ExOP3;
  Uses Graph,UGraph,UOPunct1,Crt,Dos;
  Const
    NrPuncte = 2;
  Var
    I : Integer;
    A : Array[1..NrPuncte] of Punct;
Begin { ExOP3 }
  InitGr;
  Randomize;
  A[1].Init(300,190);
  A[1].Deseneaza;
  A[2].Init(200,100);
  A[2].Deseneaza;
  ReadLn;
  Repeat
    A[2].Roteste(A[1],1);
    Delay(500)
  Until KeyPressed;
  ReadLn;
  CloseGraph
End. { ExOP3 }
