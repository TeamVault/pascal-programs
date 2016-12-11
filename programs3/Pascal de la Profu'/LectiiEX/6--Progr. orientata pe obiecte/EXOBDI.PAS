Program ExObDi;
  { Obiecte polimorfice si metode virtuale }
  Uses Graph,UGraph,UPctD,UCercD,UArc,USeg,UListF,Crt,Dos;
  Var
    L : Lista;
Begin { ExObDi }
  InitGr;
  L.Init;
  L.Insereaza(New(PointerLaCerc,Init(305,136,5)));
  L.Insereaza(New(PointerLaPunct,Init(300,150)));
  L.Insereaza(New(PointerLaSegment,Init(400,100,40,50)));
  L.Insereaza(New(PointerLaCerc,Init(400,100,40)));
  L.Insereaza(New(PointerLaPunct,Init(250,100)));
  L.Insereaza(New(PointerLaArc,Init(151,82,25,90,180)));
  L.Insereaza(New(PointerLaPunct,Init(200,300)));
  L.Listeaza;
  ReadLn;
  L.Deseneaza;
  ReadLn;
  L.Translateaza(10);
  ReadLn;
  Repeat
    L.Roteste(-1);
    Delay(100)
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
End. { ExObDi }
