Unit ULDCursD;
{ implementeaza o lista dublu inlantuita in care inserarea
  si stergerea de elemente se fac in raport cu nodul referit de cursor
  varianta dinamica
}
Interface
Uses
  Crt;
Const
  Zero = Nil;
type
  TInfo =  Integer; { tipul de date al informatiei utile din nod }
  PNod = ^TNod;
  TNod = Record
    Info: TInfo;    { camp ce contine informatia utila }
    Urm: PNod;      { adresa nodului urmator }
    Prec: PNod      { adresa nodului precedent }
  End;
  Lista = Record
    Cap,            { capul listei: folosit la traversare }
    Cursor: PNod    { nodul curent listei: acolo se fac inserari si stergeri }
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
  { creeaza o lista L vida }
    begin
      L.Cap := Nil;
      L.Cursor := L.Cap
    end; { Creeaza }

  Function Vida(var L: Lista): Boolean;
  { intoarce True daca L este vida }
    begin
      Vida := (L.Cap = Nil)
    end; { Vida }

  Function GenereazaNod(I: TInfo): PNod;
  { genereaza un nod nou cu
     campul Info egal cu I
     campurile Urm si Prec egale cu Nil
    generarea inseamna aici alocare in memoria dinamica
  }
    var
      p: PNod;
    begin
      New(p);
      P^.Info := I;
      P^.Urm  := Nil;
      P^.Prec := Nil;
      GenereazaNod := p
    end; { GenereazaNod }
  Procedure Insereaza(var L: Lista; I: TInfo);
  { adauga nodul cu informatia utila I dupa nodul referit de Cursor
    conventie
      - daca L.Cursor = Nil se face inserarea in capul listei
      - daca L.Cursor <> Nil se face inserarea dupa nodul referit de
        L.Cursor

a) Inainte de inserare:
     nodul cu informatia Ij este generat, si are adresa in N.
     El nu este inca inserat in lista, iar campurile Urm si Prec
     ale sale au valoarea Nil

         Urm⁄ƒƒø       ⁄ƒƒø      ¬Cursor ⁄ƒƒø       ⁄ƒƒø      ø       ⁄ƒƒø
Capƒƒ>⁄ƒ¬ƒƒ¬≈ø ¿>⁄ƒ¬ƒƒ¬≈ø ¿> ... ¿>⁄ƒ¬ƒƒ¬≈ø ¿>⁄ƒ¬ƒƒ¬≈ø ¿> ... ¿>⁄ƒ¬ƒƒ¬≈ø ¿>NIL
      ≥ ≥I1≥ ≥   ≥ ≥I2≥ ≥          ≥ ≥Im≥ ≥   ≥ ≥Il≥ ≥          ≥ ≥In≥ ≥
      ¿≈¡ƒƒ¡ƒŸ<ø ¿≈¡ƒƒ¡ƒŸ<ø     <ø ¿≈¡ƒƒ¡ƒŸ<ø ¿≈¡ƒƒ¡ƒŸ<ø     <ø ¿≈¡ƒƒ¡ƒŸ
NIL <ƒƒŸPrec   ¿ƒƒŸ       ¿ƒ ... ¿ƒƒŸ       ¿ƒƒŸ       ¿ƒ ... ¿ƒƒŸ

                                      øN      ⁄ƒƒø
                                      ¿>⁄ƒ¬ƒƒ¬≈ø ¿>NIL
                                        ≥ ≥Ij≥ ≥
                                  NIL<ø ¿≈¡ƒƒ¡ƒŸ
                                      ¿ƒƒŸ

b) Dupa inserare:
     nodul N^ cu informatia Ij este inserat in lista
     (1) L.Cursor^.Urm^.Prec := N
     (2) N^.Urm := L.Cursor^.Urm
     (3) L.Cursor^.Urm := N
     (4) N^.Prec := L.Cursor
     (5) L.Cursor := N

                           Cursor (4)
         Urm⁄ƒƒø       ⁄ƒƒø vechi¬ƒƒƒƒƒƒƒƒƒø (2)    ⁄ƒƒø      ø       ⁄ƒƒø
