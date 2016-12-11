Program ExObSt4;

  Uses Graph,UGraph,ULoc,UPctD,UCercD,Crt,Dos;
  Type
    PointerLaPunct = ^Punct;
    PointerLaCerc  = ^Cerc;
  Var
    PP : PointerLaPunct;
    PC : PointerLaCerc;
    A : Array[1..2] of PointerLaPunct;
Begin { ExObSt3 }
  InitGr;                                       {trecerea in modul grafic}
  New(PP);                     {alocarea obiectului dinamic referit de PP}
  PP^.Init(100,200);
  A[1] := PP;
  New(PC);                     {alocarea obiectului dinamic referit de PC}
  PC^.Init(150,230,50);

  A[2] := PC;            {constrangere: PC este vazut ca pointer la punct}
  {PC^ contine in el 'semnatura' clasei sale care este folosita de
   metodele virtuale}
  A[1]^.Deseneaza;
  A[2]^.Deseneaza;
  A[1]^.Listeaza;                                    {listarea obiectelor}
  A[2]^.Listeaza;
  ReadLn;
  A[1]^.MutaIn(200,300);                              {mutarea obiectelor}
  A[2]^.MutaIn(A[2]^.XCoord+50,A[2]^.YCoord-30);
  A[1]^.Listeaza;                                    {listarea obiectelor}
  A[2]^.Listeaza;
  ReadLn;
  Repeat                             {rotatia punctului in jurul cercului}
    A[1]^.Roteste(A[2]^,1);
    Delay(100)
  Until KeyPressed;
  ReadLn;
  Repeat                             {rotatia cercului in jurul punctului}
    A[2]^.Roteste(A[1]^,1);
    Delay(100)
  Until KeyPressed;
  ReadLn;
  A[1]^.Translateaza(10);                          {translatia obiectelor}
  A[2]^.Translateaza(10);
  Dispose(A[1]);                          {dealocarea obiectelor dinamice}
  Dispose(A[2]);
  CloseGraph                                     {revenirea in modul text}
End. { ExObSt4 }
