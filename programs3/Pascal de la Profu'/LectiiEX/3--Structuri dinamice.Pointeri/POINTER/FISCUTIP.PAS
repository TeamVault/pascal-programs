program FisCuTip;
 { program demonstrativ pentru fisiere cu tip

   diagrama ierarhica (de structura) a programului

   program principal
   ³
   ÃÄ DeschideFisier
   ³  ³
   ³  ÀÄ Asteapta
   ³
   ÃÄ ListeazaFisier
   ³  ³
   ³  ÃÄ Asteapta
   ³  ³
   ³  ÀÄ ScriePersoana
   ³     ³
   ³     ÃÄ A40ToString
   ³     ³
   ³     ÃÄ DenSex
   ³     ³
   ³     ÃÄ DenStareCiv
   ³     ³
   ³     ÀÄ DataToString
   ³        ³
   ³        ÀÄ IntToStr
   ³
   ÃÄ AdaugaInregistrare
   ³  ³
   ³  ÃÄ CitestePersoana
   ³  ³  ³
   ³  ³  ÃÄ CitesteA40
   ³  ³  ³
   ³  ³  ÃÄ CitesteSex
   ³  ³  ³
   ³  ³  ÃÄ CitesteStareCiv
   ³  ³  ³
   ³  ³  ÀÄ CitesteDataC
   ³  ³     ³
   ³  ³     ÀÄ StrToInt
   ³  ³
   ³  ÀÄ Asteapta
   ³
   ÃÄ ModificaInregistrarePrinNumar
   ³  ³
   ³  ÃÄ ModificaInregistrare
   ³  ³  ³
   ³  ³  ÃÄ ScriePersoana
   ³  ³  ³
   ³  ³  ÃÄ ModificaCamp
   ³  ³  ³  ³
   ³  ³  ³  ÃÄ CitesteA40
   ³  ³  ³  ³
   ³  ³  ³  ÃÄ CitesteSex
   ³  ³  ³  ³
   ³  ³  ³  ÃÄ CitesteStareCiv
   ³  ³  ³  ³
   ³  ³  ³  ÀÄ CitesteDataC
   ³  ³  ³     ³
   ³  ³  ³     ÀÄ StrToInt
   ³  ³  ³
   ³  ³  ÀÄ Continua
   ³  ³
   ³  ÀÄ Asteapta
   ³
   ÃÄ ModificaInregistrarePrinNrId
   ³  ³
   ³  ÃÄ CautaNrIdInFisier
   ³  ³
   ³  ÃÄ ModificaInregistrare
   ³  ³  ³
   ³  ³  ÃÄ ScriePersoana
   ³  ³  ³
   ³  ³  ÃÄ ModificaCamp
   ³  ³  ³  ³
   ³  ³  ³  ÃÄ CitesteA40
   ³  ³  ³  ³
   ³  ³  ³  ÃÄ CitesteSex
   ³  ³  ³  ³
   ³  ³  ³  ÃÄ CitesteStareCiv
   ³  ³  ³  ³
   ³  ³  ³  ÀÄ CitesteDataC
   ³  ³  ³     ³
   ³  ³  ³     ÀÄ StrToInt
   ³  ³  ³
   ³  ³  ÀÄ Continua
   ³  ³
   ³  ÀÄ Asteapta
   ³
   ÃÄ InchideFisier
   ³  ³
   ³  ÀÄ Asteapta
   ³
   ÀÄ Asteapta

 }

uses
  Crt, UFile;
type
  DataC = record
    zi: 1..31;
    lu: 1..12;
    an: integer
  end; { DataC }
  A40 = array[1..40] of char;
  TipSex = (masc, fem);
  StareCiv = (necas, casat, vaduv, divortat);
  Persoana = Record
    Nume: String[30];
    NrId: LongInt;
    Adr: A40;
    Sex: TipSex;
    StareC: StareCiv;
    DataN: DataC;
    Inaltime: Real
  end; { Persoana }
  FisierPersoane = File of Persoana;

Function IntToStr(i: Integer): String;
  var
    s: String;
  begin
    Str(i:4, s);
    while (s[1] = ' ') and (length(s) > 0) do Delete(s, 1, 1);
    IntToStr := s
  end; { IntToStr }

Function StrToInt(s: String): Integer;
  var
    c: Integer;   { cod de eroare de la Val }
    n: Integer;   { numarul convertit }
  begin
    Val(s, n, c);
    if c <> 0 then n := 0;
    StrToInt := n
  end; { StrToInt }