Capƒƒ>⁄ƒ¬ƒƒ¬≈ø ¿>⁄ƒ¬ƒƒ¬≈ø ¿> ... ¿>⁄ƒ¬ƒƒ¬ƒø≥⁄>⁄ƒ¬ƒƒ¬≈ø ¿> ... ¿>⁄ƒ¬ƒƒ¬≈ø ¿>NIL
      ≥ ≥I1≥ ≥   ≥ ≥I2≥ ≥          ≥ ≥Im≥ ≥≥≥ ≥ ≥Il≥ ≥          ≥ ≥In≥ ≥
      ¿≈¡ƒƒ¡ƒŸ<ø ¿≈¡ƒƒ¡ƒŸ<ø        ¿≈¡ƒƒ¡≈Ÿ≥≥ ¿≈¡ƒƒ¡ƒŸ<ø     <ø ¿≈¡ƒƒ¡ƒŸ
NIL <ƒƒŸPrec   ¿ƒƒŸ       ¿ƒ ... <ƒƒŸ ⁄ƒƒŸ ≥≥  ≥       ¿ƒ ... ¿ƒƒŸ
                                   (3)≥  ⁄ƒŸ≥  ¿ƒø
                                      ≥  ≥  ¿ƒø  ≥
                                   pƒƒ≈>⁄≈¬ƒƒ¬≈ø ≥
                                   (5)≥ ≥ ≥Ij≥ ≥ ≥(1)
                              CursorƒƒŸ ¿ƒ¡ƒƒ¡ƒŸ<Ÿ
                                 nou

  }
    var
      N: PNod;
    begin
      N := GenereazaNod(I);
      If L.Cursor = Nil then begin    { inserare in capul listei }
        If L.Cap <> Nil then          { (1) N^ este precedentul capului }
          L.Cap^.Prec := N;
        N^.Urm := L.Cap;              { (2) N^ se insereaza inainte de cap }
        L.Cap := N;                   { Nodul inserat devine capul listei }
        L.Cursor := N;                { (5) Cursorul refera nodul inserat }
        Exit
      end;
      If L.Cursor^.Urm <> Nil then
        L.Cursor^.Urm^.Prec := N;     { (1) nodul precedent al urmatorului
                                            nod dupa cursor devine N^ }
      N^.Urm := L.Cursor^.Urm;        { (2) nodul urmator al lui N^ va fi
                                            nodul urmator cursorului }
      L.Cursor^.Urm := N;             { (3) nodul urmator cursorului va
                                            fi N^ }
      N^.Prec := L.Cursor;            { (4) nodul precedent lui N^ va
                                            fi cursorul }
      L.Cursor := N                   { (5) Cursorul refera nodul inserat }
    end; { Insereaza }

  Procedure Sterge(var L: Lista);
  { sterge din lista nodul referit de Cursor
    pre: Cursor <> Nil

a) Inainte de stergere

         Urm⁄ƒƒø     ø       ⁄ƒƒ¬Cursor ⁄ƒƒø       ⁄ƒƒø      ø       ⁄ƒƒø
Capƒƒ>⁄ƒ¬ƒƒ¬≈ø ¿>... ¿>⁄ƒ¬ƒƒ¬≈ø ¿>⁄ƒ¬ƒƒ¬≈ø ¿>⁄ƒ¬ƒƒ¬≈ø ¿> ... ¿>⁄ƒ¬ƒƒ¬≈ø ¿>NIL
      ≥ ≥I1≥ ≥         ≥ ≥Ij≥ ≥   ≥ ≥Ik≥ ≥   ≥ ≥Im≥ ≥          ≥ ≥In≥ ≥
      ¿≈¡ƒƒ¡ƒŸ<ø     <ø¿≈¡ƒƒ¡ƒŸ<ø ¿≈¡ƒƒ¡ƒŸ<ø ¿≈¡ƒƒ¡ƒŸ<ø     <ø ¿≈¡ƒƒ¡ƒŸ
NIL <ƒƒŸPrec   ¿ƒ ... ¿ƒŸ       ¿ƒƒŸ       ¿ƒƒŸ       ¿ƒ ... ¿ƒƒŸ


