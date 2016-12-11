Program ExOP1;
  Uses Graph,UGraph,ULoc,UPctS,UCercS,Crt,Dos;
  Var
    P : Punct;
    C : Cerc;
Begin { ExOP1 }
  InitGr;
  P.Init(100,200);
  C.Init(150,230,50);
  P.Deseneaza;
  C.Deseneaza;
  P.Listeaza;                                      {listarea obiectelor}
  C.Listeaza;
  ReadLn;
  P.MutaIn(200,300);                                {mutarea obiectelor}
  C.MutaIn(C.XCoord+50,C.YCoord-30);
  P.Listeaza;                                      {listarea obiectelor}
  C.Listeaza;
  ReadLn;
  Repeat                           {rotatia punctului in jurul cercului}
    P.Roteste(C,1);
    Delay(100)
  Until KeyPressed;
  ReadLn;
  Repeat                           {rotatia cercului in jurul punctului}
    C.Roteste(P,1);
    Delay(100)
  Until KeyPressed;
  ReadLn;
  C.Translateaza(10);                            {translatia obiectelor}
  P.Translateaza(10);
  CloseGraph
End. { ExOP1 }
