Program Cercuri;

  Uses UGraph, Graph;

  begin
    InitGr;    { initializeaza modul grafic }
    Circle(300, 250, 100);
    Circle(250, 150, 10);
    Circle(200, 250, 50);
    Circle(200, 250, 70);
    Circle(200, 250, 90);
    Circle(200, 250, 120);
    ReadLn;
    CloseGraph { termina modul grafic }
  end. { Cercuri }