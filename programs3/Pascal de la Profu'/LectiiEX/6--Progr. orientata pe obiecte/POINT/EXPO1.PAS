Program ExPO1;
  Uses UPointO1;
  Var
    p1,p2,p3 : Point;
  Begin
    p1.Init(10,2);

    p2.Init(70,20);

    p3.Sub(p1,p2);
    WriteLn('p1 - p2 = ',p3.Str);
  End.