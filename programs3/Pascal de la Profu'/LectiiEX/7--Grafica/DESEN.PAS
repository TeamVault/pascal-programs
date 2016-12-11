Program Desen;
  { deseneaza linii plecand de la centru dupa cum se apasa sagetile }


  Uses UGraph, Graph;

  const
    LungimeSegment = 5;
  var
    dirX,
    dirY,
    directie: ShortInt;

  begin
    InitGr;    { initializeaza modul grafic }

    { seteaza punctul curent in centrul ecranului }
    MoveTo(GetMaxX div 2, GetMaxY div 2);

    { ciclu cat timp se apasa una dintre sageti }
    While CeDirectie(dirX, dirY) do begin
      directie := dirX * 2 + dirY;
      Case directie of
        -2: LineRel(-LungimeSegment, 0);  { sageata stanga }
        -1: LineRel(0, -LungimeSegment);  { sageata sus }
         1: LineRel(0,  LungimeSegment);  { sageata jos }
         2: LineRel( LungimeSegment, 0);  { sageata dreapta }
      end { Case }
    end;
    ReadLn;
    CloseGraph { termina modul grafic }
  end. { Desen }