Unit UCercS;
  Interface
    Uses ULoc,UPctS;
  Type
    Cerc = Object(Punct)
      procedure Init(aX,aY,aRaza:Integer);   { rescrisa }
      procedure Deseneaza;                   { rescrisa }
      procedure Ascunde;                     { rescrisa }
      procedure MutaIn(nouX,nouY:Integer);   { rescrisa }
      procedure Translateaza(pas:Integer);   { rescrisa }
      procedure Roteste(centru:Locatie; unghi:Integer);  { rescrisa }
      procedure Mareste(CuCit:Integer);                  { noua }
      function Raza : Integer;                           { noua }
      function Caracteristici : String;                  { rescrisa }
      procedure Listeaza;                                { rescrisa }
      private
        R : Integer;                                     { noua }
    End;
  Implementation
    Uses Graph,UGraph;
{ cerc }
    procedure Cerc.Init(aX,aY,aRaza:Integer);
      Begin
        Punct.Init(aX,aY);     { apel de supermetoda }
        R := aRaza
      End; { Init }
    procedure Cerc.Deseneaza;
      Begin
        Punct.Deseneaza;
        Graph.Circle(XCoord,YCoord,Raza)
      End; { Deseneaza }
    procedure Cerc.Ascunde;
      var
        c : Word;
      Begin
        c := Graph.GetColor;
        Graph.SetColor(Graph.GetBkColor);
        Punct.Ascunde;
        Graph.Circle(XCoord,YCoord,Raza);
        Graph.SetColor(c)
      End; { Ascunde }
    procedure Cerc.MutaIn(nouX,nouY:Integer);
      begin
        Ascunde;
        Locatie.Init(nouX,nouY);
        Deseneaza
      end; { MutaIn }
    procedure Cerc.Translateaza(pas:Integer);
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
    procedure Cerc.Roteste(centru:Locatie; unghi:Integer);
      Var
        nx,ny : Integer;
      Begin
        nx := XCoord;
        ny := YCoord;
        RotestePunct(nx,ny,centru.XCoord,centru.YCoord,unghi);
        MutaIn(nx,ny)
      End; { Roteste }
    procedure Cerc.Mareste(CuCit:Integer);
      Begin
        Ascunde;
        R := R + CuCit;
        If R < 0 then R := 0;
        Deseneaza
      End; { Mareste }
    function Cerc.Raza : Integer;
      Begin
        Raza := R
      End; { Raza }
    function Cerc.Caracteristici : String;
      var
        S,M : string;
      begin
        Str(Raza:3,M);
        S := ', Raza = '+M;
        Caracteristici := Punct.Caracteristici + S
      end; { Caracteristici }
    procedure Cerc.Listeaza;
      Begin
        OutTextLn(Caracteristici)
      End; { Listeaza }
end. { UCercS }