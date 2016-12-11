Program LsCursor;
{ implementeaza o lista simplu inlantuita in care inserarea
  si stergerea de elemente se fac in raport cu nodul referit de cursor
}
Uses
  Crt;
type
  TInfo =  Integer; { tipul de date al informatiei utile din nod }
  PNod = ^TNod;
  TNod = Record
    Info: TInfo;    { camp ce contine informatia utila }
    Urm: PNod       { adresa nodului urmator }
  End;
  ListaCapCursor = Record
    Cap,            { capul listei: folosit la traversare }
    Cursor: PNod    { nodul curent listei: acolo se fac inserari si stergeri }
  End;

{ operatiile implementate sunt:
  GenereazaNod(N, I)  Aloca nodul N in memoria dinamica si pune
                      informatia utila I in el
  Creeaza(L)          Crearea unei liste L vide
  Insereaza(L, N)     Adaugarea nodului N dupa nodul referit de Cursor
  Sterge(L)           Stergerea nodului referit de Cursor
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

  Function GenereazaNod(I: TInfo): PNod;
  { genereaza un nod nou cu
     campul Info egal cu I
     campul Urm  egal cu Nil
    generarea inseamna aici alocare in memoria dinamica
  }
    var
      p: PNod;
    begin
      New(p);
      P^.Info := I;
      P^.Urm  := Nil;
      GenereazaNod := p
    end; { GenereazaNod }

  Procedure Creeaza(var L: ListaCapCursor);
  { creeaza o lista L vida }
    begin
      L.Cap := Nil;
      L.Cursor := L.Cap
    end; { Creeaza }

  Procedure Insereaza(var L: ListaCapCursor; N: PNod);
  { adauga nodul N^ dupa nodul referit de Cursor
    conventie
      - daca L.Cursor = Nil se face inserarea in capul listei
      - daca L.Cursor <> Nil se face inserarea dupa nodul referit de
        L.Cursor

a) Inainte de inserare:
     nodul cu informatia Ij este generat, insa nu este inca inserat in lista
     campul Urm al sau are valoarea Nil

                      Cursor
Cap   ÚÄÄÂÄ¿          ³    ÚÄÄÂÄ¿    ÚÄÄÂÄ¿               ÚÄÄÂÄ¿
ÄÄÄÄÄ>³I1³ ÅÄÄÄ> ... ÄÁÄÄÄ>³Ik³ ÅÄÄÄ>³Im³ ÅÄÄÄ> ... ÄÄÄÄÄ>³In³ ÅÄÄÄ> NIL
      ÀÄÄÁÄÙ               ÀÄÄÁÄÙ    ÀÄÄÁÄÙ               ÀÄÄÁÄÙ
          ³                                                   ³
          ³                                                   ³
         Urm              N     ÚÄÄÂÄ¿                       Urm
                          ÄÄÄÄÄ>³Ij³ ÅÄÄÄ> NIL
                                ÀÄÄÁÄÙ

b) Dupa inserare:
     nodul cu informatia Ij este inserat in lista
     (1) campul Urm al sau are valoarea Cursor^.Urm
     (2) campul Cursor^.Urm va referi nodul nou inserat
     (3) campul Cursor va referi nodul nou inserat

Cap   ÚÄÄÂÄ¿               ÚÄÄÂÄ¿     ÚÄÄÂÄ¿               ÚÄÄÂÄ¿
ÄÄÄÄÄ>³I1³ ÅÄÄÄ> ... ÄÄÄÄÄ>³Ik³ ³   Ú>³Im³ ÅÄÄÄ> ... ÄÄÄÄÄ>³In³ ÅÄÄÄ> NIL
      ÀÄÄÁÄÙ               ÀÄÄÁÅÙ   ³ ÀÄÄÁÄÙ               ÀÄÄÁÄÙ
          ³                   ÚÙ    ³                          ³
          ³                (2)³     ³(1)                       ³
         Urm           Cursor ³ ÚÄÄÂÅ¿                        Urm
                       (3)ÄÄÄÄÁ>³Ij³ ³
                                ÀÄÄÁÄÙ

  }
    begin
      If L.Cursor = Nil then begin    { inserare in capul listei }
        N^.Urm := L.Cap;              { (1) N^ se insereaza inainte de cap }
        L.Cap := N;                   { Nodul inserat devine capul listei }
        L.Cursor := N;                { (3) Cursorul refera nodul inserat }
        Exit
      end;
      N^.Urm := L.Cursor^.Urm; { (1) nodul urmator al lui N^ va fi nodul
                                     urmator cursorului }
      L.Cursor^.Urm := N;      { (2) N^ se insereaza dupa cursor }
      L.Cursor := N            { (3) Cursorul refera nodul inserat }
    end; { Insereaza }

  Procedure Sterge(var L: ListaCapCursor);
  { sterge din lista nodul referit de Cursor
    pre: Cursor <> Nil

a) Inainte de stergere

                    p       Cursor
