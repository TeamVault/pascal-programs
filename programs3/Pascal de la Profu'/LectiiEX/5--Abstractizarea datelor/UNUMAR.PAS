Unit UNumar;
{ implementeaza TAD Numar in baza Baza
  ca tablou cu Lung elemente
}
Interface
  Const
    Baza = 10;          { baza sistemului de numeratie in care se lucreaza }
    Lung = 10;          { numarul maxim de cifre pentru un numar }
  Type
    Cifre = 0..Baza-1;  { cifrele bazei de numeratie }
    TCifre = Array[1..Lung] of Cifre;
    TNumar = Record
      Semn: Char;
      Cifra: TCifre;
    End;

  { operatii exportate }

  Function ToString(N: TNumar): String;
  Procedure FromNumber(R: Real; var N: TNumar; var ok: Boolean);
  Procedure FromString(S: String; var N: TNumar; var ok: Boolean);
  Procedure Read(var N: TNumar; var ok: Boolean);
  Procedure Write(N: TNumar);
  Function Compara(var A, B: TNumar): ShortInt;
  Procedure Opus(A: TNumar; var B: TNumar);
  Procedure Aduna(var A, B: TNumar; var C: TNumar);
  Procedure Scade(var A, B: TNumar; var C: TNumar);
  Procedure Inmulteste(var A,B: TNumar; var C: TNumar);
  Procedure Imparte(var A,B: TNumar; var C, R: TNumar);
  Procedure Cmmdc(var A, B: TNumar; var D: TNumar);

