Unit UListE;

Interface
  Uses UDecl;

  Procedure Creeaza;
  Procedure Insereaza(e: Muchie);
  Procedure Sterge;
  Procedure Extrage(var e: Muchie);
  Procedure Modifica(e: Muchie);
  Procedure Primul;
  Procedure Urmatorul(var esec: Boolean);
  Function Vida: Boolean;
  Procedure Elibereaza;
  Procedure Afiseaza(M: String);

Implementation

  type
    ptr = ^node;
    node = record
      el: Muchie;
      urm: ptr
    end;

  var
    cap, cursor: ptr;

  Procedure Creeaza;
    begin
      cap := nil;
      cursor := nil
    end; { Creeaza }

  Procedure Insereaza(e: Muchie);
    var          { inserare in cap; elementul curent este cel inserat }
      p: ptr;
    begin
      new(p);
      p^.el := e;
      p^.urm := cap;
      cap := p;
      cursor := p
    end; { Insereaza }

  Procedure Sterge;
    var          { sterge elementul curent }
      p: ptr;
    begin
      if cursor <> cap then begin
        p := cap;
        while p^.urm <> cursor do p := p^.urm;
        p^.urm := cursor^.urm
      end else cap := cap^.urm;
      dispose(cursor);
      cursor := cap
    end; { Sterge }

  Procedure Extrage(var e: Muchie);
    begin
      e := cursor^.el
    end; { Extrage }

  Procedure Modifica(e: Muchie);
    begin
      cursor^.el := e
    end; { Modifica }

  Procedure Primul;
    begin
      cursor := cap
    end; { Primul }

  Procedure Urmatorul(var esec: Boolean);
    begin
      esec := false;
      if cursor^.urm <> nil
        then cursor := cursor^.urm
        else esec := true;
    end; { Urmatorul }

  Function Vida: Boolean;
    begin
      if cap = nil
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
      e: Muchie;
    begin
      WriteLn(M);
      if Vida then begin
        WriteLn(M + ' vida');
        Exit
      end;
      p := cursor;    { salveaza cursorul }
      Extrage(e);
      WriteLn('Elementul curent este: ', MuchieToString(e));
      f := false;
      Primul;
      Repeat
        Extrage(e);
        WriteLn(MuchieToString(e));
        Urmatorul(f);
      Until f;
      cursor := p     { restaureaza cursorul }
    end; { Afiseaza }
end.