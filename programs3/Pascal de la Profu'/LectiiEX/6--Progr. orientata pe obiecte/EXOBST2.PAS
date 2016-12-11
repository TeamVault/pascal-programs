Program ExObSt2;
  Uses Graph,UGraph,ULoc,UPctS,UCercS,Crt,Dos;
  Type
    PointerLaPunct = ^Punct;
    PointerLaCerc  = ^Cerc;
  Var
    PP : PointerLaPunct;
    PC : PointerLaCerc;
Begin { ExObSt2 }
  InitGr;                                       {trecerea in modul grafic}
  New(PP);                     {alocarea obiectului dinamic referit de PP}
  PP^.Init(100,200);
  New(PC);                     {alocarea obiectului dinamic referit de PC}
  PC^.Init(150,230,50);
  PP^.Deseneaza;
  PC^.Deseneaza;
  PP^.Listeaza;                                      {listarea obiectelor}
  PC^.Listeaza;
  ReadLn;
  PP^.MutaIn(200,300);                                {mutarea obiectelor}
  PC^.MutaIn(PC^.XCoord+50,PC^.YCoord-30);
  PP^.Listeaza;                                      {listarea obiectelor}
  PC^.Listeaza;
  ReadLn;
  Repeat                             {rotatia punctului in jurul cercului}
    PP^.Roteste(PC^,1);
    Delay(100)
  Until KeyPressed;
  ReadLn;
  Repeat                             {rotatia cercului in jurul punctului}
    PC^.Roteste(PP^,1);
    Delay(100)
  Until KeyPressed;
  ReadLn;
  PC^.Translateaza(10);                            {translatia obiectelor}
  PP^.Translateaza(10);
  ReadLn;
  Dispose(PP);                            {dealocarea obiectelor dinamice}
  Dispose(PC);
  CloseGraph                                     {revenirea in modul text}
End. { ExObSt2 }
