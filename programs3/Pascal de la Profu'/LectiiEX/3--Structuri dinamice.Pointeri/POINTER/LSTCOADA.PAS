Program LstCoada;
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
    Prec: PNod      { adresa nodului precedent }
  End;
  ListaCoada = Record
    Coada: PNod
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
     campul Prec egal cu Nil
    generarea inseamna aici alocare in memoria dinamica
  }
    var
      p: PNod;
    begin
      New(p);
      P^.Info := I;
      P^.Prec  := Nil;
      GenereazaNod := p
    end; { GenereazaNod }
  Procedure Creeaza(var L: ListaCoada);
  { creeaza o lista L vida }
    begin
      L.Coada := Nil
    end; { Creeaza }
  Procedure Insereaza(var L: ListaCoada; N: PNod);
  { adauga nodul N in capul listei L }
    begin
      N^.Prec := L.Coada; { nodul precedent al lui N va fi actuala coada
                            a listei }
      L.Coada := N        { noua coada a listei este N }
    end; { Insereaza }
  Procedure Sterge(var L: ListaCoada);
  { sterge din lista nodul din coada sa (daca lista nu este vida) }
    var
      p: PNod;
    begin
      p := L.Coada;
      If p <> Nil then begin
        L.Coada := L.Coada^.Prec;
        Dispose(p)
      end;
    end; { Sterge }
  Function Cauta(var L: ListaCoada; I: TInfo): PNod;
  { cauta in lista L nodul cu informatia utila I
    daca gaseste un asemenea nod, intoarce adresa lui
    altfel intoarce Nil
  }
    var
      p: PNod;
    begin
      p := L.Coada;
      while p <> Nil do
        if p^.Info = I then begin
          Cauta := p;              { nodul a fost gasit }
          Exit                     { executia procedurii se termina }
        end else p := p^.Prec;     { trece la nodul precedent }
      Cauta := Nil                 { nodul nu a fost gasit }
    end; { Cauta }
  Procedure Traverseaza(var L: ListaCoada);
  { traverseaza toate nodurile din lista L si afiseaza informatia
    utila din ele
  }
    var
      p: PNod;
    begin
      if L.Coada = Nil then begin
        WriteLn('Lista este vida');
        Exit
      end;
      p := L.Coada;
      while p <> Nil do begin
        write(p^.Info:2, ',');     { scrie informatia utila din nod }
        p := p^.Prec              { trece la nodul precedent }
      end;
      WriteLn
    end; { Travereseaza }
  Procedure Elibereaza(var L: ListaCoada);
  { sterge din lista toate nodurile }
    begin
      While L.Coada <> Nil do Sterge(L);
    end; { Elibereaza }

  var
    Lista: ListaCoada;
    i: Integer;
    N: PNod;

  begin
    ClrScr;
    WriteLn('LstCoada - implementarea listei simplu inlantuite cu inserare in coada');
    WriteLn('Elementele listei se listeaza de la coada spre cap');
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
                   'iar nodul precedent are informatia utila ', N^.Prec^.Info)
      else WriteLn('Nu exista un nod cu informatia utila 7');
    For I := 1 to 5 do begin
      Sterge(Lista);
      Write('Lista dupa stergerea nodului din coada este:    ');
      Traverseaza(Lista)
    end;
    N := Cauta(Lista, 7);
    If N <> Nil
      then WriteLn('Exista un nod cu informatia utila 7, ',
                   'iar nodul precedent are informatia utila ', N^.Prec^.Info)
      else WriteLn('Nu exista un nod cu informatia utila 7');
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    Elibereaza(Lista);
    Write('Lista dupa operatia Eliberare este: ');
    Traverseaza(Lista);
    WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
    ReadLn
  end. { LstCoada }
