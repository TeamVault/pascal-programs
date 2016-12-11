Program TUN;
  { program de test pentru unit-ul UNumar }
  Uses
    UNumar;
  var
    N1, N2, N3: TNumar;
    ok: Boolean;
  begin
    FromString('111111', N1, ok);
    if not ok then WriteLn('eroare N1');
    FromString('1', N2, ok);
    if not ok then WriteLn('eroare N2');
    WriteLn('N1 = ', ToString(N1));
    WriteLn('N2 = ', ToString(N2));
    Aduna(N1, N2, N3);
    WriteLn('N1 + N2 = ', ToString(N3));
    FromString('111', N1, ok);
    if not ok then WriteLn('eroare N1');
    FromString('11111', N2, ok);
    if not ok then WriteLn('eroare N2');
    WriteLn('N1 = ', ToString(N1));
    WriteLn('N2 = ', ToString(N2));
    Aduna(N1, N2, N3);
    WriteLn('N1 + N2 = ', ToString(N3));
    FromString('-111', N1, ok);
    if not ok then WriteLn('eroare N1');
    FromString('-111111', N2, ok);
    if not ok then WriteLn('eroare N2');
    WriteLn('N1 = ', ToString(N1));
    WriteLn('N2 = ', ToString(N2));
    Aduna(N1, N2, N3);
    WriteLn('N1 + N2 = ', ToString(N3));
    FromString('-111', N1, ok);
    if not ok then WriteLn('eroare N1');
    FromString('111111', N2, ok);
    if not ok then WriteLn('eroare N2');
    WriteLn('N1 = ', ToString(N1));
    WriteLn('N2 = ', ToString(N2));
    Aduna(N1, N2, N3);
    WriteLn('N1 + N2 = ', ToString(N3));
    Readln
  end.