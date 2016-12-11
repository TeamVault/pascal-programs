Program Hanoi2;

  { Problema turnurilor din Hanoi - Greedy }
  {Pe o tija sunt asezate n discuri in ordine}
  {descrescatoare a diametrelor lor.Se cere sa se mute toate discurile}
  {pe o alta tija, folosind o a treia tija auxiliara, exact in aceeasi}
  {ordine. Singura mutare permisa este aceea de a aseza un disc de pe}
  {o tija pe alta respectandu-se intotdeauna ordinea descrescatoare}
  {a diametrelor discurilor aflate pe fiecare tija}
Uses Crt;

Const
  MaxMutari = 2000;
type
  Mutare = record
    depe,
    pe:   1..3
  end;
  Solutie = Array[1..MaxMutari] of Mutare;

var
  numarMutari: Integer;
  numarDiscuri: Integer;
  Rezolvare: Solutie;

function StrI(i: Integer): String;
  var
    s: String;
  begin
    if i = 0 then begin
      StrI := '0';
      Exit
    end;
    Str(i:10, s);
    while (s[1] = ' ') and (length(s) > 0) do Delete(s, 1, 1);
    StrI := s
  end; { StrI }

function MutareToString(m: Mutare): String;
  begin
    MutareToString := '(' +
                      StrI(m.depe) + ',' +
                      StrI(m.pe) +
                      ')'
  end; { MutareToString }

Procedure MutaDisc(a, b: Integer);
  { realizeaza mutarea discului din varful tijei 'a' pe tija 'b'
    aici se adauga la solutie perechea (a, b)
  }
  begin
    numarMutari := numarMutari + 1;
    with Rezolvare[numarMutari] do begin
      depe := a;
      pe   := b
    end;
  end; { MutaDisc }
Procedure Hanoi(n:Integer;a,b,c: Integer);
{ muta n discuri de pe tija 'a' pe tija 'b'
  folosind tija auxiliara 'c'
  avem relatia: a+b+c = 6 (ca indici de tije) din care rezulta
    a = 6 - b - c
    b = 6 - a - c
    c = 6 - a - b
}

begin
  if n > 0 then begin
    c := 6 - a - b;
    Hanoi(n-1, a, c);
    { aici are loc mutarea discului ramas din 'a' in 'b' }
    MutaDisc(a, b);
    Hanoi(n-1, c, b)
  end;
end;

procedure AfiseazaSolutie;
  var
    i: Integer;
    s: String;
  begin
    s := '';
    for i := 1 to numarMutari do begin
      s := s + MutareToString(Rezolvare[i]);
      if length(s) > 60 then begin
        WriteLn(s);
        s := '';
      end;
    end;
    if length(s) > 0 then WriteLn(s);
    WriteLn('Au fost necesare ', numarMutari, ' mutari')
  end; { AfiseazaSolutie }

begin
  ClrScr;
  WriteLn('Hanoi2 - problema turnurilor din Hanoi rezolvata clasic');
  Write('Cate discuri: ');
  ReadLn(numarDiscuri);
  numarMutari := 0;
  Hanoi(numarDiscuri, 1, 3);
  AfiseazaSolutie;
  ReadLn
end.