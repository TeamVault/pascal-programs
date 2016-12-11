{************************************************}
{                                                }
{   Turbo Pascal for Windows                     }
{   Toolbar unit                                 }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit ToolBar;

interface

{$R Toolbar.res}

uses Winprocs, Wintypes, Objects, OWindows, Strings, Win31;

const
  am_CalcParentClientRect = wm_User + 120;
  tbHorizontal   = $01;
  tbLeftVertical = $02;
  tbRightVertical= $04;
  DenyRepaint  = 0;
  AllowRepaint = 1;

type

  PTool = ^TTool;
  TTool = object(TObject)
    Parent: PWindowsObject;
    constructor Init(AParent: PWindowsObject);
    function GetWidth: Integer; virtual;
    function GetHeight: Integer; virtual;
    function HitTest(P: TPoint): Boolean; virtual;
    procedure Paint(DC, AMemDC: HDC; var PS: TPaintStruct); virtual;
    procedure BeginCapture(P: TPoint); virtual;
    procedure ContinueCapture(P: TPoint); virtual;
    function EndCapture(SendTo: HWnd; P: TPoint): Boolean; virtual;
    function HasCommand(Command: Word): Boolean; virtual;
    procedure Enable(State: Boolean); virtual;
    procedure SetOrigin(X, Y: Integer); virtual; 
    procedure Read(var S: TStream); virtual;
    procedure Write(var S: TStream); virtual;
  end;  

  PToolbar = ^TToolbar;
  TToolbar = object(TWindow)
    ResName: PChar;
    Tools: TCollection;
    Capture: PTool;
    Orientation: Word;
    constructor Init(AParent: PWindowsObject; AName: PChar; Orient: Word);
    destructor Done; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream); virtual;
    function  CreateTool(Num: Integer; Origin: TPoint; Command: Word;
      BitmapName: PChar): PTool; virtual;
    procedure EnableTool(Command: Word; NewState: Boolean); virtual;
    procedure FreeResName;
    function  GetClassName: PChar; virtual;
    procedure GetWindowClass(var WC: TWndClass); virtual;
    procedure SetResName(NewName: PChar);
    procedure NextToolOrigin(Num: Integer; var Origin: TPoint;
      P: PTool); virtual;
    procedure Paint(DC: HDC; var PS: TPaintStruct); virtual;
    procedure ReadResource; virtual;
    function  GetOrientation: Word;  virtual;
    procedure SetOrientation(NewOrient: Word);  virtual;
    procedure SwitchTo(NewName: PChar);
    procedure AMCalcParentClientRect(var Msg: TMessage);
      virtual wm_First + AM_CalcParentClientRect;
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMMouseMove(var Msg: TMessage);
      virtual wm_First + wm_MouseMove;
    procedure WMLButtonUp(var Msg: TMessage);
      virtual wm_First + wm_LButtonUp;
  end;

  PToolSpacer = ^TToolSpacer;
  TToolSpacer = object(TTool)
    Size: Integer;
    constructor Init(AParent: PWindowsObject; ASize: Integer);
    function GetWidth: Integer; virtual;
    function GetHeight: Integer; virtual;
  end;

  PToolButton = ^TToolButton;
  TToolButton = object(TTool)
    bmGlyph: HBitmap;
    Command: Word;
    Capturing, IsPressed, IsEnabled: Boolean;
    R: TRect;
    GlyphSize: TPoint;
    CapDC, MemDC: HDC;
    constructor Init(AParent: PWindowsObject; X, Y: Integer; ACommand: Word;
      BitmapName: PChar);
    destructor Done; virtual;
    function HasCommand(ACommand: Word): Boolean; virtual;
    procedure Enable(State: Boolean); virtual;
    function GetWidth: Integer; virtual;
    function GetHeight: Integer; virtual;
    procedure SetOrigin(X, Y: Integer); virtual;
    function HitTest(P: TPoint): Boolean; virtual;
    procedure Paint(DC, AMemDC: HDC; var PS: TPaintStruct); virtual;
    procedure PaintState(DC, AMemDC: HDC);
    procedure BeginCapture(P: TPoint); virtual;
    procedure ContinueCapture(P: TPoint); virtual;
    function  EndCapture(SendTo: HWnd; P: TPoint): Boolean; virtual;
    procedure PressIn;
    procedure PressOut;
    procedure Read(var S: TStream); virtual;
    procedure Write(var S: TStream); virtual;  
  end;

