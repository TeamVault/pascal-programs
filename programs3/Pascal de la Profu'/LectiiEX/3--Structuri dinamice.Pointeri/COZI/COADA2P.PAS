Program Coada2P;
{ program de lucru cu coada, varianta procedurala
  coada este implementata ca lista inlantuita
  }

type
  TElement = Integer;
  PNod = ^Nod;
  Nod = Record
    Spatiu : TElement;
    Urm: PNod;
  End;
  Coada = Record
    Inceput, Sfarsit: PNod
  End;

var
  C: Coada;

Procedure Eroare(M: String);
  begin
    Write('Eroare: ',M);
    ReadLn;
    Halt
  end;

{ implementarea operatiilor cozii }

Function Vida: Boolean;
  begin
    Vida := C.Inceput = Nil;
  end; { Vida }

Function Plina: Boolean;
  begin
    Plina := MemAvail = 0
  end; { Plina }

Procedure Adauga(E:TElement);
  var
    p: PNod;
  begin
    if Plina then Eroare('coada plina');
    New(p);               { genereaza un nod nou }
    p^.Spatiu := E;       { pune in el informatia utila }
    p^.Urm := Nil;
    If Vida then begin    { coada vida }
      C.Inceput := p;
      C.Sfarsit := p
    end else begin        { adauga pe p la sfarsit }
      C.Sfarsit^.Urm := p;
      C.Sfarsit := p
    end;
  end; { Adauga }

Procedure Scoate(var E:TElement);
  var
    p: PNod;
  begin
    if Vida then Eroare('coada goala');
    p := C.Inceput;
    E := p^.Spatiu;
    C.Inceput := C.Inceput^.Urm;
    Dispose(p)
  end; { Scoate }

Procedure Primul(var E:TElement);
  begin
    if Vida then Eroare('coada goala');
    E := C.Inceput^.Spatiu;
  end; { Primul }

Procedure Ultimul(var E:TElement);
  begin
    if Vida then Eroare('coada goala');
    E := C.Sfarsit^.Spatiu;
  end; { Ultimul }

Procedure Init;
  begin
    C.Inceput := Nil;
    C.Sfarsit := Nil
  end; { Init }

Procedure Term;
  var
    E: TElement;
  begin
    while not Vida do Scoate(E);
  end; { Term }

Procedure List;
  var
    P: PNod;
  begin
    if Vida then WriteLn('coada vida')
    else with C do begin
      p := Inceput;
      while p <> Nil do begin
        Write(p^.Spatiu, '  ');
        p := p^.Urm
      end;
      WriteLn
    end;
  end; { List }

{$I operatp.pas}

{$I coadap.run}

Begin
  WriteLn('Coada2P - Coada varianta procedurala, lista inlantuita, variabila globala');
  Run
End. { Coada2P }

