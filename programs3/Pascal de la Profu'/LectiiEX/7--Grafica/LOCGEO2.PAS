Program LocGeo2;

{ traseaza locul geometric al mijloacelor segmentelor de lungime data
  cu capetele pe doua semidrepte perpendiculare
  semidreptele sunt in cazul nostru ramurile pozitive ale celor doua axe de
  coordonate, adica Ox si Oy unde O este originea (0,0)

                       ³
                      B´(0, LungimeSegment)
                       ³
                      N´(0, y)
                       ³
                       ³
                       ÅÄÄÄÄÄÄÂÄÄÄÂÄÄÄÄ
                     O(0,0)   M   A(LungimeSegment, 0)
                            (x, 0)

  Lungimea L a unui segment PQ din plan P(u1, v1) si Q(u2, v2) este

      L^2 = (u2 - u1)^2 + (v2 - v1)^2

  Lungimea L a segmentului MN din plan M(x, 0) si N(0, y) este:

      L^2 = x^2 + y^2

  Mijlocul R al unui segment PQ din plan P(u1, v1) si Q(u2, v2) este
  de coordonate (uR, vR):

    uR = (u1 + u2) / 2, vR = (v1 + v2) / 2

  Mijlocul C al segmentului MN este de coordonate (uC, vC):

    uC = x / 2, vC = y / 2

  Metoda:
    Segmentele care se iau in considerare sunt
      - segmentul OA de pe axa Ox
      - segmentul OB de pe axa Oy
      - segmentul MN cu MîOA si NîOB de lungime constanta LungimeSegment.
    Lungimea ambelor segmente OA si OB este tot LungimeSegment (constanta)
    deoarece in cazurile extreme segmentul MN de lungime egala cu
    LungimeSegment care aluneca pe OA si OB va fi
      - chiar OA (cand M ð O)
      - chiar OB (cand M ð A)
    Punctul A are coordonatele (LungimeSegment, 0)
    Punctul B are coordonatele (0, LungimeSegment)

    Segmentul de lungime data este MN, unde MîOA si NîOB. Trebuie ca
    lungimea lui MN sa fie constanta (egala cu LungimeSegment)
    si atunci vom proceda astfel
      - se ia punctul MîOA, de coordonate (x, 0)  0 <= x <= LungimeSegment
      - punctul N (0, y) se calculeaza in functie de x din relatia:

         Lungime(MN) = LungimeSegment
         x^2 + y^2 = LungimeSegment^2
         y^2 = LungimeSegment^2 - x^2   relatia de calcul

      - mijlocul segmentului MN are coordonatele (x/2, y/2), care se pot
        acum trasa

    Pentru ilustrarea problemei, se traseaza si axele de coordonate
    (adica de fapt segmentele OA si OB).

}

  Uses UGraph, Graph;

  Const
    LungimeSegment = 100.0;

    Pas = 0.02; { pasul real cu care se considera punctele }
    NumarPuncte = Round(LungimeSegment / Pas) + 1;

  Var
    LocG: array[1..NumarPuncte] of TPunctEcran;

  Procedure DeseneazaLoc(u1, v1, u2, v2: Integer; decupare: Boolean);
    Var
      { coordonate reale }
      x: Real;    { punctul M de pe axa Ox este de coordonate (x, 0 }
      y: Real;    { punctul N de pe axa Oy este de coordonate (0, y)
                    y se calculeaza astfel ca distanta de la (x, 0) la (0, y)
                    sa fie LungimeSegment }
      { coordonate punct in fereastra fizica }
      uM,           { punctul M de pe OA }
      vM,
      uN,           { punctul N de pe OB }
      vN,
      uC,           { C este mijlocul segmentului MN }
      vC: Integer;
      n: Integer;   { numarul de puncte calculate }
      i: Integer;   { indice }
    begin
      SetViewPort(u1, v1, u2, v2, decupare);
      { citeste coordonatele ferestrei fizice
        sunt necesare pentru transformarile de coordonate
      }
      GetViewPort;
      { punctul x parcurge segmentul OA de pe axa Ox }
      x := 0;
      n := 0;
      Repeat
         { ascunde segmentul anterior
         if x <> 0 then begin
          SetColor(GetBkColor);
          Line(uM+1, vM+1, uN-1, vN-1);
        end; }
        { calculeaza pe y }
        y := Sqrt(Sqr(LungimeSegment) - Sqr(x));
        { calculeaza coordonatele ecran }
        RealToViewPort(x, 0, uM, vM);       { (uM, vM) sunt coordonate fizice }
        RealToViewPort(x/2, y/2, uC, vC);   { (uC, vC) sunt coordonate fizice }
        RealToViewPort(0, y, uN, vN);       { (uN, vN) sunt coordonate fizice }
        { traseaza segmentul MN }
        if x <> LungimeSegment then begin
          SetColor(Red);
          Line(uM+1, vM+1, uN-1, vN-1);
        end;
        { traseaza punctul M(x, 0) de pe segmentul OA cu galben }
        PutPixel(uM, vM, Yellow);
        { pune mijlocul segmentului in LocG }
        n := n + 1;
        LocG[n].X := uC;
        LocG[n].Y := vC;
        { traseaza punctul N(0, y) de pe segmentul OB cu galben }
        PutPixel(uN, vN, Yellow);
        { mareste pe x }
        x := x + Pas
      Until x > LungimeSegment;
      { traseaza C - mijlocul segmentului MN(x/2, y/2) cu alb }
      For i := 1 to n do
        PutPixel(LocG[i].X, LocG[i].Y, White);
    end; { PLocGeo }

  begin
    InitGr;    { initializeaza modul grafic }
    SetRealWindow(0, LungimeSegment, 0, LungimeSegment);
    DeseneazaLoc(  0,   0, 200, 200, True);  { stanga sus }
    DeseneazaLoc(250,   0, 350, 200, True);  { centru sus }
    DeseneazaLoc(400,   0, 600, 200, True);  { dreapta sus }
    DeseneazaLoc(  0, 250, 200, 350, True);  { stanga jos }
    DeseneazaLoc(250, 250, 300, 350, True);  { centru jos }
    DeseneazaLoc(400, 250, 400, 250, False); { dreapta jos }
    ReadLn;
    CloseGraph { termina modul grafic }
  end. { LocGeo2 }