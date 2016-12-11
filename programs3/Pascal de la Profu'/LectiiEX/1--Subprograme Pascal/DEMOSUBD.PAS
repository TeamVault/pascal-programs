Program DemoSubd;
{ program demonstrativ pentru tipurile subdomeniu }

Uses
  Crt;

type
  Sutime = 0..99;          { Tipul gazda este Integer }

Procedure WriteSutime(M: String; p: Sutime);
  begin
    Write(M, ': ');
    WriteLn(p);
    WriteLn('Ord(', p, ') este: ', Ord(p));
    WriteLn('Low(', p, ') este: ', Low(p));
    WriteLn('High(', p, ') este: ', High(p));
    Write('Pred(', p, ') este: ');
    If p = Low(p)
      then WriteLn('nedefinit')
      else WriteLn(Pred(p));
    Write('Succ(', p, ') este: ');
    If p = High(p)
      then WriteLn('nedefinit')
      else WriteLn(Succ(p));
  end; { WriteSutime }

Procedure DemoSutime;
  var
    a, b, c: Sutime;
    i: Integer;
  begin
    WriteLn('Domeniul tipului Sutime este: ');
    for i := Ord(Low(a)) to Ord(High(a)) do
      Write(Ord(i), ' ');
    WriteLn;
    a := 0;
    b := 99;
    c := 50;
    WriteSutime('a',a);
    WriteSutime('b',b);
    WriteSutime('c',c);
    ReadLn
  end; { DemoSutime }

type
  CifreZecimale = 0..9;          { Tipul gazda este Integer }

Procedure WriteCifreZecimale(M: String; p: CifreZecimale);
  begin
    Write(M, ': ');
    WriteLn(p);
    WriteLn('Ord(', p, ') este: ', Ord(p));
    WriteLn('Low(', p, ') este: ', Low(p));
    WriteLn('High(', p, ') este: ', High(p));
    Write('Pred(', p, ') este: ');
    If p = Low(p)
      then WriteLn('nedefinit')
      else WriteLn(Pred(p));
    Write('Succ(', p, ') este: ');
    If p = High(p)
      then WriteLn('nedefinit')
      else WriteLn(Succ(p));
  end; { WriteCifreZecimale }

Procedure DemoCifreZecimale;
  var
    a, b, c: CifreZecimale;
    i: Integer;
  begin
    WriteLn('Domeniul tipului CifreZecimale este: ');
    for i := Ord(Low(a)) to Ord(High(a)) do
      Write(Ord(i), ' ');
    WriteLn;
    a := 0;
    b := 9;
    c := 5;
    WriteCifreZecimale('a',a);
    WriteCifreZecimale('b',b);
    WriteCifreZecimale('c',c);
    ReadLn
  end; { DemoCifreZecimale }

type
  CifreOctale = 0..7;          { Tipul gazda este Integer }

Procedure WriteCifreOctale(M: String; p: CifreOctale);
  begin
    Write(M, ': ');
    WriteLn(p);
    WriteLn('Ord(', p, ') este: ', Ord(p));
    WriteLn('Low(', p, ') este: ', Low(p));
    WriteLn('High(', p, ') este: ', High(p));
    Write('Pred(', p, ') este: ');
    If p = Low(p)
      then WriteLn('nedefinit')
      else WriteLn(Pred(p));
    Write('Succ(', p, ') este: ');
    If p = High(p)
      then WriteLn('nedefinit')
      else WriteLn(Succ(p));
  end; { WriteCifreOctale }

Procedure DemoCifreOctale;
  var
    a, b, c: CifreOctale;
    i: Integer;
  begin
    WriteLn('Domeniul tipului CifreOctale este: ');
    for i := Ord(Low(a)) to Ord(High(a)) do
      Write(Ord(i), ' ');
    WriteLn;
    a := 0;
    b := 7;
    c := 5;
    WriteCifreOctale('a',a);
    WriteCifreOctale('b',b);
    WriteCifreOctale('c',c);
    ReadLn
  end; { DemoCifreOctale }

type
  CifreBinare = 0..1;          { Tipul gazda este Integer }

Procedure WriteCifreBinare(M: String; p: CifreBinare);
  begin
    Write(M, ': ');
    WriteLn(p);
    WriteLn('Ord(', p, ') este: ', Ord(p));
    WriteLn('Low(', p, ') este: ', Low(p));
    WriteLn('High(', p, ') este: ', High(p));
    Write('Pred(', p, ') este: ');
    If p = Low(p)
      then WriteLn('nedefinit')
      else WriteLn(Pred(p));
    Write('Succ(', p, ') este: ');
    If p = High(p)
      then WriteLn('nedefinit')
      else WriteLn(Succ(p));
  end; { WriteCifreBinare }

Procedure DemoCifreBinare;
  var
    a, b: CifreBinare;
    i: Integer;
  begin
    WriteLn('Domeniul tipului CifreBinare este: ');
    for i := Ord(Low(a)) to Ord(High(a)) do
      Write(Ord(i), ' ');
    WriteLn;
    a := 0;
    b := 1;
    WriteCifreBinare('a',a);
    WriteCifreBinare('b',b);
    ReadLn
  end; { DemoCifreBinare }

type
  Zile = (Luni, Marti, Miercuri, Joi, Vineri, Sambata, Duminica);
  ZileLucratoare = Luni .. Vineri;       { Tipul gazda este Zile }

