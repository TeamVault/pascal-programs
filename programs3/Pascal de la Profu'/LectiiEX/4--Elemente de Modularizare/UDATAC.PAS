Unit UDataC;
Interface
Const
  PrimulAn = 1572;
  UltimulAn = 9999;
Type
  Zile = (Duminica, Luni, Marti, Miercuri, Joi, Vineri, Sambata);
  DataC = record
    zi, luna, an: Integer;
    ziua: Zile;
  end;

Function DenZi(z: Zile): String;
Function DenLuna(l: Integer): String;
Function Compara(d1, d2: DataC): ShortInt;
Function Bisect(an: Integer): Boolean;
Function ZileInLuna(luna, an: Integer): Integer;
Function ZiCorecta(d: DataC): Boolean;
Function NumarZileInAn(an: Integer): Integer;
Function ZiuaDinAn(d: DataC): Integer;
Function ZiDinSaptamana(d: DataC): Zile;
Function NumarZile(d1, d2: DataC): LongInt;
Procedure Aduna(dataI: DataC; Interval: LongInt; var dataS: dataC);
Function ZiLucratoare(d: DataC): Boolean;
Function DataCToStr8(d: dataC): String;
Function DataCToStr10(d: dataC): String;
Function DataCToStr(d: dataC): String;
Function IntToStr(i,l: Integer): String;
Function LongToStr(i: LongInt; l: Integer): String;
Procedure AdunaZi(var d: DataC);
Procedure ScadeZi(var d: DataC);

Implementation

Function IntToStr0(i,l: Integer): String;
  var
    s: String;
    j: Integer;
  begin
    str(i, s);
    while length(s) < l do s := '0' + s;
    IntToStr0 := s
  end; { IntToStr0 }

Function IntToStr(i,l: Integer): String;
  var
    s: String;
    j: Integer;
  begin
    str(i:l, s);
    IntToStr := s
  end; { IntToStr }

Function LongToStr(i: LongInt; l: Integer): String;
  var
    s: String;
    j: Integer;
  begin
    str(i:l, s);
    LongToStr := s
  end; { LongToStr }

Function DataCToStr8(d: dataC): String;
  begin
    DataCToStr8 := IntToStr0(d.zi, 2) + IntToStr0(d.luna, 2) +
                   IntToStr0(d.an, 4)
  end; { DataCToStr8 }

Function DataCToStr10(d: dataC): String;
  begin
    DataCToStr10 := IntToStr0(d.zi, 2) + '/' + IntToStr0(d.luna, 2) + '/' +
                    IntToStr0(d.an, 4)
  end; { DataCToStr10 }

Function DataCToStr(d: dataC): String;
  begin
    DataCToStr := DenZi(d.ziua) + ', ' + IntToStr0(d.zi, 2) + ' ' +
                  DenLuna(d.luna) + ' ' + IntToStr0(d.an, 4)
  end; { DataCToStr }

Function DenZi(z: Zile): String;
  var
    s: String;
  begin
    case z of
      Duminica: s := 'duminica';
      Luni:     s := 'luni';
      Marti:    s := 'marti';
      Miercuri: s := 'miercuri';
      Joi:      s := 'joi';
      Vineri:   s := 'vineri';
      Sambata:  s := 'sambata';
    end;
    DenZi := s;
  end; { ZiDinSaptamana }

Function DenLuna(l: Integer): String;
{ intoarce denumirea lunii cu numarul l }
  var
    s: String;
  begin
    case l of
       1: s := 'ianuarie';
       2: s := 'februarie';
       3: s := 'martie';
       4: s := 'aprilie';
       5: s := 'mai';
       6: s := 'iunie';
       7: s := 'iulie';
       8: s := 'august';
       9: s := 'septembrie';
      10: s := 'octombrie';
      11: s := 'noiembrie';
      12: s := 'decembrie';
    end;
    DenLuna := s
  end; { DenLuna }

