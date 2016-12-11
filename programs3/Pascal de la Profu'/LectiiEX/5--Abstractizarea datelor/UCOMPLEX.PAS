Unit UComplex;
{ implementeaza tipul Complex ca obiect
  versiunea 2 a unit-ului UComplexe - lectia 2 }

Interface

type
  CComplex = Object                   { clasa CComplex }
    Function ToString: String;
    Constructor Fa(r, i: Real);
    Constructor Copy(c: CComplex);
    Procedure Aduna(c1, c2: CComplex);
    Procedure Scade(c1, c2: CComplex);
    Procedure Inmulteste(c1, c2: CComplex);
    Procedure Imparteste(c1, c2: CComplex);
    Function Modul: Real;
    Procedure Conjugat(c1: CComplex);
    { operatii noi }
    Function ParteReala: Real;      { selector, accesor }
    Function ParteImaginara: Real;  { selector, accesor }
    private            { campuri private: ascunderea informatiei }
      re,              { parte reala }
      im: Real;        { parte imaginara }
  End;

Function RealToString(r: Real): String;

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

Function CComplex.ToString: String;
  { intoarce reprezentarea sub forma de string a nr. complex }
  var
    s: String;
    semn: Char;
  begin
    s := '';
    if Self.re <> 0 then
      s := RealToString(Self.re);  { partea reala }
    if Self.im <> 0 then begin
      if Self.im > 0
        then
          if s <> ''
            then semn := '+'
            else semn := ' '
        else semn := ' ';
      s := s + semn + RealToString(Self.im) + '*i'
    end;
    ToString := s;
  end; { ComplexToString }

Constructor CComplex.Fa(r, i: Real);
  { produce numarul complex Self din partea reala r si
    partea imaginara i
  }
  begin
    Self.re := r;
    Self.im := i
  end; { FaComplex }

Constructor CComplex.Copy(c: CComplex);
  { constructor de copiere: Self := c
  }
  begin
    Self.re := c.re;
    Self.im := c.im
  end; { Copy }

Procedure CComplex.Aduna(c1, c2: CComplex);
  { aduna numerele complexe c1 si c2 si obtine numarul complex Self
    Apel: c.Aduna(c1, c2) produce c := c1 + c2.
  }
  begin
    Self.re := c1.re + c2.re;
    Self.im := c1.im + c2.im;
  end; { Aduna }

Procedure CComplex.Scade(c1, c2: CComplex);
  { scade numerele complexe c1 si c2 si obtine numarul complex Self }
  begin
    Self.re := c1.re - c2.re;
    Self.im := c1.im - c2.im;
  end; { Scade }

Procedure CComplex.Inmulteste(c1, c2: CComplex);
  { inmulteste numerele complexe c1 si c2 si obtine numarul complex Self }
  begin
    Self.re := c1.re * c2.re - c1.im * c2.im;
    Self.im := c1.re * c2.im + c2.re * c1.im;
  end; { Inmulteste }

Function CComplex.Modul: Real;
  { intoarce modulul numarului complex Self }
  begin
    Modul := sqrt(sqr(Self.re) + sqr(Self.im))
  end; { Modul }

Procedure CComplex.Conjugat(c1: CComplex);
  begin
    Self.Copy(c1);
    Self.im := -Self.im
  end; { Conjugat }

Procedure CComplex.Imparteste(c1, c2: CComplex);
{
  foloseste relatia:

  a + b*i   (a + b*i)(c - d*i)   (a + b*i)(c - d*i)
  ------- = ------------------ = ------------------
  c + d*i   (c + d*i)(c - d*i)        c*c + d*d
}
  var
    c3: CComplex;
    m: Real;
  begin
    c3.Conjugat(c2);
    Self.Inmulteste(c1, c3);
    m := sqr(c2.Modul);
    Self.re := Self.re / m;
    Self.im := Self.im / m
  end; { Imparteste }

Function CComplex.ParteReala: Real;
  begin
    ParteReala := Self.re
  end; { ParteReala }

Function CComplex.ParteImaginara: Real;
  begin
    ParteImaginara := Self.re
  end; { ParteImaginara }

begin { cod de initializare vid }
end. { UComplex }