Function DenumireZile(p: Zile): String;
  var
    s: String;
  begin
    case p of
      Luni:     s := 'Luni';
      Marti:    s := 'Marti';
      Miercuri: s := 'Miercuri';
      Joi:      s := 'Joi';
      Vineri:   s := 'Vineri';
      Sambata:  s := 'Sambata';
      Duminica: s := 'Duminica'
    end;
    DenumireZile := s
  end; { DenumireZile }

Procedure WriteZileLucratoare(M: String; p: ZileLucratoare);
  begin
    Write(M, ': ');
    WriteLn(DenumireZile(p));
    WriteLn('Ord(', DenumireZile(p), ') este: ', Ord(p));
    WriteLn('Low(', DenumireZile(p), ') este: ',
                    DenumireZile(Low(p)));
    WriteLn('High(', DenumireZile(p), ') este: ',
                    DenumireZile(High(p)));
    Write('Pred(', DenumireZile(p), ') este: ');
    If p = Low(p)
      then WriteLn('nedefinit')
      else WriteLn(DenumireZile(Pred(p)));
    Write('Succ(', DenumireZile(p), ') este: ');
    If p = High(p)
      then WriteLn('nedefinit')
      else WriteLn(DenumireZile(Succ(p)));
  end; { WriteZileLucratoare }

Procedure DemoZileLucratoare;
  var
    a, b, c: ZileLucratoare;
    i: Byte;
  begin
    WriteLn('Domeniul tipului ZileLucratoare este: ');
    for i := Ord(Low(a)) to Ord(High(a)) do
      Write(DenumireZile(Zile(i)), ' ');
    WriteLn;
    a := Luni;
    b := Vineri;
    c := Miercuri;
    WriteZileLucratoare('a',a);
    WriteZileLucratoare('b',b);
    WriteZileLucratoare('c',c);
    ReadLn
  end; { DemoZileLucratoare }

type
  LuniDinAn = (Ianuarie, Februarie, Martie, Aprilie, Mai, Iunie, Iulie,
               August, Septembrie, Octombrie, Noiembrie, Decembrie);
  LuniDeVara = Iunie..August;            { Tipul gazda este LuniDinAn }

Function DenumireLuniDinAn(p: LuniDinAn): String;
  var
    s: String;
  begin
    case p of
      Ianuarie:   s := 'Ianuarie';
      Februarie:  s := 'Februarie';
      Martie:     s := 'Martie';
      Aprilie:    s := 'Aprilie';
      Mai:        s := 'Mai';
      Iunie:      s := 'Iunie';
      Iulie:      s := 'Iulie';
      August:     s := 'August';
      Septembrie: s := 'Septembrie';
      Octombrie:  s := 'Octombrie';
      Noiembrie:  s := 'Noiembrie';
      Decembrie:  s := 'Decembrie'
    end;
    DenumireLuniDinAn := s
  end; { DenumireLuniDinAn }

Procedure WriteLuniDeVara(M: String; p: LuniDeVara);
  begin
    Write(M, ': ');
    WriteLn(DenumireLuniDinAn(p));
    WriteLn('Ord(', DenumireLuniDinAn(p), ') este: ', Ord(p));
    WriteLn('Low(', DenumireLuniDinAn(p), ') este: ',
                    DenumireLuniDinAn(Low(p)));
    WriteLn('High(', DenumireLuniDinAn(p), ') este: ',
                    DenumireLuniDinAn(High(p)));
    Write('Pred(', DenumireLuniDinAn(p), ') este: ');
    If p = Low(p)
      then WriteLn('nedefinit')
      else WriteLn(DenumireLuniDinAn(Pred(p)));
    Write('Succ(', DenumireLuniDinAn(p), ') este: ');
    If p = High(p)
      then WriteLn('nedefinit')
      else WriteLn(DenumireLuniDinAn(Succ(p)));
  end; { WriteLuniDeVara }

Procedure DemoLuniDeVara;
  var
    a, b, c: LuniDeVara;
    i: Byte;
  begin
    WriteLn('Domeniul tipului LuniDeVara este: ');
    for i := Ord(Low(a)) to Ord(High(a)) do
      Write(DenumireLuniDinAn(LuniDinAn(i)), ' ');
    WriteLn;
    a := Iunie;
    b := August;
    c := Iulie;
    WriteLuniDeVara('a',a);
    WriteLuniDeVara('b',b);
    WriteLuniDeVara('c',c);
    ReadLn
  end; { DemoLuniDeVara }

var
  optiune: byte;
begin
  Repeat
    ClrScr;
    WriteLn('DEMOSUBD - program demonstrativ pentru tipurile subdomeniu');
    WriteLn('1. Tipul Sutime');
    WriteLn('2. Tipul CifreZecimale');
    WriteLn('3. Tipul CifreOctale');
    WriteLn('4. Tipul CifreBinare');
    WriteLn('5. Tipul ZileLucratoare');
    WriteLn('6. Tipul LuniDeVara');
    WriteLn('0. Terminare');
    Write('Dati optiunea: ');
    ReadLn(optiune);
    Case optiune of
      1: DemoSutime;
      2: DemoCifreZecimale;
      3: DemoCifreOctale;
      4: DemoCifreBinare;
      5: DemoZileLucratoare;
      6: DemoLuniDeVara;
    end
  Until optiune = 0
end. { DemoSubd }