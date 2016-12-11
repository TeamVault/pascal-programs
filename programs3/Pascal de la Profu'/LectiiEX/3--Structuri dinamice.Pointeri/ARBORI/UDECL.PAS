Unit UDecl;

Interface
type
  TipCheie = Integer;
  TipInfo = Integer;
  ElementStandard = record
    Cheie: TipCheie;
    Info: TipInfo
  end;
  Stare = Record
    Dimensiune: Integer;
    Inaltime: Integer;
    DrumMediu: Real
  End;
  Ordine = (PreOrdine, InOrdine, PostOrdine);
  Relativ = (Radacina, FiuStang, FiuDrept, Parinte);

{ pentru UABGen }
  PNodArbore = ^NodArbore;
  NodArbore = Record
    el: ElementStandard;
    stg, dr: PNodArbore
  end;
  ProcessProc = procedure(p: Pointer; i: Integer);

{ pentru UABGenA si UABGenAI }
Const
  DimensiuneArbore = 1000;
  NodulZero: ElementStandard = (Cheie:0; Info:0);
type
  Muchie = 0..DimensiuneArbore;
  ProcessProcA = procedure(p: Muchie; i: Integer);

{ pentru UABGenA }
  Node = ElementStandard;

{ pentru UABGenAI }
  NodAB = Record
    el: ElementStandard;
    stg, dr: Muchie
  end;
  
  Function ElementStandardToString(e: ElementStandard): String;
  Procedure CreeazaElementStandard(k: TipCheie; i: TipInfo; var e: ElementStandard);
  Function PointerToString(e: Pointer): String;
  Function MuchieToString(e: Muchie): String;
  Procedure PrintNod(p: PNodArbore);
  Procedure PrintANod(p: Node);
  Procedure PrintSpatiu;
  Procedure LinieNoua;
  Procedure PaginaNoua;
  Function ZeroElem(e: ElementStandard): Boolean;

Implementation
  Uses UGen, Crt;

  Function ElementStandardToString(e: ElementStandard): String;
    begin
      ElementStandardToString := StrI(e.Cheie) + ',' + StrI(e.Info)
    end; { StdElemToString }

  Function PointerToString(e: Pointer): String;
    begin
      PointerToString := StrI(Seg(e)) + ':' + StrI(Ofs(e))
    end; { PointerToString }

  Function MuchieToString(e: Muchie): String;
    begin
      MuchieToString := StrI(e)
    end; { MuchieToString }

  Procedure CreeazaElementStandard(k: TipCheie; i: TipInfo; var e: ElementStandard);
    begin
      e.Cheie := k;
      e.Info := i
    end; { Create ElementStandard }

  Procedure Process(p: Pointer);
    begin
    end; { Process }

  Procedure ProcessA(p: Muchie);
    begin
    end; { ProcessA }

  Procedure PrintNod(p: PNodArbore);
    begin
      Write(p^.el.Cheie:3)
    end; { PrintNod }

  Procedure PrintANod(p: Node);
    begin
      Write(p.Cheie:3)
    end; { PrintANod }

  Procedure PrintSpatiu;
    begin
      Write('   ')
    end; { PrintSpatiu }

  Procedure LinieNoua;
    begin
      WriteLn
    end; { LinieNoua }

  Procedure PaginaNoua;
    begin
      ReadLn;
      ClrScr;
    end; { PaginaNoua }

  Function ZeroElem(e: ElementStandard): Boolean;
    begin
      ZeroElem := (e.Cheie = 0) and (e.Info = 0)
    end; { ZeroElem }

end.
