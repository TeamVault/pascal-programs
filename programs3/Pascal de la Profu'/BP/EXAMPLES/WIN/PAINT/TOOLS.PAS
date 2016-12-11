{************************************************}
{                                                }
{   ObjectWindows Paint demo                     }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Tools;

{ This unit supplies the actual painting and drawing tools for the paint
  program. Each tool manipulates the bits in a display context in a
  specialized manner. The behaviour of each tool is defined. The icon and
  cursor associated with a tool is specified when the tool is created, but
  the tool itself does not make use of this information.
}

interface

uses PaintDef, Rect, Strings, WinTypes, WinProcs;

type
  { A Draw Tool is a tool whose action is instigated solely by mouse input.
    The action is always fully performed within a single Mouse Down, Mouse
    Move, Mouse Up cycle.

    TDrawTool performs the actions necessary to maintain the drawing
    environment (storing window, display context, etc.) so that each tool need
    only implement those of DrawBegin (called on Mouse Down), DrawTo (called
    on Mouse Move) and DrawEnd (called on MouseUp) that perform actions 
    peculiar to that tool.
  }
  PDrawTool = ^TDrawTool;			{ Defined in PaintDef }
  TDrawTool = object(TPaintTool)
    Pen, MemPen: HPen;			        { The pens not in use }
    Brush, MemBrush: HBrush;			{ The brushes not in use }

    { Mouse responses }
    procedure MouseDown(AWindow: HWnd; X, Y: Integer;
      AState: PState); virtual;
    procedure MouseMove(X, Y: Integer); virtual;
    procedure MouseUp; virtual;
  end;

  { A Pen tool draws a freeform line using the currently selected pen color
    and width.
  }
  PPenTool = ^TPenTool;
  TPenTool = object(TDrawTool)

    { Actual drawing }
    procedure DrawBegin(X, Y: Integer); virtual;
    procedure DrawTo(X, Y: Integer); virtual;
  end;
 
  { An Eraser tool draws a freeform white line using the currently selected
    pen width.
  }
  PEraserTool = ^TEraserTool;
  TEraserTool = object(TPenTool)
    Eraser, MemEraser: HPen;			{ The pens not in use }

    { Actual drawing }
    procedure DrawBegin(X, Y: Integer); virtual;
    procedure DrawEnd; virtual;
  end;

  { A Fill tool fills an area bounded by the current pen color with the
    current brush color.
  }
  PFillTool = ^TFillTool;
  TFillTool = object(TDrawTool)

    { Actual drawing }
    procedure DrawBegin(X, Y: Integer); virtual;
  end;

  { A Box tool is a tool that operates on a rectangularly bounded area. These
    are tools whose actual drawing calls involve specifying this bounding
    rectangle, e.g., for drawing a rectangle or oval, OR that perform
    rubberbanding during drawing.
  }
  PBoxTool = ^TBoxTool;
  TBoxTool = object(TDrawTool)
    Filled: Boolean;		     { Should the internal area be colored }
    X1, Y1, X2, Y2: Integer;	     { The bounding rectangle }

    { Creation }
    constructor Init(AState: PState; IconName, CursorName: PChar; 
                     AFilled: Boolean);

    { Actual drawing }
    procedure DrawBegin(X, Y: Integer); virtual;
    procedure DrawTo(X, Y: Integer); virtual;
    procedure DrawEnd; virtual;
    procedure DrawObject(aDC: HDC); virtual;
  end;

  { A Rect tool is a tool that draws (or manipulates) a rectangle.
  }
  PRectTool = ^TRectTool;
  TRectTool = object(TBoxTool)

    { Actual drawing }
    procedure DrawObject(aDC: HDC); virtual;
  end;

  { A Select tool selects and maintains a rectangular subset (the current 
    selection) of the image. The selection may serve only to specify this
    subset, or it may actively be manipulated (e.g., by dragging).
    If it is used for dragging a separate bitmap is created that exactly
    contains the portion of the image selected.
  }
  PSelectTool = ^TSelectTool;
  TSelectTool = object(TRectTool)
    SelectionDC: HDC;		{ Display context for the current selection }

    { Creation }
    constructor Init(AState: PState; IconName, CursorName: PChar;
      AFilled: Boolean);

    { Re-initilization }
    procedure Deselect; virtual;

    { Actual drawing }
    procedure DrawBegin(X, Y: Integer); virtual;
    procedure DrawTo(X, Y: Integer); virtual;
    procedure DrawEnd; virtual;
    procedure DrawObject(aDC: HDC); virtual;

    { Utilities }
    procedure PickUpSelection(aDC: HDC; Left, Top, Width, Height: Integer);
      virtual;
    procedure ReleaseSelection; virtual;
    procedure DropSelection; virtual;
  end;

  { An Ellipse tool is a tool that draws an ellipse.
  }
  PEllipseTool = ^TEllipseTool;
  TEllipseTool = object(TBoxTool)

    { Actual drawing }
    procedure DrawObject(aDC: HDC); virtual;
  end;

  { A Line tool draws a straight line.
  }
  PLineTool = ^TLineTool;
  TLineTool = object(TBoxTool)
    
    { Actual drawing }
    procedure DrawObject(aDC: HDC); virtual;
  end;


