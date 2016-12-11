  Unit USutime;
    Interface
      Uses UNatural;
      Type
         Sutime = 0..99;   {Sutime se reprezinta ca tip subdomeniu
                            al tipului Integer}
      Function MaiMare(s1,s2:Sutime):Boolean;
      Function Egal(s1,s2:Sutime):Boolean;
      Procedure Aduna(s1,s2:Sutime; var n:Natural; var s:Sutime);
      Procedure Scade(s1,s2:Sutime; var s:Sutime);

    Implementation
      Procedure Eroare(S:String);
        Begin
          WriteLn('Eroare:',S);
          Halt
        End; { Eroare }

      Function MaiMare(s1,s2:Sutime):Boolean;
        Begin
          MaiMare := s1 > s2
        End; { MaiMare }

      Function Egal(s1,s2:Sutime):Boolean;
        Begin
          Egal := s1 = s2
        End; { Egal }

       Procedure Aduna(s1,s2:Sutime; var n:Natural; var s:Sutime);
        Var
          i : Integer;
        Begin
          i := s1 + s2;
          n := i Div 100;
          s := i Mod 100
        End; { Aduna }

      Procedure Scade(s1,s2:Sutime; var s:Sutime);
        Begin
          If MaiMare(s1,s2) or Egal(s1,s2)
            then s := s1 - s2
            else Eroare('n1 < n2');
        End; { Scade }
  End. { Unit USutime }