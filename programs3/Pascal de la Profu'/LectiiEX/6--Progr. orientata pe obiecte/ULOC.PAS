Unit ULoc;
  { Obiectul Locatie }
  Interface
  Type
    Locatie = Object
      procedure Init(aX,aY:Integer);
      function XCoord : Integer;
      function YCoord : Integer;
      private
        X,Y : Integer;
    End;
  Implementation
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
end. { Unit ULoc }