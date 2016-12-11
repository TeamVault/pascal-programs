Unit ULsCursA;
{ implementeaza o lista simplu inlantuita in care inserarea
  si stergerea de elemente se fac in raport cu nodul referit de cursor
  varianta statica - prin tablouri
}
Interface
Uses
  Crt;
Const
  MaxNoduri = 100;
  Zero = 0;
type
  TInfo =  Integer; { tipul de date al informatiei utile din nod }
  Lista = Record
    Cap,        { capul listei: folosit la traversare }
    Cursor:     { nodul curent listei: acolo se fac inserari si stergeri }
           0..MaxNoduri;
    Libere: Set of 1..MaxNoduri;  { multimea nodurilor libere }
    Info: Array[1..MaxNoduri] of TInfo;
    Urm:  Array[1..MaxNoduri] of 0..MaxNoduri;
  End;

{ operatiile implementate sunt:
  Creeaza(L)          Crearea unei liste L vide
  Vida(L)             Intoarce True daca lista L este vida
  Insereaza(L, N)     Adaugarea nodului N dupa nodul referit de Cursor
  Sterge(L)           Stergerea nodului referit de Cursor
  Modifica(L, I)      Modifica campul Info din nodul referit de cursor la I
  Extrage(L, I)       Extrage in I campul Info din nodul referit de cursor
  Cauta(L, I)         Cauta in lista L nodul cu informatia utila I
                      si pozitioneaza Cursor pe el (daca l-a gasit)
  Primul(L)           pozitioneaza Cursor pe primul nod din L
  Ultimul(L)          pozitioneaza Cursor pe ultimul nod din L
  Precedentul(L,Esec) pozitioneaza Cursor pe nodul anterior lui (daca
                      exista) sau pozitioneaza Esec pe True
  Urmatorul(L,Esec)   pozitioneaza Cursor pe nodul ulterior lui (daca
                      exista) sau pozitioneaza Esec pe True
  Traverseaza(L)      Traverseaza toate nodurile listei L si afiseaza
                      informatia utila din ele
  Elibereaza(L)       Dealoca toate elementele listei L, transformand-o
                      intr-o lista vida
}
  Procedure Creeaza(var L: Lista);
  { creeaza o lista L vida }
  Function Vida(var L: Lista): Boolean;
  { intoarce True daca L este vida }
  Procedure Insereaza(var L: Lista; I: TInfo);
  { adauga nodul cu informatia utila I dupa nodul referit de Cursor
    conventie
      - daca L.Cursor = Nil se face inserarea in capul listei
      - daca L.Cursor <> Nil se face inserarea dupa nodul referit de
        L.Cursor
  }
  Procedure Sterge(var L: Lista);
  { sterge din lista nodul referit de Cursor
    pre: Cursor <> Nil
  }
  Procedure Modifica(var L: Lista; I: TInfo);
  { seteaza campul Info din nodul referit de Cursor la I }
  Procedure Extrage(var L: Lista; var I: TInfo);
  { extrage campul Info din nodul referit de Cursor in I }
  Function Cauta(var L: Lista; I: TInfo): Boolean;
  { cauta in lista L nodul cu informatia utila I
    daca gaseste un asemenea nod,
      atunci adresa lui va fi memorata in L.Cursor
             functia intoarce True
      altfel functia intoarce False fara a modifica cursorul
  }
  Procedure Primul(var L: Lista);
    { pozitioneaza L.Cursor pe L.Cap }
  Procedure Ultimul(var L: Lista);
    { pozitioneaza L.Cursor^ pe nodul din coada lui L }
  Procedure Urmatorul(var L: Lista; var Esec: Boolean);
    { daca L.Cursor^ are un nod urmator,
        atunci L.Cursor il va referi pe acesta
               Esec := False
        altfel Esec := True
    }
  Procedure Precedentul(var L: Lista; var Esec: Boolean);
    { daca L.Cursor^ are un nod precedent,
        atunci L.Cursor il va referi pe acesta
               Esec := False
        altfel Esec := True
    }
  Procedure Traverseaza(var L: Lista);
  { traverseaza toate nodurile din lista L si afiseaza informatia
    utila din ele
  }
  Procedure Elibereaza(var L: Lista);
  { sterge din lista toate nodurile }
