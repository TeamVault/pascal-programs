Unit UPoint1;
Interface
  Type
    Point = Record
      x,y : Integer
    End;
  Procedure Init(x,y:Integer; var a:Point);
  Procedure Add(a,b:Point; var c:Point);
  Procedure Sub(a,b:Point; var c:Point);
  Function Str(a:Point) : String;
Implementation
  Procedure Init(x,y:Integer; var a:Point);
    Begin
      a.x := x;
      a.y := y
    End; { Init }
  Procedure Add(a,b:Point; var c:Point);
    Begin
      c.x := a.x + b.x;
      c.y := a.y + b.y;
    End; { Add }
  Procedure Sub(a,b:Point; var c:Point);
    Begin
      c.x := a.x - b.x;
      c.y := a.y - b.y;
    End; { Sub }
  Function Str(a:Point) : String;
    Var
      sx,sy : String;
    Begin
      System.Str(a.x,sx);
      System.str(a.y,sy);
      Str := '('+sx+','+sy+')'
    End; { Str }
End.

