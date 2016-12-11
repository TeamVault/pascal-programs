Unit UZile;
  Interface
    Type
      Zile = (luni,marti,miercuri,joi,vineri,sambata,duminica);
                         {Zile este de tip enumerare}
    Function Ieri(z:Zile):Zile;
    Function Maine(z:Zile):Zile;
    Function Libera(z:Zile):Boolean;
    Procedure Scrie(z:Zile);
    Procedure Citeste(var z:Zile);

  Implementation

    Function LowerCase(s: String): String;   { procedura interna }
      { converteste stringul s la litere mici
        este opusul lui UpCase }
      var
        r: String;
        ch: Char;
        i: Byte;
      begin
        r := '';                 { rezultatul intors }
        for i := 1 to Length(s) do begin
          ch := s[i];
          { codul ASCII al literei mici este cu 32 mai mare decat
            cel al literei mari corespunzatoare }
          if ch in ['A' .. 'Z']  { daca ch e litera mare, o transforma
                                   in litera mica }
            then ch := Chr(Ord(ch) + 32);
          r := r + ch            { adauga ch la stringul rezultat }
        end;
        LowerCase := r
      end; { LowerCase }

    Function Ieri(z:Zile):Zile;
      { parcurge circular inapoi enumerarea Zile }
      Begin
        If z = luni                { primul element }
          then Ieri := duminica    { ultimul element }
          else Ieri := Pred(z)     { predecesorul }
      End; { Ieri }

    Function Maine(z:Zile):Zile;
      { parcurge circular inainte enumerarea Zile }
      Begin
        If z = duminica            { ultimul element }
          then Maine := luni       { primul element }
          else Maine := Succ(z)    { succesorul }
      End; { Mƒine }

    Function Libera(z:Zile):Boolean;
      Begin
        If Ord(z) >= Ord(sambata)
          then Libera := True
          else Libera := False
      End; { Libera }

    Function ToString(z: Zile): String;   { locala }
      { converteste z la string }
      Begin
        Case z of
          luni     : s := 'luni';
          marti    : s := 'marti';
          miercuri : s := 'miercuri';
          joi      : s := 'joi';
          vineri   : s := 'vineri';
          sambata  : s := 'sƒmbata';
          duminica : s := 'duminica'
        End;
        ToString := s
      End; { ToString }

    Procedure Scrie(z:Zile);
      Begin
        WriteLn(ToString(z))
      End; { Scrie }

    Function FromString(s: String): Integer;   { locala }
     { intoarce ordinalul lui s din Zile sau -1 daca nu e corect }
      var
        z: Integer;
      begin
        s := LowerCase(s);
        if s = 'luni' then z := ord(luni)
        else if s = 'marti' then z := ord(marti)
        else if s = 'miercuri' then z := ord(miercuri)
        else if s = 'joi' then z := ord(joi)
        else if s = 'vineri' then z := ord(vineri)
        else if s = 'sambata' then z := ord(sambata)
        else if s = 'duminica' then z := ord(duminica)
        else z := -1;
        FromString := z
      end; { FromString }

    Procedure Citeste(var z:Zile);
      Var
        s : string;
        i: Integer;
      Begin
        Repeat
          ReadLn(s);
          i := FromString(s);
          if i = -1 then WriteLn('Gresit! Repetam')
        Until (i >= 0) and (i <= 6);
        z := Zile(i)    { converteste i la Zile; typecast = conversie
	                    explicita de tip }
      End; { Citeste }
End. { Unit UZile }