Implementation

  Procedure Creeaza(var L: Lista);
  { creeaza o lista L vida si pune toate nodurile in multimea Libere}
    var
      i: Integer;
    begin
      L.Cap := 0;
      L.Cursor := L.Cap;
      For i := 1 to MaxNoduri do
        L.Urm[i] := 0;
      L.Libere := [1..MaxNoduri]
    end; { Creeaza }

  Function Vida(var L: Lista): Boolean;
  { intoarce True daca L este vida }
    begin
      Vida := (L.Cap = 0)
    end; { Vida }

  Procedure GenereazaNod(var L: Lista; var N: Integer);
  { N va fi primul nod liber gasit in L.Libere
    daca nu se gaseste un astfel de nod, se da un mesaj de eroare
    si executia se termina
    daca se gaseste un astfel de nod, el este extras din L.Libere
    si N primeste valoarea lui }
    var
      i: Integer;
    begin
      For i := 1 to MaxNoduri do
        If i in L.Libere then begin
          N := i;
          L.Libere := L.Libere - [N];    { scoate pe N din L.Libere }
          Exit                           { termina executia }
        end;
      WriteLn('Nu mai sunt blocuri libere!');
      ReadLn;
      Halt
    end; { GenereazaNod }

  Procedure Insereaza(var L: Lista; I: TInfo);
  { adauga nodul cu informatia utila I dupa nodul referit de Cursor
    conventie
      - daca L.Cursor = 0 se face inserarea in capul listei
      - daca L.Cursor <> 0 se face inserarea dupa nodul referit de
        L.Cursor

a) Inainte de inserare:
     nodul cu informatia Ij este generat, insa nu este inca inserat in lista
     campul Urm al sau are valoarea nedefinita

                      Cursor
Cap   ÚÄÄÂÄ¿          ³    ÚÄÄÂÄ¿    ÚÄÄÂÄ¿               ÚÄÄÂÄ¿
ÄÄÄÄÄ>³I1³ ÅÄÄÄ> ... ÄÁÄÄÄ>³Ik³ ÅÄÄÄ>³Im³ ÅÄÄÄ> ... ÄÄÄÄÄ>³In³ ÅÄÄÄ> 0
      ÀÄÄÁÄÙ               ÀÄÄÁÄÙ    ÀÄÄÁÄÙ               ÀÄÄÁÄÙ
          ³                                                   ³
          ³                                                   ³
         Urm              N     ÚÄÄÂÄ¿                       Urm
                          ÄÄÄÄÄ>³Ij³ ÅÄÄÄ> 0
                                ÀÄÄÁÄÙ

b) Dupa inserare:
     nodul cu informatia Ij este inserat in lista
     (1) campul Urm[N] al sau primeste valoarea Urm[Cursor]
     (2) campul Urm[Cursor] va referi nodul nou inserat (N)
     (3) campul Cursor va referi nodul nou inserat

