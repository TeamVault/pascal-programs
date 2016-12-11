Program Exemple_Record;
{ exemple de record }
Uses Crt;

Function IntToStr(i: Integer): String;
  var
    s: String;
  begin
    Str(i:4, s);
    while (s[1] = ' ') and (length(s) > 0) do Delete(s, 1, 1);
    IntToStr := s
  end; { IntToStr }

type
  DataC = record
    zi: 1..31;
    lu: 1..12;
    an: integer
  end; { DataC }

Function DataToString(d: DataC): String;
  begin
    DataToString := IntToStr(d.zi) + '/' +
                    IntToStr(d.lu) + '/' +
                    IntToStr(d.an)
  end; { DataToString }

type
  Element_Ecran = record
    car: char;
    atr: byte
  end; { Element_Ecran }
  Ecran = array[1..25, 1..80] of Element_Ecran;  { ecranul text }

type
  A40 = array[1..40] of char;

Function A40ToString(a: A40): String;
  var
    s: String;
    i: Byte;
  begin
    s := '';
    for i := 1 to 40 do s := s + a[i];
    A40ToString := s
  end; { A40ToString }

type
  TipSex = (masc, fem);

Function DenSex(s: TipSex): String;
  begin
    case s of
      masc: DenSex := 'masculin';
      fem:  DenSex := 'feminin'
    end
  end; { DenSex }

type
  StareCiv = (necas, casat, vaduv, divortat);

Function DenStareCiv(s: StareCiv): String;
  begin
    case s of
      necas:    DenStareCiv := 'necasatorit';
      casat:    DenStareCiv := 'casatorit';
      vaduv:    DenStareCiv := 'vaduv';
      divortat: DenStareCiv := 'divortat';
    end
  end; { DenStareCiv }

type
  Persoana = Record
    Nume: String[30];
    NrId: LongInt;
    Adr: A40;
    Sex: TipSex;
    StareC: StareCiv;
    DataN: DataC;
    Inaltime: Real
  end; { Persoana }

Procedure ScriePersoana(p: Persoana);
  begin
    WriteLn(p.Nume, ', ',
            p.NrId, ', ',
            A40ToString(p.Adr), ', ',
            DenSex(p.Sex), ', ',
            DenStareCiv(p.StareC), ', ',
            DataToString(p.DataN), ', ',
            p.Inaltime:3:2);
  end; { ScriePersoana }

const
  MaxPers = 100;
  MaxDisc = 20;
type
  Personal = array[1..MaxPers] of Persoana;
  Medie = record
    Parte_Int,
    Parte_Zec: Byte;
  end;

Function MedieToStr(m: Medie): String;
  begin
    MedieToStr := IntToStr(m.Parte_Int) + '.' + IntToStr(m.Parte_Zec)
  end; { MedieToStr }

type
  Medii = array[1..MaxDisc] of Medie;

Procedure ScrieMedii(m: Medii);
  var
    i: Byte;
  begin
    for i := 1 to MaxDisc do Write(i:2, ':', MedieToStr(m[i]), ' ');
    WriteLn
  end; { ScrieMedii }

type
  Trimestru = 1..3;
  Elev = record
    DatePers: Persoana;
    SituatieScolara: Array[Trimestru] of Medii;
  end;

Procedure ScrieElev(e: Elev);
  Var
    t: Trimestru;
  begin
    WriteLn('Date personale:');
    ScriePersoana(e.DatePers);
    WriteLn('Situatia scolara:');
    For t := 1 to 3 do begin
      WriteLn('Trimestrul ', t:1);
      ScrieMedii(e.SituatieScolara[t])
    end;
  end;

type
  PersVar = record
    Nume: String[30];
    NrId: LongInt;
    Adr: A40;
    Sex: TipSex;
    case StareC: StareCiv of
      necas:    (Inalt: Real; Nume_logodnic: A40);
      casat:    (Numar_copii: Integer; Nume_sot: A40);
      vaduv:    (Pensie_urmas: Boolean);
      divortat: (Pensie_alim: Real);
  end;

Procedure ScriePersVar(p: PersVar);
  begin
    Write(p.Nume, ', ',
          p.NrId, ', ',
          A40ToString(p.Adr), ', ',
          DenSex(p.Sex), ', ',
          DenStareCiv(p.StareC), ', ');
    Case p.StareC of
      necas:    WriteLn('Inaltime: ', p.Inalt:3:2, ', ',
                'Logodnic: ', A40ToString(p.Nume_logodnic));
      casat:    WriteLn('Copii: ', p.Numar_copii:2, ', ',
                'Sot: ', A40ToString(p.Nume_sot));
      vaduv:    WriteLn('Are pensie de urmas: ', p.Pensie_urmas);
      divortat: WriteLn('Pensie alimentara: ', p.Pensie_alim:10:0);
    end;
  end; { ScriePersVar }

