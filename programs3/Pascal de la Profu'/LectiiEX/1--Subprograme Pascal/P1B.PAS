Program P1b;
 { foloseste un subprogram local, P2 }
  Procedure P2;
    Begin
      WriteLn('Valoarea lui Contor este', Contor:4)
       { aici se va produce eroare de compilare: Contor este
         identificator necunoscut }
    End; {P2}
  Var
    Contor: Integer;
  Begin {programul principal}
    For Contor := 1 To 3 Do P2
  End. { P1b }
