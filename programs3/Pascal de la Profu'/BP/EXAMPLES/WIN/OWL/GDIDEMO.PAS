{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program GDIDemo;

uses WinProcs, WinTypes, Objects, OWindows, ODialogs, Strings;

{$R GDIDEMO.RES}

{ Menu bar constants }
const
  MenuID              = 100; { Resource ID of the menu }
  QuitID              = 100; { File->Quit ID }
  MoveToLineToDemoID  = 200; { Demo->MoveToDemo ID }
  FontDemoID          = 202; { Demo->Font Demo ID }
  BitBltDemoID        = 203; { Demo->BitBlt Demo ID }
  ArtyDemoID          = 204; { Demo->Arty Demo ID }

{ BitBlt demo constants }
const
  BackgroundID        = 100; { Bitmap ID of background bitmap }
  ShipID              = 101; { Bitmap ID of Ship Bitmap }
  MonoShipID          = 102; { Bitmap ID of Monochrome mask of ship }
  BitmapSize          = 72;  { Size of Ship bitmap }

{ Font demo constants }
const
  MaxNumFonts =  20; { Maximum number of fonts to be displayed in FontDemo }

{ MoveToLineTo demo constants }
const
  MaxPoints   =  15; { Number of points to be drawn in MoveToLineToDemo }

{ Arty demo constants }
const
   MaxLineCount  = 100;
   MaxIconicLineCount = 5;
   MaxColorDuration = 10;

function Min(X, Y: Integer): Integer;
begin
  if X > Y then Min := Y else Min := X;
end;

{ TBaseDemoWindow -------------------------------------------------- }

type
  PBaseDemoWindow = ^TBaseDemoWindow;
  TBaseDemoWindow = object(TWindow)
    procedure TimerTick; virtual;
  end;

{ Trivial method that gets called whenever application receives a
  WM_Timer.  Descendants will override this procedure if they need
  timer messages.}
procedure TBaseDemoWindow.TimerTick;
begin
end;

{ TNoIconWindow --------------------------------------------------- }

type
  PNoIconWindow = ^TNoIconWindow;
  TNoIconWindow = object(TBaseDemoWindow)
    procedure GetWindowClass(var AWndClass: TWndClass);  virtual;
    function GetClassName: PChar;  virtual;
  end;

{ Alter the default window class record to make this window have
  a black background and no "white box" icon.  }
procedure TNoIconWindow.GetWindowClass(var AWndClass: TWndClass);
begin
  TBaseDemoWindow.GetWindowClass(AWndClass);
  AWndClass.hbrBackground := GetStockObject(Black_Brush);
  AWndClass.hIcon := 0;
end;

{ No need to call the ancestor's method here, since we want to
  provide an entirely new window class name. }
function TNoIconWindow.GetClassName: PChar;
begin
  GetClassName := 'NoIconWindow';
end;

{ TMoveToLineToWindow --------------------------------------------- }

type
  TRPoint = record
    X, Y: Real;
  end;

type
  PMoveToLineToWindow = ^TMoveToLineToWindow;
  TMoveToLineToWindow = object(TBaseDemoWindow)
    Points: array[0..MaxPoints] of TRPoint;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
  end;

constructor TMoveToLineToWindow.Init(AParent: PWindowsObject; ATitle: PChar);
var
  I: Integer;
  StepAngle: Integer;
  Radians: Real;
begin
  TBaseDemoWindow.Init(AParent, ATitle);
  StepAngle := 360 div MaxPoints;
  for I := 0 to MaxPoints - 1 do
  begin
    Radians := (StepAngle * I) * PI / 180;
    Points[I].x := Cos(Radians);
    Points[I].y := Sin(Radians);
  end;
end;

procedure TMoveToLinetoWindow.Paint(PaintDC: HDC;
  var PaintInfo: TPaintStruct);
var
  TheRect: TRect;
  I, J: Integer;
  CenterX,
  CenterY: Integer;
  Radius: Word;
