Unit UPointO2;
Interface
  Type
    PPoint = ^Point;
    Point = Object
      x,y : Integer;
      Constructor Init(ax,ay:Integer);
      Procedure Add(a,b:PPoint);
      Procedure Sub(a,b:PPoint);
      Function Str : String;
    End;
Implementation
  Constructor Point.Init(ax,ay:Integer);
    Begin
      x := ax;
      y := ay
    End; { Init }
  Procedure Point.Add(a,b:Point);
    Begin
      x := a.x + b.x;
      y := a.y + b.y;
    End; { Add }
  Procedure Point.Sub(a,b:Point);
    Begin
      x := a.x - b.x;
      y := a.y - b.y;
    End; { Sub }
  Function Point.Str : String;
    Var
      sx,sy : String;
    Begin
      System.Str(x,sx);
      System.str(y,sy);
      Str := '('+sx+','+sy+')'
    End; { Str }
End.