implementation

{ TDrawTool }

{ Set up the drawing environment for any drawing tool. Note that the
  display context for the off-screen bitmap has already been set up.
  
  Since shared display contexts are used for the window, they should
  be held as shortly as possible. Hence the display context for the window
  is retrieve on each operation.

}
procedure TDrawTool.MouseDown(AWindow: HWnd; X, Y: Integer; AState: PState);
begin
  { Set up the window and state }
  Window := AWindow;
  State := AState;

  { Direct all mouse input to Window }
  SetCapture(Window);

  { Create the actual pens and brushes to be used }
  Pen := CreatePen(ps_Solid, State^.PenSize, State^.PenColor); 
  MemPen := CreatePen(ps_Solid, State^.PenSize, State^.PenColor); 
  Brush := CreateSolidBrush(State^.BrushColor);
  MemBrush := CreateSolidBrush(State^.BrushColor);

  { Set up the display contexts }
  DC := GetDC(Window);		
  SelectObject(DC, Pen);
  SelectObject(State^.MemDC, MemPen);
  SelectObject(DC, Brush);
  SelectObject(State^.MemDC, MemBrush);

  DrawBegin(X, Y);		  { Tell the tool to start drawing }
end;

procedure TDrawTool.MouseMove(X, Y: Integer);
begin
  DrawTo(X, Y);			  { Tell the tool to do its draw thing }
end;

procedure TDrawTool.MouseUp;
begin
  DrawEnd;			  { Tell the tool to stop drawing }

  { Clean up }
  { Reset mouse input }
  ReleaseCapture;

  { Restore display contexts }
  SelectObject(DC, GetStockObject(Black_Pen));
  SelectObject(State^.MemDC, GetStockObject(Black_Pen));
  SelectObject(DC, GetStockObject(White_Brush));
  SelectObject(State^.MemDC, GetStockObject(White_Brush));
  
  { Delete the created objects }
  DeleteObject(Pen);
  DeleteObject(MemPen);
  DeleteObject(Brush);
  DeleteObject(MemBrush);

  ReleaseDC(Window, DC);
end;

{ TPenTool }

{ Actual drawing }
procedure TPenTool.DrawBegin(X, Y: Integer);
begin
  MoveTo(DC, X, Y);		        { Move the pen position }
  MoveTo(State^.MemDC, X+State^.Offset.X, Y+State^.Offset.Y);	{ Echo }
  DrawTo(X, Y);			        { Draw the initial pixel(s) }
end;

