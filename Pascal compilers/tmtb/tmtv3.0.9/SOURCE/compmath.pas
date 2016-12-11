(****************************************************************)
(*                                                              *)
(*       TMT Pascal 3.90 Runtime Library                        *)
(*       Complex Mathematics Unit                               *)
(*       Targets: OS/2, MS-DOS, Win32                           *)
(*                                                              *)
(*       Copyright (c) 1995, 2002 TMT Development Corporation   *)
(*       Authors: Anton Moscal, Vadim Bodrov, David Ebin        *)
(*                                                              *)
(****************************************************************)

{$i-,r-,a+,p+,t-,x+,b-,cc+,q-,v+,s-}

unit CompMath;

interface

type
  CReal = Extended;

type Complex = record
  re, im: CReal
end;
TComplex = Complex;

function Compl_RR(const re, im: CReal): Complex;
overload Complex = Compl_RR;
function Compl_R(const re: CReal): Complex;
overload Complex = Compl_R;

function add_cc(const a: Complex; const b: Complex): Complex;
overload + = add_cc;
function add_cr(const a: Complex; const b: CReal): Complex;
overload + = add_cr;
function add_rc(const a: CReal; const b: Complex): Complex;
overload + = add_rc;
function sub_cc(const a: Complex; const b: Complex): Complex;
overload - = sub_cc;
function sub_cr(const a: Complex; const b: CReal): Complex;
overload - = sub_cr;
function sub_rc(const a: CReal; const b: Complex): Complex;
overload - = sub_rc;
function mul_cc(const a: Complex; const b: Complex): Complex;
overload * = mul_cc;
function mul_cr(const a: Complex; const b: CReal): Complex;
overload * = mul_cr;
function mul_rc(const a: CReal; const b: Complex): Complex;
overload * = mul_rc;
function div_cc(const a: Complex; const b: Complex): Complex;
overload / = div_cc;
function div_cr(const a: Complex; const b: CReal): Complex;
overload / = div_cr;
function div_rc(const a: CReal; const b: Complex): Complex;
overload / = div_rc;

procedure addab_cc(var a: Complex; const b: Complex);
overload +:= = addab_cc;
procedure addab_cr(var a: Complex; const b: CReal);
overload +:= = addab_cr;
procedure subab_cc(var a: Complex; const b: Complex);
overload -:= = subab_cc;
procedure subab_cr(var a: Complex; const b: CReal);
overload -:= = subab_cr;
procedure mulab_cc(var a: Complex; const b: Complex);
overload *:= = mulab_cc;
procedure mulab_cr(var a: Complex; const b: CReal);
overload *:= = mulab_cr;
procedure divab_cc(var a: Complex; const b: Complex);
overload /:= = divab_cc;
procedure divab_cr(var a: Complex; const b: CReal);
overload /:= = divab_cr;

function eq_cc(const a: Complex; const b: Complex): Boolean;
overload = = eq_cc;
function eq_cr(const a: Complex; const b: CReal): Boolean;
overload = = eq_cr;
function eq_rc(const a: CReal; const b: Complex): Boolean;
overload = = eq_rc;
function ne_cc(const a: Complex; const b: Complex): Boolean;
overload <> = ne_cc;
function ne_cr(const a: Complex; const b: CReal): Boolean;
overload <> = ne_cr;
function ne_rc(const a: CReal; const b: Complex): Boolean;
overload <> = ne_rc;

function Conj(const z: Complex): Complex;
function Arg(const a: Complex): CReal;
function Polar(const rho: CReal; const theta: CReal): Complex;

function abs_cc(const a: Complex): CReal;
overload Abs = abs_cc;
function sqr_cc(const a: Complex): Complex;
overload Sqr = sqr_cc;
function sqrt_cc(const a: Complex): Complex;
overload Sqrt = sqrt_cc;
function ln_cc(const a: Complex): Complex;
overload Ln = ln_cc;
function exp_cc(const a: Complex): Complex;
overload Exp = exp_cc;

function power_cc(const a: Complex; const b: Complex): Complex;
overload Power = power_cc;
function power_cr(const a: Complex; const b: CReal): Complex;
overload Power = power_cr;
function power_rc(const a: CREal; const b: Complex): Complex;
overload Power = power_rc;