Function Compara(d1, d2: DataC): ShortInt;
{
  compara datele calendaristice d1 si d2
  intoarce
    -1 daca d1 < d2
     0 daca d1 = d2
    +1 daca d1 > d2
}
  var
    c: ShortInt;
  begin
    if d1.an < d2.an
      then c := -1
    else if d1.an > d2.an
      then c := 1
    else if d1.luna < d2.luna  { d1.an = d2.an }
      then c := -1
    else if d1.luna > d2.luna
      then c := 1
    else if d1.zi < d2.zi  { d1.an = d2.an si d1.luna = d2.luna }
      then c := -1
    else if d1.zi > d2.zi
      then c := 1
    else c := 0;           { d1 = d2 }
    Compara := c
  end; { Compara }

Function Bisect(an: Integer): Boolean;
{  Un an 'an' este considerat bisect daca:
    'an' este divizibil cu 400 sau
    'an' este divizibil cu 4 si nu este divizibil cu 100
}
  begin
    if an mod 400 = 0
      then Bisect := True
      else
        if (an mod 4 = 0) and (an mod 100 <> 0)
          then Bisect := True
          else Bisect := False
  end; { Bisect }

Function ZileInLuna(luna, an: Integer): Integer;
{ intoarce numarul de zile din luna
  tine cont de anii bisecti
}
  begin
    case luna of
      1, 3, 5, 7, 8, 10, 12: ZileInLuna := 31;
      4, 6, 9, 11:           ZileInLuna := 30;
      2:                     If Bisect(an)
                               then ZileInLuna := 29
                               else ZileInLuna := 28;
    end;
  end; { ZileDinLuna }

Function ZiCorecta(d: DataC): Boolean;
{ intoarce TRUE daca ziua din luna este corecta
  adica cuprinsa intre 1 si ZileInLuna(luna, an)
}
  begin
    If (d.zi >= 1) and (d.zi <= ZileInLuna(d.luna, d.an))
      then ZiCorecta := True
      else ZiCorecta := False;
  end; { ZiCorecta }

Function NumarZileInAn(an: Integer): Integer;
{ calculeaza numarul de zile in anul an }
  begin
    if Bisect(an)
      then NumarZileInAn := 366 {an bisect}
      else NumarZileInAn := 365
  end; { NumarZileInAn }

Function ZiuaDinAn(d: DataC): Integer;
{ calculeaza numarul de zile de la 1 ianuarie an si pana la ziua din
  luna specificata, in anul curent an
}
  var
    numar: Integer;
    l: Integer;     { indice de luna }
  begin
    numar := 0;
    for l := 1 to d.luna-1 do    {numarul de zile pana la 1 a lunii luna}
      numar := numar + ZileInLuna(l, d.an);
    ZiuaDinAn := numar + d.zi    {aduna zilele din luna curenta}
  end; { ZiuaDinAn }

Function NumarZile(d1, d2: DataC): LongInt;
{ Calculeaza numarul de zile dintre doua date calendaristice, d1 si d2
 (presupunem ca d2 > d1) astfel:

  d1 este definita de (zi1, luna1, an1)
  d2 este definita de (zi2, luna2, an2)

  a) se calculeaza n1 = numarul de zile de la d1 si pana la
     31 decembrie an1
      n1 = NumarZileInAn(an1) - ZiuaDinAn(zi1, luna1, an1) + 1;
             daca an1 < an2
      n1 = 0 daca an1 = an2
  b) se calculeaza n2 = numarul de zile din anii completi:
       an1 + 1, an1 + 2, ..., an2 - 1
     care este 365 (pentru anii normali) si 366 (pentru anii bisecti)
  c) se calculeaza n3 = numarul de zile de la 1 ianuarie an2 si
     pana la d2
     n3 := ZiuaDinAn(zi2, luna2, an2)
             daca an1 < an2
     n3 := ZiuaDinAn(zi2, luna2, an2) - ZiuaDinAn(zi1, luna1, an1) + 1
  d) se intoarce nz = n1 + n2 + n3 - 1 (nz va fi numarul de zile)
}
  var
    n1: Integer;
    n2: LongInt;
    n3: Integer;
    an: Integer;                   { pentru an }
  Begin
    case Compara(d1, d2) of
       0: begin                  { d1 = d2 }
            NumarZile := 0;
            Exit
          end;
      +1: begin                  { d1 > d2 }
            NumarZile := -NumarZile(d2, d1);
            Exit
          end;
    end;
    { secventa urmatoare este in cazul d2 > d1 }
    if d2.an = d1.an then begin
      n1 := 0;
      n3 := ZiuaDinAn(d2) - ZiuaDinAn(d1) + 1
    end else begin
      n1 := NumarZileInAn(d1.an) - ZiuaDinAn(d1) + 1;
      n3 := ZiuaDinAn(d2)
    end;
    n2 := 0;
    For an := d1.an + 1 to d2.an - 1 do
      n2 := n2 + NumarZileInAn(an);
    NumarZile := n1 + n2 + n3 - 1
  End; { NumarZile }

