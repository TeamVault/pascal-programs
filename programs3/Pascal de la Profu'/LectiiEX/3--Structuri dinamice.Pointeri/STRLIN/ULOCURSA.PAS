Unit ULOCursA;
{ implementeaza o lista ordonata - dublu inlantuita cu cursor
  varianta statica - prin tablouri
}
Interface
Uses
  Crt;
Const
  MaxNoduri = 100;
  Zero = 0;
type
  TCheie = Integer;
  TRest  = String;
  TInfo =  Record  { tipul de date al informatiei utile din nod }
    Cheie: TCheie;
    Rest:  TRest
  End;
  Lista = Record
    Cap,        { capul listei: folosit la traversare }
    Cursor:     { nodul curent listei: acolo se fac inserari si stergeri }
           0..MaxNoduri;
    Libere: Set of 1..MaxNoduri;  { multimea nodurilor libere }
    Info: Array[1..MaxNoduri] of TInfo;
    Urm:  Array[1..MaxNoduri] of 0..MaxNoduri;
    Prec: Array[1..MaxNoduri] of 0..MaxNoduri;
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
  Function InfoToString(I: TInfo): String;
    { converteste informatia dintr-un nod la string }
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
  Function Cauta(var L: Lista; I: TCheie): Boolean;
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
      L.Cap := Zero;
      L.Cursor := L.Cap;
      For i := 1 to MaxNoduri do begin
        L.Urm[i] := Zero;
        L.Prec[i] := Zero
      end;
      L.Libere := [1..MaxNoduri]
    end; { Creeaza }

  Function Vida(var L: Lista): Boolean;
  { intoarce True daca L este vida }
    begin
      Vida := (L.Cap = Zero)
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
          L.Prec[N] := Zero;
          L.Urm[N] := Zero;
          Exit                           { termina executia }
        end;
      WriteLn('Nu mai sunt blocuri libere!');
      ReadLn;
      Halt
    end; { GenereazaNod }

  Procedure Insereaza(var L: Lista; I: TInfo);
  { adauga nodul cu informatia utila I dupa nodul referit de Cursor
    conventie
      - daca L.Cursor = Zero se face inserarea in capul listei
      - daca L.Cursor <> Zero se face inserarea dupa nodul referit de
        L.Cursor

a) Inainte de inserare:
     nodul cu informatia Ij este generat, si are adresa in N.
     El nu este inca inserat in lista, iar campurile Urm si Prec
     ale sale au valoarea nedefinita

         Urm⁄ƒƒø       ⁄ƒƒø      øCursor ⁄ƒƒø       ⁄ƒƒø      ø       ⁄ƒƒø
Capƒƒ>⁄ƒ¬ƒƒ¬≈ø ¿>⁄ƒ¬ƒƒ¬≈ø ¿> ... ¿>⁄ƒ¬ƒƒ¬≈ø ¿>⁄ƒ¬ƒƒ¬≈ø ¿> ... ¿>⁄ƒ¬ƒƒ¬≈ø ¿>ZERO
      ≥ ≥I1≥ ≥   ≥ ≥I2≥ ≥          ≥ ≥Im≥ ≥   ≥ ≥Il≥ ≥          ≥ ≥In≥ ≥
      ¿≈¡ƒƒ¡ƒŸ<ø ¿≈¡ƒƒ¡ƒŸ<ø     <ø ¿≈¡ƒƒ¡ƒŸ<ø ¿≈¡ƒƒ¡ƒŸ<ø     <ø ¿≈¡ƒƒ¡ƒŸ
ZERO<ƒƒŸPrec   ¿ƒƒŸ       ¿ƒ ... ¿ƒƒŸ       ¿ƒƒŸ       ¿ƒ ... ¿ƒƒŸ

                                      øN      ⁄ƒƒø
                                      ¿>⁄ƒ¬ƒƒ¬≈ø ¿>ZERO
                                        ≥ ≥Ij≥ ≥
                                 ZERO<ø ¿≈¡ƒƒ¡ƒŸ
                                      ¿ƒƒŸ

b) Dupa inserare:
     se determina Cursor = nodul dupa care se va insera noul nod
     in lista
     nodul N cu informatia Ij este inserat in lista
     (1) Prec[Urm[Cursor]] := N
     (2) Urm[N] := Urm[Cursor]
     (3) Urm[Cursor] := N
     (4) Prec[N] := L.Cursor
     (5) L.Cursor := N

                           Cursor (4)
         Urm⁄ƒƒø       ⁄ƒƒø vechi¬ƒƒƒƒƒƒƒƒƒø (2)    ⁄ƒƒø      ø       ⁄ƒƒø