Implementation
  Function Max(A, B: Byte): Byte;
    begin
      If A >= B
        then Max := A
        else Max := B
    end; { Max }

  Function NumarCifre(A: TNumar): Byte;
  { intoarce numarul de cifre al numarului A }
    var
      i: Byte;
    begin
      i := 1;
      While (A.Cifra[i] = 0) and (i < Lung) do i := i + 1;
      If A.Cifra[i] = 0
        then NumarCifre := 0
        else NumarCifre := Lung - i + 1;
    end; { NumarCifre }

  Function SemnOpus(A:Char): Char;
    { intoarce semnul opus lui A }
    begin
      if A = '+' Then SemnOpus := '-' Else SemnOpus := '+';
    end; { SemnOpus }

  Function Cifra(N: TNumar; I: Integer): Cifre;
    { intoarce cifra corespunzand puterii i a bazei }
    begin
      Cifra := N.Cifra[Lung - I]
    end; { Cifra }

  Function CifraToChar(c: Cifre):Char;
    begin
      Case c of
        0..9:       CifraToChar := Chr(c + 48);
        10..Baza-1: CifraToChar := Chr(c - 10 + 65)
      end;
    end; { CifraToChar }

  Function ToString(N: TNumar): String;
    { conversie la string: in baza Baza }
    var
      S: String;
      i, j: Integer;
    begin
      S := '';
      j := 1;
      While (N.Cifra[j] = 0) and (J < Lung) do j := j + 1;
      For i := j To Lung do
        S := S + CifraToChar(N.Cifra[i]);
      If N.Semn = '-' then S := N.Semn + S;
      ToString := S
    end; { ToString }

  Procedure Zero(var N: TNumar);
    { intoarce numarul 0 }
    var
      i: Integer;
    begin
      With N do begin
        Semn := '+';
        For i := 1 to Lung do Cifra[i] := 0
      end;
    end; { Zero }

  Function CharToCifra(c: Char): Cifre;
    begin
      Case c of
        '0'..'9': CharToCifra := Ord(c) - 48;
        else      CharToCifra := Ord(c) - 55;
      end;
    end; { CharToCifra }

  Procedure FromString(S: String; var N: TNumar; var ok: Boolean);
    var
      i,
      j: Integer;
    begin
      Zero(N);
      { elimina spatiile de la inceputul lui S }
      While (S[1] = ' ') and (length(S) > 0) do Delete(S, 1, 1);
      If S = '' Then Exit;
      If S[1] in ['+', '-'] Then begin
        N.Semn := S[1];
        Delete(S, 1, 1);
      end;
      i := Length(S);
      j := Lung;
      While i > 0 do begin
        N.Cifra[j] := CharToCifra(S[i]);
        if N.Cifra[j] >= Baza then begin
          ok := False;
          exit
        end;
        i := i - 1;
        j := j - 1
      end;
      ok := True
    end; { FromString }

  Procedure FromNumber(R: Real; var N: TNumar; var ok: Boolean);
    { converteste pe I (de tip numeric) la TNumar }
    var
      c: Integer;
      s: String;
    begin
      Str(R:20:0, s);
      while (s[1] = ' ') and (length(s) > 0) do Delete(s, 1, 1);
      FromString(s, N, ok)
    end; { FromNumber }

  Procedure Read(var N: TNumar; var ok: Boolean);
    { citeste pe N de la intrarea standard }
    var
      S: String;
    begin
      System.Read(S);
      FromString(S, N, ok)
    end; { Read }

  Procedure Write(N: TNumar);
    { scrie pe N la iesirea standard }
    var
      S: String;
    begin
      S := ToString(N);
      System.Write(S)
    end; { Write }

  Function ComparaModul(var A, B: TNumar): ShortInt;
    { compara pe A si B in modul
      intoarce:
        -1 daca |A| < |B|
         0 daca |A| = |B|
         1 daca |A| > |B|
      foloseste compararea lexicografica
    }
    var
      i: Byte;
    begin
      i := 1;
      While (A.Cifra[i] = B.Cifra[i]) and (i < Lung) do i := i + 1;
      If A.Cifra[i] < B.Cifra[i] Then
        ComparaModul := -1
      Else If A.Cifra[i] > B.Cifra[i] Then
        ComparaModul := 1
      Else
        ComparaModul := 0
    end; { ComparaModul }

  Function Compara(var A, B: TNumar): ShortInt;
    { compara pe A si B tinand cont de semn
      intoarce:
        -1 daca A < B
         0 daca A = B
         1 daca A > B
    }
    begin
      If A.Semn = '+' Then
        If B.Semn = '+' Then
          Compara := ComparaModul(A, B)
        Else Compara := 1
      Else
        If B.Semn = '-' Then
          Compara := -ComparaModul(A, B)
        Else Compara := -1
    end; { Compara }

  Procedure Opus(A: TNumar; var B: TNumar);
    begin
      B := A;
      If B.Semn = '+'
        then B.Semn := '-'
        else B.Semn := '+'
    end; { Opus }

  Procedure Modul(A: TNumar; var B: TNumar);
    { B = |A| }
    begin
      B := A;
      B.Semn := '+'
    end; { Modul }

  Procedure AdunaCifre(A, B: Cifre; var T: Integer; var S: Cifre);
    { aduna cifrele zecimale A si B producand suma S si transportul T }
    var
      suma: Byte;
    begin
      suma := A + B + T;
      S := suma mod Baza;
      T := suma div Baza
    end; { AdunaCifre }

  Procedure ScadeCifre(A, B: Cifre; var T: Integer; var S: Cifre);
    { scade cifrele zecimale A si B producand diferenta S si transportul T }
    var
      dif,                { diferenta aritmetica }
      aux: Integer;       { cifra diferentei: are semnul lui dif }
    begin
      dif := A - B + T;
      aux := dif mod Baza;
      T := dif div Baza;
      if aux < 0 then begin  { ne-am imprumutat de la cifra anterioara }
        aux := aux + Baza;   { produce o cifra corecta }
        T := T - 1           { diminueaza transportul }
      end;
      S := aux;
    end; { ScadeCifre }

  Procedure AdunaModul(A, B: TNumar; Var C: TNumar);
    { aduna numerele A si B producand rezultatul R
      pre: A si B au acelasi semn
      post: C := A + B
            C are semnul lui A
    }
    var
      i: Integer;     { indice de cifra }
      l: Byte;        { numarul de cifre care se aduna }
      T: Integer;     { transportul }
    begin
      Zero(C);
      T := 0;
      { se face o iteratie in plus pentru a include si transportul }
      l := Max(NumarCifre(A), NumarCifre(B)) + 1;
      for i := 0 to l do AdunaCifre(Cifra(A,i), Cifra(B, i), T, C.Cifra[Lung-i]);
      if T <> 0 Then WriteLn('Depasire');
      C.Semn := A.Semn
    end; { AdunaModul }

  Procedure ScadeModul(A, B: TNumar; Var C: TNumar);
    { scade numerele A si B producand rezultatul R
      pre: A si B au semne diferite
           |A| > |B|
      post: C := A - B
            C are semnul lui A
    }
    var
      i: Integer;     { indice de cifra }
      l: Byte;        { numarul de cifre care se scad }
      T: Integer;     { transportul }
    begin
      Zero(C);
      T := 0;
      i := 0;
      { determina pe cate cifre se face scaderea }
      l := Max(NumarCifre(A), NumarCifre(B));
      While i <= l do begin
        ScadeCifre(Cifra(A,i), Cifra(B, i), T, C.Cifra[Lung-i]);
        i := i + 1;
      end;
      { pune transportul unde trebuie }
      if T < 0
        then C.Cifra[Lung - i] := T + Baza
        else C.Cifra[Lung - i] := T;
      C.Semn := A.Semn
    end; { ScadeModul }

  Procedure Aduna(var A, B: TNumar; Var C: TNumar);
    { C := A + B }
    begin
      Case A.Semn of
        '+': Case B.Semn of
               '+': AdunaModul(A, B, C);        { A, B, C pozitive }
               '-': Case ComparaModul(A, B) of  { A pozitiv, B negativ }
                     -1: ScadeModul(B, A, C);   { |A| < |B|, C negativ }
                      0: Zero(C);               { A = B, C = 0 }
                      1: ScadeModul(A, B, C)    { |A| > |B|, C pozitiv }
                    end;
             end;
        '-': Case B.Semn of
               '+': Case ComparaModul(A, B) of  { A negativ, B pozitiv }
                     -1: ScadeModul(B, A, C);   { |A| < |B|, C pozitiv }
                      0: Zero(C);               { A = B, C = 0 }
                      1: ScadeModul(A, B, C)    { |A| > |B|, C negativ }
                    end;
               '-': AdunaModul(A, B, C);        { A, B, C negative }
             End;
      End
    end; { Aduna }

  Procedure Scade(var A, B: TNumar; Var C: TNumar);
    { C := A - B
      apeleaza Aduna(A, -B, C) }
    Var
      D: TNumar;
    Begin
      Opus(B, D);
      Aduna(A, D, C)
    End; { Scade }

  Procedure Inmulteste(var A,B: TNumar; var C: TNumar);
    { C = A * B
      bibliografie:
        Donald E. Knuth, Tratat de programare a calculatoarelor
        volumul 3, Algoritmi seminumerici, Ed. Tehnica, Bucuresti, 1983
        Algoritmul M, p. 285
    }
    Var
      I,             { pozitia cifrei din A }
      J,             { pozitia cifrei din B }
      transport,     { transportul }
      prod,          { produsul curent }
      AI,            { cifra i din A }
      BJ: Integer;   { cifra j din B }
    Begin
      Zero(C);                                     { pasul M1 }
      For J := 0 to NumarCifre(B)-1 do begin
        BJ := Cifra(B, J);
        If BJ = 0                                  { pasul M2 }
          then C.Cifra[Lung - J] := 0
          else begin
            transport := 0;                        { pasul M3 }
            For I := 0 to NumarCifre(A)-1 do begin
              AI := Cifra(A, I);                   { pasul M4 }
              prod := AI * BJ + Cifra(C, I+J) + transport;
              C.Cifra[Lung - (I+J)] := prod mod Baza;
              transport := prod div Baza
            end; { For I }                         { pasul M5 }
            C.Cifra[Lung - (J + NumarCifre(A))]  := transport
          end;
      end; { For J }                               { pasul M6 }
      If A.Semn = B.Semn          { stabileste semnul rezultatului }
        then C.Semn := '+'
        else C.Semn := '-'
    End; { Inmulteste }

  Procedure InmultesteCuOCifra(Var A: TNumar; C: Cifre; Var B: TNumar);
    { B := A * C }
    Var
      I,             { pozitia cifrei din A }
      transport,     { transportul }
      prod: Integer; { produsul curent }
    Begin
      Zero(B);
      transport := 0;                        { pasul M3 }
      For I := 0 to NumarCifre(A)-1 do begin
        prod := Cifra(A, I) * C + Cifra(B, I) + transport;
        B.Cifra[Lung - I] := prod mod Baza;
        transport := prod div Baza
      end; { For I }                         { pasul M5 }
      B.Cifra[Lung - NumarCifre(A)]  := transport
    End; { InmultesteCuOCifra }

  Procedure ImparteCuOCifra(Var A: TNumar; C: Cifre; Var B: TNumar);
    { B := A div C
      bibliografie:
        Donald E. Knuth, Tratat de programare a calculatoarelor
        volumul 3, Algoritmi seminumerici, Ed. Tehnica, Bucuresti, 1983
        Exercitiul 16, p. 298 cu rezolvarea de la pag. 626
    }
    Var
      J,             { pozitia cifrei din A }
      r,             { transport }
      cat: Integer;  { catul curent }
    Begin
      Zero(B);
      r := 0;
      For J := NumarCifre(A) downto 1 do begin
        cat := r * Baza + Cifra(A, J-1);
        B.Cifra[Lung - J + 1] := cat div C;
        r := cat mod C
      end; { For I }
    End; { ImparteCuOCifra }

  Procedure Extrage(var A: TNumar; DeUnde, Cat: Byte; var B: TNumar);
    { B = cifrele din A de la DeUnde pana la DeUnde + Lung - 1 }
    var
      i, j: Integer;
    begin
      Zero(B);
      i := DeUnde;
      j := Lung - Cat + 1;
      While j <= Lung do begin
        B.Cifra[j] := Cifra(A, i);
        i := i - 1;
        j := j + 1
      end;
    end; { Extrage }

  Procedure Inlocuieste(var A: TNumar; DeUnde, Cat: Byte; var B: TNumar);
    { inlocuieste in A cifrele din B de la DeUnde pana la DeUnde + Lung - 1 }
    var
      i, j: Integer;
    begin
      i := Lung - DeUnde;
      j := Cat-1;
      While j >= 0 do begin
        A.Cifra[i] := Cifra(B, j);
        i := i + 1;
        j := j - 1
      end;
    end; { Inlocuieste }

  Procedure Imparte(var A,B: TNumar; var C, R: TNumar);
    { C = A div B (catul  impartirii lui A la B
      R = A mod B (restul impartirii lui A la B
        regula:
          daca deimpartitul A este pozitiv, atunci Rî[0,|B|-1]
          daca deimpartitul A este negativ, atunci Rî[-|B|+1, 0]
      bibliografie:
        Donald E. Knuth, Tratat de programare a calculatoarelor
        volumul 3, Algoritmi seminumerici, Ed. Tehnica, Bucuresti, 1983
        Algoritmul D, p. 289-290
    }
    Var
      Q,            { catul temporar }
      LA,           { numarul de cifre al lui A }
      LB,           { numarul de cifre al lui B }
      J,            { indicele cifrei din cat }
      D : Integer;  { catul de la normalizare }
      A1,           { A normalizat }
      B1,           { B normalizat }
      S,            { scazatorul la inmultire si scadere }
      P,            { descazutul la inmultire si scadere }
      PB,           { putere a bazei folosita la inmultire si scadere }
      U: TNumar;
      c1a, c2a, c3a, c1b, c2b: Integer;
      Neg: Boolean;
    Begin
      Zero(C);
      Zero(R);
      R.Semn := A.Semn;
      Case ComparaModul(A, B) of
        -1: begin
              R := A;
              Exit
            end;
         0: begin
              C.Cifra[Lung] := 1;
              If A.Semn <> B.Semn then C.Semn := '-';
              R.Semn := '+';
              Exit
            end;
      End;
      LB := NumarCifre(B);
      D := Baza Div (Cifra(B, LB-1) + 1);
      InmultesteCuOCifra(A, D, A1);  { normalizare }
      InmultesteCuOCifra(B, D, B1);
      LA := NumarCifre(A1);
      LB := NumarCifre(B1);
      c1b := Cifra(B1, LB-1);     { prima cifra a lui B1 }
      if LB < 2                   { a doua cifra a lui B1 }
        then c2b := 0
        else c2b := Cifra(B1, LB-2);
      For J := LA - LB downto 0 do begin
      { pozitia curenta in A1: J + LB }
        c1a := Cifra(A1, J+LB);
        c2a := Cifra(A1, J+LB-1);
        if LB < 2
          then c3a := 0
          else c3a := Cifra(A1, J+LB-2);
        If c1a = c1b
          then Q := Baza - 1
          else Q := (c1a * Baza + c2a) div c1b;
        While (c1b * Baza + c2b) * Q >
              (c1a * Baza + c2a) * Baza + c3a
          do Q := Q - 1;
        If Q > 0 then begin                 { inmultire si scadere }
          InmultesteCuOCifra(B1, Q, S);     { inmulteste impartitorul B cu Q
                                              se obtine scazatorul S }
          Extrage(A1, J+LB, LB+1, P);       { extrage descazutul P din A }
          Neg := False;
          If Compara(P, S) = -1 then begin  { P < S }
            Neg := True;
            Zero(PB);                       { PB este Baza^(LB + 1) }
            PB.Cifra[Lung - LB - 1] := 1;
            Aduna(PB, P, P)                 { aduna PB la P }
          end;
          Scade(P, S, PB);                  { PB = P - S }
          Inlocuieste(A1, J+LB, LB+1, PB);{ inlocuieste PB in A1 }
          If Neg then begin
            C.Cifra[Lung-J] := Q - 1;
            Aduna(PB, B1, PB);
            Inlocuieste(A1, J+LB, LB+1, PB)
          end else C.Cifra[Lung-J] := Q;
        end else C.Cifra[Lung-J] := 0;
      end; { For J }
      Extrage(A1, J+LB-1, J+LB, P);      { determina restul in P }
      ImparteCuOCifra(P, D, R);          { denormalizeaza restul }
      { stabileste semnul rezultatului }
      If A.Semn = B.Semn then begin
        C.Semn := '+';
        R.Semn := A.Semn
      end else begin
        C.Semn := '-';
        R.Semn := A.Semn
      end;
    End; { Imparte }

  Procedure Cmmdc(var A,B: TNumar; var D: TNumar);
    { D = cmmdc(A, B)
      bibliografie: algoritmul lui Euclid
    }
    var
      I, C, R, Z: TNumar;
    begin
      D := A;
      I := B;
      Zero(Z);
      while Compara(I, Z) <> 0 do begin
        Imparte(D, I, C, R);
        D := I;
        I := R
      end;
    end; { Cmmdc }

begin
end. { UNumar }