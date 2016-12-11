Unit UPoint2;
Interface
  Type
    PPoint = ^Point;
    Point = Record
      x,y : Integer
    End;
  Function Init(x,y:Integer):PPoint;
  Function Add(a,b:PPoint):PPoint;
  Function Sub(a,b:PPoint):PPoint;
  Function Str(a:PPoint) : String;
  Procedure Done(var a:PPoint);
Implementation
  Function Init(x,y:Integer):PPoint;
    Var
      a : PPoint;
    Begin
      New(a);
      a^.x := x;
      a^.y := y;
      Init := a
    End; { Init }
  Function Add(a,b:PPoint):PPoint;
    Var
      c : PPoint;
    Begin
      New(c);
      c^.x := a^.x + b^.x;
      c^.y := a^.y + b^.y;
      Add := c
    End; { Add }
  Function Sub(a,b:PPoint):PPoint;
    Var
      c : PPoint;
    Begin
      New(c);
      c^.x := a^.x - b^.x;
      c^.y := a^.y - b^.y;
      Sub := c
    End; { Sub }
  Function Str(a:PPoint) : String;
    Var
      sx,sy : String;
    Begin
      System.Str(a^.x,sx);
      System.str(a^.y,sy);
      Str := '('+sx+','+sy+')'
    End; { Str }
  Procedure Done(var a:PPoint);
    Begin
      Dispose(a);
      a := Nil
    End; { Done }
End.

