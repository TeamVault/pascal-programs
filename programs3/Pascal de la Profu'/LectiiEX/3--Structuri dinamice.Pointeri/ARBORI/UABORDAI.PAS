Unit UABOrdAI;
{$F+}

Interface
  Uses UDecl;

  Procedure StergeSubarbore;
  Procedure Extrage(var e: ElementStandard);
  Procedure Traverseaza(ord: Ordine; proc: ProcessProcA);
  Procedure Caracteristici(var St: Stare);
  Procedure Cauta(rel: Relativ; var Esec: Boolean);
  Function Vid: Boolean;
  Procedure Creeaza;
  Procedure Elibereaza;
  Procedure Afiseaza;
  Procedure Insereaza(e: ElementStandard; var Esec: Boolean);
  Procedure CautaCheie(tCheie: TipCheie; var Esec: Boolean);
  Procedure StergeCheie(tCheie: TipCheie; var Esec: Boolean);
  Procedure Modifica(e: ElementStandard);

Implementation
  Uses UABGenAI;

  Procedure StergeSubarbore;
    begin
      UABGenAI.StergeSubarbore
    end; { StergeSubarbore }

  Procedure Extrage(var e: ElementStandard);
    begin
      UABGenAI.Extrage(e)
    end; { Extrage }

  Procedure Traverseaza(ord: Ordine; proc: ProcessProcA);
    begin
      UABGenAI.Traverseaza(ord, proc)
    end; { Traverseaza }

  Procedure Caracteristici(var St: Stare);
    begin
      UABGenAI.Caracteristici(St)
    end; { Caracteristici }

  Procedure Cauta(rel: Relativ; var Esec: Boolean);
    begin
      UABGenAI.Cauta(rel, Esec)
    end; { Cauta }

  Function Vid: Boolean;
    begin
      Vid := UABGenAI.Vid
    end; { Vid }

  Procedure Creeaza;
    begin
      UABGenAI.Creeaza
    end; { Creeaza }

  Procedure Elibereaza;
    begin
      UABGenAI.Elibereaza
    end; { Elibereaza }

  Procedure Afiseaza;
    begin
      UABGenAI.Afiseaza
    end; { Afiseaza }

  Procedure CautaCheie(tCheie: TipCheie; var Esec: Boolean);
    var p: Muchie;
        e: ElementStandard;
    begin
      Esec := true;
      p := GetRadacina;
      While Esec and (not EsteVid(p)) do begin
        SetCursor(p);
        GetElem(p, e);
        if tCheie = e.Cheie then Esec := false
        else if tCheie < e.Cheie then p := SubarboreStang(p)
        else p := SubarboreDrept(p);
      end;
    end; { CautaCheie }

  Procedure Insereaza(e: ElementStandard; var Esec: Boolean);
    var p,q: NodAB;
        m: Muchie;
    begin
      CautaCheie(e.Cheie, Esec);
      if not Esec then begin
        Esec := true;
        exit
      end;
      p.el := e;
      p.Stg := 0;
      p.dr  := 0;
      m := GetPrimulLiber;
      if not Vid then begin
        GetNod(GetCursor, q);
        if e.Cheie < q.el.Cheie
          then q.Stg := m
          else q.dr  := m;
        SetNod(GetCursor, q);    { completeaza informatia de inlantuire }
      end else SetRadacina(m);
      SetPrimulLiber(SubarboreDrept(m));
      SetNod(m, p);
      SetCursor(m)
    end; { Insereaza }

  Procedure StergeCheie(tCheie: TipCheie; var Esec: Boolean);
    var p, Sters, r: Muchie;
        n: NodAB;

    Procedure StergeStanga(var q: Muchie);
      var e: ElementStandard;
          r: Muchie;
      begin
        r := SubarboreDrept(q);
        if EsteVid(r) then StergeStanga(r)
        else begin
          SetCheie(Sters, GetCheie(q));
          Sters := q;
          q := SubarboreStang(q)
        end
      end; { StergeStanga }

    Procedure Sterge(tCheie: TipCheie; var p: Muchie);
      var e: ElementStandard;
          ps, pd: Muchie;
      begin
        GetElem(p, e);
        ps := SubarboreStang(p);
        pd := SubarboreDrept(p);
        if EsteVid(p) then Esec := true
        else if tCheie < e.Cheie then Sterge(tCheie, ps)
        else if tCheie > e.Cheie then Sterge(tCheie, pd)
        else begin
          Sters := p;
          Esec := false;
          if EsteVid(pd) then p := ps
          else if EsteVid(ps) then p := pd
          else StergeStanga(ps)
        end
      end; { Sterge }
    begin
      Esec := true;
      r := GetRadacina;
      Sterge(tCheie, r);
      if not Esec then begin
        n.el  := NodulZero;
        n.Stg := 0;
        n.dr  := GetPrimulLiber;
        SetNod(Sters, n);
        SetPrimulLiber(Sters)
      end;
      if not Vid then SetCursor(1)
    end; { StergeCheie }

  Procedure Modifica(e: ElementStandard);
    var Esec: Boolean;
        c: Muchie;
    begin
      c := GetCursor;
      StergeCheie(GetCheie(c), Esec);
      Insereaza(e, Esec)
    end; { Modifica }

{$F-}
End.

