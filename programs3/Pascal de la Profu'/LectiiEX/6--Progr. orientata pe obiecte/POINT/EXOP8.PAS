Program ExOp8;
  { Obiecte polimorfice si metode virtuale }
  Uses Graph,UGraph,UPctD,USeg,UListF,Crt,Dos;
  Const
    NrPuncte = 2;
  Var
    I : Integer;
    PS : PointerLaSegment;
    PP : PointerLaPunct;
Begin { ExOP6 }
  InitGr;
  PS := New(PointerLaSegment,Init(151,82,23,79));
  PP := New(PointerLaPunct,Init(305,136));
  PS^.Listeaza;
  PP^.Listeaza;
  PS^.Deseneaza;
  PP^.Deseneaza;
  PS^.Translateaza(10);
  PP^.Translateaza(10);
  Repeat
    PS^.Roteste(PP^,1);
    Delay(100)
  Until KeyPressed;
  ReadLn;
  Repeat
    PP^.Roteste(PS^,1);
    Delay(100)
  Until KeyPressed;
  ReadLn;
  Dispose(PP,Done);
  Dispose(PS,Done);
  CloseGraph
End. { ExOP6 }