const
  RToolbar: TStreamRec = (
    ObjType: 12301;
    VmtLink: Ofs(TypeOf(TToolbar)^);
    Load:    @TToolbar.Load;
    Store:   @TToolbar.Store);

implementation

{ Unit wide resourcs }

var
  WhitePen, DarkGrayPen, BlackPen: HPen;
  GrayBrush, GrayingBrush: HBrush;

function Max(A, B: Integer): Integer;
begin
  if A > B then
    Max := A
  else
    Max := B;
end;

{ TToolbar }

constructor TToolbar.Init(AParent: PWindowsObject; AName: PChar;
  Orient: Word);
begin
  inherited Init(AParent, nil);
  Attr.Style := ws_Child or ws_Visible or ws_Border;
  SetFlags(wb_MDIChild, False);
  DefaultProc := @DefWindowProc;
  Attr.X := -1;
  Attr.Y := -1;
  Attr.W := 5;    
  Attr.H := 5;
  Capture := nil;
  Orientation := Orient;
  ResName := nil;
  SetResName(AName);

  Tools.Init(8, 8);

  ReadResource;
end;

destructor TToolbar.Done;
begin
  inherited Done;
  Tools.Done;
  FreeResName;
end;

constructor TToolbar.Load(var S: TStream);
var
  X: Integer;

  procedure RestoreStates(P : PTool); far;
  begin
    P^.Read(S);
  end;

begin
  inherited Load(S);
  Attr.Style := ws_Child or ws_Visible or ws_Border;
  SetFlags(wb_MDIChild, False);
  DefaultProc := @DefWindowProc;
  Capture := nil;
  S.Read(Orientation, SizeOf(Orientation));
  Tools.Init(8,8);

  ResName := nil;
  S.Read(X, SizeOf(X));
  if X = 0 then
    S.Read(PtrRec(ResName).Ofs, SizeOf(Word))
  else
    ResName := S.StrRead; 

  ReadResource;
  if Status <> em_InvalidChild then
    Tools.ForEach(@RestoreStates)
  else
    S.Status := stGetError;
end;


procedure TToolbar.Store(var S: TStream);
var
  X: Integer;

  procedure SaveStates(P : PTool); far;
  begin
    P^.Write(S);
  end;

begin
  inherited Store(S);
  S.Write(Orientation, SizeOf(Orientation));
  if HiWord(Longint(ResName)) <> 0 then
  begin
    X := 1;
    S.Write(X, SizeOf(X));
    S.StrWrite(ResName);
  end
  else
  begin
    X := 0;
    S.Write(X, SizeOf(X));
    S.Write(PtrRec(ResName).Ofs, SizeOf(Word));
  end;
  Tools.ForEach(@SaveStates);
end;

procedure TToolbar.ReadResource;
type
  ResRec = record
    Bitmap,
    Command: Word;
  end;

  PResArray = ^TResArray;
  TResArray = array [1..$FFF0 div sizeof(ResRec)] of ResRec;

var
  ResIdHandle: THandle;
  ResDataHandle: THandle;
  ResDataPtr: PResArray;
  Count: Word;
  X: Word;
  Origin: TPoint;
  BitInfo: TBitmap;
  P: PTool;

begin
  ResIDHandle := FindResource(HInstance, ResName, 'ToolBarData');
  ResDataHandle := LoadResource(HInstance, ResIDHandle);
  ResDataPtr := LockResource(ResDataHandle);
  if (ResIDHandle = 0) or (ResDataHandle = 0) or (ResDataPtr = nil) then
  begin
    Status := em_InvalidChild;
    Exit;
  end;

  X := 0;
  Origin.X := 2;
  Origin.Y := 2;

  Count := PWord(ResDataPtr)^;
  Inc(LongInt(ResDataPtr), SizeOf(Count)); { Skip Count }
  for X := 1 to Count do
    with ResDataPtr^[X] do
    begin
      P := CreateTool(X, Origin, Command, PChar(Bitmap));
      if P <> nil then
      begin
        NextToolOrigin(X, Origin, P);
        Tools.Insert(P);
      end;
    end;

  Inc(Attr.H, 8);
  Inc(Attr.W, 8);

  UnlockResource(ResDataHandle);
  FreeResource(ResDataHandle);
