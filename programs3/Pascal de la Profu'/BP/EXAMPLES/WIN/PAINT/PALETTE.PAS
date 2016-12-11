{************************************************}
{                                                }
{   ObjectWindows Paint demo                     }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Palette;

{ This unit defines a color palette window for the Paint program. The color
  palette is responsible for displaying the available colors, maintaining
  and displaying the current pen and brush colors and provides the interface
  for color selection.
}

interface

uses PaintDef, WinTypes, WinProcs, OWindows;

type

  PPalette = ^TPalette;
  TPalette = object(TWindow)
    State: PState;

    { Creation }
    constructor Init(AParent: PWindowsObject; AState: PState);

    { Utility }
    procedure SelectColor(var Msg: TMessage; var Color: TColorRef);

    { Display }
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;

    { Window manager responses }
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMRButtonDown(var Msg: TMessage);
      virtual wm_First + wm_RButtonDown;
  end;

implementation

const

  { The available colors in RGB format }
  Colors: array[0..2, 0..15] of TColorRef = (
    ($FFFFFF,$E0E0E0,$C0C0FF,$C0E0FF,$E0FFFF,$C0FFC0,$FFFFC0,$FFC0C0,
     $FFC0FF,$0000C0,$0040C0,$00C0C0,$00C000,$C0C000,$C00000,$C000C0),
    ($C0C0C0,$404040,$8080FF,$80C0FF,$80FFFF,$80FF80,$FFFF80,$FF8080,
     $FF80FF,$000080,$004080,$008080,$008000,$808000,$800000,$800080),
    ($808080,$000000,$0000FF,$0080FF,$00FFFF,$00FF00,$FFFF00,$FF0000,
     $FF00FF,$000040,$404080,$004040,$004000,$404000,$400000,$400040));


{ Create the palette.
}
constructor TPalette.Init(AParent: PWindowsObject; AState: PState);
begin
  TWindow.Init(AParent, nil);
  Attr.Style := ws_Child or ws_Visible;
  State := AState;
end;

{ Set the Color variable to the color pressed on in the palette window.
  (Mouse click information contained in Msg.)
  Cause the display to be updated.
}
procedure TPalette.SelectColor(var Msg: TMessage; var Color: TColorRef);
var
  X, Y, S: Integer;	{ Column, Row clicked on; Height of color squares }
  R: TRect;		{ Window client area }
begin
  GetClientRect(HWindow, R);
  S := R.bottom div 17;
  X := Msg.LParamLo div S;
  Y := Msg.LParamHi div S;
  if (X < 3) and (Y < 16) then
  begin
    Color := Colors[X, Y];
    InvalidateRect(HWindow, nil, False);
  end;
end;

{ Paint the palette window by painting the available colors in 3 columns of
  16 rows. The 17th row spans all three columns and is used to display the
  currently selected pen and brush colors.
}
procedure TPalette.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  X, Y, S: Integer;	{ Column, Row; Height of row }
  OldPen: HPen;		{ Original pen in drawing context }
  OldBrush: HBrush;	{ Original brush in drawing context }
  R: TRect;		{ Window client area }
begin
  GetClientRect(HWindow, R);

  { Draw the color panes using a solid brush of the appropriate color }
  S := R.bottom div 17;
  for Y := 0 to 15 do
    for X := 0 to 2 do
    begin
      OldBrush := SelectObject(PaintDC,
        CreateSolidBrush(Colors[X, Y]));
      Rectangle(PaintDC, X * S, Y * S, (X + 1) * S + 1, (Y + 1) * S + 1);
      DeleteObject(SelectObject(PaintDC, OldBrush));
    end;

  { Paint the frame around the current color pane }
  SelectObject(PaintDC, GetStockObject(null_brush));
  Rectangle(PaintDC, 0, S * 16, R.right, R.bottom);
  
  { Paint the current colors square with the current colors }
  OldPen := SelectObject(PaintDC, CreatePen(ps_Solid, 5, State^.PenColor));
  OldBrush := SelectObject(PaintDC, CreateSolidBrush(State^.BrushColor));
  Rectangle(PaintDC, 3, S * 16 + 3, R.right - 3, R.bottom - 3);

  { Restore the DC to its original state }
  DeleteObject(SelectObject(PaintDC, OldBrush));
  DeleteObject(SelectObject(PaintDC, OldPen));
end;

{ Select the current pen and brush colors in response to mouse clicks.
}
procedure TPalette.WMLButtonDown(var Msg: TMessage);
begin
  SelectColor(Msg, State^.PenColor);
end;

procedure TPalette.WMRButtonDown(var Msg: TMessage);
begin
  SelectColor(Msg, State^.BrushColor);
end;

end.
