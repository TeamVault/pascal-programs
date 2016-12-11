Unit ULstCcd;

{ implementeaza o lista simplu inlantuita in care inserarea
  si stergerea de noduri se face in coada
  corespunde 1:1 principiilor programarii modulare, avand
  toate avantajele si dezavantajele expuse de aceasta
}
Interface
type
  TInfo =  Integer; { tipul de date al informatiei utile din nod }
  PNod = ^TNod;
  TNod = Record
    Info: TInfo;    { camp ce contine informatia utila }
    Urm: PNod       { adresa nodului urmator }
  End;

{ operatiile implementate sunt:
  GenereazaNod(N, I): Aloca nodul N in memoria dinamica si pune
                      informatia utila I in el
  Creeaza:            Crearea unei liste vide
  Insereaza:          Adaugarea nodului N in coada listei
  Sterge:             Stergerea nodului din coada listei
  Cauta(I):           Cauta in lista nodul cu informatia utila I
  Traverseaza:        Traverseaza toate nodurile listei si afiseaza
                      informatia utila din ele
  Elibereaza:         Dealoca toate elementele listei, transformand-o
                      intr-o lista vida
}
  Function GenereazaNod(I: TInfo): PNod;
  Procedure Creeaza;
  Procedure Insereaza(N: PNod);
  Procedure Sterge;
  Function Cauta(I: TInfo): PNod;
  Procedure Traverseaza;
  Procedure Elibereaza;

Implementation
Uses
  Crt;

type
  ListaCapCoada = Record
    Cap,            { capul listei: folosit la traversare }
    Coada: PNod     { coada listei: acolo se fac inserari si stergeri }
  End;
var
  L: ListaCapCoada;

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

  Procedure Creeaza;
  { creeaza o lista L vida }
    begin
      L.Cap := Nil;
      L.Coada := Nil
    end; { Creeaza }

  Procedure Insereaza(N: PNod);
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

  Procedure Sterge;
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

  Function Cauta(I: TInfo): PNod;
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

  Procedure Traverseaza;
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

  Procedure Elibereaza;
  { sterge din lista toate nodurile }
    begin
      While L.Cap <> Nil do Sterge;
    end; { Elibereaza }

begin  { nu avem cod de initializare }
end. { UListCCD }