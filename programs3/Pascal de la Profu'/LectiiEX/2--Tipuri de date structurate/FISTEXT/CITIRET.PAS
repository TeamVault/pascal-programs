Program CitireT;
  { exemplu de citire a unui fisier text cu afisarea lui pe ecran }
  uses
    UFile, Crt;
  var
    f: text;
    linie: string;
    numeFis: string;
    nrLinie: integer;           { contor de linie }
    nrPagina: integer;
    este: boolean;
  begin
    Repeat
      ClrScr;
      WriteLn('CitireT - afisarea unui fisier text pe ecran');
      Repeat
        Write('Dati numele fisierului (ENTER la terminare): ');
        ReadLn(numeFis);
        If numeFis = '' then Exit;
        este := Exista(numeFis);
        if not este then WriteLn('Fisier inexistent!');
      Until este;
      nrLinie := 0;
      nrPagina := 1;
      WriteLn('Continutul fisierului ', numeFis, ' este:              ',
              'Pag. ', nrPagina:3);
      Assign(f, numeFis);              { asociaza f la numeFis }
      Reset(f);                        { deschide f in citire }
      While not EOF(f) do begin        { cat timp nu s-a ajuns la sfarsit }
        ReadLn(f, linie);              { citeste o linie din fisier }
        Inc(nrLinie);                  { incrementeaza contorul }
        WriteLn(nrLinie:5, ' ', linie);
        If nrLinie mod 20 = 0 then begin
          Asteapta;
          ClrScr;
          nrPagina := nrPagina + 1;
          WriteLn('Continutul fisierului ', numeFis, ' este:              ',
                  'Pag. ', nrPagina:3);
        end
      end;
      if nrLinie mod 20 <> 0 then Asteapta;
      Close(f);
      Fictiva;
    Until False
  end. { CitireT }