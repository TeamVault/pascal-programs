Unit IOSigur;

 { contine subprograme pentru I/O sigure pentru datele numerice }

Interface
  { citire de tipuri intregi }
  Function CitesteIntreg(m: String): Integer;
    { citeste un string de la tastatura si-l converteste la integer }
  Function CitesteByte(m: String): Byte;
    { citeste un string de la tastatura si-l converteste la byte }
  Function CitesteShortInt(m: String): ShortInt;
    { citeste un string de la tastatura si-l converteste la shortint }
  Function CitesteWord(m: String): Word;
    { citeste un string de la tastatura si-l converteste la word }
  Function CitesteLongInt(m: String): LongInt;
    { citeste un string de la tastatura si-l converteste la longint }

  { citire de tipuri reale }
  Function CitesteReal(m: String): Real;
    { citeste un string de la tastatura si-l converteste la real }

  { scriere de tipuri intregi }
  Function IntregToString(a: LongInt): String;
    { converteste intregul a la string punand si semnul }

  { scriere de tipuri reale }
  Function RealToString(a: Real; Zec: Integer): String;
    { converteste realul a la string punand si semnul }
Implementation
  Function CitesteIntreg(m: String): Integer;
    { citeste un string de la tastatura si-l converteste la integer
      in prealabil afiseaza stringul 'm' care explica ce se citeste
      citirea se repeta pana cand s-a citit un intreg valid
      se foloseste procedura standard Val
    }
    var
      s: String;      { stringul citit }
      n: Integer;     { intregul obtinut prin conversie }
      c: Integer;     { cod de eroare
                        c = 0  daca conversia de la s la n s-a facut bine
                        c <> 0 altfel
                      }
    begin
      repeat
        Write(m);
        ReadLn(s);
        Val(s, n, c);
        If c <> 0 then WriteLn('Eroare! Repetam');
      until c = 0;
      CitesteIntreg := n
    end; { CitesteIntreg }

  Function CitesteByte(m: String): Byte;
    { citeste un string de la tastatura si-l converteste la byte
      in prealabil afiseaza stringul 'm' care explica ce se citeste
      citirea se repeta pana cand s-a citit un byte valid
      se foloseste procedura standard Val
    }
    var
      s: String;      { stringul citit }
      n: LongInt;     { Byte-ul obtinut prin conversie }
      c: Integer;     { cod de eroare
                        c = 0  daca conversia de la s la n s-a facut bine
                        c <> 0 altfel
                      }
    begin
      repeat
        Write(m);
        ReadLn(s);
        Val(s, n, c);
        If c <> 0 then WriteLn('Eroare! Repetam');
      until c = 0;
      CitesteByte := n
    end; { CitesteByte }

  Function CitesteShortInt(m: String): ShortInt;
    { citeste un string de la tastatura si-l converteste la ShortInt
      in prealabil afiseaza stringul 'm' care explica ce se citeste
      citirea se repeta pana cand s-a citit un ShortInt valid
      se foloseste procedura standard Val
    }
    var
      s: String;      { stringul citit }
      n: LongInt;     { ShortInt-ul obtinut prin conversie }
      c: Integer;     { cod de eroare
                        c = 0  daca conversia de la s la n s-a facut bine
                        c <> 0 altfel
                      }
    begin
      repeat
        Write(m);
        ReadLn(s);
        Val(s, n, c);
        If c <> 0 then WriteLn('Eroare! Repetam');
      until c = 0;
      CitesteShortInt := n
    end; { CitesteShortInt }

  Function CitesteWord(m: String): Word;
    { citeste un string de la tastatura si-l converteste la Word
      in prealabil afiseaza stringul 'm' care explica ce se citeste
      citirea se repeta pana cand s-a citit un Word valid
      se foloseste procedura standard Val
    }
    var
      s: String;      { stringul citit }
      n: LongInt;     { Word-ul obtinut prin conversie }
      c: Integer;     { cod de eroare
                        c = 0  daca conversia de la s la n s-a facut bine
                        c <> 0 altfel
                      }
    begin
      repeat
        Write(m);
        ReadLn(s);
        Val(s, n, c);
        If c <> 0 then WriteLn('Eroare! Repetam');
      until c = 0;
      CitesteWord := n
    end; { CitesteWord }

  Function CitesteLongInt(m: String): LongInt;
    { citeste un string de la tastatura si-l converteste la LongInt
      in prealabil afiseaza stringul 'm' care explica ce se citeste
      citirea se repeta pana cand s-a citit un LongInt valid
      se foloseste procedura standard Val
    }
    var
      s: String;      { stringul citit }
      n: LongInt;     { LongInt-ul obtinut prin conversie }
      c: Integer;     { cod de eroare
                        c = 0  daca conversia de la s la n s-a facut bine
                        c <> 0 altfel
                      }
    begin
      repeat
        Write(m);
        ReadLn(s);
        Val(s, n, c);
        If c <> 0 then WriteLn('Eroare! Repetam');
      until c = 0;
      CitesteLongInt := n
    end; { CitesteLongInt }

  Function CitesteReal(m: String): Real;
    { citeste un string de la tastatura si-l converteste la Real
      in prealabil afiseaza stringul 'm' care explica ce se citeste
      citirea se repeta pana cand s-a citit un Real valid
      se foloseste procedura standard Val
    }
    var
      s: String;      { stringul citit }
      n: Real;        { Real-ul obtinut prin conversie }
      c: Integer;     { cod de eroare
                        c = 0  daca conversia de la s la n s-a facut bine
                        c <> 0 altfel
                      }
    begin
      repeat
        Write(m);
        ReadLn(s);
        Val(s, n, c);
        If c <> 0 then WriteLn('Eroare! Repetam');
      until c = 0;
      CitesteReal := n
    end; { CitesteReal }

  Function IntregFaraSemnToString(a: LongInt; poz: Byte): String;
    { converteste intregul a la string }
    var
      s: String;
    begin
      if a = 0 then begin
        IntregFaraSemnToString := '';
        Exit
      end;
      Str(a:poz, s);
      { elimina blank-urile de la inceput }
      while s[1] = ' ' do
        s := Copy(s, 2, Length(s)-1);
      {echivalent:
        while s[1] = ' ' do s := Delete(s, 1, 1);
      }
      IntregFaraSemnToString := s
    end; { IntregFaraSemnToString }

  Function IntregToString(a: LongInt): String;
    { converteste intregul a la string punand si semnul }
    var
      s: String;
    begin
      s := IntregFaraSemnToString(a, 15);
      if a > 0 then s := '+' + s;
      IntregToString := s
    end; { IntregToString }

  Function RealToString(a: Real; Zec: Integer): String;
    { converteste realul a la string punand si semnul }
    var
      s: String;
      pi, pf: String;
      r: Real;
      i: Byte;
    begin
      pi := IntregFaraSemnToString(Trunc(Int(a)), 15);
      { transforma partea fractionara in intreg }
      r := Frac(a);
      For i := 1 to Zec do r := r * 10;
      pf := IntregFaraSemnToString(Trunc(r), Zec);
      if pf = '' then for i := 1 to Zec do pf := pf + '0';
      s := pi + '.' + pf;
      if a > 0 then s := '+' + s;
      RealToString := s
    end; { RealToString }

begin
end. { IOSigur }