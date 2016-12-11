Unit UABGenA;
{$F+}

Interface
  Uses UDecl;

  Procedure Insereaza(e: ElementStandard; Rel: Relativ; var Esec: Boolean);
  Procedure StergeSubArbore;
  Procedure Modifica(e: ElementStandard);
  Procedure Extrage(var e: ElementStandard);
  Procedure Traverseaza(Ord: Ordine; proc: ProcessProcA);
  Procedure Caracteristici(var St: Stare);
  Procedure Cauta(Rel: Relativ; var Esec: Boolean);
  Function Vid: Boolean;
  Procedure Creeaza;
  Procedure Elibereaza;
  Procedure Afiseaza;

  Function SubarboreStang(p: Muchie): Muchie;
  Function SubarboreDrept(p: Muchie): Muchie;
  Procedure GetElem(p: Muchie; var e: ElementStandard);
  Procedure SetCursor(p: Muchie);
  Function GetCursor: Muchie;
  Procedure SetCheie(p: Muchie; k: TipCheie);
  Function GetCheie(p: Muchie): TipCheie;
  Procedure SetElem(p: Muchie; e: ElementStandard);
  Function EsteVid(p: Muchie): Boolean;
  Procedure Muta(p, q: Muchie);

type
  ABG = record
    A: array[1..DimensiuneArbore] of Node;
    Cursor: Muchie
  end;

