Program FrecvCuv;
  { programul citeste un fisier text si afiseaza frecventa de
    aparitie a cuvintelor din el.
    Se foloseste o lista simplu inlantuita pentru memorarea
    cuvintelor
  }
  uses
    UFile, Crt;

  type
    TInfo = record    { informatia utila }
      cuvant: String;
      frecv: Word
    end;
    PNod = ^TNod;
    TNod = Record
      Info: TInfo;    { camp ce contine informatia utila }
      Urm: PNod       { adresa nodului urmator }
    End;
    ListaCapCoada = Record
      Cap,            { capul listei: folosit la traversare }
      Coada: PNod     { coada listei: acolo se fac inserari si stergeri }
    End;

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
        if p^.Info.cuvant = I.cuvant then begin
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
      numarLinie: Integer;
    begin
      if L.Cap = Nil then begin
        WriteLn('Lista este vida');
        Exit
      end;
      p := L.Cap;
      numarLinie := 0;
      while p <> Nil do begin
        { scrie informatia utila din nod }
        writeln(p^.Info.cuvant, ' ', p^.Info.frecv);
        numarLinie := numarLinie + 1;
        if numarLinie mod 20 = 0 then Asteapta;
        p := p^.Urm                  { trece la nodul urmator }
      end;
      writeLn
    end; { Travereseaza }

  Procedure Elibereaza(var L: ListaCapCoada);
  { sterge din lista toate nodurile }
    begin
      While L.Cap <> Nil do Sterge(L);
    end; { Elibereaza }

  Function Dimensiune(L: ListaCapCoada): Word;
  { intoarce dimensiunea listei L = numarul de noduri din ea }
    var
      p: PNod;
      d: Word;
    begin
      p := L.Cap;
      d := 0;
      while p <> Nil do begin
        d := d + 1;
        p := p^.Urm;               { trece la nodul urmator }
      end;
      Dimensiune := d
    end; { Dimensiune }

  Procedure InsereazaCuvant(var L: ListaCapCoada; c: string);
  { cauta nodul care are cuvantul c in el
    daca il gaseste, adauga 1 la frecventa
    daca nu-l gaseste, genereaza un nod si-l adauga la lista
  }
    var
      p: PNod;
      I: TInfo;
    begin
      I.cuvant := c;
      I.frecv := 1;
      p := Cauta(L, I);
      if p <> Nil
        then p^.Info.frecv := p^.Info.frecv + 1
        else begin
          p := GenereazaNod(I);
          Insereaza(L, p)
        end;
    end; { InsereazaCuvant }
  var
    f: text;
    linie, cuvant: string;
    numeFis: string;
    este: boolean;
    poz: Integer;
    L: ListaCapCoada;
  begin
    Repeat
      ClrScr;
      WriteLn('CitireT - afisarea unui fisier text pe ecran');
      Repeat
        Write('Dati numele fisierului (ENTER la terminare): ');
        ReadLn(numeFis);
        If numeFis = '' then Exit;
        este := Exista(numeFis);
        if not este then WriteLn('Fisier inexistent!');
      Until este;
      Creeaza(L);
      Assign(f, numeFis);              { asociaza f la numeFis }
      Reset(f);                        { deschide f in citire }
      While not EOF(f) do begin        { cat timp nu s-a ajuns la sfarsit }
        ReadLn(f, linie);              { citeste o linie din fisier }
        { desparte linia un cuvinte }
        while linie <> '' do begin
          while (linie[1] = ' ') and (length(linie) > 0) do
            Delete(linie, 1, 1);
          poz := Pos(' ', linie);
          if poz > 0 then begin
            cuvant := Copy(linie, 1, poz-1);
            Delete(linie, 1, poz)
          end else begin
            cuvant := linie;
            linie := ''
          end;
          InsereazaCuvant(L, cuvant);
        end;
      end;
      Close(f);
      WriteLn('S-au gasit ', Dimensiune(L):5, ' cuvinte');
      WriteLn('Cuvintele din fisier sunt: ');
      Traverseaza(L);
      Asteapta
    Until False
  end. { CitireT }
