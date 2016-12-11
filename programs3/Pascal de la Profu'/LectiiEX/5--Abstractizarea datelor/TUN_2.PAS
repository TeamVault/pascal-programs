Program TUN_2;
  { program de test pentru unit-ul UNumar: impartire }
  Uses
    UNumar;
  var
    N1, N2, N3, N4, N5: TNumar;
    ok: Boolean;
  begin
    FromString('147887', N1, ok);
    FromString('1', N2, ok);
    WriteLn('N1 = ', ToString(N1));
    WriteLn('N2 = ', ToString(N2));
    Imparte(N1, N2, N3, N4);
    WriteLn('N3 = N1 div N2 = ', ToString(N3));
    WriteLn('N4 = N1 mod N2 = ', ToString(N4));
    Inmulteste(N2, N3, N5);
    Aduna(N5, N4, N5);
    Scade(N1, N5, N5);
    WriteLn('Proba: N1 - (N2 * N3 + N4) = ', ToString(N5));
    CmmDc(N1, N2, N5);
    WriteLn('Cmmdc(N1,N2) = ', ToString(N5));

    Readln
  end.