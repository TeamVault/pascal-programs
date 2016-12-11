Program ExP2;
  Uses UPoint2;
  Var
    p1,p2,p3 : PPoint;
  Begin
    p1 := Init(10,2);

    p2 := Init(70,20);

    p3 := Sub(p1,p2);
    WriteLn('p1 - p2 = ',Str(p3));
    Done(p1);
    Done(p2);
    Done(p3)
  End.