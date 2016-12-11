Unit USeg;
  { Obiecte polimorfe si metode virtuale }
  Interface
    Uses
      ULoc,UPctD;
  Type
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
        XOrigine := XCoord
      End; { XOrigine }
    function Segment.YOrigine : Integer;
      Begin
        YOrigine := YCoord
      End; { YOrigine }
    function Segment.XCapat : Integer;
      Begin
        XCapat := XCoord + trunc(L * cos(P*Pi/180));
      End; { XCapat }
    function Segment.YCapat : Integer;
      Begin
        YCapat := YCoord + trunc(L * sin(P*Pi/180));
      End; { YCapat }
    procedure Segment.Deseneaza;
      Begin
        MoveTo(XCoord,YCoord);
        Punct.Deseneaza;
        LineTo(XCapat,YCapat);
      End; { Deseneaza }
    procedure Segment.Ascunde;
      var
        c : Word;
      Begin
        c := Graph.GetColor;
        Graph.SetColor(Graph.GetBkColor);
        MoveTo(XCoord,YCoord);
        Punct.Ascunde;
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
        nx := XCoord;
        ny := YCoord;
        RotestePunct(nx,ny,centru.XCoord,centru.YCoord,unghi);
        Ascunde;
        P := P + unghi;
        Locatie.Init(nx,ny);
        Deseneaza
      End; { Roteste }
end. { Unit USeg }
