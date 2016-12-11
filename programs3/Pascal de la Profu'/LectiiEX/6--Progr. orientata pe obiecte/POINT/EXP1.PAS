Program ExP1;
  Uses UPoint1;
  Var
    p1,p2,p3 : Point;
  Begin
    Init(10,2,p1);

    Init(70,20,p2);

    Sub(p1,p2,p3);
    WriteLn('p1 - p2 = ',Str(p3));
  End.