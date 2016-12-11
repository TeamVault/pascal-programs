Program P1c;
 { foloseste un subprogram local, P2 }
  Procedure P2(C: Integer);
    Begin
      WriteLn('Valoarea lui Contor este', C:4)
    End; {P2}
  Var
    Contor: Integer;
  Begin {programul principal}
    For Contor := 1 To 3 Do P2(Contor)
  End. { P1c }

