Program Placinta;

  Uses UGraph, Graph;

  const
    VenituriPeTrimestru: array[1..4] of integer = (120, 200, 30, 75);
  begin
    InitGr;    { initializeaza modul grafic }
    PieInt(VenituriPeTrimestru,
           GetMaxX div 2, GetMaxY div 2,
           200);
    ReadLn;
    CloseGraph { termina modul grafic }
  end. { Placinta }