procedure TPenTool.DrawTo(X, Y: Integer);
begin
  LineTo(DC, X, Y);		        { Draw a line from the pen position }
  LineTo(State^.MemDC, X+State^.Offset.X, Y+State^.Offset.Y);	{ Echo }
end;

{ TEraserTool }

{ Actual drawing }
procedure TEraserTool.DrawBegin(X, Y: Integer);
begin
  { Create an erasing pen and reset the display context }
  Eraser := CreatePen(ps_Solid, State^.PenSize, $FFFFFF);
  MemEraser := CreatePen(ps_Solid, State^.PenSize, $FFFFFF);
  SelectObject(DC, Eraser);
  SelectObject(State^.MemDC, MemEraser);

  SelectObject(DC, GetStockObject(White_Brush));
  SelectObject(State^.MemDC, GetStockObject(White_Brush));

  TPenTool.DrawBegin(X, Y);	{ Start drawing }
end;

procedure TEraserTool.DrawEnd;
begin
  { Clean up }
  SelectObject(DC, Pen);
  SelectObject(State^.MemDC, MemPen);
  DeleteObject(Eraser);
  DeleteObject(MemEraser);
end;

{ TFillTool }

procedure TFillTool.DrawBegin(X, Y: Integer);
var
 PixelColor: LongInt;
begin
 PixelColor := GetPixel(State^.MemDC, X, Y);

 { Change the surface under X, Y to the background color }
 ExtFloodFill(DC, X, Y, PixelColor, FloodFillSurface);
 ExtFloodFill(State^.MemDC, X, Y, PixelColor, FloodFillSurface);
end;

{ TBoxTool }

{ Creation }
constructor TBoxTool.Init(AState: PState; IconName, CursorName:
  PChar; AFilled: Boolean);
begin
  TDrawTool.Init(AState, IconName, CursorName);
  Filled := AFilled;		{ Record whether tool operates on outline }
                                { or outline and bounded area }
end;

{ Actual drawing }
{ During the drawing a BoxTool rubberbands a black outline of the final 
  object on the screen by alternately erasing and redrawing the outline. }
procedure TBoxTool.DrawBegin(X, Y: Integer);
begin
  X1 := X;			{ Initially the rectangle is a single pixel }
  Y1 := Y;
  X2 := X;
  Y2 := Y;

  { Set up the display context to draw a black outline during drawing }
  SelectObject(DC, GetStockObject(Black_Pen));
  SelectObject(DC, GetStockObject(Null_Brush));

  { Invert pixels under the pen }
  SetROP2(DC, r2_Not);

  { Draw the initial outline }
  DrawObject(DC);
end;

procedure TBoxTool.DrawTo(X, Y: Integer);
begin
  { Draw over the outline last drawn. Since the pen inverts pixels and is
    black this will erase the last outline. }
  DrawObject(DC);

  { Update the rectangle to be operated on }
  X2 := X;	
  Y2 := Y;

  { Draw the new outline }
  DrawObject(DC);
end;

procedure TBoxTool.DrawEnd;
begin
  { Erase the last outline drawn }
  DrawObject(DC);

  { Set up the display context to draw the real image }  
  SetROP2(DC, r2_CopyPen);
  SelectObject(DC, Pen);
  if Filled then 
    SelectObject(DC, Brush)
  else
    SelectObject(State^.MemDC, GetStockObject(Null_Brush));

  { Draw the actual image }
  DrawObject(DC);
  with State^ do
  begin
    X1 := X1 + Offset.X;
    Y1 := Y1 + Offset.Y;
    X2 := X2 + Offset.X;
    Y2 := Y2 + Offset.Y;
  end;
  DrawObject(State^.MemDC);
end;

{ Allow the real tool to specify the image it draws.
}
procedure TBoxTool.DrawObject(aDC: HDC);
begin
end;

{ TRectTool }

{ Draw a rectangle.
}
procedure TRectTool.DrawObject(aDC: HDC);
begin
  Rectangle(aDC, X1, Y1, X2, Y2);
end;

{ TSelectTool }