end;

function TToolbar.GetOrientation: Word;
begin
  GetOrientation := Orientation;
end;

procedure TToolbar.SetOrientation(NewOrient: Word);
var
  X: Integer;
  Origin: TPoint;

  procedure ResetOrigins(P : PTool); far;
  begin
    P^.SetOrigin(Origin.X, Origin.Y);
    NextToolOrigin(X, Origin, P);
    Inc(X);
  end;

begin
  Orientation := NewOrient;
  Attr.H := 5;
  Attr.W := 5;
  X := 0;
  Origin.X := 2;
  Origin.Y := 2;
  Tools.ForEach(@ResetOrigins);
  Inc(Attr.W, 8);
  Inc(Attr.H, 8);
  SetWindowPos(HWindow, 0, -1, -1, Attr.W, Attr.H,  swp_NoZOrder or
    swp_NoRedraw);
end;


{ You may override CreateTool to make Toolbar use a different
  kind of ToolButton object }

function TToolbar.CreateTool(Num: Integer; Origin: TPoint;
  Command: Word; BitmapName: PChar): PTool;
begin
  if Word(BitmapName) = 0 then
    CreateTool := New(PToolSpacer, Init(@Self, Command))
  else
    CreateTool := New(PToolButton, Init(@Self, Origin.X, Origin.Y, Command,
      BitmapName));
end;

procedure TToolbar.EnableTool(Command: Word; NewState: Boolean);
var
  P: PTool;

  function FoundIt(P: PTool): Boolean; far;
  begin
    FoundIt := P^.HasCommand(Command);
  end;

begin
  P := Tools.FirstThat(@FoundIt);
  if P <> nil then
    P^.Enable(NewState);
end; 

function TToolbar.GetClassName: PChar;
begin
  GetClassName := 'OWLToolbar';
end;

procedure TToolbar.GetWindowClass(var WC: TWndClass);
begin
  TWindow.GetWindowClass(WC);
  WC.hbrBackground := GetStockObject(LtGray_Brush);
end;

{ NextToolOrigin should the origin for the next tool button based upon the
  current tool's size and the toolbar's primary orientation or layout
  system (horizontal, vertical, palette or other).  This method is called in
  the Toolbar's constructor after each tool that is added to the toolbar.

  The code below supports horizontal and vertical orientation.  Descendents
  of TToolbar can override this method to implement other layout schemes.}

procedure TToolbar.NextToolOrigin(Num: Integer; var Origin: TPoint;
  P: PTool);
begin
  case Orientation of
    tbHorizontal :
      begin
        Inc(Origin.X, P^.GetWidth);
        Attr.H := Max(Attr.H, P^.GetHeight);
      end;
   tbLeftVertical,
   tbRightVertical:
     begin
       Inc(Origin.Y, P^.GetHeight);
       Attr.W := Max(Attr.W, P^.GetWidth);
     end;
  end;
end;

procedure TToolbar.Paint(DC: HDC; var PS: TPaintStruct);
var
  MemDC: HDC;
  OldPen: HPen;

  procedure PaintIt(Item: PTool); far;
  begin
    Item^.Paint(DC, MemDC, PS);
  end;

begin
  OldPen := SelectObject(DC, WhitePen);
  MoveTo(DC, 0, 0);
  LineTo(DC, Attr.W + 1, 0);
  SelectObject(DC, OldPen);
  MemDC := CreateCompatibleDC(DC);
  Tools.ForEach(@PaintIt);
  DeleteDC(MemDC);
end;

{ FreeResName handles releasing memory, if necessary, occupied by a
  PChar / integer resource identifier }

