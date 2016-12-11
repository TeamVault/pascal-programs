Unit UOPun;
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
      procedure Deseneaza;
      procedure Ascunde;
      function EVizibil : Boolean;
      procedure MutaIn(nouX,nouY:Integer);
      procedure Translateaza(pas:Integer);
      procedure Roteste(centru:Locatie; unghi:Integer);
      private
        Vizibil : Boolean;
    End;
    PointerLaCerc = ^Cerc;
    Cerc = Object(Punct)
      constructor Init(aX,aY,aRaza:Integer);
      procedure Deseneaza;
      procedure Ascunde; virtual;
      procedure Mareste(CuCit:Integer);
      function CercRaza : Integer;
      private
        Raza : Integer;
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
        MutaIn(nx,ny)
      End; { Roteste }
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
end. { Unit UOPun }