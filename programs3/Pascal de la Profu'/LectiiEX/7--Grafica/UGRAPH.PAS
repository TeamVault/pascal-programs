Unit UGraph;
Interface

type
  TPunctReal = record
    X,
    Y: Real;
  end;
  TPunctEcran = record
    X,
    Y: Integer;
  end;
  procedure InitGr;
  function CeDirectie(var DirX,DirY : ShortInt) : Boolean;
  procedure OutTextLN(S:String);
  procedure RotestePunct(var x,y:Integer; cx,cy,unghi:Integer);
  procedure SetRealWindow(ra, rb, rc, rd: Real);
  procedure GetViewPort;
  procedure RealToViewPort(x, y: Real; var u, v: Integer);
  Procedure PieInt(var A: array of integer; cx, cy, raza: Integer);
Implementation
  Uses
    Graph,Crt;
  Const
    CaleBGI = 'c:\BP\BGI';   { calea spre directorul unde se gasesc
                                 driver-ele }
  Type
    TFereastraReala = record
      { fereastra reala: domeniul D al planului real }
      a, b,            { abscisa minima si maxima }
      c, d: Real;      { ordonata minima si maxima }
    end;
  Var
    DriverGrafic,
    ModGrafic : Integer;

    { fereastra reala }
    FereastraReala: TFereastraReala;
    { fereastra fizica }
    FereastraFizica: ViewPortType;

  Procedure SetRealWindow(ra, rb, rc, rd: Real);
   { seteaza coordonatele ferestrei reale
     aceste coordonate se vor folosi la transformarea coordonatelor
     din domeniul D al planului real (fereastra reala) la
     fereastra fizica }
    begin
      with FereastraReala do begin
        a := ra;
        b := rb;
        c := rc;
        d := rd;
      end
    end; { SetRealWindow }

  procedure GetViewPort;
    { citeste coordonatele ferestrei fizice si deseneaza
      dreptunghiul corespunzator }
    begin
      GetViewSettings(FereastraFizica);
      with FereastraFizica do Rectangle(0, 0, X2 - X1, Y2 - Y1)
    end; { GetViewPort }

  procedure RealToViewPort(x, y: Real; var u, v: Integer);
    { transforma coordonatele reale x, y in coordonate ecran (viewport)
      u, v
    }
    begin
      u := Round((x - FereastraReala.a) *
                 (FereastraFizica.X2 - FereastraFizica.X1) /
                 (FereastraReala.b - FereastraReala.a));
      v := Round((y - FereastraReala.d) *
                 (FereastraFizica.Y2 - FereastraFizica.Y1) /
                 (FereastraReala.c - FereastraReala.d));
    end;
  Procedure InitGr;
    var
      Rezultat: Integer;
  { trecerea de la modul text la modul grafic }
    Begin
      DetectGraph(DriverGrafic,ModGrafic);       { detecteaza placa grafica }
      InitGraph(DriverGrafic,ModGrafic,CaleBGI); { apel InitGraph }
      Rezultat := GraphResult;
      If Rezultat <> grOK then begin               { esec? }
        WriteLn(GraphErrorMsg(Rezultat));
        If Rezultat = grFileNotFound
          then WriteLn('in ', CaleBGI,
                       '. Modificati "CaleBGI" in unit-ul UGraph');
        WriteLn('Apasati ENTER ...');
        ReadLn;
        Halt(1)
      End;
    End; { InitGr }

  function CeDirectie(var DirX,DirY : ShortInt) : Boolean;
  { preia o tasta functionala sageata si seteaza DirX si DirY
    intorcand True
    la Enter sau orice alta tasta diferita de sageti intoarce False
  }
    var
      CodCar : Byte;
      Gata : Boolean;
    Begin
      DirX := 0;
      DirY := 0;
      CeDirectie := True;
      Repeat
        CodCar := Ord(ReadKey);
        Gata := True;
        Case CodCar of
          0 : Begin         { cod de tasta functionala }
                CodCar := Ord(ReadKey);
                Case CodCar of
                  72 : DirY := -1;   { sageata sus }
                  80 : DirY :=  1;   { sageata jos }
                  75 : DirX := -1;   { sageata stanga }
                  77 : DirX :=  1;   { sageata dreapta }
                  else Gata := False;
                End;
              End;
          13 : CeDirectie := False   { termina }
          else Gata := False
        End;
      Until Gata;
    End; { CeDirectie }
  procedure OutTextLN(S:String);
    Begin
      OutText(S);
      MoveTo(0,GetY+TextHeight(S)+2)
    End; { OutTextLn }
 procedure RotestePunct(var x,y:integer; cx,cy,unghi:Integer);
   { roteste punctul (x, y) in jurul centrului (cx, cy) cu
     unghiul unghi - dat in grade

      * (final)      * (x, y)  (pozitie initiala)
       \           /
        r\ unghi /r
           \   /   fi
             *  -----------------> OX
         (cx, cy)

 legatura dintre coordonatele polare (r, fi) si coordonatele carteziene
 (x, y) este urmatoarea:

   x = cx + r cos fi
   y = cy + r sin fi

 si invers,

   r = sqrt(x*x + y*y)
   cos fi = (x - cx) / r
   sin fi = (y - cy) / r

   }
   Var
     r,dx,dy,uu,sf,cf,su,cu,s,c : Real;
   Begin
     dx := x-cx;
     dy := y-cy;
     r := sqrt(dx*dx+dy*dy);
     If r = 0.0
       then Exit;
     sf := dy / r;   { sin fi }
     cf := dx / r;   { cos fi }
     uu := unghi * pi / 180;   { unghi in radiani }
     su := sin(uu);            { sin unghi }
     cu := cos(uu);            { cos unghi }
     c := cf * cu - sf * su;   { cos (fi + unghi) }
     s := sf * cu + cf * su;   { sin (fi + unghi) }
     x := cx + round(r * c);   { noul x }
     y := cy + round(r * s);   { noul y }
   End; { RotestePunct }

  Procedure PieInt(var A: array of integer; cx, cy, raza: Integer);
    { deseneaza o placinta <Pie> folosind un tablou de intregi
      placinta are centrul in (cx, cy) si raza 'raza'
      pre: ecranul trebuie sa fie in mod grafic }
    var
      Suma: Integer;
      i: Integer;
      UnghiInitial, UnghiFinal: Integer;
    begin
      { calculeaza suma elementelor din tabloul deschis A }
      Suma := 0;
      for i := Low(A) to High(A) do Suma := Suma + A[i];
      UnghiInitial := 0;
      { deseneaza feliile placintei cu PieSlice }
      for i := Low(A) to High(A) do begin
        UnghiFinal := UnghiInitial + Round(A[i]*360/Suma);
        SetFillStyle(i, i+8);  { umple cu sablonul i si culoarea i+8 }
        PieSlice(cx, cy,
                 UnghiInitial, UnghiFinal,
                 Raza);
        UnghiInitial := UnghiFinal
      end { For }
    end; { PieInt }

begin { cod de initializare }
  { initializeaza implicit domeniul D }
  with FereastraReala do begin
    a := -1000;
    b :=  1000;
    c := -1000;
    d :=  1000
  end;
End. { UGraph }