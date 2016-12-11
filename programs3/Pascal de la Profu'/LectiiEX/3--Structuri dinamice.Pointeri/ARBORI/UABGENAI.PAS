Unit UABGenAI;
{$F+}

Interface
  Uses UDecl;

  Procedure Insereaza(e: ElementStandard; rel: Relativ; var Esec: Boolean);
  Procedure StergeSubArbore;
  Procedure Modifica(e: ElementStandard);
  Procedure Extrage(var e: ElementStandard);
  Procedure Traverseaza(Ord: Ordine; proc: ProcessProcA);
  Procedure Caracteristici(var st: Stare);
  Procedure Cauta(rel: Relativ; var Esec: Boolean);
  Function Vid: Boolean;
  Procedure Creeaza;
  Procedure Elibereaza;
  Procedure Afiseaza;

  Function SubarboreStang(p: Muchie): Muchie;
  Function SubarboreDrept(p: Muchie): Muchie;
  Procedure SetElem(p: Muchie; e: ElementStandard);
  Procedure GetElem(p: Muchie; var e: ElementStandard);
  Procedure SetNod(p: Muchie; e: NodAB);
  Procedure GetNod(p: Muchie; var e: NodAB);
  Procedure SetCursor(p: Muchie);
  Function GetCursor: Muchie;
  Procedure SetPrimulLiber(p: Muchie);
  Function GetPrimulLiber: Muchie;
  Procedure SetRadacina(p: Muchie);
  Function GetRadacina: Muchie;
  Procedure SetCheie(p: Muchie; k: TipCheie);
  Function GetCheie(p: Muchie): TipCheie;
  Function EsteVid(p: Muchie): Boolean;

type
  ABG = record
    A: array[Muchie] of NodAB;
    Radacina, Cursor: Muchie;
    PrimulLiber: Muchie;  { capul listei nodurilor libere }
  end;