function sin_cc(const a: Complex): Complex;
overload Sin = sin_cc;
function sinh_cc(const a: Complex): Complex;
overload SinH = sinh_cc;
function cos_cc(const a: Complex): Complex;
overload Cos = cos_cc;
function cosh_cc(const a: Complex): Complex;
overload CosH = cosh_cc;
function tan_cc(const a: Complex): Complex;
overload Tan = tan_cc;
function tanh_cc(const a: Complex): Complex;
overload TanH = tanh_cc;
function cotan_cc(const a: Complex): Complex;
overload Cotan = cotan_cc;
function cotanh_cc(const a: Complex): Complex;
overload CotanH = cotanh_cc;
function arcsin_cc(const a: Complex): Complex;
overload ArcSin = arcsin_cc;
function arcsinh_cc(const a: Complex): Complex;
overload ArcSinH = arcsinh_cc;
function arccos_cc(const a: Complex): Complex;
overload ArcCos = arccos_cc;
function arccosh_cc(const a: Complex): Complex;
overload ArcCosH = arccosh_cc;
function arctan_cc(const a: Complex): Complex;
overload ArcTan = arctan_cc;
function arctanh_cc(const a: Complex): Complex;
overload ArcTanH = arctanh_cc;

procedure __writer(var f: Text; const value: Complex; w: Integer);
procedure __reader(var f: text; var result: Complex);

implementation

uses Math, ErrCodes, Strings;

function Compl_RR;
begin
  Result.re := re;
  Result.im := im
end;

function Compl_R;
begin
  Result.re := re;
  Result.im := 0
end;

function add_cc;
with Result do
begin
  re := b.re + a.re;
  im := a.im + b.im
end;

function add_cr;
with Result do
begin
  re := b + a.re;
  im := a.im;
end;

function add_rc;
with Result do
begin
  re := a + b.re;
  im := b.im;
end;

function sub_cc;
with Result do
begin
  re := a.re - b.re;
  im := a.im - b.im
end;

function sub_cr;
with Result do
begin
  re := a.re - b;
  im := a.im;
end;

function sub_rc;
with Result do
begin
  re := a - b.re;
  im :=   - b.im;
end;

function mul_cc;
with Result do
begin
  re := a.re * b.re - a.im * b.im;
  im := a.re * b.im + a.im * b.re
end;

function mul_cr;
with Result do
begin
  re := b * a.re;
  im := b * a.im;
end;

function mul_rc;
with Result do
begin
  re := a * b.re;
  im := a * b.im;
end;

function div_cc;
var
  x: CReal;
begin
  x := sqr(b.re) + sqr(b.im);
  with Result do begin
    re := (a.re * b.re + a.im * b.im) / x;
    im := (a.im * b.re - a.re * b.im) / x;
  end;
end;

function div_cr;
with Result do
begin
  re := b / a.re;
  im := b / a.im;
end;

function div_rc;
with Result do
begin
  re := a / b.re;
  im := a / b.im;
end;

procedure addab_cc;
with a do begin
  re +:= b.re;
  im +:= b.im
end;

procedure addab_cr;
begin
  a.re +:= b;
end;

procedure subab_cc;
with a do begin
  re -:= b.re;
  im -:= b.im
end;

procedure subab_cr;
begin
  a.re -:= b;
end;

procedure mulab_cc;
var
  c: Complex;
with c do
begin
  re := a.re * b.re - a.im * b.im;
  im := a.re * b.im + a.im * b.re;
  a := c
end;

procedure mulab_cr;
with a do
begin
  re *:= b;
  im *:= b;
end;

procedure divab_cc;
var
  c: Complex;
  x: CReal;
begin
  x := sqr(b.re) + sqr(b.im);
  with c do
  begin
    re := (a.re * b.re + a.im * b.im) / x;
    im := (a.im * b.re - a.re * b.im) / x;
  end;
  a := c
end;

procedure divab_cr;
with a do
begin
  re /:= b;
  im /:= b;
end;

function eq_cc;
begin
  Result := (a.re  = b.re) and (a.im =  b.im);
end;

function eq_cr;
begin
  Result := (a.re = b) and (a.im = 0);
end;

function eq_rc;
begin
  Result := (a = b.re) and (b.im = 0);
end;

function ne_cc;
begin
  Result := (a.re <> b.re) or (a.im <> b.im);
end;

function ne_cr;
begin
  Result := (a.re <> b) OR (a.im <> 0);
end;

function ne_rc;
begin
  Result := (a <> b.re) or (b.im <> 0);
end;

function Conj;
with Result do
begin
  re := z.re;
  im :=-z.im
end;

function Arg(const a: Complex): CReal;
begin
  Result := ArcTan2(a.im, a.re);
end;

function Polar(const rho: CReal; const theta: CReal): Complex;
begin
  Result := Complex(rho * cos(theta), rho * sin(theta));
end;

function abs_cc(const a: Complex): CReal;
begin
  Result := Hypot(a.re, a.im);
end;

