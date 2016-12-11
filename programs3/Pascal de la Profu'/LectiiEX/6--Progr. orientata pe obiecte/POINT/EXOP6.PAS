Program ExOP6;
  { Obiecte polimorfice si metode virtuale }
  Uses Graph,UGraph,UOPunct4,UListFi1,Crt,Dos;
  Const
    NrPuncte = 2;
  Var
    I : Integer;
    L : Lista;
Begin { ExOP6 }
  InitGr;
  L.Init;
  L.Adauga(New(PointerLaCerc,Init(305,136,5)));
  L.Adauga(New(PointerLaSegment,Init(151,82,23,79)));
  L.Adauga(New(PointerLaPunct,Init(305,136)));
  L.Adauga(New(PointerLaArc,Init(151,82,25,200,330)));
  L.Adauga(New(PointerLaCerc,Init(400,100,40)));
  L.Adauga(New(PointerLaPunct,Init(400,100)));
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
End. { ExOP6 }
