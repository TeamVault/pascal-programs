Unit UABOrd;

Interface
  Uses UDecl;

  { identice cu cele de la Arborele Binar General }
  Procedure StergeSubarbore;
  Procedure Extrage(var e: ElementStandard);
  Procedure Traverseaza(Ord: Ordine; proc: ProcessProc);
  Procedure Caracteristici(var St: Stare);
  Procedure Cauta(Rel: Relativ; var Esec: Boolean);
  Function Vid: Boolean;
  Procedure Creeaza;
  Procedure Elibereaza;
  Procedure Afiseaza;

  { proprii }
  Procedure Insereaza(e: ElementStandard; var Esec: Boolean);
  { cauta nodul cu cheia specificata }
  Procedure CautaCheie(tCheie: TipCheie; var Esec: Boolean);
  { sterge nodul cu cheia specificata }
  Procedure StergeCheie(tCheie: TipCheie; var Esec: Boolean);
  { modifica nodul curent }
  Procedure Modifica(e: ElementStandard);

Implementation
  Uses UABGen;

  Procedure StergeSubarbore;
    begin
      UABGen.StergeSubarbore
    end; { StergeSubarbore }

  Procedure Extrage(var e: ElementStandard);
    begin
      UABGen.Extrage(e)
    end; { Extrage }

  Procedure Traverseaza(Ord: Ordine; proc: ProcessProc);
    begin
      UABGen.Traverseaza(Ord, proc)
    end; { Traverseaza }

  Procedure Caracteristici(var St: Stare);
    begin
      UABGen.Caracteristici(St)
    end; { Caracteristici }

  Procedure Cauta(Rel: Relativ; var Esec: Boolean);
    begin
      UABGen.Cauta(Rel, Esec)
    end; { Cauta }

  Function Vid: Boolean;
    begin
      Vid := UABGen.Vid
    end; { Vid }

  Procedure Creeaza;
    begin
      UABGen.Creeaza
    end; { Creeaza }

  Procedure Elibereaza;
    begin
      UABGen.Elibereaza
    end; { Elibereaza }

  Procedure Afiseaza;
    begin
      UABGen.Afiseaza
    end; { Afiseaza }

{ proceduri proprii}
  Procedure CautaCheie(tCheie: TipCheie; var Esec: Boolean);
    var p: PNodArbore;
    begin
      Esec := True;
      p := GetRadacina;
      SetCursor(Nil);
      While Esec and (p <> Nil) do with p^ do begin
        SetCursor(p);
        if tCheie = el.Cheie then Esec := False
        else if tCheie < el.Cheie then p := Stg
        else p := Dr;
      end;
    end; { CautaCheie }

  Procedure GenereazaNod(var p: PNodArbore);
    begin
      new(p);
      p^.Stg := Nil;
      p^.Dr  := Nil
    end; { GenereazaNod }

  Procedure Insereaza(e: ElementStandard; var Esec: Boolean);
    var
      p,c: PNodArbore;
    begin
      CautaCheie(e.Cheie, Esec);
      { Esec = False inseamna ca arborele contine cheia }
      if not Esec then begin
        Esec := true;  { nu se poate insera cheia }
        exit
      end;
      GenereazaNod(p);
      p^.el := e;
      Esec := false;
      if GetRadacina = Nil then begin
        SetRadacina(p);
        Exit
      end;
      c := GetCursor;
      With c^ do
        if e.Cheie < el.Cheie
          then Stg := p
          else Dr := p;
      SetCursor(p)
    end; { Insereaza }

  Procedure StergeCheie(tCheie: TipCheie; var Esec: Boolean);
    var p,                  { pointer la nodul cu care se opereaza }
        Sters,              { nodul care se sterge }
        r: PNodArbore;      { pointer la nodul cu care se opereaza }

    Procedure StergeStanga(var q: PNodArbore);
      begin { StergeStanga }
        { cazul iii): nodul Sters are doi fii,
          iar q initial este Sters^.Stg
        }
        { cauta cel mai din dreapta nod din subarborele cu radacina q }
        if q^.Dr <> Nil then StergeStanga(q^.Dr)
        { s-a gasit cel mai din dreapta nod: q^ refera nodul N care se
          va sterge fizic
        }
        else begin
          { inlocuieste continutul lui Sters (a carui cheie se sterge)
            cu continutul lui N }
          Sters^.el.Cheie := q^.el.Cheie;

          Sters := q;
          q := q^.Stg   { inlocuieste legatura lui de la parintele lui q
                          (N) cu legatura de la parintele lui q la
                          fiul stang al acestuia - q nu are fiu drept }
        end
      end; { StergeStanga }

    Procedure Sterge(tCheie: TipCheie; var p: PNodArbore);
      begin { Sterge }
        { cautarea recursiva - binara - a nodului de sters }
        With p^ do begin
          if p = Nil then Esec := true
          { continua cu subarborele stang }
          else if tCheie < el.Cheie then Sterge(tCheie, Stg)
          { continua cu subarborele drept }
          else if tCheie > el.Cheie then Sterge(tCheie, Dr)
          { nodul a fost gasit - este referit de p }
          else begin { sterge nodul p^ }
            Sters := p;
            Esec := false;
            { cazurile i) si ii): inlocuieste legatura de la parintele
              lui p la p cu legatura de la parintele lui p la fiul lui p }
            if Dr = Nil then p := Stg
            else if Stg = Nil then p := Dr
            { cazul iii): pointerii Stg si Dr sunt ambii non Nil }
            else StergeStanga(Stg)
            { analog StergeDreapta(Dr) }
          end
        end
      end; { Sterge }
    begin  { StergeCheie }
      Esec := true;
      r := GetRadacina;
      { apeleaza Sterge plecand de la Radacina }
      Sterge(tCheie, r);
      { dealoca nodul Sters daca s-a facut stergerea }
      if not Esec then begin
        Dispose(Sters);
        { reseteaza cursorul }
        if not Vid then SetCursor(GetRadacina)
      end;
    end; { StergeCheie }

  Procedure Modifica(e: ElementStandard);
    var Esec: Boolean;
        c: PNodArbore;
    begin
      c := GetCursor;
      StergeCheie(c^.el.Cheie, Esec);
      Insereaza(e, Esec)
    end; { Modifica }

End. { UABOrd }