Function Maine(z: Zile): Zile;
  { intoarce ziua de maine parcurgand circular enumerarea Zile }
  begin
    if ord(z) < 6
      then Maine := Succ(z)
      else Maine := Duminica
  end; { Maine }

Function Ieri(z: Zile): Zile;
  { intoarce ziua de ieri parcurgand circular enumerarea Zile }
  begin
    if ord(z) > 0
      then Ieri := Pred(z)
      else Ieri := Sambata
  end; { Ieri }

Procedure AdunaZi(var d: DataC);
{
  aduna la d o zi
  modifica corespunzator campurile zi, luna, an si Ziua
}
  begin
    d.zi := d.zi + 1;
    if d.zi > ZileInLuna(d.luna, d.an) then begin
      d.zi := 1;
      d.luna := d.luna + 1;
      if d.luna > 12 then begin
        d.luna := 1;
        d.an := d.an + 1
      end
    end;
    d.Ziua := Maine(d.Ziua)
  end; { AdunaZi }

Procedure ScadeZi(var d: DataC);
{
  scade din d o zi
  modifica corespunzator campurile zi, luna, an si Ziua
}
  begin
    d.zi := d.zi -1;
    if d.zi < 1 then begin
      d.luna := d.luna -1;
      if d.luna < 1 then begin
        d.an := d.an - 1;
        d.luna := 12
      end;
      d.zi := ZileInLuna(d.luna, d.an)
    end;
    d.Ziua := Ieri(d.Ziua)
  end; { ScadeZi }

Procedure Aduna(dataI: DataC; Interval: LongInt; var dataS: dataC);
{
  aduna la dataI un numar de zile egal cu Interval si produce
  noua data dataS, cu toate campurile actualizate corect
}
  var
    i: LongInt;
    zia: Integer;
  begin
    dataS := dataI;
    if Interval = 0 then exit;
    if Interval > 0
      then for i := 1 to interval do AdunaZi(dataS)
      else for i := 1 to -interval do ScadeZi(dataS);
    dataS.ziua := ZiDinSaptamana(dataS)
  end; { Aduna }

Function ZiDinSaptamana(d: DataC): Zile;
{
  determina ziua din saptamana a datei d
  foloseste ca data de referinta ziua de
  3 ianuarie 1999 care e duminica
}
  const
    DataReferinta: DataC = (Zi: 3; Luna: 01; An: 1999; Ziua: Duminica);
  var
    dif: LongInt;
    z: Integer;
  begin
    dif := NumarZile(DataReferinta, d);
    z := dif mod 7;   { semnul lui z este semnul lui d }
    if z >= 0
      { se foloseste conversia explicita (cast) de la Integer la Zile }
      then ZiDinSaptamana := Zile(z)
      else ZiDinSaptamana := Zile(7 + z)
  end; { ZiDinSaptamana }

Function ZiLucratoare(d: DataC): Boolean;
{ intoarce TRUE daca ziua precizata prin zi, luna, an este
  zi lucratoare, adica luni, marti, miercuri, joi sau vineri
}
  begin
    if (d.Ziua = Sambata) or (d.Ziua = Duminica)
      then ZiLucratoare := False
      else ZiLucratoare := True
  end; { ZiLucratoare }

begin { cod de initializare vid }
end. { UDataC }