Implementation
  Uses UABPrint;

  var Arb: ABG;
      St: Stare;
      ht, sz, lc: Integer;
      ap, tpl: Real;

  Function SubarboreStang(p: Muchie): Muchie;
    begin
      SubarboreStang := 2*p
    end; { SubarboreStang }

  Function SubarboreDrept(p: Muchie): Muchie;
    begin
      SubarboreDrept := 2*p+1
    end; { SubarboreDrept }

  Procedure SetCursor(p: Muchie);
    begin
      Arb.Cursor := p
    end; { SetCursor }

  Function GetCursor: Muchie;
    begin
      GetCursor := Arb.Cursor
    end; { GetCursor }

  Procedure SetCheie(p: Muchie; k: TipCheie);
    begin
      Arb.A[p].Cheie := k
    end; { SetCheie }

  Function GetCheie(p: Muchie): TipCheie;
    begin
      GetCheie := Arb.A[p].Cheie
    end; { GetCheie }

  Procedure SetElem(p: Muchie; e: ElementStandard);
    begin
      Arb.A[p] := e
    end; { SetElem }

  Procedure GetElem(p: Muchie; var e: ElementStandard);
    begin
      e := Arb.A[p]
    end; { ArbElem }

  Procedure Muta(p, q: Muchie);
    var e: ElementStandard;
    { traversare in preordine }
    begin
      GetElem(q, e);
      SetElem(p, e);
      SetElem(q, NodulZero);
      if not EsteVid(SubarboreStang(q)) then Muta(SubarboreStang(p), SubarboreStang(q));
      if not EsteVid(SubarboreDrept(q)) then Muta(SubarboreDrept(p), SubarboreDrept(q))
    end; { Muta }

  Function EsteVid(p: Muchie): Boolean;
    begin
      EsteVid := ZeroElem(Arb.A[p])
    end; { EsteVid }

  Procedure PreOrdine(p: Muchie; l: Integer; proc: ProcessProcA);
    begin
      if not ZeroElem(Arb.A[p]) then begin
        proc(p, l);
        PreOrdine(SubarboreStang(p), l+1, proc);
        PreOrdine(SubarboreDrept(p), l+1, proc);
      end;
    end; { PreOrdine }

  Procedure InOrdine(p: Muchie; l: Integer; proc: ProcessProcA);
    begin
      if not ZeroElem(Arb.A[p]) then begin
        InOrdine(SubarboreStang(p), l+1, proc);
        proc(p, l);
        InOrdine(SubarboreDrept(p), l+1, proc);
      end;
    end; { InOrdine }

  Procedure PostOrdine(p: Muchie; l: Integer; proc: ProcessProcA);
    begin
      if not ZeroElem(Arb.A[p]) then begin
        PoStOrdine(SubarboreStang(p), l+1, proc);
        PostOrdine(SubarboreDrept(p), l+1, proc);
        proc(p, l);
      end;
    end; { PostOrdine }

  Procedure CautaParinte(var p: Muchie; var Esec: Boolean);
    begin
      p := Arb.Cursor div 2;
      Esec := p = 0
    end; { CautaParinte }

  Procedure DealocaNod(p: Muchie; i: Integer);
    begin
      Arb.a[p].Cheie := 0;
      Arb.a[p].info := 0
    end; { DealocaNod }

  Procedure DealocaArbore(p: Muchie);
    var l: Integer;
    begin
      l := 0;
      PostOrdine(p, l+1, DealocaNod)
    end; { DealocaArbore }

  Procedure Insereaza(e: ElementStandard; Rel: Relativ; var Esec: Boolean);
    var p: Muchie;
    begin
      Esec := False;
      case Rel of
        Radacina: If Vid
                    then p := 1
                    else Esec := true;
        FiuStang: if EsteVid(SubarboreStang(Arb.Cursor))
                    then p := SubarboreStang(Arb.Cursor)
                    else Esec := true;
        FiuDrept: if EsteVid(SubarboreDrept(Arb.Cursor))
                    then p := SubarboreDrept(Arb.Cursor)
                    else Esec := true;
        Parinte:  Esec := true
      end;
      if not Esec then begin
        Arb.Cursor := p;
        Arb.A[p] := e
      end
    end; { Insereaza }

  Procedure StergeSubArbore;
    var
      p: Muchie;
      Esec: Boolean;
    begin
      p := Arb.Cursor;
      CautaParinte(p, Esec);
      if not Esec then
        if SubarboreStang(p) = Arb.Cursor
          then Arb.A[SubarboreStang(p)] := NodulZero
          else Arb.A[SubarboreDrept(p)] := NodulZero;
      DealocaArbore(Arb.Cursor);
      If Arb.Cursor = 1
        then Arb.Cursor := 0;
    end; { StergeSubArbore }

  Procedure Modifica(e: ElementStandard);
    begin
      Arb.A[Arb.Cursor] := e
    end; { Modifica }

  Procedure Extrage(var e: ElementStandard);
    begin
      e := Arb.A[Arb.Cursor]
    end; { Extrage }

  Procedure Traverseaza(Ord: Ordine; proc: ProcessProcA);
    var l: Integer;
    begin
      l := 0;
      case Ord of
        UDecl.PreOrdine:  PreOrdine(1, l+1, proc);
        UDecl.InOrdine:   InOrdine(1, l+1, proc);
        UDecl.PostOrdine: PostOrdine(1, l+1, proc);
      end;
    end; { Traverseaza }

  Procedure Numara(p: Muchie; i: Integer);
    begin
      sz := sz + 1;
      tpl := tpl + i;
      if ht < i then ht := i;
    end; { Numara }

  Procedure Caracteristici(var st: Stare);
    begin
      sz := 0;
      ht := 0;
      tpl := 0;
      if not Vid then begin
        InOrdine(1, 1, Numara);
        ap := tpl / sz
      end else ap := 0;
      St.Dimensiune := sz;
      St.Inaltime := ht;
      St.DrumMediu := ap
    end; { Caracteristici }

  Procedure Cauta(Rel: Relativ; var Esec: Boolean);
    var p: Muchie;
    begin
      Esec := false;
      case Rel of
        Radacina: Arb.Cursor := 1;
        FiuStang: if not ZeroElem(Arb.A[SubarboreStang(Arb.Cursor)])
                    then Arb.Cursor := SubarboreStang(Arb.Cursor)
                    else Esec := true;
        FiuDrept: if not ZeroElem(Arb.A[SubarboreDrept(Arb.Cursor)])
                    then Arb.Cursor := SubarboreDrept(Arb.Cursor)
                    else Esec := true;
        Parinte:  begin
                    CautaParinte(p, Esec);
                    if not Esec then Arb.Cursor := p
                  end;
      end;
    end; { Cauta }

  Function Vid: Boolean;
    begin
      Vid := ZeroElem(Arb.A[1])
    end; { Vid }

  Procedure Creeaza;
    var i: 1..DimensiuneArbore;
    begin
      for i := 1 to DimensiuneArbore do Arb.A[i] := NodulZero;
      Arb.Cursor := 0
    end; { Creeaza }

  Procedure Elibereaza;
    begin
      DealocaArbore(1);
      Creeaza
    end; { Elibereaza }

  Procedure Afiseaza;
    var Esec: Boolean;
    begin
{      WPrint(Arb.rad, 0)}
      VAPrint(Arb, 1, 20, Esec);
      Caracteristici(St);
      WriteLn('Dimensiune: ', St.Dimensiune:7);
      WriteLn('Inaltime:   ', St.Inaltime:7);
      WriteLn('Drum mediu: ', St.DrumMediu:7:2);
    end; { Afiseaza }

{$F-}
End.

