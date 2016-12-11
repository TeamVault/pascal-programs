Program P1a;
 { foloseste un subprogram local, P2 }
  Var
    Contor: Integer;
  Procedure P2;     { local; apare in zona de declaratii a programului P1 }
    Begin
      WriteLn('Valoarea lui Contor este', Contor:4)
    End; {P2}
  Begin {programul principal}
    For Contor := 1 To 3 Do P2
  End. { P1a }
