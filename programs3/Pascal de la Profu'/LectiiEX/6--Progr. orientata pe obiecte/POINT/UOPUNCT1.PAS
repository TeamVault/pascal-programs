Unit UOPunct1;
  { Obiecte si metode statice }
  Interface
  Type
    Locatie = Object
      procedure Init(aX,aY:Integer);
      function XCoord : Integer;
      function YCoord : Integer;
      private
        X,Y : Integer;
    End;
    Punct = Object(Locatie)
      procedure Init(aX,aY:Integer);
      procedure Deseneaza;
      procedure Ascunde;
      function EVizibil : Boolean;
      procedure MutaIn(nouX,nouY:Integer);
      procedure Roteste(centru:Locatie; unghi:Integer);
      private
        Vizibil : Boolean;
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
    procedure Punct.Init(aX,aY:Integer);
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
    procedure Punct.Roteste(centru:Locatie; unghi:Integer);
      Var
        nx,ny : Integer;
      Begin
        nx := x;
        ny := y;
        RotestePunct(nx,ny,centru.x,centru.y,unghi);
        MutaIn(nx,ny)
      End; { Roteste }

end. { Unit UOPunct1 }