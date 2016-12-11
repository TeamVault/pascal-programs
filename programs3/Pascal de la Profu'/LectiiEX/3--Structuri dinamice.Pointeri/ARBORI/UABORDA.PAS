Unit UABOrdA;
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
  Uses UABGenA;

  Procedure StergeSubarbore;
    begin
      UABGenA.StergeSubarbore
    end; { StergeSubarbore }

  Procedure Extrage(var e: ElementStandard);
    begin
      UABGenA.Extrage(e)
    end; { Extrage }

  Procedure Traverseaza(ord: Ordine; proc: ProcessProcA);
    begin
      UABGenA.Traverseaza(ord, proc)
    end; { Traverseaza }

  Procedure Caracteristici(var St: Stare);
    begin
      UABGenA.Caracteristici(St)
    end; { Caracteristici }

  Procedure Cauta(rel: Relativ; var Esec: Boolean);
    begin
      UABGenA.Cauta(rel, Esec)
    end; { Cauta }

  Function Vid: Boolean;
    begin
      Vid := UABGenA.Vid
    end; { Vid }

  Procedure Creeaza;
    begin
      UABGenA.Creeaza
    end; { Creeaza }

  Procedure Elibereaza;
    begin
      UABGenA.Elibereaza
    end; { Elibereaza }

  Procedure Afiseaza;
    begin
      UABGenA.Afiseaza
    end; { Afiseaza }

  Procedure CautaCheie(tCheie: TipCheie; var Esec: Boolean);
    var p: Muchie;
        e: ElementStandard;
    begin
      Esec := true;
      SetCursor(0);
      p := 1;
      While Esec and (not EsteVid(p)) do begin
        SetCursor(p);
        GetElem(p, e);
        if tCheie = e.Cheie then Esec := false
        else if tCheie < e.Cheie then p := SubarboreStang(p)
        else p := SubarboreDrept(p);
      end;
    end; { CautaCheie }

  Procedure Insereaza(e: ElementStandard; var Esec: Boolean);
    var p,c: Muchie;
        el: ElementStandard;
    begin
      CautaCheie(e.Cheie, Esec);
      if not Esec then begin
        Esec := true;
        exit
      end;
      Esec := false;
      if Vid then begin
        SetCursor(1);
        SetElem(GetCursor, e);
        Exit
      end;
      c := GetCursor;
      GetElem(c, el);
      if e.Cheie < el.Cheie
        then SetCursor(SubarboreStang(c))
        else SetCursor(SubarboreDrept(c));
      SetElem(GetCursor, e)
    end; { Insereaza }

  Procedure StergeCheie(tCheie: TipCheie; var Esec: Boolean);
    var p, Sters, r: Muchie;

    Procedure StergeStanga(var q: Muchie);
      var r: Muchie;
      begin
        r := SubarboreDrept(q);
        if (not EsteVid(r)) then StergeStanga(r)
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
          if EsteVid(pd) then Muta(p, ps)
          else if EsteVid(ps) then Muta(p, pd)
          else StergeStanga(ps)
        end
      end; { Sterge }
    begin
      Esec := true;
      r := 1;
      Sterge(tCheie, r);
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

