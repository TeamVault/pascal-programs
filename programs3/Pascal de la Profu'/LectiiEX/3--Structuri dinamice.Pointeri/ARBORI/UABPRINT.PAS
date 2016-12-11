Unit UABPrint;

Interface
  Uses UDecl, UABGenA, UABGenAI;

  Procedure VPrint(p: PNodArbore; pw: Integer; var Esec: Boolean);
  Procedure VAPrint(var A: UABGenA.ABG; p: Muchie; pw: Integer; var Esec: Boolean);
  Procedure VAIPrint(var A: UABGenAI.ABG; p: Muchie; pw: Integer; var Esec: Boolean);
  Procedure WPrint(p: PNodArbore; Nivel: Integer);
  Procedure WAPrint(var A: UABGenA.ABG; p: Muchie; Nivel: Integer);
  Procedure WAIPrint(var A: UABGenAI.ABG; p: Muchie; Nivel: Integer);

Implementation
  type
    PNodLista = ^NodLista;
    PNodListaA = ^NodListaA;
    PNodNivel = ^NodNivel;
    PNodNivelA = ^NodNivelA;
    NodNivel = record
      first: PNodLista;
      next:  PNodNivel;
    end;
    NodLista  = record
      pnode: Pointer;
      next:  PNodLista;
      pos:   Integer
    end;
    NodNivelA = record
      first: PNodListaA;
      next:  PNodNivelA;
    end;
    NodListaA  = record
      pnode: ElementStandard;
      next:  PNodListaA;
      pos:   Integer
    end;

    var
      k, minpos, maxpos: integer;
      entry: PNodNivel;
      entryA: PNodNivelA;

  Procedure StergeNivel(l: PNodNivel);
    var lp, lq: PNodNivel;
    begin
      lp := l;
      while lp <> nil do begin
        lq := lp^.next;
        Dispose(lp);
        lp := lq
      end;
    end; { StergeNivel }

  Procedure StergeNivelA(l: PNodNivelA);
    var lp, lq: PNodNivelA;
    begin
      lp := l;
      while lp <> nil do begin
        lq := lp^.next;
        Dispose(lp);
        lp := lq
      end;
    end; { StergeNivelA }

  Function Pozitie(p: PNodArbore; var lp: PNodNivel; pos: Integer): Integer;
    var list: PNodLista;

    Procedure InsereazaNivel(var lp: PNodNivel);
      begin
        New(lp);
        lp^.next := nil;
        lp^.first := nil
      end; { InsereazaNivel }

    Procedure InsereazaLista(lp: PNodNivel);
      begin
        New(list);
        list^.pnode := p;
        list^.next := lp^.first;
        lp^.first := list
      end; { InsereazaLista }

    begin
      if p = Nil then begin
        Pozitie := pos;
        exit
      end;
      if lp = Nil
        then InsereazaNivel(lp)
        else If (pos + 2) > lp^.first^.pos then pos := lp^.first^.pos - 2;
      InsereazaLista(lp);
      if p^.stg = Nil then
        pos := Pozitie(p^.dr, lp^.next, pos + 1) - 1
      else if p^.dr = Nil then
        pos := Pozitie(p^.stg, lp^.next, pos - 1) + 1
      else
        pos := (Pozitie(p^.stg, lp^.next, pos - 1) +
               Pozitie(p^.dr, lp^.next, pos + 1)) div 2;
      if pos > maxpos then maxpos := pos
      else if pos < minpos then minpos := pos;
      list^.pos := pos;
      Pozitie := pos
    end; { Pozitie }

  Function PozitieA(var A: UABGenA.ABG; p: Muchie; var lp: PNodNivelA; pos: Integer): Integer;
    var list: PNodListaA;

    Procedure InsereazaNivel(var lp: PNodNivelA);
      begin
        New(lp);
        lp^.next := nil;
        lp^.first := nil
      end; { InsereazaNivel }

    Procedure InsereazaLista(lp: PNodNivelA);
      begin
        New(list);
        list^.pnode := A.A[p];
        list^.next := lp^.first;
        lp^.first := list
      end; { InsereazaLista }

    begin
      if ZeroElem(A.A[p]) then begin
        PozitieA := pos;
        exit
      end;
      if lp = Nil
        then InsereazaNivel(lp)
        else If (pos + 2) > lp^.first^.pos then pos := lp^.first^.pos - 2;
      InsereazaLista(lp);
      if ZeroElem(A.A[SubarboreStang(p)]) then
        pos := PozitieA(A, UABGenA.SubarboreDrept(p), lp^.next, pos + 1) - 1
      else if ZeroElem(A.A[UABGenA.SubarboreDrept(p)]) then
        pos := PozitieA(A, UABGenA.SubarboreStang(p), lp^.next, pos - 1) + 1
      else
        pos := (PozitieA(A, UABGenA.SubarboreStang(p), lp^.next, pos - 1) +
               PozitieA(A, UABGenA.SubarboreDrept(p), lp^.next, pos + 1)) div 2;
      if pos > maxpos then maxpos := pos
      else if pos < minpos then minpos := pos;
      list^.pos := pos;
      PozitieA := pos
    end; { PozitieA }

  Function PozitieAI(var A: UABGenAI.ABG; p: Muchie; var lp: PNodNivelA; pos: Integer): Integer;
    var list: PNodListaA;

    Procedure InsereazaNivel(var lp: PNodNivelA);
      begin
        New(lp);
        lp^.next := nil;
        lp^.first := nil
      end; { InsereazaNivel }

    Procedure InsereazaLista(lp: PNodNivelA);
      begin
        New(list);
        list^.pnode := A.A[p].el;
        list^.next := lp^.first;
        lp^.first := list
      end; { InsereazaLista }

    begin
      if ZeroElem(A.A[p].el) then begin
        PozitieAI := pos;
        exit
      end;
      if lp = Nil
        then InsereazaNivel(lp)
        else If (pos + 2) > lp^.first^.pos then pos := lp^.first^.pos - 2;
      InsereazaLista(lp);
      if A.A[p].stg = 0 then
        pos := PozitieAI(A, A.A[p].dr, lp^.next, pos + 1) - 1
      else if A.A[p].dr = 0 then
        pos := PozitieAI(A, A.A[p].stg, lp^.next, pos - 1) + 1
      else
        pos := (PozitieAI(A, A.A[p].stg, lp^.next, pos - 1) +
               PozitieAI(A, A.A[p].dr, lp^.next, pos + 1)) div 2;
      if pos > maxpos then maxpos := pos
      else if pos < minpos then minpos := pos;
      list^.pos := pos;
      PozitieAI := pos
    end; { PozitieA }

  Procedure LLPrint(pw: Integer);
    var
      startpos, k: Integer;
      lp: PNodLista;
      Nivel: PNodNivel;
    begin
      startpos := minpos;
      while startpos <= maxpos do begin
        Nivel := entry;
        while Nivel <> Nil do begin
          k := startpos;
          lp := Nivel^.first;
          while (k < startpos + pw) and (lp <> nil) do begin
            if lp^.pos = k then begin
              PrintNod(lp^.pnode);
              Nivel^.first := lp^.next;
              dispose(lp);
              lp := Nivel^.first
            end else PrintSpatiu;
            k := k + 1
          end;
          LinieNoua;
          Nivel := Nivel^.next
        end;
        startpos := startpos + pw;
        {newpage}
      end;
      StergeNivel(entry);
    end; { LLPrint }

  Procedure LLPrintA(pw: Integer);
    var
      startpos, k: Integer;
      lp: PNodListaA;
      Nivel: PNodNivelA;
    begin
      startpos := minpos;
      while startpos <= maxpos do begin
        Nivel := entryA;
        while Nivel <> Nil do begin
          k := startpos;
          lp := Nivel^.first;
          while (k < startpos + pw) and (lp <> nil) do begin
            if lp^.pos = k then begin
              PrintANod(lp^.pnode);
              Nivel^.first := lp^.next;
              dispose(lp);
              lp := Nivel^.first
            end else PrintSpatiu;
            k := k + 1
          end;
          LinieNoua;
          Nivel := Nivel^.next
        end;
        startpos := startpos + pw;
        {newpage}
      end;
      StergeNivelA(entryA);
    end; { LLPrintA }

  Procedure VPrint(p: PNodArbore; pw: Integer; var Esec: Boolean);
    var i: Integer;
    begin
      if p = Nil then begin
        Esec := true;
        exit
      end;
      Esec := false;
      entry := nil;
      minpos := 0;
      maxpos := 0;
      k := Pozitie(p, entry, 0);
      for i := 1 to k do PrintSpatiu;
      LLPrint(pw);
    end; { VPrint }

  Procedure VAPrint(var A: UABGenA.ABG; p: Muchie; pw: Integer; var Esec: Boolean);
    var i: Integer;
    begin
      if p = 0 then begin
        Esec := true;
        exit
      end;
      Esec := false;
      entryA := nil;
      minpos := 0;
      maxpos := 0;
      k := PozitieA(A, p, entryA, 0);
      for i := 1 to k do PrintSpatiu;
      LLPrintA(pw);
    end; { VAPrint }

  Procedure VAIPrint(var A: UABGenAI.ABG; p: Muchie; pw: Integer; var Esec: Boolean);
    var i: Integer;
    begin
      if p = 0 then begin
        Esec := true;
        exit
      end;
      Esec := false;
      entryA := nil;
      minpos := 0;
      maxpos := 0;
      k := PozitieAI(A, p, entryA, 0);
      for i := 1 to k do PrintSpatiu;
      LLPrintA(pw);
    end; { VAIPrint }

  Procedure WPrint(p: PNodArbore; Nivel: Integer);
    var k: Integer;
    { traversare in inordine }
    begin
      if p <> Nil then begin
        { subarborele stang }
        WPrint(p^.dr, Nivel + 1);
        { prelucrarea din nodul curent }
        for k := 1 to Nivel do PrintSpatiu;
        PrintNod(p);
        LinieNoua;
        { subarborele drept }
        WPrint(p^.stg, Nivel + 1);
      end;
    end; { WPrint }

  Procedure WAPrint(var A: UABGenA.ABG; p: Muchie; Nivel: Integer);
    var k: Integer;
    begin
      if p <> 0 then begin
        WAPrint(A, SubarboreStang(p), Nivel + 1);
        for k := 1 to Nivel do PrintSpatiu;
        PrintANod(A.A[p]);
        LinieNoua;
        WAPrint(A, SubarboreDrept(p), Nivel + 1);
      end;
    end; { WAPrint }

  Procedure WAIPrint(var A: UABGenAI.ABG; p: Muchie; Nivel: Integer);
    var k: Integer;
    begin
      if p <> 0 then begin
        WAIPrint(A, A.A[p].stg, Nivel + 1);
        for k := 1 to Nivel do PrintSpatiu;
        PrintANod(A.A[p].el);
        LinieNoua;
        WAIPrint(A, A.A[p].dr, Nivel + 1);
      end;
    end; { WAIPrint }
end.