Cap   ÚÄÄÂÄ¿               ÚÄÄÂÄ¿     ÚÄÄÂÄ¿               ÚÄÄÂÄ¿
ÄÄÄÄÄ>³I1³ ÅÄÄÄ> ... ÄÄÄÄÄ>³Ik³ ³   Ú>³Im³ ÅÄÄÄ> ... ÄÄÄÄÄ>³In³ ÅÄÄÄ> 0
      ÀÄÄÁÄÙ               ÀÄÄÁÅÙ   ³ ÀÄÄÁÄÙ               ÀÄÄÁÄÙ
          ³                   ÚÙ    ³                          ³
          ³                (2)³     ³(1)                       ³
         Urm           Cursor ³ ÚÄÄÂÅ¿                        Urm
                       (3)ÄÄÄÄÁ>³Ij³ ³
                                ÀÄÄÁÄÙ

  }
    var
      N: Integer;
    begin
      GenereazaNod(L, N);           { N este indicele pe care se pune
                                      noul nod }
      L.Info[N] := I;               { pune I in L.Info[N] }
      If L.Cursor = 0 then begin    { inserare in capul listei }
        L.Urm[N] := L.Cap;          { (1) N se insereaza inainte de cap }
        L.Cap := N;                 { Nodul inserat devine capul listei }
        L.Cursor := N;              { (3) Cursorul refera nodul inserat }
        Exit
      end;
      L.Urm[N] := L.Urm[L.Cursor]; { (1) nodul urmator al lui N va fi
                                         nodul urmator cursorului }
      L.Urm[L.Cursor] := N;        { (2) N se insereaza dupa cursor }
      L.Cursor := N                { (3) Cursorul refera nodul inserat }
    end; { Insereaza }

  Procedure Sterge(var L: Lista);
  { sterge din lista nodul referit de Cursor
    pre: Cursor <> 0

a) Inainte de stergere

                    i       Cursor
Cap   ÚÄÄÂÄ¿        ³  ÚÄÄÂÄ¿ ³  ÚÄÄÂÄ¿   ÚÄÄÂÄ¿            ÚÄÄÂÄ¿
ÄÄÄÄÄ>³I1³ ÅÄÄ> ... ÁÄ>³Ij³ ÅÄÁÄ>³Ik³ ÅÄÄ>³Im³ ÅÄÄ> ... ÄÄÄ>³In³ ÅÄÄ> 0
      ÀÄÄÁÄÙ           ÀÄÄÁÄÙ    ÀÄÄÁÄÙ   ÀÄÄÁÄÙ            ÀÄÄÁÄÙ
          ³                                                     ³
          ³                                                     ³
         Urm                                                   Urm

b) Dupa stergere
     nodul cu informatia Ik (referit de Cursor) este scos din lista
     (1) cauta nodul i anterior nodului referit de Cursor (Ij)
     (2) Urm[i] := Urm[Cursor] (elimina nodul referit de cursor)
     (3) Sterge Cursor: Urm[Cursor] := 0 si pune Cursor in L.Libere
     (4) Cursor := Cap

   Cursor           i
