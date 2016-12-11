Unit UPctD;
  { Obiectul dinamic Punct }
  Interface
    Uses ULoc;
  type
    PointerLaPunct = ^Punct;
    Punct = Object(Locatie)
      constructor Init(aX,aY:Integer);
      destructor Done;
      procedure Deseneaza; virtual;
      procedure Ascunde; virtual;
      function EVizibil : Boolean;
      procedure MutaIn(nouX,nouY:Integer);
      procedure Translateaza(pas:Integer);
      procedure Roteste(centru:Locatie; unghi:Integer);
      function Caracteristici: String; virtual;
      procedure Mareste(CuCit:Integer); virtual;
      procedure Listeaza;
      private
        Vizibil : Boolean;
    End;
  Implementation
    Uses UGraph,Graph;
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
        PutPixel(XCoord,YCoord,GetColor)
      End; { Deseneaza }
    procedure Punct.Ascunde;
      Begin
        Vizibil := False;
        PutPixel(XCoord,YCoord,GetBkColor)
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
        CrtX := XCoord;
        CrtY := YCoord;
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
        nx := XCoord;
        ny := YCoord;
        RotestePunct(nx,ny,centru.XCoord,centru.YCoord,unghi);
        MutaIn(nx,ny)
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
    procedure Punct.Mareste(CuCit : Integer);
      Begin
      End; { Mareste }
end. { Unit UPctD }