procedure TToolbar.FreeResName;
begin
  if HiWord(Longint(ResName)) <> 0 then
    StrDispose(ResName);
end;

{ SetResName handles allocating memory, if necessary, to hold a PChar or
  integer resource identifier. }

procedure TToolbar.SetResName(NewName: PChar);
begin
  FreeResName;
  if HiWord(Longint(NewName)) <> 0 then
    ResName := StrNew(NewName)
  else
    ResName := NewName;
end;

{ Switch the Toolbar object to use a different toolbar resource. }

procedure TToolbar.SwitchTo(NewName: PChar);
begin
  Tools.Done;
  Tools.Init(8,8);
  SetResName(NewName);
  ReadResource;
end;

{ AMCalcParentClientRect is a message sent to the Toolbar by the main window.
  LParam points to a TRect filled with the main window's client rectangle.
  After passing this rect to each child window for possible modification,
  the main window will use it to resize the MDI Client window.  You can
  modify this rect to remove slices of the client window from any of the
  four sides.  Horizontal toolbars slice off the top of the client rect,
  while vertical toolbars take either a left or right slice.
  Note that other 'special' windows, such as a status line, may also
  modify the rect before or after the toolbar is given its chance.
  Do not assume the rect always starts out as the main window's
  full client area.  Base your calculations on the passed rect, not on
  direct observation of the main window's true client rect.

  This message will be sent to the child windows in Z-Order.  In
  situations where two special child windows might want to control the
  same corner (ie a vertical and a horizontal toolbar vie for the same
  corner), the window on top (first in ZOrder) will get the corner.  The
  lower window should accept the relocated client origin (passed in LParam)
  as the basis of owner-client origin calculations, so it will abut the
  side of the higher child window.

  If Msg.wParam is zero, the child window should not repaint anything in
  response to this message - the parent is only asking for info and doesn't
  want the child windows to repaint themselves yet.  If Msg.WParam is
  non-zero, the child may reposition or paint itself as needed to
  synchronise with the new client rect.  The following
  code keeps redraw flicker to an absolute minimum, so it's a little
  more complicated than the trivial case of just always repainting
  everything. }

procedure TToolbar.AMCalcParentClientRect( var Msg: TMessage);
var
  TB,               { Toolbar rect in screen coords }
  PC,               { Parent client rect in screen coords  }
  NewTB,            { New toolbar rect in screen coords    }
  R   : TRect;      { scratch }
  S2PC, S2TB: TPoint; { Screen to local coord. conversion offsets } 
  XOfs : Integer;