Implementation
  Uses ULStackE, UABPrint;

  var Arb: ABG;
      St: Stare;
    var
      ht, sz, lc: Integer;
      ap, tpl: Real;

  Function SubarboreStang(p: Muchie): Muchie;
    begin
      SubarboreStang := Arb.A[p].stg
    end; { SubarboreStang }

  Function SubarboreDrept(p: Muchie): Muchie;
    begin
      SubarboreDrept := Arb.A[p].dr
    end; { SubarboreDrept }

  Procedure SetCursor(p: Muchie);
    begin
      Arb.Cursor := p
    end; { SetCursor }

  Function GetCursor: Muchie;
    begin
      GetCursor := Arb.Cursor
    end; { GetCursor }

  Procedure SetPrimulLiber(p: Muchie);
    begin
      Arb.PrimulLiber := p
    end; { SetPrimulLiber }

  Function GetPrimulLiber: Muchie;
    begin
      GetPrimulLiber := Arb.PrimulLiber
    end; { GetFree }

  Procedure SetRadacina(p: Muchie);
    begin
      Arb.Radacina := p
    end; { SetRadacina }

  Function GetRadacina: Muchie;
    begin
      GetRadacina := Arb.Radacina
    end; { GetRadacina }

  Procedure SetCheie(p: Muchie; k: TipCheie);
    begin
      Arb.A[p].el.Cheie := k
    end; { SetCheie }

  Function GetCheie(p: Muchie): TipCheie;
    begin
      GetCheie := Arb.A[p].el.Cheie
    end; { GetCheie }

  Procedure SetElem(p: Muchie; e: ElementStandard);
    begin
      Arb.A[p].el := e
    end; { SetElem }

  Procedure GetElem(p: Muchie; var e: ElementStandard);
    begin
      e := Arb.A[p].el
    end; { GetElem }

  Procedure SetNod(p: Muchie; e: NodAB);
    begin
      Arb.A[p] := e
    end; { SetNod }

  Procedure GetNod(p: Muchie; var e: NodAB);
    begin
      e := Arb.A[p]
    end; { GetNod }

  Function EsteVid(p: Muchie): Boolean;
    begin
      EsteVid := ZeroElem(Arb.A[p].el)
    end; { EsteVid }

  Procedure PreOrdine(p: Muchie; l: Integer; proc: ProcessProcA);
    begin
      if p <> 0 then begin
        proc(p, l);
        PreOrdine(Arb.A[p].stg, l+1, proc);
        PreOrdine(Arb.A[p].dr, l+1, proc);
      end;
    end; { PreOrdine }

  Procedure InOrdine(p: Muchie; l: Integer; proc: ProcessProcA);
    begin
      if p <> 0 then begin
        InOrdine(Arb.A[p].stg, l+1, proc);
        proc(p, l);
        InOrdine(Arb.A[p].dr, l+1, proc);
      end;
    end; { InOrdine }

  Procedure PostOrdine(p: Muchie; l: Integer; proc: ProcessProcA);
    begin
      if p <> 0 then begin
        PostOrdine(Arb.A[p].stg, l+1, proc);
        PostOrdine(Arb.A[p].dr, l+1, proc);
        proc(p, l);
      end;
    end; { PostOrdine }

  Procedure CautaParinte(var p: Muchie; var Esec: Boolean);
    var Gasit: Boolean;
    begin
      ULStackE.Creeaza;
      Gasit := false;
      p := Arb.Radacina;
      while (p <> 0) and (not Gasit) do
        if (Arb.A[p].stg = Arb.Cursor) or (Arb.A[p].dr = Arb.Cursor)
          then Gasit := true
          else begin
            if Arb.A[p].dr <> 0 then ULStackE.Push(Arb.A[p].dr);
            if Arb.A[p].stg <> 0
              then p := Arb.A[p].stg
              else p := ULStackE.Pop
          end;
      ULStackE.Elibereaza;
      Esec := not Gasit
    end; { CautaParinte }

  Procedure DealocaNod(p: Muchie; i: Integer);
    begin
      Arb.A[p].el.Cheie := 0;
      Arb.A[p].el.Info := 0;
      Arb.A[p].stg := 0;
      Arb.A[p].dr := Arb.PrimulLiber;
      Arb.PrimulLiber := p
    end; { DealocaNod }

  Procedure DealocaArbore(p: Muchie);
    var l: Integer;
    begin
      l := 0;
      PostOrdine(p, l+1, DealocaNod)
    end; { DealocaArbore }

  Procedure GenereazaNod(var p: NodAB);
    begin
      p.stg := 0;
      p.dr  := 0
    end; { GenereazaNod }

  Procedure Insereaza(e: ElementStandard; rel: Relativ; var Esec: Boolean);
    var p: NodAB;
        m: Muchie;
    begin
      Esec := False;
      p.el := e;
      GenereazaNod(p);
      { pozitia in tablou unde se introduce p }
      m := Arb.PrimulLiber;
      { lista de noduri libere este vida? }
      if m = 0 then begin
        Esec := true;       { da: esec }
        exit
      end;
      case rel of
        Radacina: if m = 1
                    then Arb.Radacina := 1
                    else Esec := true;
        FiuStang: if Arb.A[Arb.Cursor].stg = 0
                    then Arb.A[Arb.Cursor].stg := m
                    else Esec := true;
        FiuDrept: if Arb.A[Arb.Cursor].dr = 0
                    then Arb.A[Arb.Cursor].dr := m
                    else Esec := true;
        Parinte:  Esec := true
      end;
      if not Esec then begin
        { se scoate din lista nodurilor libere capul ei }
        Arb.PrimulLiber := Arb.A[Arb.PrimulLiber].dr;
        p.dr := 0;
        { pune p in tablou pe pozitia m }
        Arb.A[m] := p;
        { stabileste cursorul }
        Arb.Cursor := m;
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
        if Arb.A[p].stg = Arb.Cursor
          then Arb.A[p].stg := 0
          else Arb.A[p].dr  := 0;
      DealocaArbore(Arb.Cursor);
      If Arb.Cursor = Arb.Radacina
        then Arb.Radacina := 0;
      Arb.Cursor := Arb.Radacina
    end; { StergeSubArbore }

  Procedure Modifica(e: ElementStandard);
    begin
      Arb.A[Arb.Cursor].el := e
    end; { Modifica }

  Procedure Extrage(var e: ElementStandard);
    begin
      e := Arb.A[Arb.Cursor].el
    end; { Extrage }

  Procedure Traverseaza(Ord: Ordine; proc: ProcessProcA);
    var l: Integer;
    begin
      l := 0;
      case Ord of
        UDecl.PreOrdine:  PreOrdine(Arb.Radacina, l+1, proc);
        UDecl.InOrdine:   InOrdine(Arb.Radacina, l+1, proc);
        UDecl.PostOrdine: PostOrdine(Arb.Radacina, l+1, proc);
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
        InOrdine(Arb.Radacina, 1, Numara);
        ap := tpl / sz
      end else ap := 0;
      st.Dimensiune := sz;
      st.Inaltime := ht;
      st.DrumMediu := ap
    end; { Caracteristici }

  Procedure Cauta(rel: Relativ; var Esec: Boolean);
    var p: Muchie;
    begin
      Esec := false;
      case rel of
        Radacina: Arb.Cursor := Arb.Radacina;
        FiuStang: if Arb.A[Arb.Cursor].stg <> 0
                    then Arb.Cursor := Arb.A[Arb.Cursor].stg
                    else Esec := true;
        FiuDrept: if Arb.A[Arb.Cursor].dr <> 0
                    then Arb.Cursor := Arb.A[Arb.Cursor].dr
                    else Esec := true;
        Parinte:  begin
                    CautaParinte(p, Esec);
                    if not Esec then Arb.Cursor := p
                  end;
      end;
    end; { Cauta }

  Function Vid: Boolean;
    begin
      Vid := (Arb.Radacina = 0)
    end; { Vid }

  Procedure Creeaza;
    var i: Muchie;
    begin
      Arb.Radacina := 0;
      Arb.Cursor := 0;
      { creeaza lista nodurilor libere = tot tabloul }
      for i := 1 to DimensiuneArbore-1 do Arb.A[i].dr := i+1;
      Arb.A[DimensiuneArbore].dr := 0;
      { capul listei nodurilor libere }
      Arb.PrimulLiber := 1
    end; { Creeaza }

  Procedure Elibereaza;
    begin
      DealocaArbore(Arb.Radacina);
      Creeaza
    end; { Elibereaza }

  Procedure Afiseaza;
    var Esec: Boolean;
    begin
{      WAIPrint(Arb, Arb.Radacina, 0)}
      VAIPrint(Arb, Arb.Radacina, 20, Esec);
      Caracteristici(St);
      WriteLn('Dimensiune: ', St.Dimensiune:7);
      WriteLn('Inaltime:   ', St.Inaltime:7);
      WriteLn('Drum mediu: ', St.DrumMediu:7:2);
    end; { Afiseaza }

{$F-}
End. { unit UABGen }