begin
  GetClientRect(HWindow,TheRect);
  CenterX := TheRect.Right div 2;
  CenterY := TheRect.Bottom div 2;
  Radius := Min(CenterY, CenterX);
  Ellipse(PaintDC,CenterX - Radius, CenterY - Radius, CenterX + Radius,
    CenterY + Radius);
  for I := 0 to MaxPoints - 1 do
  begin
    for J := I + 1 to MaxPoints - 1 do
    begin
      MoveTo(PaintDC, CenterX + Round(Points[I].X * Radius),
	CenterY + Round(Points[I].Y * Radius));
      LineTo(PaintDC, CenterX + Round(Points[J].X * Radius),
	CenterY + Round(Points[J].Y * Radius));
    end;
  end;
end;

{ TFontWindow ------------------------------------------------------ }

type
  FontInfoRec = record
    Handle: HFont;  { Handle to logical font }
    Height: Byte;   { Height of logical font in pixels }
    Width: LongInt; { Width of name of the font in pixels }
    Name: array[0..lf_FaceSize-1] of char; { Name of this font }
  end;

const
  FontUsers: Integer = 0;
var
  FontInfo: array[0..MaxNumFonts] of FontInfoRec;
  NumFonts: Integer; { Number of system fonts available }
  TheDC: HDC;

type
  PFontWindow = ^TFontWindow;
  TFontWindow = object(TBaseDemoWindow)
    FontsHeight: LongInt;
    FontsWidth: LongInt;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure Destroy; virtual;
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;
  end;

{ EnumerateFont is a call back function.  It receives information
  about system fonts.  It creates an example of each font by calling
  CreateFont when MaxNumFonts have been processed, 0 is returned
  notifying windows to stop sending information, otherwise 1 is
  returned telling windows to send more information if available }
function EnumerateFont(var LogFont: TLogFont; TextMetric: PTextMetric;
  FontType: Integer; Data: PChar): Integer; export;
var
  OldFont: HFont;
