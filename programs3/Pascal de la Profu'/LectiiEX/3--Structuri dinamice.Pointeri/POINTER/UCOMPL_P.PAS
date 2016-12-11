Unit UCompl_P;
{ versiunea 2 a unit-ului UComplex
  foloseste pointeri
}
Interface

type
  TComplex = Record
    re,                 { parte reala }
    im: Real;           { parte imaginara }
  End;
  PComplex = ^TComplex; { pointer la un numar complex }

{ fata de versiunea anterioara a unit-ului UComplex, aici toate
  subprogramele care determina un numar complex nou, adica
  - FaComplex
  - Aduna
  - Scade
  - Inmulteste
  - Imparteste
  - Conjugat
  s-au transformat din proceduri in functii. Acest lucru este
  posibil in Pascal deoarece ele intorc drept rezultat un pointer
  de tip PComplex.

  In varianta anterioara a unit-ului, UComplex.PAS, aceste operatii
  nu au putut fi considerate functii deoarece ele intorceau un rezultat
  de tip TComplex (care este record). Se stie ca o functie Pascal nu poate
  intoarce decat un rezultat de tip simplu; pointerii sunt tipuri
  simple, pe cand inregistrarile (record) sunt tipuri structurate.

  Toate functiile care intorc un pointer c de tip PComplex realizeaza
  alocarea in heap a variabilei dinamice c^. Dealocarea acestei variabile
  cade in seama programului apelant (sau client al unit-ului).

  Toate functiile care intorc un pointer c de tip PComplex reprezinta
  exemple de folosire a pointerilor in subprograme. Variabilele dinamice
  create in ele au durata de viata mai mare decat durata de executie
  a functiei care le-a creat. Variabilele locale c: PComplex din fiecare
  functie isi termina existenta (durata de viata) la terminarea executiei
  functiei, deoarece ele sunt alocate in stiva. In schimb, variabilele
  dinamice c^ create prin New(c) isi continua existenta si dupa terminarea
  executiei functiei care le-a creat. Adresa lor este intoarsa in
  programul apelant si ele pot fi folosite in continuare printr-o variabila
  pointer de acelasi tip (PComplex). Va ramane in sarcina programului
  apelant (client) sa foloseasca Dispose pentru a le dealoca.

  Folosirea uzuala a acestor functii in programul apelant este;

  Uses UCompl_P;
  var
    p1, p2: PComplex;
  begin
    p1 := FaComplex(1, 2);
    p2 := FaComplex(2, 3);
    p3 := Aduna(p1, p2);
    Dispose(p1);
    Dispose(p2);
    Dispose(p3);
  end.

  Vezi programul COMPLEXP.PAS pentru folosirea unit-ului.
}

Function RealToString(r: Real): String;
Function ComplexToString(c: PComplex): String;
Function FaComplex(r, i: Real): PComplex;
Function Aduna(c1, c2: PComplex): PComplex;
Function Scade(c1, c2: PComplex): PComplex;
Function Inmulteste(c1, c2: PComplex): PComplex;
Function Imparteste(c1, c2: PComplex): PComplex;
Function Modul(c: PComplex): Real;
Function Conjugat(c1: PComplex): PComplex;

Implementation

Function RealToString(r: Real): String;
  var
    s: String;
  begin
    if frac(r) = 0
      then Str(r:10:0, s)
      else Str(r:10:2, s);
    While s[1] = ' ' do
      Delete(s, 1, 1);
    RealToString := s
  end; { RealToString }

Function ComplexToString(c: PComplex): String;
  { intoarce reprezentarea sub forma de string a nr. complex c^ }
  var
    s: String;
    semn: Char;
  begin
    s := '';
    if c^.re <> 0 then
      s := RealToString(c^.re);  { partea reala }
    if c^.im <> 0 then begin
      if c^.im > 0
        then
          if s <> ''
            then semn := '+'
            else semn := ' '
        else semn := ' ';
      s := s + semn + RealToString(c^.im) + '*i'
    end;
    ComplexToString := s;
  end; { ComplexToString }

Function FaComplex(r, i: Real): PComplex;
  { produce numarul complex c^ din partea reala r si
    partea imaginara i si intoarce un pointer la el
  }
  var
    c: PComplex;
  begin
    New(c);              { aloca pe c^ in heap }
    c^.re := r;
    c^.im := i;
    FaComplex := c
  end; { FaComplex }

Function Aduna(c1, c2: PComplex): PComplex;
  { aduna numerele complexe c1^ si c2^ si obtine numarul complex c^
    alocat in heap; intoarce un pointer la el }
  var
    c: PComplex;
  begin
    New(c);              { aloca pe c^ in heap }
    c^.re := c1^.re + c2^.re;
    c^.im := c1^.im + c2^.im;
    Aduna := c
  end; { Aduna }

Function Scade(c1, c2: PComplex): PComplex;
  { scade numerele complexe c1^ si c2^ si obtine numarul complex c^
    alocat in heap; intoarce un pointer la el }
  var
    c: PComplex;
  begin
    New(c);              { aloca pe c^ in heap }
    c^.re := c1^.re - c2^.re;
    c^.im := c1^.im - c2^.im;
    Scade := c
  end; { Scade }

Function Inmulteste(c1, c2: PComplex): PComplex;
  { inmulteste numerele complexe c1^ si c2^ si obtine numarul complex c^
    alocat in heap; intoarce un pointer la el }
  var
    c: PComplex;
  begin
    New(c);              { aloca pe c^ in heap }
    c^.re := c1^.re * c2^.re - c1^.im * c2^.im;
    c^.im := c1^.re * c2^.im + c2^.re * c1^.im;
    Inmulteste := c
  end; { Inmulteste }

Function Imparteste(c1, c2: PComplex): PComplex;
{
  imparte numerele complexe c1^ si c2^ si obtine numarul complex c^
  alocat in heap; intoarce un pointer la el

  foloseste relatia:

  a + b*i   (a + b*i)(c - d*i)   (a + b*i)(c - d*i)
  ------- = ------------------ = ------------------
  c + d*i   (c + d*i)(c - d*i)        c*c + d*d
}
  var
    c,                  { rezultatul }
    c3: PComplex;       { variabila locala: c3^ se va dealoca inainte de
                          terminarea subprogramului }
    m: Real;
  begin
    c3 := Conjugat(c2);
    c := Inmulteste(c1, c3);
    Dispose(c3);            { dealoca pe c3^ din heap }
    m := Modul(c2);
    c^.re := c^.re / sqr(m);
    c^.im := c^.im / sqr(m);
    Imparteste := c
  end; { Imparteste }

Function Modul(c: PComplex): Real;
  { intoarce modulul numarului complex c^ }
  begin
    Modul := sqrt(sqr(c^.re) + sqr(c^.im))
  end; { Modul }

Function Conjugat(c1: PComplex): PComplex;
  { determina conjugatul numarului complex c1^ in c^ alocat in heap
    intoarce un pointer la c^ }
  var
    c: PComplex;
  begin
    New(c);              { aloca pe c^ in heap }
    c^ := c1^;
    c^.im := -c^.im;
    Conjugat := c
  end; { Conjugat }

begin { cod de initializare vid }
end. { UComplex }