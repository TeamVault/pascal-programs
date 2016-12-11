Unit UArc;
  { Obiecte polimorfe si metode virtuale }
  Interface
    Uses ULoc,UPctD,UCercD;
  Type
    PointerLaArc = ^Arc;
    Arc = Object(Cerc)
      constructor Init(aX,aY,aRaza,aUnghiI,aUnghiF:Integer);
      procedure Deseneaza; virtual;
      procedure Ascunde; virtual;
      Function UnghiI : Integer;
      Function UnghiF : Integer;
      function Caracteristici: String; virtual;
      private
        UI,UF : Integer;
    End;
  Implementation
    Uses Graph,UGraph;
{ arc }
    constructor Arc.Init(aX,aY,aRaza,aUnghiI,aUnghiF:Integer);
      Begin
        Cerc.Init(aX,aY,aRaza);
        UI := aUnghiI;
        UF := aUnghiF
      End; { Init }
    procedure Arc.Deseneaza;
      Begin
        Punct.Deseneaza;
        Graph.Arc(XCoord,YCoord,UnghiI,UnghiF,Raza)
      End; { Deseneaza }
    procedure Arc.Ascunde;
      var
        c : Word;
      Begin
        c := Graph.GetColor;
        Graph.SetColor(Graph.GetBkColor);
        Punct.Ascunde;
        Graph.Arc(XCoord,YCoord,UnghiI,UnghiF,Raza);
        Graph.SetColor(c)
      End; { Ascunde }
    function Arc.UnghiI : Integer;
      Begin
        UnghiI := UI
      End; { UnghiI }
    function Arc.UnghiF : Integer;
      Begin
        UnghiF := UF
      End; { UnghiF }
    function Arc.Caracteristici : String;
      var
        S,M : string;
      begin
        Str(UnghiI:3,M);
        S := ', de la = '+M;
        Str(UnghiF:3,M);
        S := S + ', pina la = '+M;
        Caracteristici := Cerc.Caracteristici + S
      end; { Caracteristici }
end. { Unit UArc }