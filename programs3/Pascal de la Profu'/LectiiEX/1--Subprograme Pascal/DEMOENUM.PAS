Program DemoEnum;
{ program demonstrativ pentru tipurile enumerare}

Uses
  Crt;

type
  PuncteCardinale = (Nord, Est, Sud, Vest);

Function DenumirePuncteCardinale(p: PuncteCardinale): String;
  var
    s: String;
  begin
    case p of
      Nord: s := 'Nord';
      Est:  s := 'Est';
      Sud:  s := 'Sud';
      Vest: s := 'Vest';
    end;
    DenumirePuncteCardinale := s
  end; { DenumirePuncteCardinale }

Procedure WritePuncteCardinale(M: String; p: PuncteCardinale);
  begin
    Write(M, ': ');
    WriteLn(DenumirePuncteCardinale(p));
    WriteLn('Ord(', DenumirePuncteCardinale(p), ') este: ', Ord(p));
    WriteLn('Low(', DenumirePuncteCardinale(p), ') este: ',
                    DenumirePuncteCardinale(Low(p)));
    WriteLn('High(', DenumirePuncteCardinale(p), ') este: ',
                    DenumirePuncteCardinale(High(p)));
    Write('Pred(', DenumirePuncteCardinale(p), ') este: ');
    If p = Low(p)
      then WriteLn('nedefinit')
      else WriteLn(DenumirePuncteCardinale(Pred(p)));
    Write('Succ(', DenumirePuncteCardinale(p), ') este: ');
    If p = High(p)
      then WriteLn('nedefinit')
      else WriteLn(DenumirePuncteCardinale(Succ(p)));
  end; { WritePuncteCardinale }

Procedure DemoPuncteCardinale;
  var
    a, b, c: PuncteCardinale;
    i: Byte;
  begin
    WriteLn('Domeniul tipului PuncteCardinale este: ');
    for i := Ord(Low(a)) to Ord(High(a)) do
      Write(DenumirePuncteCardinale(PuncteCardinale(i)), ' ');
    WriteLn;
    a := Nord;
    b := Vest;
    c := Sud;
    WritePuncteCardinale('a',a);
    WritePuncteCardinale('b',b);
    WritePuncteCardinale('c',c);
    ReadLn
  end; { DemoPuncteCardinale }

type
  Spectru = (Rosu, Orange, Galben, Verde, Albastru, Indigo, Violet);

Function DenumireSpectru(p: Spectru): String;
  var
    s: String;
  begin
    case p of
      Rosu:     s := 'Rosu';
      Orange:   s := 'Orange';
      Galben:   s := 'Galben';
      Verde:    s := 'Verde';
      Albastru: s := 'Albastru';
      Indigo:   s := 'Indigo';
      Violet:   s := 'Violet'
    end;
    DenumireSpectru := s
  end; { DenumireSpectru }

Procedure WriteSpectru(M: String; p: Spectru);
  begin
    Write(M, ': ');
    WriteLn(DenumireSpectru(p));
    WriteLn('Ord(', DenumireSpectru(p), ') este: ', Ord(p));
    WriteLn('Low(', DenumireSpectru(p), ') este: ',
                    DenumireSpectru(Low(p)));
    WriteLn('High(', DenumireSpectru(p), ') este: ',
                    DenumireSpectru(High(p)));
    Write('Pred(', DenumireSpectru(p), ') este: ');
    If p = Low(p)
      then WriteLn('nedefinit')
      else WriteLn(DenumireSpectru(Pred(p)));
    Write('Succ(', DenumireSpectru(p), ') este: ');
    If p = High(p)
      then WriteLn('nedefinit')
      else WriteLn(DenumireSpectru(Succ(p)));
  end; { WriteSpectru }

Procedure DemoSpectru;
  var
    a, b, c: Spectru;
    i: Byte;
  begin
    WriteLn('Domeniul tipului Spectru este: ');
    for i := Ord(Low(a)) to Ord(High(a)) do
      Write(DenumireSpectru(Spectru(i)), ' ');
    WriteLn;
    a := Rosu;
    b := Violet;
    c := Verde;
    WriteSpectru('a',a);
    WriteSpectru('b',b);
    WriteSpectru('c',c);
    ReadLn
  end; { DemoSpectru }

