Program Test;
  Uses Crt, UDataC;

Type
  Str8 = String[8];

Procedure Extrage(s: Str8; var d: DataC; var corect: Boolean);
{ extrage dintr-un string d de forma zzllaaaa
  valorile pentru zi, luna si an si pune corect pe TRUE
  daca conversiile nu se pot face corect, seteaza corect pe FALSE
}
  var
    c: Integer;
  begin
    corect := True;
    Val(Copy(s, 1, 2), d.zi, c);
    If c <> 0 then begin
      corect := False;
      Exit
    end;
    Val(Copy(s, 3, 2), d.luna, c);
    If c <> 0 then begin
      corect := False;
      Exit
    end;
    Val(Copy(s, 5, 4), d.an, c);
    If c <> 0 then corect := False;
    d.ziua := ZiDinSaptamana(d)
  end; { Extrage }

Function DataCorecta(var s: Str8): Boolean;
{ verifica daca data calendaristica introdusa a fost corecta }
  var
    d: DataC;
    corect: Boolean;
  begin
    Extrage(s, d, corect);
    If not corect then begin
      DataCorecta := False;
      Exit
    End;
    If (d.luna < 1) or (d.luna > 12) then begin
      DataCorecta := False;
      Exit
    End;
    If not ZiCorecta(d) then begin
      DataCorecta := False;
      Exit
    End;
    If (d.an < PrimulAn) or (d.an > UltimulAn) then begin
      DataCorecta := False;
      Exit
    End;
    d.Ziua := ZiDinSaptamana(d);
    If not ZiLucratoare(d) then begin
      DataCorecta := False;
      Exit
    End;
    DataCorecta := True
  End; { DataCorecta }

  var
    d1, d2, d3: DataC;
    corect: Boolean;
    i: longInt;
  begin
    ClrScr;
    Extrage('02121978', d1, corect);
    WriteLn(DataCToStr10(d1), '=', DataCToStr(d1));
    Extrage('27091953', d2, corect);
    WriteLn(DataCToStr(d2));
    i := 10000;
    Aduna(d1, i, d3);
    WriteLn(DataCToStr(d1), ' adunat cu ', i:5, ' da ', DataCToStr(d3));
    ReadLn
  end.