begin
  PC := PRect(Msg.LParam)^;
  R := PC;
  ClientToScreen(Parent^.HWindow, PPoint(@PC)^);
  ClientToScreen(Parent^.HWindow, PPoint(@PC.Right)^);
  S2PC.X := PC.Left - R.Left;
  S2PC.Y := PC.Top  - R.Top;

  GetWindowRect(HWindow, TB);
  S2TB.X := TB.Left ;
  S2TB.Y := TB.Top;

  if Orientation = tbHorizontal then
  begin
    if Bool(Msg.WParam) then  { We have permission to repaint & reposition }
    begin
      if TB.Right <> PC.Right then     { Parent client relative coords }
        SetWindowPos(HWindow, 0, -1, -1, PC.Right - S2TB.X + 1,
          TB.Bottom - S2TB.Y, swp_NoZOrder or swp_NoRedraw);
      if TB.Right < PC.Right then
      begin                      { Width increases, paint new area }
        SetRect(R, TB.Right - S2TB.X - 2, TB.Top - S2TB.Y - 1, 
          PC.Right - S2TB.X + 1, TB.Bottom - S2TB.Y +1);
        InvalidateRect(HWindow, @R, True);
      end;
    end;
    if PC.Top < TB.Bottom then
      PC.Top := TB.Bottom;
  end
  else
  if (Orientation and (tbLeftVertical or tbRightVertical)) <> 0 then
  begin
    if Orientation = tbRightVertical then
      XOfs := PC.Right - (TB.Right - TB.Left) + 2
    else
      XOfs := PC.Left;
    SetRect(NewTB, XOfs - 1, PC.Top  - 1, XOfs + (TB.Right - TB.Left) - 1,
      PC.Bottom);
    if Bool(Msg.WParam) then   { We have permission to repaint & reposition }
    begin
      if TB.Bottom <> PC.Bottom then
        SetWindowPos(HWindow, 0, NewTB.Left - S2PC.X, NewTB.Top - S2PC.Y,
          NewTB.Right - NewTB.Left, NewTB.Bottom - NewTB.Top + 1,
          swp_NoZOrder or swp_NoRedraw);

      if (TB.Left <> NewTB.Left) or (TB.Top <> NewTB.Top) then
      begin
        InvalidateRect(HWindow, nil, True) { Window moved, paint it all }
      end
      else
      if TB.Bottom < NewTB.Bottom then  { Height grew, paint new area }
      begin
        SetRect(R, NewTB.Left - S2TB.X - 1, TB.Bottom - S2TB.Y - 2,
          NewTB.Right - S2TB.X, NewTB.Bottom - S2TB.Y);
        InvalidateRect(HWindow, @R, True);
      end;
    end;

    if (Orientation = tbLeftVertical) and (PC.Left < NewTB.Right) then
      PC.Left := NewTB.Right;
    if (Orientation = tbRightVertical) and (PC.Right > NewTB.Left) then
      PC.Right := NewTB.Left;
  end;

  { Map the screen coord PC record back into parent relative coords }
  SetRect(PRect(Msg.LParam)^, PC.Left - S2PC.X, PC.Top - S2PC.Y,
    PC.Right - S2PC.X, PC.Bottom - S2PC.Y);
end;

procedure TToolbar.WMLButtonDown(var Msg: TMessage);

  function IsHit(Item: PTool): Boolean; far;
  begin
    IsHit := Item^.HitTest(TPoint(Msg.LParam));
  end;

begin
  Capture := Tools.FirstThat(@IsHit);
  if Capture <> nil then
    Capture^.BeginCapture(TPoint(Msg.LParam));
end;

procedure TToolbar.WMMouseMove(var Msg: TMessage);
begin
  if (Capture <> nil) then
    Capture^.ContinueCapture(TPoint(Msg.LParam));
end;

procedure TToolbar.WMLButtonUp(var Msg: TMessage); 
begin
  if (Capture <> nil) and Capture^.EndCapture(Parent^.HWindow,
      TPoint(Msg.LParam)) then
    Capture := nil;  
end;

{ TTool }

constructor TTool.Init(AParent: PWindowsObject);
begin
  Parent := AParent;
end;

function TTool.GetWidth: Integer;
begin
  GetWidth := 0;
end;
 
function TTool.GetHeight: Integer;
begin
  GetHeight := 0;
end;
 
function TTool.HitTest(P: TPoint): Boolean;
begin
  HitTest := False;
end;
 
procedure TTool.Paint(DC, AMemDC: HDC; var PS: TPaintStruct);
begin
end;
 
procedure TTool.BeginCapture(P: TPoint);
begin
end;

procedure TTool.ContinueCapture(P: TPoint);
begin
end;
 
function TTool.EndCapture(SendTo: HWnd; P: TPoint): Boolean;
begin
end;
 
procedure TTool.Enable(State: Boolean);
begin
end;

procedure TTool.SetOrigin(X, Y: Integer);
begin
end; 

function TTool.HasCommand(Command: Word): Boolean;
begin
  HasCommand := False;
end;
 
procedure TTool.Read(var S: TStream);
begin
end;
 
procedure TTool.Write(var S: TStream);
begin
end; 

{ TToolSpacer } 

constructor TToolSpacer.Init(AParent: PWindowsObject; ASize: Integer);
begin
  inherited Init(AParent);
  Size := ASize;
end;

function TToolSpacer.GetWidth: Integer;
begin
  GetWidth := Size;
end;
 
function TToolSpacer.GetHeight: Integer;
begin
  GetHeight := Size;
end;

{ TToolButton }

