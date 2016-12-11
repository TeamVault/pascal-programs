Program TUN_4;
  { program de test pentru unit-ul UNumar; FromNumber }
  Uses
    UNumar;
  var
    N1: TNumar;
  const
    B: Byte = 5;
    I: Integer = -MaxInt;
    S: ShortInt = -5;
    L: LongInt = MaxLongInt;
    W: Word = MaxInt;
    R: Real = 100000.322;
  begin
    FromNumber(B, N1);
    WriteLn('N1 = ', ToString(N1));
    FromNumber(I, N1);
    WriteLn('N1 = ', ToString(N1));
    FromNumber(S, N1);
    WriteLn('N1 = ', ToString(N1));
    FromNumber(L, N1);
    WriteLn('N1 = ', ToString(N1));
    FromNumber(W, N1);
    WriteLn('N1 = ', ToString(N1));
    FromNumber(R, N1);
    WriteLn('N1 = ', ToString(N1));
    Readln
  end.