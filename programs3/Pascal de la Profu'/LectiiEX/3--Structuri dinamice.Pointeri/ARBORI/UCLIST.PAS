Unit UCList;

Interface
  Uses UDecl;

  Procedure Creeaza;
  Procedure Insereaza(e: ElementStandard);
  Procedure Sterge;
  Procedure Extrage(var e: ElementStandard);
  Procedure Modifica(e: ElementStandard);
  Procedure Primul;
  Procedure Urmatorul(var fail: Boolean);
  Function Vida: Boolean;
  Procedure Elibereaza;
  Procedure Afiseaza(M: String);

Implementation

  type
    ptr = ^node;
    node = record
      el: ElementStandard;
      urm: ptr
    end;

  var
    coada, cursor: ptr;

  Procedure Creeaza;
    begin
      coada := nil;
      cursor := nil
    end; { Creeaza }

  Procedure Insereaza(e: ElementStandard);
    var          { inserare in cap; elementul curent este cel inserat }
      p: ptr;
    begin
      new(p);
      p^.el := e;
      if coada = nil
        then coada := p
        else p^.urm := coada^.urm;
      coada^.urm := p;
      cursor := p
    end; { Insereaza }

  Procedure Sterge;
    var          { sterge elementul curent }
      p: ptr;
    begin
      if cursor^.urm = cursor then begin
        dispose(cursor);
        coada := nil;
        exit
      end;
      if cursor <> coada^.urm then begin
        p := coada^.urm;
        while p^.urm <> cursor do p := p^.urm;
        p^.urm := cursor^.urm
      end else coada^.urm := cursor^.urm;
      dispose(cursor);
      cursor := coada^.urm;
    end; { Sterge }

  Procedure Extrage(var e: ElementStandard);
    begin
      e := cursor^.el
    end; { Extrage }

  Procedure Modifica(e: ElementStandard);
    begin
      cursor^.el := e
    end; { Modifica }

  Procedure Primul;
    begin
      cursor := coada^.urm
    end; { Primul }

  Procedure Urmatorul(var fail: Boolean);
    begin
      fail := false;
      if cursor^.urm <> coada^.urm
        then cursor := cursor^.urm
        else fail := true;
    end; { Urmatorul }

  Function Vida: Boolean;
    begin
      if coada = nil
        then Vida := true
        else Vida := false
    end; { Vida }

  Procedure Elibereaza;
    begin
      Primul;
      while not Vida do Sterge;
    end; { Elibereaza }

  Procedure Afiseaza(M: String);
    var
      p: ptr;
      f: Boolean;
      e: ElementStandard;
    begin
      WriteLn(M);
      if Vida then begin
        WriteLn('Lista vida');
        Exit
      end;
      p := cursor;    { salveaza cursorul }
      Extrage(e);
      WriteLn('Elementul curent este: ', ElementStandardToString(e));
      f := false;
      Primul;
      Repeat
        Extrage(e);
        WriteLn(ElementStandardToString(e));
        Urmatorul(f);
      Until f;
      cursor := p     { restaureaza cursorul }
    end; { Afiseaza }
end. { UCList }