const
  BorderWidth = 2;

constructor TToolButton.Init(AParent: PWindowsObject; X, Y: Integer;
  ACommand: Word; BitmapName: PChar);
var
  BI: TBitmap;
  GrayBM, OldBM: HBitmap;
  OldPen: HPen;
begin
  inherited Init(AParent);
  CapDC := 0;
  MemDC := 0;
  IsPressed := False;
  Capturing := False;
  IsEnabled := True;
  Command := ACommand;
  bmGlyph := LoadBitmap(HInstance, BitmapName);
  GetObject(bmGlyph, SizeOf(BI), @BI);
  GlyphSize.X := BI.bmWidth;
  GlyphSize.Y := BI.bmHeight;
  SetRect(R, X, Y, X + BI.bmWidth + BorderWidth * 2, Y + BI.bmHeight +
    BorderWidth * 2);
end;

destructor TToolButton.Done;
begin
  if Capturing then
  begin
    DeleteDC(MemDC);
    ReleaseDC(Parent^.HWindow, CapDC);
    ReleaseCapture;
  end;
  if bmGlyph <> 0 then DeleteObject(bmGlyph);
  inherited Done;
end;

function TToolButton.HasCommand(ACommand: Word): Boolean;
begin
  HasCommand := Command = ACommand;
end;

procedure TToolButton.Enable(State: Boolean);
begin
  if (IsEnabled <> State) and (Parent^.HWindow <> 0) then
    InvalidateRect(Parent^.HWindow, @R, False);
  IsEnabled := State;
end;

function TToolButton.GetWidth: Integer;
begin
  GetWidth := R.Right - R.Left;
end;

function TToolButton.GetHeight: Integer;
begin
  GetHeight := R.Bottom - R.Top;
end;

procedure TToolButton.SetOrigin(X, Y: Integer);
var
  BI : TBitmap;
begin
  GetObject(bmGlyph, SizeOf(BI), @BI);
  SetRect(R, X, Y, X + BI.bmWidth + BorderWidth * 2,
    Y + BI.bmHeight + BorderWidth * 2);
end;

function TToolButton.HitTest(P: TPoint): Boolean;
begin
  HitTest := Boolean(PtInRect(R, P));
end;

{ InitButtonBitmaps loads the button images that the tool button glyphs
  will be copied onto.  TToolButton assumes all the tool buttons on the
  toolbar will be the same size.  If you want variable sized (width or
  height or both) tool buttons, create a descendent of TToolButton and
  override this method to create or stretch the button image to suite
  each tool's glyph size.  Creating bitmaps for each toolbutton uses more
  memory than several toolbuttons referencing the same bitmap resource.
  String names are used to identify the bitmaps to avoid integer id
  collisions with other bitmaps in the application.
}


procedure TToolButton.Paint(DC, AMemDC: HDC; var PS: TPaintStruct);
begin
  PaintState(DC, AMemDC);
end;

procedure TToolButton.PaintState(DC, AMemDC: HDC);
var
  OldBitmap: HBitmap;
  OldBrush: HBrush;
  OldPen: HPen;
  Offset: Integer;
begin
  OldPen := SelectObject(DC, BlackPen);
  OldBrush := SelectObject(DC, GrayBrush);
  with R do
  begin
    Rectangle(DC, Left, Top, Right + 1, Bottom + 1);
    if not IsPressed then
    begin
      Offset := BorderWidth;
      SelectObject(DC, WhitePen);
      MoveTo(DC, Left + 1, Bottom - 1);
      LineTo(DC, Left + 1, Top + 1);
      LineTo(DC, Right - 1, Top + 1);
      SelectObject(DC, DarkGrayPen);
      MoveTo(DC, Right - 1, Top + 1);
      LineTo(DC, Right - 1, Bottom - 1);
      LineTo(DC, Left + 1, Bottom - 1);
    end
    else
    begin
      Offset := BorderWidth + 1;
      SelectObject(DC, DarkGrayPen);
      MoveTo(DC, Left + 1, Bottom - 1);
      LineTo(DC, Left + 1, Top + 1);
      LineTo(DC, Right, Top + 1);
    end;
  end;

  OldBitmap := SelectObject(AMemDC, bmGlyph);
  if IsEnabled then
    BitBlt(DC, R.Left + Offset, R.Top + Offset, GlyphSize.X, GlyphSize.Y,
      AMemDC, 0, 0, SrcCopy)
  else
  begin
    UnRealizeObject(GrayingBrush);
    OldBrush := SelectObject(DC, GrayingBrush);
    BitBlt(DC, R.Left + Offset, R.Top + Offset, GlyphSize.X, GlyphSize.Y,
      AMemDC, 0, 0, $00A803A9 {DPSoa});
  end;

  SelectObject(DC, OldBrush);
  SelectObject(DC, OldPen);
  SelectObject(AMemDC, OldBitmap);