{ Creation }
constructor TSelectTool.Init(AState: PState; IconName, CursorName: PChar;
  AFilled: Boolean);
begin
  TRectTool.Init(AState, IconName, CursorName, AFilled);
  SelectionDC := 0;
end;

{ Utility }
{ Make sure there is no active selection before exiting. If there is an image
  in the selection paste it into the current image.
}
procedure TSelectTool.Deselect;
begin
  DropSelection;
end;

{ Actual drawing }
{ The selection tool has two states of operation: While the selection is
  being made, it operates as a rectangle tool. If a selection has been made
  and the mouse clicks on it, the selection is dragged with the mouse.

  SelectionDC is valid only during dragging and thus serves as the
  flag to distinguish the two modes during drawing.

  Dragging the selection is effected by creating a copy (i.e., a
  bitmap) of the selection and alternately restoring the screen to the
  original (actually, only restoring those pieces that are revealed by
  moving the selection), and copying the selection bitmap to the screen.

  Throughout dragging
    X1, Y1 contains the previous mouse position
    State^.Selection contains the current coordinates of the selection
}
procedure TSelectTool.DrawBegin(X, Y: Integer);
var
  Pt: TPoint;
begin
  { Check to see if there is a hit on the selection }
  Pt.X := X;
  Pt.Y := Y;
  if PtInRect(State^.Selection, Pt) then
    { Drag selection }
  begin
    { Last mouse position }
    X1 := X;
    Y1 := Y;

    { Create the selection bitmap if necessary. (It may already have been
      created, for example through a Paste operation.) }
    if State^.SelectionBM = 0 then
      with State^.Selection, State^ do
      begin
	PickUpSelection(MemDC, Left + Offset.X, Top + Offset.Y,
	  Right-Left, Bottom-Top);

        { The convention is to cut the selection, so white out
          the hole }
	PatBlt(MemDC, Left + Offset.X, Top + Offset.Y,
	  Right - Left, Bottom - Top, Whiteness);
      end;

    { Set up the selection display context }
    SelectionDC := CreateCompatibleDC(DC);
    State^.SelectionBM := SelectObject(SelectionDC, State^.SelectionBM);
  end
  else
  { Make new selection }
  begin
    { Paste down the old one if there is one }
    DropSelection;
    TRectTool.DrawBegin(X, Y);
  end;
end;

procedure TSelectTool.DrawTo(X, Y: Integer);
var
  I, Count: Integer;		{ Number of rectangles that must be restored }
  MoveX, MoveY: Integer;	{ Change in X, Y coordinates of selection }
  Result: RectArray;		{ Rectangles that must be restored }
  NewCoords: TRect;		{ The new coordinates of selection }
begin
  if SelectionDC <> 0 then	{ Dragging }
  begin

    { Figure out the new coordinates }
    MoveX := X - X1;
    MoveY := Y - Y1;
    with State^.Selection do
      SetRect(NewCoords, Left + MoveX, Top + MoveY, Right + MoveX,
        Bottom + MoveY);

    { Determine the area that must be repainted. Note that this will always
      be 0, 1, or 2 rectangles exactly }
    Count := SubtractRect(Result, State^.Selection, NewCoords);

    { Repaint the rectangles revealed by the move }
    for I := 0 to Count-1 do
      with Result[I], State^ do
	BitBlt(DC, Left, Top, Right - Left, Bottom - Top,
	  State^.MemDC, Left + Offset.X, Top + Offset.Y, SrcCopy);

    { Update and repaint the selection }
    with NewCoords do
      SetRect(State^.Selection, Left, Top, Right, Bottom);
    X1 := X;
    Y1 := Y;
    DrawObject(DC);
  end
  else				{ Selecting }
    TRectTool.DrawTo(X, Y);
end;

procedure TSelectTool.DrawEnd;

  procedure Sort(var N1, N2: Integer);
  var
    Temp: Integer;
  begin
    if N1 > N2 then
    begin
      Temp := N1;
      N1 := N2;
      N2 := Temp;
    end;
  end;