Capƒƒ>⁄ƒ¬ƒƒ¬≈ø ¿>⁄ƒ¬ƒƒ¬≈ø ¿> ... ¿>⁄ƒ¬ƒƒ¬ƒø≥⁄>⁄ƒ¬ƒƒ¬≈ø ¿> ... ¿>⁄ƒ¬ƒƒ¬≈ø ¿>ZERO
      ≥ ≥I1≥ ≥   ≥ ≥I2≥ ≥          ≥ ≥Im≥ ≥≥≥ ≥ ≥Il≥ ≥          ≥ ≥In≥ ≥
      ¿≈¡ƒƒ¡ƒŸ<ø ¿≈¡ƒƒ¡ƒŸ<ø        ¿≈¡ƒƒ¡≈Ÿ≥≥ ¿≈¡ƒƒ¡ƒŸ<ø     <ø ¿≈¡ƒƒ¡ƒŸ
ZERO<ƒƒŸPrec   ¿ƒƒŸ       ¿ƒ ... <ƒƒŸ ⁄ƒƒŸ ≥≥  ≥       ¿ƒ ... ¿ƒƒŸ
                                   (3)≥  ⁄ƒŸ≥  ¿ƒø
                                      ≥  ≥  ¿ƒø  ≥
                                   Nƒƒ≈>⁄≈¬ƒƒ¬≈ø ≥
                                   (5)≥ ≥ ≥Ij≥ ≥ ≥(1)
                              CursorƒƒŸ ¿ƒ¡ƒƒ¡ƒŸ<Ÿ
                                 nou

  }
    var
      N: Integer;
      succes: Boolean;
    begin
      GenereazaNod(L, N);           { N este indicele pe care se pune
                                      noul nod }
      L.Info[N] := I;               { pune I in L.Info[N] }
      Succes := Cauta(L, I.Cheie);  { determina cursorul }
      If L.Cursor = Zero then begin { inserare in capul listei }
        If L.Cap <> Zero then       { (1) N este precedentul capului }
          L.Prec[L.Cap] := N;
        L.Urm[N] := L.Cap;          { (2) N se insereaza inainte de cap }
        L.Cap := N;                 { Nodul inserat devine capul listei }
        L.Cursor := N;              { (5) Cursorul refera nodul inserat }
        Exit
      end;
      If L.Urm[L.Cursor] <> Zero then { (1) nodul precedent al urmatorului }
        L.Prec[L.Urm[L.Cursor]] := N; {     nod dupa cursor devine N }

      L.Urm[N] := L.Urm[L.Cursor];    { (2) nodul urmator al lui N va fi
                                            nodul urmator cursorului }
      L.Urm[L.Cursor] := N;           { (3) nodul urmator cursorului va
                                            fi N }
      L.Prec[N] := L.Cursor;          { (4) nodul precedent lui N va
                                            fi cursorul }
      L.Cursor := N                   { (5) Cursorul refera nodul inserat }
    end; { Insereaza }

  Procedure Sterge(var L: Lista);
  { sterge din lista nodul referit de Cursor
    pre: Cursor <> ZERO

a) Inainte de stergere

         Urm⁄ƒƒø     ø       ⁄ƒƒ¬Cursor ⁄ƒƒø       ⁄ƒƒø      ø       ⁄ƒƒø
Capƒƒ>⁄ƒ¬ƒƒ¬≈ø ¿>... ¿>⁄ƒ¬ƒƒ¬≈ø ¿>⁄ƒ¬ƒƒ¬≈ø ¿>⁄ƒ¬ƒƒ¬≈ø ¿> ... ¿>⁄ƒ¬ƒƒ¬≈ø ¿>ZERO
      ≥ ≥I1≥ ≥         ≥ ≥Ij≥ ≥   ≥ ≥Ik≥ ≥   ≥ ≥Im≥ ≥          ≥ ≥In≥ ≥
      ¿≈¡ƒƒ¡ƒŸ<ø     <ø¿≈¡ƒƒ¡ƒŸ<ø ¿≈¡ƒƒ¡ƒŸ<ø ¿≈¡ƒƒ¡ƒŸ<ø     <ø ¿≈¡ƒƒ¡ƒŸ
ZERO<ƒƒŸPrec   ¿ƒ ... ¿ƒŸ       ¿ƒƒŸ       ¿ƒƒŸ       ¿ƒ ... ¿ƒƒŸ


b) Dupa stergere
     nodul cu informatia Ik (referit de Cursor) este scos din lista
     (1) i := L.Cursor
     (2) Urm[Prec[Cursor]] := Urm[Cursor]
     (3) Prec[Urm[Cursor]] := Prec[Cursor]
     (4) Sterge i
     (5) L.Cursor := L.Cap

                                   (2)
Cursor   Urm⁄ƒƒø     ø       ⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒø       ⁄ƒƒø      ø       ⁄ƒƒø
Cap¡ƒ>⁄ƒ¬ƒƒ¬≈ø ¿>... ¿>⁄ƒ¬ƒƒ¬≈ø ⁄>⁄ƒ¬ƒƒ¬ƒø ¿>⁄ƒ¬ƒƒ¬≈ø ¿> ... ¿>⁄ƒ¬ƒƒ¬≈ø ¿>ZERO
      ≥ ≥I1≥ ≥         ≥ ≥Ij≥ ≥ ¿i≥ ≥Ik≥ ≥   ≥ ≥Im≥ ≥          ≥ ≥In≥ ≥
      ¿≈¡ƒƒ¡ƒŸ<ø     <ø¿≈¡ƒƒ¡ƒŸ<ø ¿ƒ¡ƒƒ¡ƒŸ   ¿≈¡ƒƒ¡ƒŸ<ø     <ø ¿≈¡ƒƒ¡ƒŸ
