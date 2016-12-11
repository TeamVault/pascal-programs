Program LstCap;
{ implementeaza o lista simplu inlantuita in care inserarea
  si stergerea de elemente se fac in capul acesteia
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
  ListaCap = Record
    Cap: PNod
  End;

{ operatiile implementate sunt:
  GenereazaNod(N, I): Aloca nodul N in memoria dinamica si pune
                      informatia utila I in el
  Creeaza(L):         Crearea unei liste L vide
  Insereaza(L, N):    Adaugarea nodului N in capul listei L
  Sterge(L):          Stergerea nodului din capul listei
  Cauta(L, I):        Cauta in lista L nodul cu informatia utila I
  Traverseaza(L):     Traverseaza toate nodurile listei L si afiseaza
                      informatia utila din ele
  Elibereaza(L):      Dealoca toate elementele listei L, transformand-o
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
  Procedure Creeaza(var L: ListaCap);
  { creeaza o lista L vida }
    begin
      L.Cap := Nil
    end; { Creeaza }
  Procedure Insereaza(var L: ListaCap; N: PNod);
  { adauga nodul N^ in capul listei L

  inainte de inserare

Cap   ÚÄÄÂÄÄ¿    ÚÄÄÂÄÄ¿               ÚÄÄÂÄÄ¿
ÄÄÄÄÄ>³I1³  ÅÄÄÄ>³I2³  ÅÄÄÄ> ... ÄÄÄÄÄ>³In³  ÅÄÄÄ> NIL
      ÀÄÄÁÄÄÙ    ÀÄÄÁÄÄÙ               ÀÄÄÁÄÄÙ
           ³          ³                     ³
           ³          ³                     ³
          Urm        Urm                   Urm
     N
   ÚÄÄÂÄÄ¿
   ³IN³  ÅÄÄ> NIL
   ÀÄÄÁÄÄÙ

  dupa inserare

      ÚÄÄÂÄÄ¿    ÚÄÄÂÄÄ¿               ÚÄÄÂÄÄ¿
   ÚÄ>³I1³  ÅÄÄÄ>³I2³  ÅÄÄÄ> ... ÄÄÄÄÄ>³In³  ÅÄÄÄ> NIL
   ³  ÀÄÄÁÄÄÙ    ÀÄÄÁÄÄÙ               ÀÄÄÁÄÄÙ
   ³       ³          ³                     ³
   ³ (1)   ³          ³                     ³
   ÀÄÄÄÄ¿ Urm        Urm                   Urm
Cap  N  ³
³  ÚÄÄÂÄÅ¿
ÀÄ>³IN³  ³
(2)ÀÄÄÁÄÄÙ


  }
    begin
      N^.Urm := L.Cap; { nodul urmator al lui N va fi actualul cap
                         al listei }
      L.Cap := N       { noul cap al listei este N }
    end; { Insereaza }

  Procedure Sterge(var L: ListaCap);
  { sterge din lista nodul din capul sau (daca lista nu este vida)

  inainte de stergere

Cap   ÚÄÄÂÄÄ¿    ÚÄÄÂÄÄ¿               ÚÄÄÂÄÄ¿
ÄÄÄÄÄ>³I1³  ÅÄÄÄ>³I2³  ÅÄÄÄ> ... ÄÄÄÄÄ>³In³  ÅÄÄÄ> NIL
      ÀÄÄÁÄÄÙ    ÀÄÄÁÄÄÙ               ÀÄÄÁÄÄÙ
           ³          ³                     ³
           ³          ³                     ³
          Urm        Urm                   Urm

  dupa stergere
    ÚÄÄÄÄÄÄÄÄÄ¿(2)
Cap ³ ÚÄÄÂÄÄ¿ ³  ÚÄÄÂÄÄ¿               ÚÄÄÂÄÄ¿
ÄÄÄÄÙ ³I1³  ³ ÀÄ>³I2³  ÅÄÄÄ> ... ÄÄÄÄÄ>³In³  ÅÄÄÄ> NIL
  ÄÄÄ>ÀÄÄÁÄÄÙ    ÀÄÄÁÄÄÙ               ÀÄÄÁÄÄÙ
  p (1)    ³          ³                     ³
           ³          ³                     ³
          Urm        Urm                   Urm

  }
    var
      p: PNod;
    begin
      p := L.Cap;
      If p <> Nil then begin
        L.Cap := L.Cap^.Urm;
        Dispose(p)
      end;
    end; { Sterge }

  Function Cauta(var L: ListaCap; I: TInfo): PNod;
  { cauta in lista L nodul cu informatia utila I
    daca gaseste un asemenea nod, intoarce adresa lui
    altfel intoarce Nil
  }
    var
      p: PNod;
    begin
      p := L.Cap;
      while p <> Nil do
        if p^.Info = I then begin
          Cauta := p;              { nodul a fost gasit }
          Exit                     { executia procedurii se termina }
        end else p := p^.Urm;      { trece la nodul urmator }
      Cauta := Nil                 { nodul nu a fost gasit }
    end; { Cauta }
  Procedure Traverseaza(var L: ListaCap);
  { traverseaza toate nodurile din lista L si afiseaza informatia
    utila din ele
  }
    var
      p: PNod;
    begin
      if L.Cap = Nil then begin
        WriteLn('Lista este vida');
        Exit
      end;
      p := L.Cap;
      while p <> Nil do begin
        write(p^.Info:2, ',');        { scrie informatia utila din nod }
        p := p^.Urm                  { trece la nodul urmator }
      end;
      writeLn
    end; { Travereseaza }
  Procedure Elibereaza(var L: ListaCap);
  { sterge din lista toate nodurile }
    begin
      While L.Cap <> Nil do Sterge(L);
    end; { Elibereaza }

  var
    Lista: ListaCap;
    i: Integer;
    N: PNod;

  begin
    ClrScr;
    WriteLn('LstCap - implementarea listei simplu inlantuite cu inserare in cap');
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
    N := Cauta(Lista, 7);
    If N <> Nil
      then WriteLn('Exista un nod cu informatia utila 7, ',
                   'iar nodul urmator are informatia utila ', N^.Urm^.Info)
      else WriteLn('Nu exista un nod cu informatia utila 7');
    For I := 1 to 5 do begin
      Sterge(Lista);
      Write('Lista dupa stergerea nodului din cap este:      ');
      Traverseaza(Lista)
    end;
    N := Cauta(Lista, 7);
    If N <> Nil
      then WriteLn('Exista un nod cu informatia utila 7, ',
                   'iar nodul urmator are informatia utila ', N^.Urm^.Info)
      else WriteLn('Nu exista un nod cu informatia utila 7');
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    Elibereaza(Lista);
    Write('Lista dupa operatia Eliberare este: ');
    Traverseaza(Lista);
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    ReadLn
  end. { LstCap }