begin
  DrawObject(DC);
  if SelectionDC <> 0 then
  begin
    { Clean up }
    State^.SelectionBM := SelectObject(SelectionDC, State^.SelectionBM);
    DeleteDC(SelectionDC);
    SelectionDC := 0;
  end
  else
  begin
    { Update the selection }
    Sort(X1, X2);
    Sort(Y1, Y2);
    SetRect(State^.Selection, X1, Y1, X2, Y2);
  end;
end;

procedure TSelectTool.DrawObject(aDC: HDC);
begin
  if SelectionDC <> 0 then
    { Draw the selection bitmap }
    with State^.Selection, State^ do
      BitBlt(aDC, Left, Top, Right-Left, Bottom-Top,
	SelectionDC, 0, 0, SrcCopy)
  else
    { Pretend to be a rectangle }
    TRectTool.DrawObject(aDC)
end;

{ Utilities }
{ Set the selection bitmap to be a bitmap that contains a copy of the
  bits contained in the indicated rectangle of the bitmap in a drawing
  context.
}
procedure TSelectTool.PickUpSelection(aDC: HDC; Left, Top, Width,
  Height: Integer);
var
  SelDC: HDC;			{ For copying into the selection bitmap }
begin
  { Paste down the current selection if there is one }
  if State^.SelectionBM <> 0 then DropSelection;

  { Set the default screen coordinates for the selection if necessary }
  if IsRectEmpty(State^.Selection) then 
    SetRect(State^.Selection, 0, 0, Width, Height);
  
  { Create the selection bitmap and copy the bits }
  SelDC := CreateCompatibleDC(aDC);
  State^.SelectionBM := CreateCompatibleBitmap(aDC, Width, Height);
  State^.SelectionBM := SelectObject(SelDC, State^.SelectionBM);
  BitBlt(SelDC, 0, 0, Width, Height, aDC, Left, Top, SrcCopy);

  { Clean up }
  State^.SelectionBM := SelectObject(SelDC, State^.SelectionBM);
  DeleteDC(SelDC);
end;

{ Set the current selection to none without copying back the selection bitmap.
}
procedure TSelectTool.ReleaseSelection;
begin
  if not IsRectEmpty(State^.Selection) then
  begin
    InvalidateRect(Window, @State^.Selection, False);
    SetRectEmpty(State^.Selection);
    if State^.SelectionBM <> 0 then
    begin
      DeleteObject(State^.SelectionBM);
      State^.SelectionBM := 0;
    end;
  end;
end;

{ Set the current selection to none, but paste the selection bitmap down.
}
procedure TSelectTool.DropSelection;
var
  SelDC: HDC;
begin
  if State^.SelectionBM <> 0 then
  begin
    { Mark the bitmap as having been modified }
    State^.IsDirtyBitmap := True;

    { Copy the selection bitmap back }
    SelDC := CreateCompatibleDCW(Window);
    State^.SelectionBM := SelectObject(SelDC, State^.SelectionBM);
    with State^.Selection, State^ do
      BitBlt(MemDC, Left + Offset.X, Top + Offset.Y,
        Right + Offset.X, Bottom + Offset.Y, SelDC, 0, 0, SrcCopy);
    State^.SelectionBM := SelectObject(SelDC, State^.SelectionBM);

    { Clean up }
    DeleteDC(SelDC);
  end;
  ReleaseSelection;
end;

{ TEllipseTool }

{ Draw an ellipse.
}
procedure TEllipseTool.DrawObject(aDC: HDC);
begin
  Ellipse(aDC, X1, Y1, X2, Y2);
end;

{ TLineTool }

{ Actual drawing }
procedure TLineTool.DrawObject(aDC: HDC);
begin
  MoveTo(aDC, X1, Y1);
  LineTo(aDC, X2, Y2);
end;

end.
