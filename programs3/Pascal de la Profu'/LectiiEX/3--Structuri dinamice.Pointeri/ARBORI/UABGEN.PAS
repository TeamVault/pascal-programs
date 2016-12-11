Unit UABGen;
{$F+}

Interface
  Uses UDecl;

  Procedure Insereaza(e: ElementStandard; Rel: Relativ; var Esec: Boolean);
  Procedure StergeSubArbore;
  Procedure Modifica(e: ElementStandard);
  Procedure Extrage(var e: ElementStandard);
  Procedure Traverseaza(ord: Ordine; proc: ProcessProc);
  Procedure Caracteristici(var St: Stare);
  Procedure Cauta(Rel: Relativ; var Esec: Boolean);
  Function Vid: Boolean;
  Procedure Creeaza;
  Procedure Elibereaza;
  Procedure Afiseaza;

  Procedure SetRadacina(p: Pointer);
  Procedure SetCursor(p: Pointer);
  Function GetRadacina: Pointer;
  Function GetCursor: Pointer;

Implementation
  Uses ULStackP, UABPrint;

type
  ABG = record
    Radacina, Cursor: PNodArbore
  end;

  var Arb: ABG;
      St: Stare;
    var
      ht, sz, lc: Integer;
      ap, tpl: Real;

  Procedure SetRadacina(p: Pointer);
    begin
      Arb.Radacina := PNodArbore(p)
    end; { SetRadacina }

  Procedure SetCursor(p: Pointer);
    begin
      Arb.Cursor := PNodArbore(p)
    end; { SetCursor }

  Function GetRadacina: Pointer;
    begin
      GetRadacina := Arb.Radacina
    end; { GetRadacina }

  Function GetCursor: Pointer;
    begin
      GetCursor := Arb.Cursor
    end; { GetCursor }

  Procedure PreOrdine(p: Pointer; l: Integer; proc: ProcessProc);
    begin
      if p <> Nil then begin
        proc(p, l);
        PreOrdine(PNodArbore(p)^.Stg, l+1, proc);
        PreOrdine(PNodArbore(p)^.Dr, l+1, proc);
      end;
    end; { PreOrdine }

  Procedure InOrdine(p: Pointer; l: Integer; proc: ProcessProc);
    begin
      if p <> Nil then begin
        InOrdine(PNodArbore(p)^.Stg, l+1, proc);
        proc(p, l);
        InOrdine(PNodArbore(p)^.Dr, l+1, proc);
      end;
    end; { InOrdine }

  Procedure PostOrdine(p: Pointer; l: Integer; proc: ProcessProc);
    begin
      if p <> Nil then begin
        PostOrdine(PNodArbore(p)^.Stg, l+1, proc);
        PostOrdine(PNodArbore(p)^.Dr, l+1, proc);
        proc(p, l);
      end;
    end; { PostOrdine }

  Procedure GenereazaNod(var p: PNodArbore);
    begin
      new(p);
      p^.Stg := Nil;
      p^.Dr  := Nil
    end; { GenereazaNod }

  Procedure CautaParinte(var p: PNodArbore; var Esec: Boolean);
    var Gasit: Boolean;
    { traverseaza in preordine arborele }
    begin
      ULStackP.Creeaza;
      Gasit := false;
      p := Arb.Radacina;
      while (p <> Nil) and (not Gasit) do
        if (p^.Stg = Arb.Cursor) or (p^.Dr = Arb.Cursor)
          then Gasit := true
          else begin
            if p^.Dr <> Nil then ULStackP.Push(p^.Dr);
            if p^.Stg <> Nil
              then p := p^.Stg
              else p := ULStackP.Pop   { nu mai e nevoie de cast }
          end;
      ULStackP.Elibereaza;
      Esec := not Gasit
    end; { CautaParinte }

  Procedure DealocaNod(p: Pointer; i: Integer);
    begin
      Dispose(PNodArbore(p))
    end; { DealocaNod }

  Procedure DealocaArbore(p: PNodArbore);
    var l: Integer;
    begin
      l := 0;
      PostOrdine(p, l+1, DealocaNod)
    end; { DealocaArbore }

  Procedure Insereaza(e: ElementStandard; Rel: Relativ; var Esec: Boolean);
    var p: PNodArbore;
    begin
      Esec := False;
      GenereazaNod(p);
      p^.el := e;
      case Rel of
        Radacina: If Vid
                    then Arb.Radacina := p
                    else Esec := True;
        FiuStang: if Arb.Cursor^.Stg = Nil
                    then Arb.Cursor^.Stg := p
                    else Esec := true;
        FiuDrept: if Arb.Cursor^.Dr = Nil
                    then Arb.Cursor^.Dr := p
                    else Esec := true;
        Parinte:  Esec := true
      end;
      if Esec
        then Dispose(p)
        else Arb.Cursor := p;
    end; { Insereaza }

  Procedure StergeSubArbore;
    var
      p: PNodArbore;
      Esec: Boolean;
    begin
      p := Arb.Cursor;
      CautaParinte(p, Esec);
      if not Esec then
        if p^.Stg = Arb.Cursor
          then p^.Stg := Nil
          else p^.Dr  := Nil;
      DealocaArbore(Arb.Cursor);
      If Arb.Cursor = Arb.Radacina
        then Arb.Radacina := Nil;
      Arb.Cursor := Arb.Radacina
    end; { DeleteSub }

  Procedure Modifica(e: ElementStandard);
    begin
      Arb.Cursor^.el := e
    end; { Modifica }

  Procedure Extrage(var e: ElementStandard);
    begin
      e := Arb.Cursor^.el
    end; { Extrage }

  Procedure Traverseaza(ord: Ordine; proc: ProcessProc);
    var l: Integer;
    begin
      l := 0;
      case ord of
        UDecl.PreOrdine:  PreOrdine(Arb.Radacina, l+1, proc);
        UDecl.InOrdine:   InOrdine(Arb.Radacina, l+1, proc);
        UDecl.PostOrdine: PostOrdine(Arb.Radacina, l+1, proc);
      end;
    end; { Traverseaza }

  Procedure Numara(p: Pointer; i: Integer);
    begin
      sz := sz + 1;
      tpl := tpl + i;
      if ht < i then ht := i;
    end; { Numara }

  Procedure Caracteristici(var St: Stare);
    begin
      sz := 0;
      ht := 0;
      tpl := 0;
      if not Vid then begin
        InOrdine(Arb.Radacina, 1, Numara);
        ap := tpl / sz
      end else ap := 0;
      St.Dimensiune := sz;
      St.Inaltime := ht;
      St.DrumMediu := ap
    end; { Caracteristici }

  Procedure Cauta(Rel: Relativ; var Esec: Boolean);
    var p: PNodArbore;
    begin
      Esec := false;
      case Rel of
        Radacina: Arb.Cursor := Arb.Radacina;
        FiuStang: if Arb.Cursor^.Stg <> Nil
                    then Arb.Cursor := Arb.Cursor^.Stg
                    else Esec := true;
        FiuDrept: if Arb.Cursor^.Dr <> Nil
                    then Arb.Cursor := Arb.Cursor^.Dr
                    else Esec := true;
        Parinte:  begin
                    CautaParinte(p, Esec);
                    if not Esec then Arb.Cursor := p
                  end;
      end;
    end; { Cauta }

  Function Vid: Boolean;
    begin
      Vid := (Arb.Radacina = Nil)
    end; { Vid }

  Procedure Creeaza;
    begin
      Arb.Radacina := Nil;
      Arb.Cursor := Nil
    end; { Creeaza }

  Procedure Elibereaza;
    begin
      DealocaArbore(Arb.Radacina);
      Creeaza
    end; { Elibereaza }

  Procedure Afiseaza;
    var Esec: Boolean;
    begin
{      WPrint(Arb.Radacina, 0)}
      VPrint(Arb.Radacina, 20, Esec);
      Caracteristici(St);
      WriteLn('Dimensiune: ', St.Dimensiune:7);
      WriteLn('Inaltime:   ', St.Inaltime:7);
      WriteLn('Drum mediu: ', St.DrumMediu:7:2);
    end; { Afiseaza }
{$F-}
End. { unit UABGen }

