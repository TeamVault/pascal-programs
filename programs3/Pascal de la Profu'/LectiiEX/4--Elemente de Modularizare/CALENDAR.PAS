Program Calendar;
{ genereaza calendarul pentru un an specificat
  intr-un fisier text
}
  Uses
    UDataC, Crt;

  Type
    TablouAn = Array[1..366] of DataC;

  Procedure Antet;
    begin
      ClrScr;
      WriteLn('Calendar - genereaza calendarul pentru un an "a" dat');
      WriteLn('Calendarul se va genera in fisierul "a.txt"')
    end; { Antet }

  Procedure Generare(an: Integer; var A: TablouAn);
    { genereaza calendarul pentru anul 'an' in
      tabloul A astfel:
      A[1] primeste valoarea 1/1/an
      ...
      A[NumarZileInAn(an)] primeste valoarea 31/12/an
    }
    var
      d: DataC;
      i: Integer;
    begin
      d.zi := 1;
      d.luna := 1;
      d.an := an;
      d.Ziua := ZiDinSaptamana(d);
      A[1] := d;
      For i := 2 to NumarZileInAn(an) do begin
        AdunaZi(d);
        A[i] := d
      end;
    end; { Generare }

  Procedure Scriere(an: Integer; var A: TablouAn);
    var
      f: text;
      numef: string;
      i: Integer;
    begin
      numef := IntToStr(an,4);
      while numef[1] = ' ' do Delete(numef, 1, 1);
      numef := numef + '.txt';
      assign(f, numef);
      rewrite(f);
      WriteLn(f, 'Calendarul pentru anul ', IntToStr(an, 4));
      WriteLn(f);
      For i := 1 to NumarZileInAn(an) do
        WriteLn(f, DataCToStr(A[i]));
      WriteLn(f);
      Close(f)
    end; { Scriere }

  var
    anul: Integer;
    Cal: TablouAn;
  begin
    Antet;
    Repeat
      Write('Dati anul: ');
      ReadLn(anul);
      if (anul < PrimulAn) or (anul > UltimulAn) then
        WriteLn('Anul trebuie sa fie intre ', PrimulAn:4,
                ' si ', UltimulAn:4);
    Until (anul >= PrimulAn) and (anul <= UltimulAn);
    Generare(anul, Cal);
    Scriere(anul, Cal);
    WriteLn('Programul s-a terminat normal');
    ReadLn
  end. { Calendar }