b) Dupa stergere
     nodul cu informatia Ik (referit de Cursor) este scos din lista
     (1) p := L.Cursor
     (2) L.Cursor^.Prec^.Urm := L.Cursor^.Urm
     (3) L.Cursor^.Urm^.Prec := L.Cursor^.Prec
     (4) Sterge p^
     (5) L.Cursor := L.Cap

                                   (2)
Cursor   Urm⁄ƒƒø     ø       ⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒø       ⁄ƒƒø      ø       ⁄ƒƒø
Cap¡ƒ>⁄ƒ¬ƒƒ¬≈ø ¿>... ¿>⁄ƒ¬ƒƒ¬≈ø ⁄>⁄ƒ¬ƒƒ¬ƒø ¿>⁄ƒ¬ƒƒ¬≈ø ¿> ... ¿>⁄ƒ¬ƒƒ¬≈ø ¿>NIL
      ≥ ≥I1≥ ≥         ≥ ≥Ij≥ ≥ ¿p≥ ≥Ik≥ ≥   ≥ ≥Im≥ ≥          ≥ ≥In≥ ≥
      ¿≈¡ƒƒ¡ƒŸ<ø     <ø¿≈¡ƒƒ¡ƒŸ<ø ¿ƒ¡ƒƒ¡ƒŸ   ¿≈¡ƒƒ¡ƒŸ<ø     <ø ¿≈¡ƒƒ¡ƒŸ
NIL <ƒƒŸPrec   ¿ƒ ... ¿ƒŸ       ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒŸ       ¿ƒ ... ¿ƒƒŸ
                                   (3)

  }
    var
      p: PNod;
    begin
      if L.Cursor = Nil then Exit;
      p := L.Cursor;              { (1) }
      If L.Cursor^.Prec <> Nil then
        L.Cursor^.Prec^.Urm := L.Cursor^.Urm;      { (2) }
      If L.Cursor^.Urm <> Nil then
        L.Cursor^.Urm^.Prec := L.Cursor^.Prec;     { (3) }
      If p = L.Cap then                       { L.Cursor = L.Cap }
        L.Cap := L.Cap^.Urm;
      Dispose(p);                                  { (4) }
      L.Cursor := L.Cap                            { (5) }
    end; { Sterge }

  Procedure Modifica(var L: Lista; I: TInfo);
  { seteaza campul Info din nodul referit de Cursor la I }
    begin
      L.Cursor^.Info := I
    end; { Modifica }

  Procedure Extrage(var L: Lista; var I: TInfo);
  { extrage campul Info din nodul referit de Cursor in I }
    begin
      I := L.Cursor^.Info
    end; { Extrage }

  Function Cauta(var L: Lista; I: TInfo): Boolean;
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

  Procedure Primul(var L: Lista);
    { pozitioneaza L.Cursor pe L.Cap }
    begin
      L.Cursor := L.Cap;
    end; { Primul }

  Procedure Ultimul(var L: Lista);
    { pozitioneaza L.Cursor^ pe nodul din coada lui L }
    begin
      L.Cursor := L.Cap;
      while L.Cursor^.Urm <> Nil do L.Cursor := L.Cursor^.Urm
    end; { Primul }

  Procedure Urmatorul(var L: Lista; var Esec: Boolean);
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

  Procedure Precedentul(var L: Lista; var Esec: Boolean);
    { daca L.Cursor^ are un nod precedent,
        atunci L.Cursor il va referi pe acesta
               Esec := False
        altfel Esec := True
    }
    begin
      Esec := False;
      If L.Cursor^.Prec <> Nil
        then L.Cursor := L.Cursor^.Prec
        else Esec := True;
    end; { Precedentul }

  Procedure Traverseaza(var L: Lista);
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

  Procedure Elibereaza(var L: Lista);
  { sterge din lista toate nodurile }
    begin
      Primul(L);
      While L.Cap <> Nil do Sterge(L);
    end; { Elibereaza }

  begin  { cod de initializare vid }
  end.   { ULDCursD }