begin
  { Create the font described by LogFont }
  FontInfo[NumFonts].Handle := CreateFontIndirect(LogFont);
  with LogFont do
  begin
    { Save the height of the font for positioning when drawing in
      the window }
    FontInfo[NumFonts].Height := lfHeight;
    { Save the name of the font for drawing in the window }
    StrCopy(FontInfo[NumFonts].Name, lfFaceName);
    OldFont := SelectObject(TheDC, FontInfo[NumFonts].Handle);
    FontInfo[NumFonts].Width := Word(GetTextExtent(TheDC, lfFaceName,
      StrLen(lfFaceName)));
    SelectObject(TheDC, OldFont);
  end;
  Inc(NumFonts);
  if NumFonts > MaxNumFonts then
    EnumerateFont := 0 { Don't send any more information }
  else
    EnumerateFont := 1; { Send more information if available }
end;

{ Collect all of the system fonts }
procedure GetFontInfo;
var
  EnumProc: TFarProc;
begin
  if FontUsers = 0 then
  begin
    TheDC := GetDC(GetFocus);
    NumFonts := 0;
    { Create an instance of the call back function.  This allows
      our program to refer to an exported function.  Otherwise the
      Data segment will not be correct. }
    EnumProc := MakeProcInstance(@EnumerateFont, HInstance);
    { Gather information about all fonts that are allowable in our window (DC) }
    EnumFonts(TheDC, nil, EnumProc, nil);
    { Free the instance of our call back function }
    FreeProcInstance(EnumProc);
    ReleaseDC(GetFocus, TheDC);
  end;
  Inc(FontUsers);
end;

{ Release font information }
procedure ReleaseFontInfo;
var
  I: Integer;
begin
  Dec(FontUsers);
  if FontUsers = 0 then
    for I := 0 to NumFonts - 1 do
      DeleteObject(FontInfo[I].Handle);
end;

{ Initialize object and collect font information }
constructor TFontWindow.Init(AParent: PWindowsObject; ATitle: PChar);
var
  I: Integer;

function Max(I, J: LongInt): LongInt;
begin
  if I > J then Max := I else Max := J;
end;

begin
  TBaseDemoWindow.Init(AParent, ATitle);
  GetFontInfo;
  Attr.Style := Attr.Style or ws_VScroll or ws_HScroll;
  FontsHeight := 0;
  FontsWidth := 0;
  for I := 0 to NumFonts - 1 do
  begin
    Inc(FontsHeight, FontInfo[I].Height);
    FontsWidth := Max(FontsWidth, FontInfo[I].Width);
  end;
  Scroller := New(PScroller, Init(@Self, 1, 1, 0, 0));
end;

{ Draw each font name in it's font in the Display context.  Each
  line is incremented by the height of the font }
procedure TFontWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  I: Integer;
  Position: Integer;
begin
  Position := 0;
  for I := 0 to NumFonts - 1 do
  begin
    SelectObject(PaintDC, FontInfo[I].Handle);
    TextOut(PaintDC, 10, Position, FontInfo[I].Name,
      StrLen(FontInfo[I].Name));
    Inc(Position, FontInfo[I].Height);
  end;
end;

procedure TFontWindow.Destroy;
begin
  TBaseDemoWindow.Destroy;
  ReleaseFontInfo;
end;

procedure TFontWindow.WMSize(var Msg: TMessage);
begin
  TWindow.WMSize(Msg);
  if Scroller <> nil then
    Scroller^.SetRange(FontsWidth - Msg.lParamLo + 10,
      FontsHeight - Msg.lParamHi);
end;

{ TBitBltWindow ---------------------------------------------------- }

type
  PBitBltWindow = ^TBitBltWindow;
  TBitBltWindow = object(TNoIconWindow)
    WindowSize: TPoint;
    ScratchBitmap,
    StretchedBkgnd,
    Background,
    MonoShip,
    Ship: HBitmap;
    OldX, OldY,
    Delta,
    X, Y: Integer;
    CurClick: Integer;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    destructor Done; virtual;
    procedure WMSize(var Message: TMessage); virtual WM_Size;
    procedure WMPaint(var Message: TMessage); virtual WM_Paint;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure SetupWindow; virtual;
    procedure TimerTick; virtual;
    procedure CalculateNewXY;
  end;

{ Initialize the bitblt demo window and allocate bitmaps }
constructor TBitBltWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  TNoIconWindow.Init(AParent, ATitle);
  Background := LoadBitmap(HInstance, MakeIntResource(BackgroundID));
  Ship := LoadBitmap(HInstance, MakeIntResource(ShipID));
  MonoShip := LoadBitmap(HInstance, MakeIntResource(MonoShipID));
  ScratchBitmap := 0;
  StretchedBkgnd := 0;
  OldX := 0;
  OldY := 0;
  X := 0;
  Y := 0;
  Delta := 5;
  CurClick := 1;
end;

{ Dispose of all used resources }
destructor TBitBltWindow.Done;
begin
  DeleteObject(Background);
  DeleteObject(Ship);
  DeleteObject(MonoShip);
  if ScratchBitmap <> 0 then DeleteObject(ScratchBitmap);
  if StretchedBkgnd <> 0 then DeleteObject(StretchedBkgnd);
  TNoIconWindow.Done;
end;

{ Allocate scratch bitmaps }
procedure TBitBltWindow.SetupWindow;
var
  HandleDC: HDC;
begin
  TNoIconWindow.SetupWindow;
  HandleDC := GetDC(HWindow);
  ScratchBitmap := CreateCompatibleBitmap(HandleDC, 80, 80);
  StretchedBkgnd := CreateCompatibleBitmap(HandleDC, 1000, 1000);
  ReleaseDC(HWindow, HandleDC);
end;

{ Record the new size and stretch the background to it }
procedure TBitBltWindow.WMSize(var Message: TMessage);
var
  HandleDC, MemDC, StretchedDC: HDC;
  StretchObject, MemObject: THandle;
  OldCur: HCursor;
begin
  TNoIconWindow.WMSize(Message);
  WindowSize.X := Message.LParamLo;
  WindowSize.Y := Message.LParamHi;

  HandleDC := GetDC(HWindow);

  { Create a stretched to fit background }
  StretchedDC := CreateCompatibleDC(HandleDC);
  MemDC := CreateCompatibleDC(HandleDC);
  StretchObject := SelectObject(StretchedDC, StretchedBkgnd);
  MemObject := SelectObject(MemDC, Background);
  OldCur := SetCursor(LoadCursor(0, idc_Wait));
  with WindowSize do
    StretchBlt(StretchedDC, 0, 0, X, Y, MemDC, 0, 0, 100, 100, SrcCopy);
  SetCursor(OldCur);
  SelectObject(StretchedDC, StretchObject);
  SelectObject(MemDC, MemObject);
  DeleteDC(MemDC);
  DeleteDC(StretchedDC);
  ReleaseDC(HWindow, HandleDC);
end;

{ Need to ensure that the Old copy of the ship gets redrawn with
  any paint messages. }
procedure TBitBltWindow.WMPaint(var Message: TMessage);
var
  Rect: TRect;
begin
  Rect.Top := OldY;
  Rect.Left := OldX;
  Rect.Bottom := OldY+BitmapSize;
  Rect.Right := OldX+BitmapSize;
  InvalidateRect(HWindow, @Rect, False);
  TNoIconWindow.WMPaint(Message);
end;

procedure TBitBltWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  MemDC: HDC;
  MemObject: THandle;
begin
  MemDC := CreateCompatibleDC(PaintDC);
  MemObject := SelectObject(MemDC, StretchedBkgnd);
  with WindowSize do
    BitBlt(PaintDC, 0, 0, X, Y, MemDC, 0, 0, SrcCopy);
  SelectObject(MemDC, MemObject);
  DeleteDC(MemDC);
end;

{ TimerTick deletes the old position of the saucer and blt's a new one }
procedure TBitBltWindow.TimerTick;
const
  ClicksToSkip = 4;
var
  Bits, BackingStore, WindowDC: HDC;
  SavedBitsObject, SavedStoreObject: THandle;
  BX, BY, OX, OY, BH, BW: Integer;
begin
  { Make the saucer go slower then everyone else }
  if CurClick < ClicksToSkip then
  begin
    Inc(CurClick);
    Exit;
  end
  else CurClick := 1;

  TNoIconWindow.TimerTick;

  { Setup the DC's }
  WindowDC := GetDC(HWindow);
  Bits := CreateCompatibleDC(WindowDC);
  BackingStore := CreateCompatibleDC(WindowDC);

  CalculateNewXY;

  { Calulate the offsets into and dimentions of the backing store }
  BX := Min(X, OldX);
  BY := Min(Y, OldY);
  OX := Abs(X - BX);
  OY := Abs(Y - BY);
  BW := 72 + Abs(OldX - X);
  BH := 72 + Abs(OldY - Y);

  { Create an image into the backing store the will that, when blt into
    the window will both erase the old image and draw the new one. }
  SavedStoreObject := SelectObject(BackingStore, ScratchBitmap);
  SavedBitsObject := SelectObject(Bits, StretchedBkgnd);
  BitBlt(BackingStore, 0, 0, BW, BH, Bits, BX, BY, srcCopy);
  SelectObject(Bits, MonoShip);
  BitBlt(BackingStore, OX, OY, 72, 72, Bits, 0, 0, SrcAnd);
  SelectObject(Bits, Ship);
  BitBlt(BackingStore, OX, OY, 72, 72, Bits, 0, 0, SrcPaint);

  { Blt the backing store to the window }
  BitBlt(WindowDC, BX, BY, BW, BH, BackingStore, 0, 0, SrcCopy);

  { Clean up the DC's }
  SelectObject(Bits, SavedBitsObject);
  SelectObject(BackingStore, SavedStoreObject);
  DeleteDC(Bits);
  DeleteDC(BackingStore);
  ReleaseDC(HWindow, WindowDC);

  OldX := X;
  OldY := Y;
end;

procedure TBitBltWindow.CalculateNewXY;
begin
  if WindowSize.X < BitmapSize then Exit;  { Don't move if too small }
  if (X > WindowSize.X - BitmapSize) or (X < 0) then
  begin
    Delta := -Delta;
    if X > WindowSize.X - BitmapSize then
      X := WindowSize.X - BitmapSize - 5;
  end;
  X := X + Delta;
  Y := Y + Integer(Random(10)) - 5;
  if Y > WindowSize.Y - BitmapSize then Y := WindowSize.Y - BitmapSize
  else if Y < 0 then Y := 0;
end;

{ TArtyWindow ------------------------------------------------------ }

type
  TLineRec = record
    LX1,LY1: Integer;
    LX2,LY2: Integer;
    Color: Longint;
  end;

  PLineList = ^TLineList;
  TLineList = array[1..MaxLineCount] of TLineRec;

  PList = ^TList;
  TList = object(TObject)
    Line: PLineList;
    MaxLines,
    Xmax, Ymax,
    X1, Y1, X2, Y2,
    MaxDelta,
    ColorDuration,
    IncrementCount,
    DeltaX1, DeltaY1, DeltaX2, DeltaY2,
    CurrentLine: Integer;
    PenColor: Longint;
    Paused: Boolean;
    constructor Init(Max: Integer);
    destructor Done;  virtual;
    procedure AdjustX(var X, DeltaX: Integer);
    procedure AdjustY(var Y, DeltaY: Integer);
    procedure Draw(DC: HDC; a1, b1, a2, b2: Integer; lPenColor: Longint);
    procedure DrawLine(DC: HDC; Index: Integer);  virtual;
    procedure EraseLine(DC: HDC; Index: Integer); virtual;
    procedure Redraw(DC: HDC);
    procedure ResetLines;
    procedure ScaleTo(NewXmax, NewYmax: Integer);
    procedure SelectNewColor;
    procedure SelectNewDeltaValues;
    procedure LineTick(DC: HDC);
  end;

  PQuadList = ^TQuadList;
  TQuadList = object(TList)   { Quads draw 4 reflections of each line }
    procedure DrawLine(DC: HDC; Index: Integer);  virtual;
    procedure EraseLine(DC: HDC; Index: Integer);  virtual;
  end;

  PArtyWindow = ^TArtyWindow;
  TArtyWindow = object(TNoIconWindow)
    List,
    BigLineList,
    IconicLineList : PList;
    TextHeight: Integer;
    Iconized : Boolean;
    StaticControl: PStatic;
    constructor Init(aParent: PWindowsObject; aTitle: PChar);
    destructor Done;  virtual;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure WMLButtonDown(var Message: TMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMRButtonDown(var Message: TMessage);
      virtual wm_First + wm_RButtonDown;
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;
    procedure TimerTick; virtual;
  end;

{ Initialize the list-of-lines object }
constructor TList.Init(Max: Integer);
begin
  TObject.Init;
  If Max > MaxLineCount then
    Max := MaxLineCount;

  { Don't change MaxLines!  It will be used to free memory in Done}
  MaxLines := Max;
  GetMem(Line, SizeOf(TLineRec) * MaxLines);
  CurrentLine := 1;
  Xmax := 0;
  Ymax := 0;
  ColorDuration := MaxColorDuration;
  IncrementCount := 0;
  MaxDelta := 10;
  PenColor := RGB(Random(256), Random(256), Random(256));
  Paused := False;
end;

destructor TList.Done;
begin
  FreeMem(Line, SizeOf(TLineRec) * MaxLines);
  TObject.Done;
end;

{ Keep X within range, and reverse Delta if necessary to do so }
procedure TList.AdjustX(var X, DeltaX: Integer);
var
  TestX: Integer;
begin
  TestX := X + DeltaX;
  if (TestX < 1) or (TestX > Xmax) then
  begin
    TestX := X;
    DeltaX := -DeltaX;
  end;
  X := TestX;
end;

{ Keep Y within range, and reverse Delta if necessary to do so }
procedure TList.AdjustY(var Y,DeltaY: Integer);
var
  TestY: Integer;
begin
  TestY := Y + DeltaY;
  if (TestY < 1) or (TestY > Ymax) then
  begin
    TestY := Y;
    DeltaY := -DeltaY;
  end;
  Y := TestY;
end;

{ Clear the array of lines }
procedure TList.ResetLines;
var
  StartX, StartY, I: Integer;
begin
  StartX := Xmax div 2;
  StartY := Ymax div 2;
  for I := 1 to MaxLines do
    with Line^[I] do
    begin
      LX1 := StartX; LX2 := StartX;
      LY1 := StartY; LY2 := StartY;
      Color := 0;
    end;
  X1 := StartX;
  X2 := StartX;
  Y1 := StartY;
  Y2 := StartY;
end;

{ Scale the old line coordinates to the new Xmax and Ymax coordinates.
  The new Xmax and new Ymax are passed in as parameters so we can
  calculate the scaling ratios. }
procedure TList.ScaleTo(NewXmax, NewYMax: Integer);
var
  I: Integer;
  RatioX, RatioY: Real;
begin
  if (Xmax = 0) or (Ymax = 0) then { at startup, Xmax and Ymax are zero }
  begin
    Xmax := NewXmax;
    Ymax := NewYmax;
    ResetLines;
  end
  else
  begin
    RatioX := NewXMax / Xmax;
    RatioY := NewYmax / Ymax;
    X1 := Trunc(X1 * RatioX);
    X2 := Trunc(X2 * RatioX);
    Y1 := Trunc(Y1 * RatioY);
    Y2 := Trunc(Y2 * RatioY);
    for I := 1 to MaxLines do
      with Line^[I] do
      begin
	LX1 := Trunc(LX1 * RatioX);
	LX2 := Trunc(LX2 * RatioX);
	LY1 := Trunc(LY1 * RatioY);
	LY2 := Trunc(LY2 * RatioY);
      end;
  end;
  Xmax := NewXmax;
  Ymax := NewYmax;
end;

{ The low-level Draw method of the object. }
procedure TList.Draw(DC: HDC; a1, b1, a2, b2: Integer; lPenColor: Longint);
var
  OldPen: HPen;
begin
  OldPen := SelectObject(DC, CreatePen(PS_SOLID, 1, lPenColor));
  MoveTo(DC, a1, b1);
  LineTo(DC, a2, b2);
  DeleteObject(SelectObject(DC, OldPen));
end;

{ The high-level Draw method of the object. }
procedure TList.DrawLine(DC: HDC; Index: Integer);
begin
  with Line^[Index] do
    Draw(DC, LX1, LY1, LX2, LY2, Color);
end;

{ The high-level draw which erases a line. }
procedure TList.EraseLine(DC: HDC; Index: Integer);
begin
  with Line^[Index] do
    Draw(DC, LX1, LY1, LX2, LY2, RGB(0, 0, 0));
end;

{ Redraw all the lines in the array. }
procedure TList.Redraw(DC: HDC);
var I: Integer;
begin
  for I := 1 to MaxLines do
    DrawLine(DC, I);
end;

{ Reset the color counter and pick a random color. }
procedure TList.SelectNewColor;
begin
  ColorDuration := MaxColorDuration;
  PenColor := RGB(Random(256), Random(256), Random(256));
end;

{ Pick random directional deltas and reset the delta counter. }
procedure TList.SelectNewDeltaValues;
begin
  DeltaX1 := Random(MaxDelta)-(MaxDelta Div 2);
  DeltaX2 := Random(MaxDelta)-(MaxDelta Div 2);
  DeltaY1 := Random(MaxDelta)-(MaxDelta Div 2);
  DeltaY2 := Random(MaxDelta)-(MaxDelta Div 2);
  IncrementCount := 2*(1+Random(10));
end;

{ Process the movement of one line. }
procedure TList.LineTick(DC: HDC);
begin
    EraseLine(DC, CurrentLine);
    if ColorDuration < 0 then SelectNewColor;
    if IncrementCount=0 then SelectNewDeltaValues;
    AdjustX(X1,DeltaX1); AdjustX(X2,DeltaX2);
    AdjustY(Y1,DeltaY1); AdjustY(Y2,DeltaY2);
    with Line^[CurrentLine] do
    begin
      LX1 := X1;  LX2 := X2;
      LY1 := Y1;  LY2 := Y2;
      Color := PenColor;
    end;
    DrawLine(DC, CurrentLine);
    Inc(CurrentLine);
    if CurrentLine > MaxLines then CurrentLine := 1;
    Dec(ColorDuration);
    Dec(IncrementCount);
end;

{ Draw the line and 3 reflections of it. }
procedure TQuadList.DrawLine(DC: HDC; Index: Integer);
begin
  with Line^[Index] do
  begin
    Draw(DC,LX1,LY1,LX2,LY2,Color);
    Draw(DC,Xmax-LX1,LY1,Xmax-LX2,LY2,Color);
    Draw(DC,LX1,Ymax-LY1,LX2,Ymax-LY2,Color);
    Draw(DC,Xmax-LX1,Ymax-LY1,Xmax-LX2,Ymax-LY2,Color);
  end;
end;

{ Erase the line and 3 reflections of it. }
procedure TQuadList.EraseLine(DC: HDC; Index: Integer);
begin
  with Line^[Index] do
  begin
    Draw(DC, LX1, LY1, LX2, LY2, RGB(0,0,0));
    Draw(DC, Xmax-LX1, LY1,Xmax-LX2, LY2, RGB(0,0,0));
    Draw(DC, LX1,Ymax-LY1, LX2, Ymax-LY2, RGB(0,0,0));
    Draw(DC, Xmax-LX1, Ymax-LY1, Xmax-LX2, Ymax-LY2, RGB(0,0,0));
  end;
end;

constructor TArtyWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  TNoIconWindow.Init(AParent, ATitle);
  StaticControl := New(PStatic,Init(@Self,100,
    'Press Left Button to pause, Right Button to Clear',10,10,10,10,0));
  Iconized := False;
  TextHeight := 20;

  { Initialize two line list objects:
      BigLineList is the 4-reflection artwork that is displayed in
	a full sized window.  Mouse clicks will pause or clear
	the display, and the line list will be scaled to the
	new window coordinates when the window is resized.
      IconicLineList is a smaller list implementing a single-line
	quark to display in the iconized window region.  Since
	mouse clicks are not sent to iconized windows, the icon
	cannout be paused or cleared, and since there is only one
	icon window size, scaling the lines to new coordinates
	has no visual effect.
    The List pointer will be toggled between the two line list
    objects: when the window is iconized, List will point to the
    IconicLineList object.  When the window is restored to full
    size, List will be made to point to the BigLineList object.
    This is so the window routines don't have to know which kind
    of list they're dealing with.  Keyword: polymorphism.   }

  BigLineList := New(PQuadList, Init(MaxLineCount));
  IconicLineList := New(PList, Init(MaxIconicLineCount));
  List := BigLineList;
end;

{ Dispose of the objects that this window object created.  There's
  no need to dispose the List pointer, since it will only point to
  one of these two objects which are being disposed by their
  primary pointers }
destructor TArtyWindow.Done;
begin
  TNoIconWindow.Done;
  Dispose(BigLineList, Done);
  Dispose(IconicLineList, Done);
end;

{ When the window is resized, scale the line list to fit the new
  window extent, or switch between full size and iconized window
  states.  }
procedure TArtyWindow.WMSize(var Msg: TMessage);
var
  NewXmax, NewYmax: Integer;
begin
  TNoIconWindow.WMSize(Msg);
  { Force Windows to repaint the entire window region }
  InvalidateRect(HWindow, nil, True);
  NewXmax := Msg.LParamLo;
  NewYmax := Msg.LParamHi;
  if IsIconic(HWindow) then
    if not Iconized then
    begin
      Iconized := True;
      List := IconicLineList;
    end
    else
  else
  begin
    if Iconized then
    begin
      Iconized := False;
      List := BigLineList;
    end;
    Dec(NewYmax, TextHeight);  { allow room for the text at the bottom }
  end;
  List^.ScaleTo(NewXmax, NewYmax);  { scale the lines in the list }
  MoveWindow(StaticControl^.HWindow, 0, NewYmax, NewXmax, TextHeight, True);
end;

{ Toggle the list object's Paused status.  Since the window will
  not receive mouse clicks when iconized, this will not pause the
  iconized lines display.  }
procedure TArtyWindow.WMLButtonDown(var Message: TMessage);
begin
  List^.Paused := not List^.Paused;
end;

{ Clear the line list when the user presses the right mouse
  button.  Same comments as above on iconized windows.  }
procedure TArtyWindow.WMRButtonDown(var Message: TMessage);
begin
  InvalidateRect(HWindow,nil,True);
  List^.ResetLines;
end;

{ When the window is resized, or some other window blots out part
  of our client area, redraw the entire line list.  The PaintDC
  is fetched before Paint is called and is released for us after
  Paint is finished. }
procedure TArtyWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
begin
  TNoIconWindow.Paint(PaintDC, PaintInfo);
  List^.Redraw(PaintDC);
end;

{ Fetch a device context, pass it to the line list object, then
  release the device context back to Windows.  }
procedure TArtyWindow.TimerTick;
var
  DC: HDC;
begin
  if not List^.Paused then
  begin
    DC := GetDC(HWindow);
    List^.LineTick(DC);
    ReleaseDC(HWindow, DC);
  end;
end;

{ TGDIDemoWindow --------------------------------------------------- }

type
  PGDIDemoWindow = ^TGDIDemoWindow;
  TGDIDemoWindow = object(TMDIWindow)
    procedure SetupWindow; virtual;
    procedure MoveToLineToDemo(var Msg: TMessage);
      virtual cm_First + MoveToLineToDemoID;
    procedure FontDemo(var Msg: TMessage);
      virtual cm_First + FontDemoID;
    procedure BitBltDemo(var Msg: TMessage);
      virtual cm_First + BitBltDemoID;
    procedure ArtyDemo(var Msg: TMessage);
      virtual cm_First + ArtyDemoID;
    procedure Quit(var Msg: TMessage);
      virtual cm_First + QuitID;
    procedure WMTimer(var Msg: TMessage);
      virtual wm_First + wm_Timer;
    procedure WMDestroy(var Msg: TMessage);
      virtual wm_First + wm_Destroy;
  end;

procedure TGDIDemoWindow.SetupWindow;
var
  Result: Integer;
begin
  TMDIWindow.SetupWindow;
  Result := IDRetry;
  while (SetTimer(hWIndow, 0, 50, nil) = 0) and (Result = IDRetry) do
    Result := MessageBox(GetFocus,'Could not Create Timer', 'GDIDemo',
      mb_RetryCancel);
  if Result = IDCancel then PostQuitMessage(0);
end;

procedure TGDIDemoWindow.MoveToLineToDemo(var Msg: TMessage);
begin
  Application^.MakeWindow(New(PMoveToLineToWindow, Init(@Self,
    'MoveTo/LineTo Window')));
end;

procedure TGDIDemoWindow.FontDemo(var Msg: TMessage);
begin
  Application^.MakeWindow(New(PFontWindow, Init(@Self, 'Font Window')));
end;

procedure TGDIDemoWindow.BitBltDemo(var Msg: TMessage);
begin
  Application^.MakeWindow(New(PBitBltWindow, Init(@Self, 'BitBlt Window')));
end;

procedure TGDIDemoWindow.ArtyDemo(var Msg: TMessage);
begin
  Application^.MakeWindow(New(PArtyWindow, Init(@Self, 'Arty Window')));
end;

procedure TGDIDemoWindow.Quit(var Msg: TMessage);
begin
  CloseWindow;
end;

{ In response to WMTimer messages, each MDI child window's TimerTick
  Method is called. }
procedure TGDIDemoWindow.WMTimer(var Msg: TMessage);

  procedure ChildTimers(PChildWindow: PBaseDemoWindow); far;
  begin
    PChildWindow^.TimerTick;
  end;

begin
  ForEach(@ChildTimers);
end;

procedure TGDIDemoWindow.WMDestroy(var Msg: TMessage);
begin
  KillTimer(HWindow, 0);
  TMDIWindow.WMDestroy(Msg);
end;

{ TGDIDemoApp ------------------------------------------------------ }

type
  TGDIDemoApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

procedure TGDIDemoApp.InitMainWindow;
begin
  { Create a main window of type TGDIWindow. }
  MainWindow := New(PGDIDemoWindow,
    Init('GDI Demo', LoadMenu(HInstance,MakeIntResource(MenuID))));
end;

var
  GDIDemoApp: TGDIDemoApp;

begin
  GDIDemoApp.Init('GDIDEMO');
  GDIDemoApp.Run;
  GDIDemoApp.Done;
end.