Cap   ÚÄÄÂÄ¿        ³  ÚÄÄÂÄ¿ ³  ÚÄÄÂÄ¿   ÚÄÄÂÄ¿            ÚÄÄÂÄ¿
ÄÄÄÄÄ>³I1³ ÅÄÄ> ... ÁÄ>³Ij³ ÅÄÁÄ>³Ik³ ÅÄÄ>³Im³ ÅÄÄ> ... ÄÄÄ>³In³ ÅÄÄ> NIL
      ÀÄÄÁÄÙ           ÀÄÄÁÄÙ    ÀÄÄÁÄÙ   ÀÄÄÁÄÙ            ÀÄÄÁÄÙ
          ³                                                     ³
          ³                                                     ³
         Urm                                                   Urm

b) Dupa stergere
     nodul cu informatia Ik (referit de Cursor) este scos din lista
     (1) cauta nodul p anterior nodului referit de Cursor (Ij)
     (2) p^.Urm := Cursor^.Urm (elimina nodul referit de cursor)
     (3) Sterge Cursor^
     (4) Cursor := Cap

   Cursor
Cap ³ ÚÄÄÂÄ¿           ÚÄÄÂÄ¿    ÚÄÄÂÄ¿   ÚÄÄÂÄ¿            ÚÄÄÂÄ¿
ÄÄÄÄÁ>³I1³ ÅÄÄ> ... ÄÄ>³Ij³ ÅÄ¿  ³Ik³ ³ Ú>³Im³ ÅÄÄ> ... ÄÄÄ>³In³ ÅÄÄ> NIL
      ÀÄÄÁÄÙ           ÀÄÄÁÄÙ ³  ÀÄÄÁÄÙ ³ ÀÄÄÁÄÙ            ÀÄÄÁÄÙ
          ³                   ³         ³                       ³
          ³                   ÀÄÄÄÄÄÄÄÄÄÙ                       ³
         Urm                                                   Urm

  }
    var
      p: PNod;
    begin
      if L.Cursor = Nil then Exit;
      if L.Cap = L.Cursor then { se sterge elementul din capul listei }
        L.Cap := L.Cap^.Urm                        { (2) }
      else begin               { L.Cursor refera un nod dupa cap }
        p := L.Cap;            { p^ va fi nodul anterior lui Cursor^ }
        while p^.Urm <> L.Cursor do p :=p^.Urm;    { (1) }
        p^.Urm := L.Cursor^.Urm                    { (2) }
      end;
      Dispose(L.Cursor);                           { (3) }
      L.Cursor := L.Cap                            { (4) }
    end; { Sterge }

 Function Cauta(var L: ListaCapCursor; I: TInfo): Boolean;
  { cauta in lista L nodul cu informatia utila I
    daca gaseste un asemenea nod,
      atunci adresa lui va fi memorata in L.Cursor
             functia intoarce True
      altfel functia intoarce False fara a modifica cursorul
  }
    var
      p: PNod;
    begin
      p := L.Cap;
      while p <> Nil do
        if p^.Info = I then begin
          L.Cursor := p;              { nodul a fost gasit }
          Cauta := True;               { cautare cu succes }
          Exit
        end else p := p^.Urm;         { trece la nodul urmator }
      Cauta := False                  { cautare fara succes }
    end; { Cauta }

  Procedure Primul(var L: ListaCapCursor);
    { pozitioneaza L.Cursor pe L.Cap }
    begin
      L.Cursor := L.Cap;
    end; { Primul }

  Procedure Ultimul(var L: ListaCapCursor);
    { pozitioneaza L.Cursor^ pe nodul din coada lui L }
    begin
      L.Cursor := L.Cap;
      while L.Cursor^.Urm <> Nil do L.Cursor := L.Cursor^.Urm
    end; { Primul }

  Procedure Urmatorul(var L: ListaCapCursor; var Esec: Boolean);
    { daca L.Cursor^ are un nod urmator,
        atunci L.Cursor il va referi pe acesta
               Esec := False
        altfel Esec := True
    }
    begin
      Esec := False;
      If L.Cursor^.Urm <> Nil
        then L.Cursor := L.Cursor^.Urm
        else Esec := True;
    end; { Urmatorul }

  Procedure Precedentul(var L: ListaCapCursor; var Esec: Boolean);
    { daca L.Cursor^ are un nod precedent,
        atunci L.Cursor il va referi pe acesta
               Esec := False
        altfel Esec := True
    }
    var
      p: PNod;
    begin
      if L.Cursor = L.Cap then begin
        Esec := True;
        Exit
      end else begin
        p := L.Cap;            { p^ va fi nodul anterior lui Cursor^ }
        while p^.Urm <> L.Cursor do p :=p^.Urm;
      end;
      L.Cursor := p;
      Esec := False
    end; { Precedentul }

  Procedure Traverseaza(var L: ListaCapCursor);
  { traverseaza toate nodurile din lista L si afiseaza informatia
    utila din ele
  }
    var
      Esec: Boolean;
      p: PNod;
    begin
      if L.Cap = Nil then begin
        WriteLn('Lista este vida');
        Exit
      end;
      p := L.Cursor;                  { p pastreaza pozitia Cursorului }
      Primul(L);                      { seteaza Cursor la primul element
                                        din lista L }
      Esec := False;                  { lista are cel putin un nod }
      repeat
        write(L.Cursor^.Info:2, ','); { scrie informatia utila din nodul
                                        curent }
        Urmatorul(L, Esec)            { trece la nodul urmator }
      until Esec;
      L.Cursor := p;                  { reface pozitia cursorului dinainte
                                        de inceperea traversarii }
      writeLn
    end; { Travereseaza }

  Procedure Elibereaza(var L: ListaCapCursor);
  { sterge din lista toate nodurile }
    begin
      Primul(L);
      While L.Cap <> Nil do Sterge(L);
    end; { Elibereaza }

  var
    Lista: ListaCapCursor;
    i: Integer;
    N: PNod;
    Info: TInfo;
    Gasit: Boolean;

  begin
    ClrScr;
    WriteLn('LsCursor - implementarea listei simplu inlantuite cu cursor');
    WriteLn('Elementele listei se listeaza de la cap spre coada');
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    Creeaza(Lista);
    For I := 1 to 10 do begin
      N := GenereazaNod(I);
      Insereaza(Lista, N);
      Write('Lista dupa inserarea nodului cu Info = ', I:2, ' este: ');
      Traverseaza(Lista);
    end;
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    Gasit := Cauta(Lista, 7);
    If Gasit
      then WriteLn('Exista un nod cu informatia utila 7, ',
                   'iar nodul urmator are informatia utila ',
                   Lista.Cursor^.Urm^.Info)
      else WriteLn('Nu exista un nod cu informatia utila 7');
    For I := 1 to 5 do begin
      Info := Lista.Cursor^.Info;
      Sterge(Lista);
      Write('S-a sters nodul (', Info:2, ') de pe pozitia cursorului : ');
      Traverseaza(Lista)
    end;
    Gasit := Cauta(Lista, 7);
    If Gasit
      then WriteLn('Exista un nod cu informatia utila 7, ',
                   'iar nodul urmator are informatia utila ',
                   Lista.Cursor^.Urm^.Info)
      else WriteLn('Nu exista un nod cu informatia utila 7');
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    Elibereaza(Lista);
    Write('Lista dupa operatia Eliberare este: ');
    Traverseaza(Lista);
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    ReadLn
  end. { LsCursor }
