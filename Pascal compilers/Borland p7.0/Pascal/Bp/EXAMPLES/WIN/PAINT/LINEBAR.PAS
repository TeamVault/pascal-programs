{************************************************}
{                                                }
{   ObjectWindows Paint demo                     }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit LineBar;

{ This unit defines a line thickness selection window for the paint program.
  The line bar is responsible for displaying the available and current line
  widths and provides the interface to select the current line width.
}

interface

uses PaintDef, WinTypes, WinProcs, OWindows;

const
  LineCount = 8;	{ Number of line widths available }
  LineBarWidth = LineCount * 4 + 6 + (1 + 2 + 3 + 4 + 5 + 7 + 9 + 12);
  			{ Total width of window }

type

  PLineBar = ^TLineBar;
  TLineBar = object(TWindow)
    State: PState;
    
    { Creation }
    constructor Init(AParent: PWindowsObject; AState: PState);

    { Display }
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;

    { Window manager interface }
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
  end;


implementation

const
  LineWidth: array[0..LineCount - 1] of Integer = (
    1, 2, 3, 4, 5, 7, 9, 12); 		{ The available line widths }

{ Create a line bar.
}
constructor TLineBar.Init(AParent: PWindowsObject; AState: PState);
begin
  TWindow.Init(AParent, nil);
  Attr.Style := ws_Border or ws_Child or ws_Visible;
  State := AState;
end;

{ Draw the line bar. A sample line of each availble is drawn vertically
  (samples arrayed horizontally).
  Each sample line is drawn by filling in the rectangle it occupies rather
  than as a true line for ease of computation of position.
}
procedure TLineBar.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  I, X, W: Integer;  { Sample number; X position of sample; Sample width }
  R: TRect;	     { Rect that sample will occupy }

{ Draw triangular notch marks to indicate the currently selected width.
}
procedure Notch(Y, DY: Integer);
var
  L: Integer;
begin
  for L := 3 downto 0 do
  begin
    MoveTo(PaintDC, X + W div 2 - L, Y);
    LineTo(PaintDC, X + W div 2 + L + 1, Y);
    Inc(Y, DY);
  end;
end;

begin
  X := 4;
  for I := 0 to LineCount - 1 do
  begin
    { Draw the line sample }
    W := LineWidth[I];
    SetRect(R, X, 5, X + W, 25);
    FillRect(PaintDC, R, GetStockObject(black_Brush));

    { Mark the currently selected width }
    if W = State^.PenSize then
    begin
      Notch(0, 1);
      Notch(29, -1);
    end;
    Inc(X, W + 4);
  end;
end;

{ Set the currently selected line widht to be that whose sample line was
  pressed and update the display.
}
procedure TLineBar.WMLButtonDown(var Msg: TMessage);
var
  I, X, W: Integer;
begin
  X := 2;
  for I := 0 to LineCount - 1 do
  begin
    W := LineWidth[I];
    if (Msg.LParamLo >= X) and (Msg.LParamLo < X + W + 4) then
    begin
      State^.PenSize := W;
      InvalidateRect(HWindow, nil, True);
      Exit;
    end;
    Inc(X, W + 4);
  end;
end;

end.
