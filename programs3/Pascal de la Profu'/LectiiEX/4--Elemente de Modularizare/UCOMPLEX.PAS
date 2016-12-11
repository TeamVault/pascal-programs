Unit UComplex;

Interface

type
  TComplex = Record
    re,                { parte reala }
    im: Real;          { parte imaginara }
  End;

Function RealToString(r: Real): String;
Function ComplexToString(c: TComplex): String;
Procedure FaComplex(r, i: Real; var c: TComplex);
Procedure Aduna(c1, c2: TComplex; var c: TComplex);
Procedure Scade(c1, c2: TComplex; var c: TComplex);
Procedure Inmulteste(c1, c2: TComplex; var c: TComplex);
Procedure Imparteste(c1, c2: TComplex; var c: TComplex);
Function Modul(c: TComplex): Real;
Procedure Conjugat(c1: TComplex; var c: TComplex);

Implementation

Function RealToString(r: Real): String;
  var
    s: String;
  begin
    if frac(r) = 0
      then Str(r:10:0, s)
      else Str(r:10:2, s);
    { elimina blank-urile de la inceput }
    While (s[1] = ' ') and (s <> '') do Delete(s, 1, 1);
    RealToString := s
  end; { RealToString }

Function ComplexToString(c: TComplex): String;
  { intoarce reprezentarea sub forma de string a nr. complex }
  var
    s: String;
    semn: Char;
  begin
    s := '';
    if c.re <> 0 then
      s := RealToString(c.re);  { partea reala }
    if c.im <> 0 then begin
      if c.im > 0
        then
          if s <> ''
            then semn := '+'
            else semn := ' '
        else semn := ' ';
      s := s + semn + RealToString(c.im) + '*i'
    end;
    ComplexToString := s;
  end; { ComplexToString }

Procedure FaComplex(r, i: Real; var c: TComplex);
  { produce numarul complex c din partea reala r si partea imaginara i }
  begin
    c.re := r;
    c.im := i
  end; { FaComplex }

Procedure Aduna(c1, c2: TComplex; var c: TComplex);
  { aduna numerele complexe c1 si c2 si obtine numarul complex c }
  begin
    c.re := c1.re + c2.re;
    c.im := c1.im + c2.im;
  end; { Aduna }

Procedure Scade(c1, c2: TComplex; var c: TComplex);
  { scade numerele complexe c1 si c2 si obtine numarul complex c }
  begin
    c.re := c1.re - c2.re;
    c.im := c1.im - c2.im;
  end; { Scade }

Procedure Inmulteste(c1, c2: TComplex; var c: TComplex);
  { inmulteste numerele complexe c1 si c2 si obtine numarul complex c }
  begin
    c.re := c1.re * c2.re - c1.im * c2.im;
    c.im := c1.re * c2.im + c2.re * c1.im;
  end; { Inmulteste }

Procedure Imparteste(c1, c2: TComplex; var c: TComplex);
{ imparte numerele complexe c1 si c2 si obtine numarul complex c

  foloseste relatia:

  a + b*i   (a + b*i)(c - d*i)   (a + b*i)(c - d*i)
  ------- = ------------------ = ------------------
  c + d*i   (c + d*i)(c - d*i)        c*c + d*d
}
  var
    c3: TComplex;
    m: Real;
  begin
    Conjugat(c2, c3);
    Inmulteste(c1, c3, c);  { c este numaratorul rezultatului }
    m := Modul(c2);         { m^ este numitorul rezultatului }
    c.re := c.re / sqr(m);
    c.im := c.im / sqr(m)
  end; { Imparteste }

Function Modul(c: TComplex): Real;
  { intoarce modulul numarului complex c }
  begin
    Modul := sqrt(sqr(c.re) + sqr(c.im))
  end; { Modul }

Procedure Conjugat(c1: TComplex; var c: TComplex);
  { intoarce conjugatul numarului complex c1 in c }
  begin
    c := c1;
    c.im := -c.im
  end; { Conjugat }

begin { cod de initializare vid }
end. { UComplex }