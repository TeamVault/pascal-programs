Program TUN_1;
  { program de test pentru unit-ul UNumar: inmultire }
  Uses
    UNumar;
  var
    N1, N2, N3: TNumar;
  begin
    FromString('111111', N1);
    FromString('100000000000000000000000000000000000', N2);
    WriteLn('N1 = ', ToString(N1));
    WriteLn('N2 = ', ToString(N2));
    Inmulteste(N1, N2, N3);
    WriteLn('N1 * N2 = ', ToString(N3));
    Readln
  end.