Program Tun_3;
  { program de test pentru unit-ul UNumar: Extrage si Inlocuieste }
  Uses
    UNumar;
  Function Cifra(N: TNumar; I: Integer): Cifre;
    { intoarce cifra corespunzand puterii i a bazei }
    begin
      Cifra := N.Cifra[Lung - I]
    end; { Cifra }

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

  var
    N1, N2, N3, N4: TNumar;
  begin
    FromString('123456789', N1);
    FromString('7865', N2);
    WriteLn('N1 = ', ToString(N1));
    WriteLn('N2 = ', ToString(N2));
    Extrage(N1, 7, 4, N3);
    WriteLn('Extrage(N1, 7, 4, N3) = ', ToString(N3));
    N4 := N1;
    Inlocuieste(N4, 7, 4, N2);
    WriteLn('Inlocuieste(N1, 7, 4, N2) = ', ToString(N4));
    Readln
  end.