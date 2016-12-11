Unit UOPunct4;
  { Obiecte polimorfe si metode virtuale }
  Interface
  Type
    Locatie = Object
      procedure Init(aX,aY:Integer);
      function XCoord : Integer;
      function YCoord : Integer;
      private
        X,Y : Integer;
    End;
    PointerLaPunct = ^Punct;
    Punct = Object(Locatie)
      constructor Init(aX,aY:Integer);
      destructor Done; virtual;
      procedure Deseneaza; virtual;
      procedure Ascunde; virtual;
      function EVizibil : Boolean;
      procedure MutaIn(nouX,nouY:Integer);
      procedure Translateaza(pas:Integer);
      procedure Roteste(centru:Locatie; unghi:Integer);
      function Caracteristici: String; virtual;
      procedure Listeaza;
      private
        Vizibil : Boolean;
    End;
    PointerLaCerc = ^Cerc;
    Cerc = Object(Punct)
      constructor Init(aX,aY,aRaza:Integer);
      procedure Deseneaza; virtual;
      procedure Ascunde; virtual;
      procedure Mareste(CuCit:Integer);
      function CercRaza : Integer;
      function Caracteristici: String; virtual;
      private
        Raza : Integer;
    End;
    PointerLaArc = ^Arc;
    Arc = Object(Cerc)
      constructor Init(aX,aY,aRaza,aUnghiI,aUnghiF:Integer);
      procedure Deseneaza; virtual;
      procedure Ascunde; virtual;
      Function ArcUnghiI : Integer;
      Function ArcUnghiF : Integer;
      function Caracteristici: String; virtual;
      private
        UnghiI,UnghiF : Integer;
    End;
    PointerLaSegment = ^Segment;
    Segment = Object(Punct)
      constructor Init(aX,aY,aL,aP:Integer);
      procedure Deseneaza; virtual;
      procedure Ascunde; virtual;
      function Lungime : Integer;
      function Panta : Integer;
      function XOrigine : Integer;
      function YOrigine : Integer;
      function XCapat : Integer;
      function YCapat : Integer;
      function Caracteristici: String; virtual;
      procedure Roteste(centru:Locatie; unghi:Integer);
      private
        L,             { lungime }
        P : Integer;   { panta: unghiul cu directia pozitiva a axei Ox }
    End;
  Implementation
    Uses Graph,UGraph;
{ Locatie }
    procedure Locatie.Init(aX,aY:Integer);
      Begin
        X := aX;
        Y := aY
      End; { Init }
    function Locatie.XCoord : Integer;
      Begin
        XCoord := X
      End; { XCoord }
    function Locatie.YCoord : Integer;
      Begin
        YCoord := Y
      End; { YCoord }
{ Punct }
    constructor Punct.Init(aX,aY:Integer);
      Begin
        Locatie.Init(aX,aY);
        Vizibil := False
      End; { Init }
    destructor Punct.Done;
      Begin
        Ascunde
      End; { Done }
    procedure Punct.Deseneaza;
      Begin
        Vizibil := True;
        PutPixel(X,Y,GetColor)
      End; { Deseneaza }
    procedure Punct.Ascunde;
      Begin
        Vizibil := False;
        PutPixel(X,Y,GetBkColor)
      End; { Ascunde }
    function Punct.EVizibil : Boolean;
      Begin
        EVizibil := Vizibil
      End; { EVizibil }
    procedure Punct.MutaIn(nouX,nouY:Integer);
      Begin
        Ascunde;
        Locatie.Init(nouX,nouY);
        Deseneaza
      End; { MutaIn }
    procedure Punct.Translateaza(pas:Integer);
      Var
        DX,DY : ShortInt;
        CrtX,CrtY : Integer;
      Begin
        Deseneaza;
        CrtX := X;
        CrtY := Y;
        While CeDirectie(DX,DY) do
          Begin
            CrtX := CrtX + DX * pas;
            CrtY := CrtY + DY * pas;
            MutaIn(CrtX,CrtY)
          End;
      End; { Translateaza }
    procedure Punct.Roteste(centru:Locatie; unghi:Integer);
      Var
        nx,ny : Integer;
      Begin
        nx := x;
        ny := y;
        RotestePunct(nx,ny,centru.x,centru.y,unghi);
        MutaIn(nx,ny);
      End; { Roteste }
    function Punct.Caracteristici: String;
      Var
        S,M : String;
      Begin
        Str(XCoord:3,M);
        S := 'X = '+M;
        Str(YCoord:3,M);
        S := S + ', Y = '+M;
        Caracteristici := S
      End; { Caracteristici }
    procedure Punct.Listeaza;
      Begin
        OutTextLn(Caracteristici)
      End; { Listeaza }
{ cerc }
    constructor Cerc.Init(aX,aY,aRaza:Integer);
      Begin
        Punct.Init(aX,aY);
        Raza := aRaza
      End; { Init }
    procedure Cerc.Deseneaza;
      Begin
        Vizibil := True;
        Graph.Circle(X,Y,Raza)
      End; { Deseneaza }
    procedure Cerc.Ascunde;
      var
        c : Word;
      Begin
        c := Graph.GetColor;
        Graph.SetColor(Graph.GetBkColor);
        Vizibil := False;
        Graph.Circle(X,Y,Raza);
        Graph.SetColor(c)
      End; { Ascunde }
    procedure Cerc.Mareste(CuCit:Integer);
      Begin
        Ascunde;
        Raza := Raza + CuCit;
        If Raza < 0 then Raza := 0;
        Deseneaza
      End; { Mareste }
    function Cerc.CercRaza : Integer;
      Begin
        CercRaza := Raza
      End; { CercRaza }
    function Cerc.Caracteristici : String;
      var
        S,M : string;
      begin
        Str(CercRaza:3,M);
        S := ', Raza = '+M;
        Caracteristici := Punct.Caracteristici + S
      end; { Caracteristici }
{ arc }
    constructor Arc.Init(aX,aY,aRaza,aUnghiI,aUnghiF:Integer);
      Begin
        Cerc.Init(aX,aY,aRaza);
        UnghiI := aUnghiI;
        UnghiF := aUnghiF
      End; { Init }
    procedure Arc.Deseneaza;
      Begin
        Vizibil := True;
        Graph.Arc(X,Y,UnghiI,UnghiF,Raza)
      End; { Deseneaza }
    procedure Arc.Ascunde;
      var
        c : Word;
      Begin
        c := Graph.GetColor;
        Graph.SetColor(Graph.GetBkColor);
        Vizibil := False;
        Graph.Arc(X,Y,UnghiI,UnghiF,Raza);
        Graph.SetColor(c)
      End; { Ascunde }
    function Arc.ArcUnghiI : Integer;
      Begin
        ArcUnghiI := UnghiI
      End; { ArcUnghiI }
    function Arc.ArcUnghiF : Integer;
      Begin
        ArcUnghiF := UnghiF
      End; { ArcUnghiF }
    function Arc.Caracteristici : String;
      var
        S,M : string;
      begin
        Str(ArcUnghiI:3,M);
        S := ', de la = '+M;
        Str(ArcUnghiF:3,M);
        S := S + ', pina la = '+M;
        Caracteristici := Cerc.Caracteristici + S
      end; { Caracteristici }
{ Segment }
    constructor Segment.Init(aX,aY,aL,aP:Integer);
      Begin
        Punct.Init(aX,aY);
        L := aL;
        P := aP
      End; { Init }
    function Segment.Lungime : Integer;
      Begin
        Lungime := L
      End; { Lungime }
    function Segment.Panta : Integer;
      Begin
        Panta := P
      End; { Panta }
    function Segment.XOrigine : Integer;
      Begin
        XOrigine := X
      End; { XOrigine }
    function Segment.YOrigine : Integer;
      Begin
        YOrigine := Y
      End; { YOrigine }
    function Segment.XCapat : Integer;
      Begin
        XCapat := X + trunc(L * cos(P*Pi/180));
      End; { XCapat }
    function Segment.YCapat : Integer;
      Begin
        YCapat := Y + trunc(L * sin(P*Pi/180));
      End; { YCapat }
    procedure Segment.Deseneaza;
      Begin
        MoveTo(X,Y);
        LineTo(XCapat,YCapat);
        Vizibil := True
      End; { Deseneaza }
    procedure Segment.Ascunde;
      var
        c : Word;
      Begin
        c := Graph.GetColor;
        Graph.SetColor(Graph.GetBkColor);
        Vizibil := False;
        MoveTo(X,Y);
        LineTo(XCapat,YCapat);
        Graph.SetColor(c)
      End; { Ascunde }
    function Segment.Caracteristici : String;
      var
        S,M : string;
      begin
        Str(Lungime:3,M);
        S := ', Lungime = '+M;
        Str(Panta:3,M);
        S := S + ', Panta = '+M;
        Caracteristici := Punct.Caracteristici + S
      end; { Caracteristici }
    procedure Segment.Roteste(centru:Locatie; unghi:Integer);
      Var
        nx,ny : Integer;
      Begin
        nx := x;
        ny := y;
        RotestePunct(nx,ny,centru.x,centru.y,unghi);
        Ascunde;
        P := P + unghi;
        Locatie.Init(nx,ny);
        Deseneaza
      End; { Roteste }
end. { Unit UOPunct4 }
