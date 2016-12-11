Program Ferestre;

  Uses UGraph, Graph;

  Procedure DeseneazaCercuri(u1, v1, u2, v2: Integer;
                             decupare: Boolean);
    { seteaza fereastra fizica de coordonate P1(u1, v1), P2(u2, v2)
      si cu decupare
      la sfarsit reseteaza fereastra fizica la tot ecranul}
    Begin
      Rectangle(u1, v1, u2, v2);
      If decupare
        then SetViewPort(u1, v1, u2, v2, ClipOn)
        else SetViewPort(u1, v1, u2, v2, ClipOff);
      Circle(100, 100, 100);
      Circle( 50,  50,  10);
      Circle(150,  50,  10);
      Circle( 90, 100,   3);
      Circle(110, 100,   3);
      Circle(100, 150,  20);
      SetViewPort(0, 0, GetMaxX, GetMaxY, ClipOn)
    End; { DeseneazaCercuri }
  begin
    InitGr;    { initializeaza modul grafic }
    Rectangle(0, 0, GetMaxX, GetMaxY);
    DeseneazaCercuri(  0,   0, 200, 200, True);  { stanga sus - integral }
    DeseneazaCercuri(250,   0, 350, 200, True);  { centru sus - decupat stg}
    DeseneazaCercuri(400,   0, 600, 200, True);  { dreapta sus - integral }
    DeseneazaCercuri(  0, 250, 200, 350, True);  { stanga jos - decupat sus}
    DeseneazaCercuri(250, 250, 300, 350, True);  { centru jos - decupat stg sus}
    DeseneazaCercuri(400, 250, 400, 250, False); { dreapta jos - nedecupat }
    ReadLn;
    CloseGraph { termina modul grafic }
  end. { Ferestre }