Cap ³ ÚÄÄÂÄ¿        ³  ÚÄÄÂÄ¿    ÚÄÄÂÄ¿   ÚÄÄÂÄ¿            ÚÄÄÂÄ¿
ÄÄÄÄÁ>³I1³ ÅÄÄ> ... ÁÄ>³Ij³ ÅÄ¿  ³Ik³ ³ Ú>³Im³ ÅÄÄ> ... ÄÄÄ>³In³ ÅÄÄ> 0
      ÀÄÄÁÄÙ           ÀÄÄÁÄÙ ³  ÀÄÄÁÄÙ ³ ÀÄÄÁÄÙ            ÀÄÄÁÄÙ
          ³                   ³         ³                       ³
          ³                   ÀÄÄÄÄÄÄÄÄÄÙ                       ³
         Urm                                                   Urm

  }
    var
      i: Integer;
    begin
      if L.Cursor = 0 then Exit;
      if L.Cap = L.Cursor then { se sterge elementul din capul listei }
        L.Cap := L.Urm[L.Cap]                          { (2) }
      else begin               { L.Cursor refera un nod dupa cap }
        i := L.Cap;            { i va referi nodul anterior lui Cursor }
        while L.Urm[i] <> L.Cursor do i :=L.Urm[i];    { (1) }
        L.Urm[i] := L.Urm[L.Cursor]                    { (2) }
      end;
      L.Urm[L.Cursor] := 0;                            { (3) }
      L.Libere := L.Libere + [L.Cursor];   { pune L.Cursor in L.Libere }
      L.Cursor := L.Cap                                { (4) }
    end; { Sterge }

  Procedure Modifica(var L: Lista; I: TInfo);
  { seteaza campul Info din nodul referit de Cursor la I }
    begin
      L.Info[L.Cursor] := I
    end; { Modifica }

  Procedure Extrage(var L: Lista; var I: TInfo);
  { extrage campul Info din nodul referit de Cursor in I }
    begin
      I := L.Info[L.Cursor]
    end; { Extrage }

  Function Cauta(var L: Lista; I: TInfo): Boolean;
  { cauta in lista L nodul cu informatia utila I
    daca gaseste un asemenea nod,
      atunci adresa lui va fi memorata in L.Cursor
             functia intoarce True
      altfel functia intoarce False fara a modifica cursorul
  }
    var
      N: Integer;
    begin
      N := L.Cap;
      while N <> 0 do
        if L.Info[N] = I then begin
          L.Cursor := N;               { nodul a fost gasit }
          Cauta := True;               { cautare cu succes }
          Exit
        end else N := L.Urm[N];        { trece la nodul urmator }
      Cauta := False                   { cautare fara succes }
    end; { Cauta }

  Procedure Primul(var L: Lista);
    { pozitioneaza L.Cursor pe L.Cap }
    begin
      L.Cursor := L.Cap;
    end; { Primul }

  Procedure Ultimul(var L: Lista);
    { pozitioneaza L.Cursor^ pe nodul din coada lui L }
    begin
      L.Cursor := L.Cap;
      while L.Urm[L.Cursor] <> 0 do L.Cursor := L.Urm[L.Cursor]
    end; { Primul }

  Procedure Urmatorul(var L: Lista; var Esec: Boolean);
    { daca L.Cursor^ are un nod urmator,
        atunci L.Cursor il va referi pe acesta
               Esec := False
        altfel Esec := True
    }
    begin
      Esec := False;
      If L.Urm[L.Cursor] <> 0
        then L.Cursor := L.Urm[L.Cursor]
        else Esec := True;
    end; { Urmatorul }

  Procedure Precedentul(var L: Lista; var Esec: Boolean);
    { daca L.Cursor^ are un nod precedent,
        atunci L.Cursor il va referi pe acesta
               Esec := False
        altfel Esec := True
    }
    var
      N: Integer;
    begin
      if L.Cursor = L.Cap then begin
        Esec := True;
        Exit
      end;
      N := L.Cap;            { p^ va fi nodul anterior lui Cursor^ }
      while L.Urm[N] <> L.Cursor do N :=L.Urm[N];
      L.Cursor := N;
      Esec := False
    end; { Precedentul }

  Procedure Traverseaza(var L: Lista);
  { traverseaza toate nodurile din lista L si afiseaza informatia
    utila din ele
  }
    var
      Esec: Boolean;
      N: Integer;
    begin
      if L.Cap = 0 then begin
        WriteLn('Lista este vida');
        Exit
      end;
      N := L.Cursor;                  { p pastreaza pozitia Cursorului }
      Primul(L);                      { seteaza Cursor la primul element
                                        din lista L }
      Esec := False;                  { lista are cel putin un nod }
      repeat
        write(L.Info[L.Cursor]:2, ','); { scrie informatia utila din nodul
                                        curent }
        Urmatorul(L, Esec)            { trece la nodul urmator }
      until Esec;
      L.Cursor := N;                  { reface pozitia cursorului dinainte
                                        de inceperea traversarii }
      writeLn
    end; { Travereseaza }

  Procedure Elibereaza(var L: Lista);
  { sterge din lista toate nodurile }
    begin
      Primul(L);
      While L.Cap <> 0 do Sterge(L);
    end; { Elibereaza }

  begin  { cod de initializare vid }
  end.   { ULsCursA }
