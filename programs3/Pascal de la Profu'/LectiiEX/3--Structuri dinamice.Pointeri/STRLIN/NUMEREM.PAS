Program NumereMari;
  { implementeaza operatii pe numere mari folosind liste
    exemplu de folosire a operatiilor primitive pe liste pentru a crea
    operatii mai complexe:
      - Copiaza(L1, L2): copiaza lista L1 in L2
      - NumarElemente(L): numarul de elemente (noduri) al listei L
      - Compara(L1, L2): compararea lexicografica a listelor L1 si L2
      - StringToLista(S, L): creeaza o lista L care contine in fiecare nod
                             cate un caracter din S; inserarea se face in
                             coada listei si S este parcurs de la inceput
      - ListaToString(L): creeaza un string care contine informatia utila
                          din nodurile listei L (caracter/nod); lista este
                          parcursa de la coada la inceput (se poate parcurge
                          si invers)
      - Aduna(N1, N2, N3): aduna doua numere naturale reprezentate ca liste
                           si obtine rezultatul tot in forma de lista
                           N3 := N1 + N2
  }

Uses
 Crt, UFile, ULDCursD;
{ Crt, UFile, ULDCursA; }
{ Crt, UFile, ULsCursD; }
{ Crt, UFile, ULsCursA; }

  Procedure Copiaza(var L1, L2: Lista);
    { copiaza lista L1 in lista L2 }
    Var
      e: TInfo;
      esec: Boolean;
    begin
      Creeaza(L2);
      If Vida(L1) then Exit;   { daca L1 e vida, si L2 va fi vida }
      Primul(L1);
      esec := False;
      While not esec do begin
        Extrage(L1, e);
        Insereaza(L2, e);
        Urmatorul(L1, esec)
      end;
    end; { Copiaza }

  Function NumarElemente(var L: Lista): Integer;
    { intoarce numarul de elemente al listei L }
    var
      n: Integer;
      esec: Boolean;
    begin
      If Vida(L) then begin
        NumarElemente := 0;
        Exit
      end;
      n := 0;
      esec := False;
      Primul(L);
      while not esec do begin
        n := n + 1;
        Urmatorul(L, esec)
      end;
      NumarElemente := n
    end; { NumarElemente }

  Function Compara(var L1, L2: Lista): Integer;
    { compara listele L1 si L2 si intoarce:
        -1 daca NumarElemente(L1) < NumarElemente(L2) (in sens lexicografic)
           sau daca L1 < L2
         0 daca L1 = L2
         1 daca NumarElemente(L1) > NumarElemente(L2)
           sau daca L1 > L2
    }
    var
      n1, n2: Integer;
      e1, e2: TInfo;
      esec: Boolean;
    begin
      n1 := NumarElemente(L1);
      n2 := NumarElemente(L2);
      { daca L1 are mai putine elemente decat L2, rezulta L1 < L2 }
      If n1 < n2 then Compara := -1
      { daca L1 are mai multe elemente decat L2, rezulta L1 > L2 }
      else If n1 > n2 then Compara := 1
      { daca L1 si L2 sunt vide, atunci L1 = L2 }
      else If n1 = 0 then Compara := 0
      { listele au acelasi numar de elemente: se compara elementele
        de la primul spre ultimul
      }
      else begin
        Primul(L1);
        Primul(L2);
        esec := False;
        while not esec do begin     { s-a ajuns la ultimul element? }
          Extrage(L1, e1);
          Extrage(L2, e2);
          If e1 < e2 then begin
            { pe aceeasi pozitie, informatia utila din L1 este mai mica
              decat informatia utila din L2; ==> L1 < L2
            }
            Compara := -1;
            Exit
          end else If e1 > e2 then begin
            { pe aceeasi pozitie, informatia utila din L1 este mai mare
              decat informatia utila din L2; ==> L1 > L2
            }
            Compara := 1;
            Exit
          end else begin
            { cifrele sunt egale; se trece la urmatoarele cifre }
            Urmatorul(L1, esec);
            Urmatorul(L2, esec)
          end
        end;
        { listele sunt egale, element cu element, atat ca numar de elemente
          cat si ca pozitie: pe aceeasi pozitie, in fiecare lista,
          se gaseste aceeasi informatie
        }
        Compara := 0
      end
    end; { Compara }

  Procedure StringToLista(S: String; var N: Lista);
    { citeste un numar natural S primit ca string intr-o lista
      elementele sunt inserate normal - dupa cursor }
    var
      e: TInfo;
      i: Integer;
    const
      Cifre: Set of Char = ['0'..'9'];
    begin
      Creeaza(N);        { creeaza lista vida }
      { elimina blank-urile de la inceput }
      While (S[1] = ' ') and (Length(S) > 0) do Delete(S, 1, 1);
      for i := 1 to Length(S) do
        if S[i] in Cifre then begin
          e := Ord(S[i]) - 48;
          Insereaza(N, e)
        end
    end; { StringToLista }

  Function ListaToString(var N: Lista): String;
    { converteste elementele unei liste = cifre zecimale la string }
    var
      S: String;
      e: TInfo;
      esec: Boolean;
    begin
      if Vida(N) then S := '0'
      else begin
        Ultimul(N);               { parcurgere de la coada spre cap }
        esec := False;
        S := '';
        while not esec do begin
          Extrage(N, e);
          S := Chr(e + 48) + S;   { e se adauga in fata vechiului S }
          Precedentul(N, esec)    { precedentul nod }
        end
    { alternativ:
        Primul(N);                { parcurgere de la coada spre cap }{
        esec := False;
        S := '';
        while not esec do begin
          Extrage(N, e);
          S := S + Chr(e + 48);   { e se adauga la coada vechiului S }{
          Urmatorul(N, esec)      { urmatorul nod }{
        end
    }
      end;
      ListaToString := S
    end; { ListaToString }

  Procedure Aduna(var N1, N2, N3: Lista);
    { N3 = N1 + N2
      Metoda de lucru:
        (1) daca N1 = 0 atunci N3 := N2
        (2) daca N2 = 0 atunci N3 := N1
        (3) altfel
           3.1. Copiaza pe N1 in L1 si pe N2 in L2
           3.2. Aduce L1 si L2 la acelasi numar de elemente,
                inserandu-le in cap zerouri
           3.3. Creeaza lista N3 vida
                transport := 0;
           3.4. Traverseaza L1 si L2 de la coada spre cap (ele vor avea
                acelasi numar de elemente - vezi 2.) si
                pentru fiecare pereche de cifre e1 (extras din din L1) si e2 (din L2)
                  - efectueaza calculele
                      suma := e1 + e2 + transport;
                      e3 := suma mod 10;
                      transport := suma div 10;
                  - adauga pe e3 in capul listei N3
                  - repozitioneaza cursorul in L1 si L2 pe elementul
                    precedent
           3.5. Cand L1 si L2 sunt epuizate (s-a ajuns la primul element
                din fiecare si acesta a fost prelucrat)
                  - se insereaza in N3 si transportul (daca acesta este
                    nenul)
                  - se elibereaza (dealoca) spatiul ocupat de listele
                    auxiliare L1 si L2
                  - procedura se termina

    }
    var
      L1, L2: Lista;
      nr1, nr2: Integer;
      e1, e2, e3: TInfo;
      i, transport, suma: Integer;
      esec: Boolean;
    begin
      nr1 := NumarElemente(N1);
      nr2 := NumarElemente(N2);
      if nr1 = 0 then begin                      { 1 }
        Copiaza(N2, N3);
        Exit
      end else if nr2 = 0 then begin             { 2 }
        Copiaza(N1, N3);
        Exit
      end else begin                             { 3 }
        Copiaza(N1, L1);                         { 3.1. }
        Copiaza(N2, L2);
        { aduce pe L1 si L2 la acelasi numar de elemente
          punand in cap zerouri acolo unde trebuie
        }
        if nr1 > nr2                             { 3.2. }
          then for i := nr2+1 to nr1 do begin
            L2.Cursor := Zero;       { urmeaza inserare in cap }
            Insereaza(L2, 0)
          end
        else if nr2 > nr1
          then for i := nr1+1 to nr2 do begin
            L1.Cursor := Zero;       { urmeaza inserare in cap }
            Insereaza(L1, 0)
          end;
        { incepe adunarea de la ultimul spre primul element in
          fiecare lista
        }
        transport := 0;                          { 3.3. }
        Creeaza(N3);                             { initial vida }
        Ultimul(L1);                             { 3.4. }
        Ultimul(L2);
        esec := False;
        while not esec do begin           { incepe calculele }
          { extrage cifrele de pe pozitia cursorului din L1 si L2 }
          Extrage(L1, e1);
          Extrage(L2, e2);
          { aduna cifrele e1 si e2 }
          suma := e1 + e2 + transport;
          e3 := suma mod 10;
          transport := suma div 10;
          { insereaza cifra e3 in capul lui N3 }
          N3.Cursor := Zero;
          Insereaza(N3, e3);
          { trece la cifra precedenta in L1 si L2 }
          Precedentul(L1, esec);
          Precedentul(L2, esec)
        end;
        { insereaza transportul in capul lui N3 daca e nenul }
        if transport <> 0 then begin
          N3.Cursor := Zero;
          Insereaza(N3, transport);
        end;
        { dealoca spatiul ocupat de listele auxiliare L1 si L2 }
        Elibereaza(L1);
        Elibereaza(L2)
      end
    end; { Aduna }

  var
    A, B, C: Lista;

  begin
    ClrScr;
    WriteLn('NumereMari - Numere naturale mari implementate ca liste');
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    StringToLista('111111111111111111111111111111934512345678901234567890', A);
    StringToLista('999999999999111111111111111111111', B);
    Aduna(A, B, C);
    { #13#10 inseamna CR + LF - salt fortat la rand nou }
    WriteLn(ListaToString(A):70, ' + ', #13#10,
            ListaToString(B):70, ' = ', #13#10,
            ListaToString(C):70);
    Elibereaza(A);
    Elibereaza(B);
    Elibereaza(C);
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    ReadLn
  end. { NumereMari }