ZERO<ƒƒŸPrec   ¿ƒ ... ¿ƒŸ       ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒŸ       ¿ƒ ... ¿ƒƒŸ
                                   (3)

  }
    var
      i: Integer;
    begin
      if L.Cursor = ZERO then Exit;
      i := L.Cursor;                                     { (1) }
      If L.Prec[L.Cursor] <> ZERO then
        L.Urm[L.Prec[L.Cursor]] := L.Urm[L.Cursor];      { (2) }
      If L.Urm[L.Cursor] <> ZERO then
        L.Prec[L.Urm[L.Cursor]] := L.Prec[L.Cursor];     { (3) }
      If i = L.Cap then                       { L.Cursor = L.Cap }
        L.Cap := L.Urm[L.Cap];
      L.Urm[i] := ZERO;                                  { (4) }
      L.Prec[i] := ZERO;
      L.Libere := L.Libere + [i];   { pune fostul L.Cursor in L.Libere }
      L.Cursor := L.Cap                                  { (5) }
    end; { Sterge }

  Procedure Modifica(var L: Lista; I: TInfo);
  { seteaza campul Info din nodul referit de Cursor la I }
    begin
      Sterge(L);            { sterge nodul curent }
      Insereaza(L, I)       { insereaza un nod nou }
    end; { Modifica }

  Procedure Extrage(var L: Lista; var I: TInfo);
  { extrage campul Info din nodul referit de Cursor in I }
    begin
      I := L.Info[L.Cursor]
    end; { Extrage }

  Function Cauta(var L: Lista; I: TCheie): Boolean;
  { cauta in lista L nodul cu cheia I
    daca gaseste un asemenea nod,
      atunci adresa lui va fi memorata in L.Urm[L.Cursor]
             functia intoarce True
      altfel functia intoarce False
             cursorul se pozitioneaza acolo unde ar trebui sa fie
             nodul respectiv (inainte de el de fapt)
  }
    var
      N, C: Integer;
    begin
      If Vida(L) then begin
        L.Cursor := ZERO;
        Cauta := False;
        Exit
      end;
      If I <= L.Info[L.Cap].Cheie then begin
        L.Cursor := ZERO;
        If I < L.Info[L.Cap].Cheie
          then Cauta := False
          else Cauta := True;
        Exit
      end;
      N := L.Cap;
      while N <> ZERO do
        if L.Info[N].Cheie < I then begin
          C := N;
          N := L.Urm[N]             { trece la nodul urmator }
        end else begin
          if L.Info[N].Cheie = I
            then Cauta := True      { cautare cu succes }
            else Cauta := False;
          L.Cursor := C;            { Urm[C] contine informatia dorita }
          Exit
        end;
      L.Cursor := C;                { Urm[C] ar contine informatia dorita }
      Cauta := False                { cautare fara succes }
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
      while L.Urm[L.Cursor] <> ZERO do L.Cursor := L.Urm[L.Cursor]
    end; { Primul }

  Procedure Urmatorul(var L: Lista; var Esec: Boolean);
    { daca L.Cursor^ are un nod urmator,
        atunci L.Cursor il va referi pe acesta
               Esec := False
        altfel Esec := True
    }
    begin
      Esec := False;
      If L.Urm[L.Cursor] <> ZERO
        then L.Cursor := L.Urm[L.Cursor]
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
      If L.Prec[L.Cursor] <> ZERO
        then L.Cursor := L.Prec[L.Cursor]
        else Esec := True;
    end; { Precedentul }

  Function InfoToString(I: TInfo): String;
    { converteste informatia dintr-un nod la string }
    var
      S: String;
    begin
      Str(I.Cheie:3, S);
      InfoToString := '(' + S + ',' + I.Rest + ')'
    end; { InfoToString }

  Procedure Traverseaza(var L: Lista);
  { traverseaza toate nodurile din lista L si afiseaza informatia
    utila din ele
  }
    var
      Esec: Boolean;
      N: Integer;
    begin
      if L.Cap = ZERO then begin
        WriteLn('Lista este vida');
        Exit
      end;
      N := L.Cursor;                  { p pastreaza pozitia Cursorului }
      Primul(L);                      { seteaza Cursor la primul element
                                        din lista L }
      Esec := False;                  { lista are cel putin un nod }
      repeat
        { scrie informatia utila din nodul curent }
        write(InfoToString(L.Info[L.Cursor]), ',');
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
      While L.Cap <> ZERO do Sterge(L);
    end; { Elibereaza }

  begin  { cod de initializare vid }
  end.   { ULDCursA }