function sqr_cc;
with Result do
begin
  re := sqr(a.re) - sqr(a.im);
  im := 2 * a.re * a.im;
end;

function sqrt_cc;
var
  r: CReal := abs_cc(a);
begin
  if r = 0.0 then
  begin
    Result.re := r;
    Result.im := r;
  end else
  if a.re > 0 then
  begin
    Result.re := Sqrt(0.5 * (r + a.re));
    Result.im := a.im / Result.re / 2;
  end else
  begin
    Result.im := Sqrt(0.5 * (r - a.re));
    if a.im < 0 then
      Result.im := - Result.im;
    Result.re := a.im / Result.im / 2;
  end;
end;

function ln_cc;
with Result do
begin
  im := ArcTan2(a.im, a.re);
  re := Ln(Hypot(a.re, a.im));
end;

function exp_cc;
begin
  Result := Polar((Exp(a.re)), a.im);
end;

function power_cc;
var
  lnr: CReal := Ln(Abs(a));
  t: CReal := ArcTan2(a.im, a.re);
begin
  Result := Polar(Exp(lnr * b.re - b.im * t), b.im * lnr + b.re * t);
end;

function power_cr;
begin
  Result := Exp(b * Ln(a));
end;

function power_rc;
begin
  Result := Exp(b * Ln(a));
end;

function sin_cc;
begin
  Result := Complex(Sin(a.re) * CosH(a.im), Cos(a.re) * SinH(a.im));
end;

function sinh_cc;
begin
  Result := Complex(SinH(a.re) * Cos(a.im), CosH(a.re) * Sin(a.im));
end;

function cos_cc;
begin
  Result := Complex(Cos(a.re) * CosH(a.im), - Sin(a.re) * SinH(a.im));
end;

function cosh_cc;
begin
  Result := Complex(CosH(a.re) * Cos(a.im), SinH(a.re) * Sin(a.im));
end;

function tan_cc;
begin
  Result := Sin(a) / Cos(a);
end;

function tanh_cc;
begin
  Result := SinH(a) / CosH(a);
end;

function cotan_cc;
begin
  Result := Cos(a) / Sin(a);
end;

function cotanh_cc;
begin
  Result := CosH(a) / SinH(a);
end;

function alphabeta(a: Complex): Complex;
begin
  Result.re := Sqrt(Sqr(a.re + 1) + Sqr(a.im)) / 2 + Sqrt(Sqr(a.re - 1) + Sqr(a.im)) / 2;
  Result.im := Sqrt(Sqr(a.re + 1) + Sqr(a.im)) / 2 - Sqrt(Sqr(a.re - 1) + Sqr(a.im)) / 2;
end;

function arccos_cc;
var
  ab: Complex := alphabeta(a);
begin
  Result := Complex(ArcCos(ab.im), -Ln(ab.re + Sqrt(Sqr(ab.re) - 1)));
end;

function arccosh_cc;
begin
  Result := Ln(a + Sqrt(Sqr(a) - 1));
end;

function arcsin_cc;
var
  ab: Complex := alphabeta(a);
begin
  Result := Complex(ArcSin(ab.im), Ln(ab.re + Sqrt(Sqr(ab.re) - 1)));
end;

function arcsinh_cc;
begin
  Result := Ln(a + Sqrt(Sqr(a) + 1));
end;

function arctan_cc;
begin
  Result := Complex(ArcTan(2 * a.re / (1 - Sqr(a.re) - Sqr(a.im))) / 2, Ln((Sqr(a.re) + Sqr(a.im + 1)) / (Sqr(a.re) + Sqr(a.im - 1))) / 4);
end;

function arctanh_cc;
begin
  Result := Ln((a + 1) / (1 - a));
end;

procedure __writer(var f: Text; const value: Complex; w: Integer);
begin
  Write(f, '(', FloatToStr(value.re), ',', FloatToStr(value.im), ')');
end;

procedure __reader(var f: text; var result: Complex);
var
  l, i: Integer;
  im, re: String := '';
  s: String;
  flg: Boolean := FALSE;
begin
  Read(f, s);
  s := LowerCase(Trim(s));
  l := Length(s);
  if (l > 2) and (s[1] = '(') then
  begin
    for i := 2 to l do
    begin
      if not flg and (s[i] = ',') then
        flg := TRUE
      else
      if s[i] in ['+', '-', '.', '0'..'9', 'e'] then
      begin
        if flg then
          im := im + s[i]
        else
          re := re + s[i]
      end else
      if s[i] <> ' ' then
        Break;
    end;
  end;
  Val(re, Result.re, i);
  if i <> 0 then RunError(invalid_numeric_format);
  Val(im, Result.im, i);
end;

end.