end;

procedure TToolButton.PressIn;
begin
  if (not IsPressed) and IsEnabled then
  begin
    IsPressed := True;
    PaintState(CapDC, MemDC);
  end;
end;

procedure TToolButton.PressOut;
begin
  if IsPressed then
  begin
    IsPressed := False;
    PaintState(CapDC, MemDC);
  end;
end;

procedure TToolButton.BeginCapture(P: TPoint);
begin
  CapDC := GetDC(Parent^.HWindow);
  MemDC := CreateCompatibleDC(CapDC);
  IsPressed := False;
  Capturing := True;
  SetCapture(Parent^.HWindow);
  if HitTest(P) then
    PressIn;
end;

procedure TToolButton.ContinueCapture(P: TPoint);
begin
  if HitTest(P) then
    PressIn
  else
    PressOut;
end;


{ The boolean function result of EndCapture indicates whether the tool button
  has released the mouse capture or not.  The Toolbar should not clear its
  capture field/state until the toolbutton says to.

  The SendTo parameter is the HWindow to notify that the tool button was clicked
  upon, if such is the case.  This code emulates a menu command message, but
  any message type could be used. }

function TToolButton.EndCapture(SendTo: HWnd; P: TPoint): Boolean;
begin
  if HitTest(P) then
  begin
    PressOut;
    PostMessage(SendTo, wm_Command, Command, 0);
  end;
  EndCapture := True;
  ReleaseCapture;
  Capturing := False;
  DeleteDC(MemDC);
  ReleaseDC(Parent^.HWindow, CapDC);
  MemDC := 0;
  CapDC := 0;
end;

{ Toolbuttons are not Loaded from the stream, but instead are constructed
  from the resource info and then allowed to read their state info from the stream.
  Conversely, the toolbuttons write state info but are not stored on the
  stream. }

procedure TToolButton.Read(var S: TStream);
begin
  S.Read(IsEnabled, SizeOf(IsEnabled));
end;

procedure TToolButton.Write(var S: TStream);
begin
  S.Write(IsEnabled, SizeOf(IsEnabled));
end;  

{ Allocate unit wide resources }
procedure AllocateResources;
const
  coDarkGray = $808080;
var
  LBrush: TLogBrush;
begin
  { Allocate graying brush (used to disable buttons) }
  LBrush.lbStyle := bs_Pattern;
  Word(LBrush.lbHatch) := LoadBitmap(HInstance, 'GrayingBitmap');
  GrayingBrush := CreateBrushIndirect(LBrush);
  DeleteObject(Word(LBrush.lbHatch));

  { Allocate drawing pens and brushes }
  GrayBrush := GetStockObject(LtGray_Brush);
  WhitePen := GetStockObject(White_Pen);
  BlackPen := GetStockObject(Black_Pen);
  DarkGrayPen := CreatePen(ps_Solid, 1, coDarkGray);
end;

{ Free allocate resources }
procedure DeallocateResources;
begin
  DeleteObject(GrayingBrush);
  DeleteObject(DarkGrayPen);
end;

var
  SaveExit: Pointer;

procedure ExitToolBar; far;
begin
  DeallocateResources;
  ExitProc := SaveExit;
end;

begin
  SaveExit := ExitProc;
  ExitProc := @ExitToolBar;
  AllocateResources;
end.