Unit UCercD;
  Interface
    Uses ULoc,UPctD;
  Type
    PointerLaCerc = ^Cerc;
    Cerc = Object(Punct)
      constructor Init(aX,aY,aRaza:Integer);
      procedure Deseneaza; virtual;
      procedure Ascunde; virtual;
      procedure Mareste(CuCit:Integer); virtual;
      function Raza : Integer;
      function Caracteristici : String; virtual;
      private
        R : Integer;
    End;
  Implementation
    Uses Graph,UGraph;
{ cerc }
    constructor Cerc.Init(aX,aY,aRaza:Integer);
      Begin
        Punct.Init(aX,aY);
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
end. { UCercD }