Function DataToString(d: DataC): String;
  begin
    DataToString := IntToStr(d.zi) + '/' +
                    IntToStr(d.lu) + '/' +
                    IntToStr(d.an)
  end; { DataToString }

Procedure CitesteDataC(M: String; var d: DataC);
  var
    s: String;
  begin
    Write(M, ' (in forma zz/ll/aaaa): ');
    ReadLn(s);
    d.zi := StrToInt(Copy(s, 1, 2));
    d.lu := StrToInt(Copy(s, 4, 2));
    d.an := StrToInt(Copy(s, 7, 4));
  end; { CitesteDataC }

Function A40ToString(a: A40): String;
  var
    s: String;
    i: Byte;
  begin
    s := '';
    for i := 1 to 40 do s := s + a[i];
    A40ToString := s
  end; { A40ToString }

Procedure CitesteA40(M: String; var a: A40);
  var
    s: String;
    i: Integer;
  begin
    Write(M, ': ');
    ReadLn(s);
    s := Copy(s, 1, 40);
    for i := 1 to 40 do
      if i <= length(s)
        then a[i] := s[i]
        else a[i] := ' '
  end; { CitesteAdr }

Function DenSex(s: TipSex): String;
  begin
    case s of
      masc: DenSex := 'masculin';
      fem:  DenSex := 'feminin'
    end
  end; { DenSex }

Function CitesteSex: TipSex;
  var
    c: char;
  begin
    Repeat
      Write('Sexul(M, F): ');
      ReadLn(c);
    Until UpCase(c) in ['M', 'F'];
    If UpCase(c) = 'M'
      then CitesteSex := masc
      else CitesteSex := fem;
  end; { CitesteSex }

Function DenStareCiv(s: StareCiv): String;
  begin
    case s of
      necas:    DenStareCiv := 'necasatorit';
      casat:    DenStareCiv := 'casatorit';
      vaduv:    DenStareCiv := 'vaduv';
      divortat: DenStareCiv := 'divortat';
    end
  end; { DenStareCiv }

Function CitesteStareCiv: StareCiv;
  var
    c: char;
  begin
    Repeat
      Write('Starea civila (N = necas, C = casat, V = vaduv, D = divortat): ');
      ReadLn(c);
    Until UpCase(c) in ['N', 'C', 'V', 'D'];
    Case Upcase(c) of
      'N': CitesteStareCiv := necas;
      'C': CitesteStareCiv := casat;
      'V': CitesteStareCiv := vaduv;
      'D': CitesteStareCiv := divortat;
    end
  end; { CitesteStareCiv }

Procedure ScriePersoana(p: Persoana);
  Const
    CRLF: String = Chr(13) + Chr(10);
  begin
    WriteLn('1. Nume:          ', p.Nume, CRLF,
            '2. NrId:          ', p.NrId, CRLF,
            '3. Adr:           ', A40ToString(p.Adr), CRLF,
            '4. Sex:           ', DenSex(p.Sex), CRLF,
            '5. Stare civ:     ', DenStareCiv(p.StareC), CRLF,
            '6. Data nasterii: ', DataToString(p.DataN), CRLF,
            '7. Inaltime:      ', p.Inaltime:3:2);
  end; { ScriePersoana }

