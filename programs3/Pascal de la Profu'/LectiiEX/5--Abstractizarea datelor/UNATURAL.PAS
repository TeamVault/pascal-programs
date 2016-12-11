  Unit UNatural;
    Interface
      Type
        Natural = 0..MaxLongInt;
        {Natural se reprezinta ca tip subdomeniu al tipului predefinit
         LongInt}
      Function MaiMare(n1,n2:Natural):Boolean;
      Function Egal(n1,n2:Natural):Boolean;
      Procedure Aduna(n1,n2:Natural; var n:Natural);
      Procedure Scade(n1,n2:Natural; var n:Natural);
      Procedure Ori(n1,n2:Natural; var n:Natural);
      Procedure Cat(n1,n2:Natural; var n:Natural);
      Procedure Rest(n1,n2:Natural; var n:Natural);

    Implementation
      Procedure Eroare(S:String);
        Begin
          WriteLn('Eroare:',S);
          Halt
        End; { Eroare }

      Function MaiMare(n1,n2:Natural):Boolean;
        Begin
          MaiMare := n1 > n2
        End; { MaiMare }

      Function Egal(n1,n2:Natural):Boolean;
        Begin
          Egal := n1 = n2
        End; { Egal }

      Procedure Aduna(n1,n2:Natural; var n:Natural);
        Begin
          n := n1 + n2      {nu este testata depasirea}
        End; { Aduna }

      Procedure Scade(n1,n2:Natural; var n:Natural);
        Begin
          If MaiMare(n1,n2) or Egal(n1,n2)
            then n := n1 - n2
            else Eroare('n1 < n2');
        End; { Scade }

      Procedure Ori(n1,n2:Natural; var n:Natural);
        Begin
          n := n1 * n2      {nu este testat_ dep__irea}
        End; { Ori }

      Procedure Cat(n1,n2:Natural; var n:Natural);
        Begin
          n := n1 Div n2
        End; { Cƒt }

      Procedure Rest(n1,n2:Natural; var n:Natural);
        Begin
          n := n1 Mod n2
        End; { Rest }
  End. { Unit UNatural }
