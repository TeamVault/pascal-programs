{************************************************}
{                                                }
{   ObjectWindows Paint demo                     }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Rect;

{ This unit augments the support for type TRect.
}

interface

uses WinTypes, WinProcs;

type
  RectArray = array[0..3] of TRect;  	{ To return results from rect ops }

{ Compute Rect1 - Rect2 as (up to 4) non-overlapping rectangles.
  Returns the number of non-null resulting rectangles.
}
function SubtractRect(var Result: RectArray; var Rect1,
  Rect2: TRect): Integer;
		      
implementation

{ Compute Rect1 - Rect2 as (up to 4) non-overlapping rectangles.
  Returns the number of non-null resulting rectangles.
}
function SubtractRect(var Result: RectArray; var Rect1,
  Rect2: TRect): Integer;
		      
  function Max(A, B: Integer): Integer;
  begin
    if A > B then Max := A else Max := B;
  end;

  function Min(A, B: Integer): Integer;
  begin
    if A < B then Min := A else Min := B;
  end;

var
  I: Integer;
begin
  I := IntersectRect(Result[0], Rect1, Rect2);
  if I = 0 then
  begin
    with Rect1 do
      SetRect(Result[0], Left, Top, Right, Bottom);
    I := 1;           		     { difference is Rect1 }
  end
  else
    if not EqualRect(Result[0], Rect1) then  { else difference is empty }
    begin
      I := 0;
      if Rect2.Top > Rect1.Top then        { compute 'top' rectangle }
        with Rect1 do
      	begin
      	  SetRect(Result[I], Left, Top, Right, Rect2.Top);
    	  Inc(I);
        end;
      if Rect2.Bottom < Rect1.Bottom then  { compute 'bottom' rectangle }
        with Rect1 do
        begin
          SetRect(Result[I], Left, Rect2.Bottom, Right, Bottom);
  	  Inc(I);
        end;
      if Rect2.Left > Rect1.Left then      { compute 'left' rectangle }
      begin				   { note that top and bottom }
   	SetRect(Result[I], Rect1.Left,     { should not overlap }
	  Max(Rect1.Top, Rect2.Top), Rect2.Left,
          Min(Rect1.Bottom, Rect2.Bottom));
        Inc(I);
      end;
      if Rect2.Right < Rect1.Right then    { ditto 'right' rectangle }
      begin
        SetRect(Result[I], Rect2.Right, Max(Rect1.Top, Rect2.Top),
          Rect1.Right, Min(Rect1.Bottom, Rect2.Bottom));
        Inc(I);
      end;
  end;
  SubtractRect := I;			     { number of valid rectangles }
end;

end.