Procedure CitestePersoana(var p: Persoana);
  begin
    with p do begin
      Write('Numele: ');
      ReadLn(Nume);
      Write('NrId: ');
      ReadLn(NrId);
      CitesteA40('Adresa', Adr);
      Sex := CitesteSex;
      StareC := CitesteStareCiv;
      CitesteDataC('Data nasterii: ', DataN);
      Write('Inaltime: ');
      ReadLn(Inaltime);
    end;
  end; { CitestePersoana }

  Procedure ModificaCamp(camp: Byte; var p: Persoana);
    { modifica campul camp al inregistrarii p }
    begin
      case camp of
        1: begin
             Write('Numele: ');
             ReadLn(p.Nume);
           end;
        2: begin
             Write('NrId: ');
             ReadLn(p.NrId);
           end;
        3: CitesteA40('Adresa', p.Adr);
        4: p.Sex := CitesteSex;
        5: p.StareC := CitesteStareCiv;
        6: CitesteDataC('Data nasterii: ', p.DataN);
        7: begin
             Write('Inaltime: ');
             ReadLn(p.Inaltime);
           end;
      end
    end; { ModificaCamp }

  Procedure ModificaInregistrare(var p: Persoana);
    { modifica unul sau mai multe din campurile persoanei p }
    var
      c: Byte;        { numarul campului care se modifica }
    begin
      WriteLn('Datele persoanei sunt: ');
      ScriePersoana(p);
      Repeat
        WriteLn;
        Write('Specificati numarul campului care se modifica: ');
        ReadLn(c);
        if (c >= 1) and (c <= 7) then ModificaCamp(c, p);
        ScriePersoana(p);
      Until not Continua('Continuati modificarea');
    end; { ModificaInregistrare }

  Procedure DeschideFisier(var f: FisierPersoane; var d: Boolean);
    { parametri
        f - variabila fisier corespunzatoare fisierului care
            se deschide
        d - variabila booleana cu semnificatia
             d = True  - fisierul este deschis deja
             d = False - fisierul nu este deschis
      functionalitate
        daca d = True
          atunci da un mesaj de eroare si asteapta
          altfel
            deschide fisierul PERSOANE.DAT
            pune d pe True
        sfdaca
    }
    begin
      if d then begin
        WriteLn('Fisierul este deja deschis!');
        Asteapta;
        Exit
      end;
      If not Exista('PERSOANE.DAT') then begin
        Assign(f, 'PERSOANE.DAT');
        Rewrite(f);
        Close(f);
      End;
      Assign(f, 'PERSOANE.DAT');
      Reset(f);
      WriteLn('Fisierul a fost deschis');
      Asteapta;
      d := True
    end; { DeschideFisier }

  procedure ListeazaFisier(var f: FisierPersoane; d: Boolean);
    { listeaza inregistrarile din f }
    var
      p: Persoana;
    begin
      if not d then begin
        WriteLn('Fisierul nu este deschis!');
        Asteapta;
        Exit
      end;
      if FileSize(f) = 0 then begin
        WriteLn('Fisierul este vid!');
        Asteapta;
        Exit
      end;
      Seek(f, 0);   { pozitioneaza fisierul la inceput }
      while not eof(f) do begin
        WriteLn('Inregistrarea cu numarul ', FilePos(f) + 1, ' din ', FileSize(f), ' inregistrari');
        Read(f, p);
        ScriePersoana(p);
        Asteapta;
      end;
    end; { ListeazaFisier }

  procedure AdaugaInregistrare(var f: FisierPersoane; d: Boolean);
    { adauga o noua inregistrare la sfarsitul fisierului }
    var
      p: Persoana;
      nr: Integer;
    begin
      if not d then begin
        WriteLn('Fisierul nu este deschis!');
        Asteapta;
        Exit
      end;
      nr := FileSize(f);
      Seek(f, nr);   { pozitioneaza fisierul la sfarsit }
      WriteLn('Introduceti datele pentru inregistrarea ', nr + 1);
      CitestePersoana(p);
      Write(f, p)
    end; { AdaugaInregistrare }

  procedure ModificaInregistrarePrinNumar(
                 var f: FisierPersoane;
                 d: Boolean);
    { modifica o inregistrare din fisier specificata prin
      pozitia ei relativa in fisier }
    var
      p: Persoana;
      nr: Word;      { numarul curent al inregistrarii din fisier }
    begin
      if not d then begin
        WriteLn('Fisierul nu este deschis!');
        Asteapta;
        Exit
      end;
      if FileSize(f) = 0 then begin
        WriteLn('Fisierul este vid!');
        Asteapta;
        Exit
      end;
      Repeat
        WriteLn('In fisier sunt ', FileSize(f), ' inregistrari');
        Write('Dati numarul inregistrarii pe care vreti sa o modificati: ');
        ReadLn(nr);
        If (nr <= 0) or (nr > FileSize(f))
          then WriteLn('Numar de inregistrare eronat!');
      Until (nr >= 1) and (nr <= FileSize(f));
      Seek(f, nr-1);   { pozitioneaza fisierul pe inregistrarea nr }
      Read(f, p);    { citeste inregistrarea dorita in p }
      ModificaInregistrare(p); { modifica inregistrarea p }
      Seek(f, nr-1);   { repozitioneaza fisierul pe inregistrarea nr }
      Write(f, p)
    end; { ModificaInregistrarePrinNumar }

  function CautaNrIdInFisier(
             var f: FisierPersoane;
             nrId: LongInt): Word;
    { cauta in f o inregistrare p cu p.nrId = nrId
      daca o gaseste,
        atunci intoarce FilePos(f)
        altfel intoarce 0
    }
    var
      p: Persoana;
    begin
      Seek(f, 0);   { pozitioneaza fisierul la inceput }
      while not eof(f) do begin
        Read(f, p);
        if p.NrId = nrId then begin
          CautaNrIdInFisier := FilePos(f);
          Exit
        end;
      end;
      CautaNrIdInFisier := 0
    end; { CautaNrIdInFisier }

  procedure ModificaInregistrarePrinNrId(
                 var f: FisierPersoane;
                 d: Boolean);
    { modifica o inregistrare din fisier specificata prin
      pozitia ei relativa in fisier }
    var
      p: Persoana;
      nrId: LongInt;   { valoarea campului NrId al inregistrarii
                         cautate din fisier }
      nr: Word;
    begin
      if not d then begin
        WriteLn('Fisierul nu este deschis!');
        Asteapta;
        Exit
      end;
      if FileSize(f) = 0 then begin
        WriteLn('Fisierul este vid!');
        Asteapta;
        Exit
      end;
      Repeat
        Write('Dati valoarea campului NrId pentru persoana dorita: ');
        ReadLn(nrId);
        { nr este numarul inregistrarii p din f care are campul
          p.nrId = nrId

          daca nr = 0 inseamna ca nu exista in f o
          inregistrare cu p.nrId = nrId
        }
        nr := CautaNrIdInFisier(f, nrId);
        If nr = 0
          then WriteLn('Nu exista o astfel de inregistrare')
          else begin
            Seek(f, nr-1);   { pozitioneaza fisierul pe inregistrarea nr }
            Read(f, p);    { citeste inregistrarea dorita in p }
            ModificaInregistrare(p); { modifica inregistrarea p }
            Seek(f, nr-1);   { repozitioneaza fisierul pe inregistrarea nr }
            Write(f, p)
          end;
      Until (nr > 0) and (nr <= FileSize(f));
    end; { ModificaInregistrarePrinNrId }

  Procedure InchideFisier(var f: FisierPersoane; var d: Boolean);
    { parametri
        f - variabila fisier corespunzatoare fisierului care
            se deschide
        d - variabila booleana cu semnificatia
             d = True  - fisierul este deschis
             d = False - fisierul nu este deschis
      functionalitate
        daca d = False
          atunci da un mesaj de eroare si asteapta
          altfel
            inchide fisierul PERSOANE.DAT
            pune d pe False
        sfdaca
    }
    begin
      if not d then begin
        WriteLn('Fisierul nu este deschis!');
        Asteapta;
        Exit
      end;
      Close(f);
      WriteLn('Fisierul a fost inchis');
      Asteapta;
      d := False
    end; { InchideFisier }

  var                         { variabile globale }
    f: FisierPersoane;        { fisierul de persoane }
    p: Persoana;              { inregistrarea curenta din fisier }
    nr: Word;                 { numarul inregistrarii curente }
    deschis: Boolean;
    optiune: Byte;
  begin
    deschis := False;
    Repeat
      ClrScr;
      WriteLn('FisCuTip - program demonstrativ pentru fisiere cu tip');
      WriteLn('Optiuni:');
      WriteLn('1. Deschidere fisier');
      WriteLn('2. Listare fisier');
      WriteLn('3. Adaugare inregistrare (la sfarsit)');
      WriteLn('4. Modificare inregistrare (prin numar)');
      WriteLn('5. Modificare inregistrare (dupa NrId)');
      WriteLn('6. Inchidere fisier');
      WriteLn('0. Terminare program');
      Write('Dati optiunea: ');
      ReadLn(optiune);
      Case optiune of
        1: DeschideFisier(f, deschis);
        2: ListeazaFisier(f, deschis);
        3: AdaugaInregistrare(f, deschis);
        4: ModificaInregistrarePrinNumar(f, deschis);
        5: ModificaInregistrarePrinNrId(f, deschis);
        6: InchideFisier(f, deschis);
        0: If deschis then begin
             WriteLn('Nu se poate termina programul pentru ca fisierul este deschis!');
             optiune := 10;
             Asteapta;
           end;
      end;
    Until optiune = 0
  end. { FisCuTip }