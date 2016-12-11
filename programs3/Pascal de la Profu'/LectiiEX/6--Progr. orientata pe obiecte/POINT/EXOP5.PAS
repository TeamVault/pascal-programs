Program ExOP5;
  Uses Graph,UGraph,UOPunct3,UListFig,Crt,Dos;
  Const
    NrPuncte = 2;
  Var
    I : Integer;
    L : Lista;
Begin { ExOP5 }
  InitGr;
  L.Init;
  L.Adauga(New(PointerLaCerc,Init(305,136,5)));
  L.Adauga(New(PointerLaPunct,Init(305,136)));
  L.Adauga(New(PointerLaCerc,Init(400,100,40)));
  L.Adauga(New(PointerLaPunct,Init(400,100)));
  L.Adauga(New(PointerLaArc,Init(151,82,25,90,180)));
  L.Adauga(New(PointerLaPunct,Init(151,82)));
  L.Listeaza;
  ReadLn;
  L.Deseneaza;
  ReadLn;
  L.Translateaza(10);
  ReadLn;
  Repeat
    L.Roteste(1);
    Delay(1000)
  Until KeyPressed;
  ReadLn;
  Repeat
    L.Mareste(1);
    Delay(1000)
  Until KeyPressed;
  ReadLn;
  Repeat
    L.Mareste(-1);
    Delay(1000)
  Until KeyPressed;
  ReadLn;
  L.Ascunde;
  L.Done;
  CloseGraph
End. { ExOP5 }
