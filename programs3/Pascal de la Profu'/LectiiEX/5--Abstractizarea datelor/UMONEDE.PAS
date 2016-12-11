Unit UMonede;
Interface
  Uses UNatural,USutime;
  Type
    Monede = Record
      Lei  : Natural;
      Bani : Sutime
    End;
  Procedure BaniInMonede(n:Sutime; var r:Monede);
  Procedure LeiInMonede(n:Natural; var r:Monede);
  Function LeiDinMonede(s:Monede):Natural;
  Function BaniDinMonede(s:Monede):Sutime;
  Function MonedeInReal(s:Monede):Real;
  Procedure RealInMonede(r:Real; var s:Monede);
  Function MaiMare(s1,s2:Monede):Boolean;
  Function Egal(s1,s2:Monede):Boolean;
  Procedure Aduna(s1,s2:Monede; var r:Monede);
  Procedure Scade(s1,s2:Monede; var r:Monede);
  Procedure Scrie(s:Monede);
  Procedure Dobanda(s:Monede; d:Real; var r:Monede);

Implementation
  Procedure Eroare(S:String);
    Begin
      WriteLn('Eroare:',S);
      Halt
    End; { Eroare }

  Procedure BaniInMonede(n:Sutime; var r:Monede);
    Begin
      r.Lei := 0;
      r.Bani := n
    End; { BaniInMonede }

  Procedure LeiInMonede(n:Natural; var r:Monede);
    Begin
      r.Lei := n;
      r.Bani := 0
    End; { LeiInMonede }

  Function LeiDinMonede(s:Monede):Natural;
    Begin
      LeiDinMonede := s.Lei
    End; { LeiDinMonede }

  Function BaniDinMonede(s:Monede):Sutime;
    Begin
      BaniDinMonede := s.Bani
    End; { BaniDinMonede }

  Function MonedeInReal(s:Monede):Real;
    Begin
      MonedeInReal := s.Lei + s.Bani / 100.
    End; { MonedeInReal }

  Procedure RealInMonede(r:Real; var s:Monede);
    Var
      i : Integer;
    Begin
      i := Trunc(r*100);
      s.Bani := i Mod 100;
      s.Lei := i Div 100
    End; { RealInMonede }

  Function MaiMare(s1,s2:Monede):Boolean;
    Begin
       MaiMare := UNatural.MaiMare(s1.Lei,s2.Lei) Or
                  (UNatural.Egal(s1.Lei,s2.Lei))  And
                  (USutime.MaiMare(s1.Bani,s2.Bani));
    End; { MaiMare }

  Function Egal(s1,s2:Monede):Boolean;
    Begin
      Egal := UNatural.Egal(s1.Lei,s2.Lei) And
              USutime.Egal(s1.Bani,s2.Bani);
    End; { Egal }

  Procedure Aduna(s1,s2:Monede; var r:Monede);
    Var
      t : Natural;
    Begin
      USutime.Aduna(s1.Bani,s2.Bani,t,r.Bani);
      r.Lei := s1.Lei + s2.Lei + t
    End; { Adun_ }

  Procedure Dobanda(s:Monede; d:Real; var r:Monede);
    Begin
      RealInMonede(MonedeInReal(s) * d,r);
    End; { Dobƒnda }

  Procedure Scrie(s:Monede);
    Begin
      Write(s.Lei:6,',');
      If s.Bani < 10
        then Write('0',s.Bani:1)
        else Write(s.Bani:2);
      WriteLn(' lei')
    End; { Scrie }

  Procedure Scade(s1,s2:Monede; var r:Monede);
    Begin
      If MaiMare(s1,s2) Or Egal(s1,s2) then
        If USutime.MaiMare(s1.Bani,s2.Bani) or
           USutime.Egal(s1.Bani,s2.Bani) then begin
          r.Lei := s1.Lei - s2.Lei;
          r.Bani := s1.Bani - s2.Bani
        end else Begin
          r.Lei := s1.Lei - s2.Lei - 1;
          r.Bani := s1.Bani - s2.Bani + 100
        end
      else Eroare('Scade: s1 < s2');
    End; { Scade }

  End. { Unit UMonede }

