Program LstCapCda;
{ implementeaza o lista simplu inlantuita in care inserarea
  si stergerea de noduri se face in coada
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
  ListaCapCoada = Record
    Cap,            { capul listei: folosit la traversare }
    Coada: PNod     { coada listei: acolo se fac inserari si stergeri }
  End;

{ operatiile implementate sunt:
  GenereazaNod(N, I): Aloca nodul N in memoria dinamica si pune
                      informatia utila I in el
  Creeaza(L):         Crearea unei liste L vide
  Insereaza(L, N):    Adaugarea nodului N in coada listei L
  Sterge(L):          Stergerea nodului din coada listei
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
  Procedure Creeaza(var L: ListaCapCoada);
  { creeaza o lista L vida }
    begin
      L.Cap := Nil;
      L.Coada := Nil
    end; { Creeaza }
  Procedure Insereaza(var L: ListaCapCoada; N: PNod);
  { adauga nodul N in coada listei L }
    var
      p: PNod;
    begin
      If L.Cap = Nil then begin    { daca coada este vida }
        L.Cap := N;
        L.Coada := N;
        Exit
      end;
      L.Coada^.Urm := N;           { actuala Coada va avea urmator pe N }
      L.Coada := N                 { noua coada va fi N }
    end; { Insereaza }
  Procedure Sterge(var L: ListaCapCoada);
  { sterge din lista nodul din coada sa (daca lista nu este vida) }
    var
      p: PNod;
    begin
      if L.Cap = Nil then Exit;       { lista este vida }
      if L.Cap = L.Coada then begin   { lista are un singur nod }
        Dispose(L.Cap);               { dealoca unicul nod }
        L.Cap := Nil;                 { lista redevine vida }
        L.Coada := Nil;
        Exit                          { executia se termina in acest caz }
      end;
      { cauta p = nodul anterior celui din coada
        p va avea p^.Urm = L.Coada }
      p := L.Cap;                     { cautarea incepe din capul listei }
      While p^.Urm <> L.Coada do p := p^.Urm;
      { sterge nodul din coada si reactualizeaza campul Coada }
      Dispose(L.Coada);               { dealoca nodul din coada }
      L.Coada := p;                   { nodul p devine coada }
      p^.Urm := Nil;                  { si nu mai are nod urmator }
    end; { Sterge }
  Function Cauta(var L: ListaCapCoada; I: TInfo): PNod;
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
  Procedure Traverseaza(var L: ListaCapCoada);
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
  Procedure Elibereaza(var L: ListaCapCoada);
  { sterge din lista toate nodurile }
    begin
      While L.Cap <> Nil do Sterge(L);
    end; { Elibereaza }

  var
    Lista: ListaCapCoada;
    i: Integer;
    N: PNod;

  begin
    ClrScr;
    WriteLn('LstCapCoada - implementarea listei simplu inlantuite cu inserare in coada');
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
      Write('Lista dupa stergerea nodului din coada este:    ');
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