const
  P1: PersVar = (Nume: 'Popescu';
                 NrId: 999;
                 Adr: 'Malului 5, Alba Iulia';
                 Sex: masc;
                 StareC: necas;
                 Inalt: 1.82;
                 Nume_logodnic: 'Steffi Graf');
  P2: PersVar = (Nume: 'Ionescu Narcisa';
                 NrId: 995;
                 Adr: 'Malului 8, Alba Iulia, Alba';
                 Sex: fem;
                 StareC: casat;
                 Numar_copii: 2;
                 Nume_sot: 'Robert Redford');
  P3: PersVar = (Nume: 'Petrescu Narcisa';
                 NrId: 905;
                 Adr: 'Malului 11, Alba Iulia, Alba';
                 Sex: fem;
                 StareC: vaduv;
                 Pensie_urmas: False);
  P4: PersVar = (Nume: 'Ionescu Petre';
                 NrId: 5;
                 Adr: 'Malului 11, Alba Iulia, Alba';
                 Sex: masc;
                 StareC: divortat;
                 Pensie_alim: 1000000);

Procedure Demo1;
{ demonstreaza calificarea campurilor intr-o inregistrare }
  var
    azi: DataC;
  Procedure InitPunct;
  { initializeaza pe azi folosind calificari cu punct }
    begin
      WriteLn('Calificare cu punct');
      azi.zi := 12;
      azi.lu := 1;
      azi.an := 1999;
    end;
  Procedure InitWith;
  { initializeaza pe azi folosind calificari cu With }
    begin
      WriteLn('Calificare cu With');
      with azi do begin
        zi := 12;
        lu := 1;
        an := 1999
      end;
    end; { InitWith }
  begin { Demo1 }
    WriteLn('Demo1: calificarea campurilor intr-o inregistrare');
    InitWith;
    WriteLn(DataToString(azi));
    InitPunct;
    WriteLn(DataToString(azi));
  end; { Demo1 }

Procedure InitPunct(var p: Persoana);
{ initializeaza pe p folosind calificari cu punct }
  var
    i: Byte;
  begin
    p.Nume := 'Ionescu';
    p.NrId := 5;
    p.Sex := fem;
    p.StareC := vaduv;
    for i := 1 to 10 do p.Adr[i] := chr(64 + i);
    for i := 11 to 20 do p.Adr[i] := chr(95 + i - 10);
    for i := 21 to 40 do p.Adr[i] := ' ';
    p.DataN.zi := 1;
    p.DataN.an := 1;
    p.DataN.lu := 1;
    p.Inaltime := 1.92;
  end; { InitPunct }
Procedure Demo2;
{ demonstreaza calificarea campurilor intr-o inregistrare mai complexa }
  var
    p: Persoana;
  Procedure InitPunct;
  { initializeaza pe p folosind calificari cu punct }
    var
      i: Byte;
    begin
      WriteLn('Calificare cu punct');
      p.Nume := 'Ionescu';
      p.NrId := 5;
      p.Sex := fem;
      p.StareC := vaduv;
      for i := 1 to 10 do p.Adr[i] := chr(64 + i);
      for i := 11 to 20 do p.Adr[i] := chr(95 + i - 10);
      for i := 21 to 40 do p.Adr[i] := ' ';
      p.DataN.zi := 1;
      p.DataN.an := 1;
      p.DataN.lu := 1;
      p.Inaltime := 1.92;
    end; { InitPunct }
  Procedure InitWith;
  { initializeaza pe p folosind calificari cu With }
    var
      i: Byte;
    begin
      WriteLn('Calificare cu With');
      with p do begin
        Nume := 'Ionescu';
        NrId := 5;
        Sex := fem;
        StareC := vaduv;
        for i := 1 to 10 do Adr[i] := chr(64 + i);
        for i := 11 to 20 do Adr[i] := chr(95 + i - 10);
        for i := 21 to 40 do p.Adr[i] := ' ';
        with DataN do begin
          zi := 1;
          an := 1;
          lu := 1
        end;
        Inaltime := 1.92
      end;
    end; { InitWith }
  begin { Demo2 }
    WriteLn('Demo2: calificarea campurilor intr-o inregistrare complexa');
    InitPunct;
    ScriePersoana(p);
    InitWith;
    ScriePersoana(p);
  end; { Demo2 }
Procedure Demo3;
  var
    e: Elev;
    t, d: Byte;
  begin
    WriteLn('Demo3: folosirea inregistrarilor complexe');
    InitPunct(e.DatePers);
    Randomize;
    for t := 1 to 3 do
      for d := 1 to MaxDisc do begin
        e.SituatieScolara[t][d].Parte_Int := Random(10);
        if e.SituatieScolara[t][d].Parte_Int = 10
          then e.SituatieScolara[t][d].Parte_Zec := 0
          else e.SituatieScolara[t][d].Parte_Zec := Random(99)
      end; { for d }
    ScrieElev(e);
  end; { Demo3 }
Procedure Demo4;
  begin
    WriteLn('Demo4: inregistrari cu variante');
    ScriePersVar(P1);
    ScriePersVar(P2);
    ScriePersVar(P3);
    ScriePersVar(P4)
  end; { Demo4 }

var
  rasp: Byte;
begin
  Repeat
    ClrScr;
    WriteLn('Optiuni:');
    WriteLn('1. Inregistrari simple');
    WriteLn('2. Inregistrari mai complexe');
    WriteLn('3. Inregistrari complexe');
    WriteLn('4. Inregistrari cu variante');
    WriteLn('0. Terminare');
    WriteLn;
    Write('Selectati optiunea: ');
    ReadLn(rasp);
    Case rasp of
      1:   Demo1;
      2:   Demo2;
      3:   Demo3;
      4:   Demo4;
      0:   Break
    End;
    ReadLn
  Until rasp = 0
end.