type
  Anotimp = (Primavara, Vara, Toamna, Iarna);

Function DenumireAnotimp(p: Anotimp): String;
  var
    s: String;
  begin
    case p of
      Primavara: s := 'Primavara';
      Vara:      s := 'Vara';
      Toamna:    s := 'Toamna';
      Iarna:     s := 'Iarna';
    end;
    DenumireAnotimp := s
  end; { DenumireAnotimp }

Procedure WriteAnotimp(M: String; p: Anotimp);
  begin
    Write(M, ': ');
    WriteLn(DenumireAnotimp(p));
    WriteLn('Ord(', DenumireAnotimp(p), ') este: ', Ord(p));
    WriteLn('Low(', DenumireAnotimp(p), ') este: ',
                    DenumireAnotimp(Low(p)));
    WriteLn('High(', DenumireAnotimp(p), ') este: ',
                    DenumireAnotimp(High(p)));
    Write('Pred(', DenumireAnotimp(p), ') este: ');
    If p = Low(p)
      then WriteLn('nedefinit')
      else WriteLn(DenumireAnotimp(Pred(p)));
    Write('Succ(', DenumireAnotimp(p), ') este: ');
    If p = High(p)
      then WriteLn('nedefinit')
      else WriteLn(DenumireAnotimp(Succ(p)));
  end; { WriteAnotimp }

Procedure DemoAnotimp;
  var
    a, b, c: Anotimp;
    i: Byte;
  begin
    WriteLn('Domeniul tipului Anotimp este: ');
    for i := Ord(Low(a)) to Ord(High(a)) do
      Write(DenumireAnotimp(Anotimp(i)), ' ');
    WriteLn;
    a := Iarna;
    b := Vara;
    c := Primavara;
    WriteAnotimp('a',a);
    WriteAnotimp('b',b);
    WriteAnotimp('c',c);
    ReadLn
  end; { DemoAnotimp }

type
  Zile = (Luni, Marti, Miercuri, Joi, Vineri, Sambata, Duminica);

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

Procedure WriteZile(M: String; p: Zile);
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
  end; { WriteZile }

Procedure DemoZile;
  var
    a, b, c: Zile;
    i: Byte;
  begin
    WriteLn('Domeniul tipului Zile este: ');
    for i := Ord(Low(a)) to Ord(High(a)) do
      Write(DenumireZile(Zile(i)), ' ');
    WriteLn;
    a := Luni;
    b := Duminica;
    c := Miercuri;
    WriteZile('a',a);
    WriteZile('b',b);
    WriteZile('c',c);
    ReadLn
  end; { DemoZile }

type
  LuniDinAn = (Ianuarie, Februarie, Martie, Aprilie, Mai, Iunie, Iulie,
               August, Septembrie, Octombrie, Noiembrie, Decembrie);

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

Procedure WriteLuniDinAn(M: String; p: LuniDinAn);
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
  end; { WriteLuniDinAn }

Procedure DemoLuniDinAn;
  var
    a, b, c: LuniDinAn;
    i: Byte;
  begin
    WriteLn('Domeniul tipului LuniDinAn este: ');
    for i := Ord(Low(a)) to Ord(High(a)) do
      Write(DenumireLuniDinAn(LuniDinAn(i)), ' ');
    WriteLn;
    a := Ianuarie;
    b := Decembrie;
    c := Mai;
    WriteLuniDinAn('a',a);
    WriteLuniDinAn('b',b);
    WriteLuniDinAn('c',c);
    ReadLn
  end; { DemoLuniDinAn }

var
  optiune: byte;
begin
  Repeat
    ClrScr;
    WriteLn('DEMOENUM - program demonstrativ pentru tipurile enumerare');
    WriteLn('1. Tipul PuncteCardinale');
    WriteLn('2. Tipul Spectru');
    WriteLn('3. Tipul Anotimp');
    WriteLn('4. Tipul Zile');
    WriteLn('5. Tipul LuniDinAn');
    WriteLn('0. Terminare');
    Write('Dati optiunea: ');
    ReadLn(optiune);
    Case optiune of
      1: DemoPuncteCardinale;
      2: DemoSpectru;
      3: DemoAnotimp;
      4: DemoZile;
      5: DemoLuniDinAn;
    end
  Until optiune = 0
end. { DemoEnum }