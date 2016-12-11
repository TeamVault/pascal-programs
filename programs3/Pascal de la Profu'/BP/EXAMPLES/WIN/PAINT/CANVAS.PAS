{************************************************}
{                                                }
{   ObjectWindows Paint demo                     }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Canvas;

{ This unit supplies the drawing canvas for the paint program, that is, the
  window where drawing actually takes place.

  The Canvas is responisble for maintaining the screen state, including
  updating the cursor, directing input to the currently selected drawing
  tool and managing the enabling of certain menu items (cut/copy/paste/etc).
}

interface

uses PaintDef, ResDef, Bitmaps, WinTypes, WinProcs, Strings, OWindows;

type

  PCanvas = ^TCanvas;
  TCanvas = object(TWindow)
    State: PState;

    Bitmap: HBitmap;		{ Save the bitmap originally in State^.MemDC }
    UndoBitmap: HBitmap;	{ Saved bitmap for undoing }
    UndoDC: HDC;		{ Display context for undoing }

    Drawing: Boolean;		{ In the process of drawing }
    OverSelection: Boolean;	{ Cursor is the 'over selection' cursor }

    { Creation and destruction }
    constructor Init(AParent: PWindowsObject; AState: PState);
    destructor Done; virtual;
    procedure SetupWindow; virtual;
    procedure NewBitmaps(DC: HDC);

    { Display }
    procedure MoveSelf(WX, WY, WW, WH: Integer; Repaint: Boolean);
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure PaintSelection(DC: HDC; AddOffset: Boolean);
    procedure SaveUndo;

    { Menu management }
    { Cut/Copy/Paste }
    procedure EnableCCDMenu(mf_Flag: Integer);
    procedure EnableCCD;
    procedure DisableCCD;

    { Undo/Redo }
    procedure EnableUndoMenu(mf_Flag: Integer);
    procedure EnableUndo;
    procedure DisableUndo;
    procedure ResetUndoLabel(NewLabel: PChar);

    { Menu initiated actions }
    { File }
    procedure Undo;
    function Load(FileName: PChar): Integer;
    function Store(FileName: PChar): Integer;

    { Edit }
    procedure CopyToClipBoard(DC: HDC; Left, Top, Width, Height: Integer);
    procedure Erase(Left, Top, Width, Height: Integer);
    procedure PickUpSelection(aDC: HDC; Left, Top, Width, Height: Integer);
    procedure ReleaseSelection;

    procedure Cut;
    procedure Copy;
    procedure Paste;
    procedure Delete;
    procedure ClearAll;

    { Options }
    procedure Resize(CopyFlag: Integer);
    procedure BitmapCopy(aBitmap: HBitmap; CopyFlag: Integer);

    { Window manager responses }
    { Mouse initiated actions }
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMLButtonUp(var Msg: TMessage);
      virtual wm_First + wm_LButtonUp;
    procedure WMMouseMove(var Msg: TMessage);
      virtual wm_First + wm_MouseMove;
    procedure wmSetCursor(var Msg: TMessage);
      virtual wm_First + wm_SetCursor;

  end;

  PCanvasScroller = ^TCanvasScroller;
  TCanvasScroller = object(TScroller)
    procedure BeginView(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
  end;

implementation

{ Create a new canvas and initialize the selection.
}
constructor TCanvas.Init(AParent: PWindowsObject; AState: PState);
var
  DC: HDC;
begin
  TWindow.Init(AParent, nil);
  Attr.Style := ws_Border or ws_Child or ws_Visible
		or ws_HScroll or ws_VScroll;
  Scroller := New(PCanvasScroller, Init(@Self, 1, 1, 200, 200));
  State := AState;
  
  { Initialize the selection }
  SetRectEmpty(State^.Selection);
  State^.SelectionBM := 0;

  Drawing := False;
  OverSelection := False;

  State^.IsDirtyBitmap := False;
{  DisableUndo;}

  { Set up the display contexts }
  DC := GetDC(0);
  State^.MemDC := CreateCompatibleDC(DC);
  UndoDC       := CreateCompatibleDC(DC);

  { Create the bitmaps }
  NewBitmaps(DC);

  ReleaseDC(0, DC);
end;

{ Destroy the off-screen bitmaps before dying.
}
destructor TCanvas.Done;
begin
  DeleteObject(SelectObject(State^.MemDC, Bitmap));
  DeleteObject(SelectObject(UndoDC, UndoBitmap));
  DeleteDC(State^.MemDC);
  DeleteDC(UndoDC);
  if State^.SelectionBM <> 0 then DeleteObject(State^.SelectionBM);
  TWindow.Done;
end;

procedure TCanvas.SetupWindow;
begin
  TWindow.SetupWindow;
  DisableUndo;
end;

{ Set up new bitmaps for the canvas. It is assumed that the DCs have already
  been set up appropriately.
}
procedure TCanvas.NewBitmaps(DC: HDC);
begin
  with State^.BitmapSize do
    begin
      Bitmap     := SelectObject(State^.MemDC, 
		                 CreateCompatibleBitmap(DC, X, Y));
      UndoBitmap := SelectObject(UndoDC, 
	                         CreateCompatibleBitmap(DC, X, Y));

      { White them out }
      PatBlt(State^.MemDC, 0, 0, X, Y, whiteness);
      PatBlt(UndoDC,       0, 0, X, Y, whiteness);
   end;
end;

{ Display }
{ Move and resize the window. Adjust the Scroller as needed.
}
procedure TCanvas.MoveSelf(WX, WY, WW, WH: Integer; Repaint: Boolean);
var
  XRange, YRange: Integer;
begin
  with State^.BitmapSize do
  begin
    if WW > X + 2 then
    begin
      XRange := 0;
      WW := X + 2;
    end
    else
      XRange := X - WW;

    if WH > Y + 2 then
    begin
     YRange := 0;
     WH := Y + 2;
    end
    else
      YRange := Y - WH;
  end;

  { Windows' MoveWindow does not repaint the window if the given
    coordinates are exactly the same as the current coordinates. }
  if (Attr.X = WX) and (Attr.Y = WY) and (Attr.W = WW)
     and (Attr.H = WH) and Repaint then
    InvalidateRect(HWindow, nil, True)
  else
    MoveWindow(HWindow, WX, WY, WW, WH, Repaint);

  { When one of the parameters is zero and the other unchanged, the
    corresponding scrollbar is eliminated. }

  Scroller^.SetRange(XRange, Scroller^.YRange);
  Scroller^.SetRange(Scroller^.XRange, YRange);
  Scroller^.ScrollTo(0, 0);
end;

{ Update the screen display from the off-screen bitmap. Highlight the 
  selection if there is one.
}
procedure TCanvas.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  R: TRect;			{ The window client area }
begin
  { Copy from the off-screen bitmap to the screen }
  GetClientRect(HWindow, R);
  BitBlt(PaintDC, 0, 0, State^.BitmapSize.X, State^.BitmapSize.Y, 
    State^.MemDC, 0, 0, SrcCopy);

  { Highlight the selection }  
  PaintSelection(PaintDC, True);
end;

{ Highlight the selection, if there is one, by drawing a dotted line around
  it. If there is a selection bitmap display it. Add the Offset in State
  to the coordinates if requested.
}
procedure TCanvas.PaintSelection(DC: HDC; AddOffset: Boolean);
var
  SelDC: HDC;			{ For the selection bitmap }
  XOffset, YOffset: Integer;	{ The offsets to be used }
begin
  if not IsRectEmpty(State^.Selection) then
  begin
    XOffset := 0;
    YOffset := 0;
    if AddOffset then
    begin
      XOffset := State^.Offset.X;
      YOffset := State^.Offset.Y;
    end;

    { Draw the selecton bitmap }
    if State^.SelectionBM <> 0 then
    begin

      { Set up the drawing context }
      SelDC := CreateCompatibleDC(DC);
      State^.SelectionBM := SelectObject(SelDC, State^.SelectionBM);

      { Copy the bits to the screen }
      with State^.Selection do
	BitBlt(DC, Left + XOffset, Top + YOffset, Right - Left,
          Bottom - Top, SelDC, 0, 0, SrcCopy);

      { Clean up }
      State^.SelectionBM := SelectObject(SelDC, State^.SelectionBM);
      DeleteDC(SelDC);
    end;

    { Draw a dotted line marking the selected area }
    SetROP2(DC, r2_CopyPen);
    SelectObject(DC, DashedPen);
    SelectObject(DC, GetStockObject(Null_Brush));
    with State^.Selection do
      Rectangle(DC, Left + XOffset, Top + YOffset, Right + XOffset,
        Bottom + YOffset);
  end;
end;

{ Save the potentially modified portion of the current bitmap on the
  undo bitmap and enable undoing.
}
procedure TCanvas.SaveUndo;
begin
  { Save the current bitmap as the undo bitmap }
  BitBlt(UndoDC, 0, 0, State^.BitmapSize.X, State^.BitmapSize.Y,
    State^.MemDC, 0, 0, SrcCopy);
  EnableUndo;
end;


{ Menu management }
{ Enable/Disable the cut/copy/delete menu items.
}
procedure TCanvas.EnableCCDMenu(mf_Flag: Integer);
var
  Menu: HMenu;
begin
  Menu := GetMenu(Parent^.HWindow);
  EnableMenuItem(Menu, cm_EditCut, mf_Flag);
  EnableMenuItem(Menu, cm_EditCopy, mf_Flag);
  EnableMenuItem(Menu, cm_EditDelete, mf_Flag);
end;

procedure TCanvas.EnableCCD;
begin
  EnableCCDMenu(mf_Enabled);
end;

procedure TCanvas.DisableCCD;
begin
  EnableCCDMenu(mf_Grayed);
end;

{ Enable/Disable the undo menu item.
}
procedure TCanvas.EnableUndoMenu(mf_Flag: Integer);
var
  Menu: HMenu;
begin
  Menu := GetMenu(Parent^.HWindow);
  ModifyMenu(Menu, cm_EditUndo, mf_ByCommand or mf_String,
    cm_EditUndo, '&Undo');
  EnableMenuItem(Menu, cm_EditUndo, mf_Flag);
end;

procedure TCanvas.EnableUndo;
begin
  EnableUndoMenu(mf_Enabled);
end;
  
procedure TCanvas.DisableUndo;
begin
  EnableUndoMenu(mf_Grayed);
end;
 
procedure TCanvas.ResetUndoLabel(NewLabel: PChar);
begin
  ModifyMenu(GetMenu(Parent^.HWindow), cm_EditUndo, mf_ByCommand or mf_String,
    cm_EditUndo, NewLabel);
end;


{ Menu initiated functions }
{ File }

{ Undo the last change to the current bitmap and toggle the undo/redo menu
  item.
}
procedure TCanvas.Undo;
var
  MLabel: String[6];     	{ The current undo/redo label }
  R: TRect;			{ The window client area }
begin
  { Swap the bitmaps in the DCs }
  Bitmap := SelectObject(State^.MemDC, SelectObject(UndoDC,
    SelectObject(State^.MemDC, Bitmap)));

  { Reset the undo/redo label }
  GetMenuString(GetMenu(Parent^.HWindow), cm_EditUndo, @MLabel, 6,
    mf_ByCommand);
  if StrComp(@MLabel, '&Undo') = 0 then
    ResetUndoLabel('&Redo')
  else
    ResetUndoLabel('&Undo');

  { Update the screen }
  GetClientRect(HWindow, R);
  InvalidateRect(HWindow, @R, False);
end;  

{ Read a bitmap from a file into the current drawing canvas. Returns 0 on 
  error, otherwise non-zero.
}
function TCanvas.Load(FileName: PChar): Integer;

  function Smaller(A, B: Integer): Integer;
  begin
    if A < B then Smaller := A else Smaller := B;
  end;

var
  HBM: HBitmap;			{ The new bitmap }
  BM: TBitmap;			{ Information about the new bitmap }
begin
  Load := 1;

  { Actually read in the bitmap }
  HBM := LoadBitmapFile(FileName);
  if HBM = 0 then		{ Failure }
  begin
    Load := 0;
    Tell('Unable to read bitmap.');
    exit;
  end;

  { Mark the bitmap as unmodified, and clear the selection }
  State^.IsDirtyBitmap := False;
  DisableUndo;
  SetRectEmpty(State^.Selection);

  { Reconfigure the world to suit the new bitmap size }
  GetObject(HBM, sizeOf(BM), @BM);	{ Information about the new bitmap }
  with State^.BitmapSize do
  begin
    X := BM.bmWidth;
    Y := BM.bmHeight;
  end;
  DeleteObject(SelectObject(State^.MemDC, HBM));
  DeleteObject(SelectObject(UndoDC, CreateCompatibleBitmap(UndoDC,
    State^.BitmapSize.X, State^.BitmapSize.Y)));
end;

{ Write the current image out to a file. Returns 0 if error, otherwise
  non-zero.
}
function TCanvas.Store(FileName: PChar): Integer;
var 
  I: Integer;			{ Result from the actual write }
begin
  { Retrieve the actual bitmap from the State display context }
  Bitmap := SelectObject(State^.MemDC, Bitmap);
  I := StoreBitmapFile(FileName, Bitmap);
  
  { Restore the off-screen bitmap to the State display context }
  Bitmap := SelectObject(State^.MemDC, Bitmap);

  State^.IsDirtyBitmap := I <> 1; { Mark the bitmap unmodified if successful }
  DisableUndo;
  Store := I;
end;

{ Edit }

{ Copy the indicated bits of bitmap in the drawing context to the clipboard.
  Copying to the clipboard is done by transferring a bitmap to the clipboard.
  Once the clipboard has been passed this bitmap, it is no longer owned by
  the application, so a new bitmap is created expressly for this purpose.
}
procedure TCanvas.CopyToClipBoard(DC: HDC; Left, Top, Width, Height: Integer);
var
  CopyDC: HDC;			{ For the new bitmap }
  CopyBitmap: HBitmap;		{ The new bitmap }
begin
  { Make sure clipboard is available and can be copied to }
  if OpenClipBoard(HWindow) and EmptyClipBoard then
  begin

    { Create the new bitmap }
    CopyDC := CreateCompatibleDC(DC);
    CopyBitmap := CreateCompatibleBitmap(DC, Width, Height);
    CopyBitmap := SelectObject(CopyDC, CopyBitmap);
    BitBlt(CopyDC, 0, 0, Width, Height, DC, Left, Top, SrcCopy);
    CopyBitmap := SelectObject(CopyDC, CopyBitmap);

    { Transfer the new bitmap to the clipboard }
    SetClipBoardData(cf_Bitmap, CopyBitmap);

    { Clean up }
    CloseClipBoard;
    DeleteDC(CopyDC);
  end;
end;

{ White out the rectangle indicated on the off-screen bitmap.
}
procedure TCanvas.Erase(Left, Top, Width, Height: Integer);
begin
  { White out the rectangle }
  PatBlt(State^.MemDC, Left, Top, Width, Height, Whiteness);
end;

{ Make the current selection into a selection bitmap. Note that this should
  (and can be) only invoked when the SelectTool is active. (Otherwise there
  could be no selection.
}
procedure TCanvas.PickUpSelection(aDC: HDC; Left, Top, Width, Height: Integer);
begin
  State^.PaintTool^.PickUpSelection(aDC, Left, Top, Width, Height);
end;

{ Release the current selection without saving the bits. Also gray out the
  appropriate menu items.
}
procedure TCanvas.ReleaseSelection;
begin
  State^.PaintTool^.ReleaseSelection;
  DisableCCD;
end;

{ Copy the current selection to the clipboard and white out the hole.
}
procedure TCanvas.Cut;
begin
  Copy;
  Delete;
end;

{ Copy the current selection to the clipboard.
}
procedure TCanvas.Copy;
begin
  if State^.SelectionBM <> 0 then
    
    { Use the selection bitmap }
    begin
      State^.SelectionBM := SelectObject(State^.MemDC, State^.SelectionBM);
      with State^.Selection do
        CopyToClipBoard(State^.MemDC, 0, 0, Right-Left, Bottom-Top);
      State^.SelectionBM := SelectObject(State^.MemDC, State^.SelectionBM);
    end
  else
    
    { Copy from the off-screen bitmap }
    begin
      with State^.Selection do
        CopyToClipBoard(State^.MemDC, Left, Top, Right-Left, Bottom-Top);
    end;
    DisableUndo;
end;

{ Retrieve what is in the clipboard and make it the current selection bitmap.
  The clipboard retains ownership of the retrieved bitmap, so it must be
  copied into a new selection bitmap.
}
procedure TCanvas.Paste;
var
  DC, ClipDC: HDC;		{ For screen and clipboard bitmaps }
  ClipBitmap: HBitmap;		{ The clipboard bitmap }
  BM: TBitmap;			{ Information on the clipboard bitmap }
begin

  { Make sure the clipboard is available }
  if OpenClipBoard(HWindow) then
  begin

    { Set up the drawing contexts }
    DC := GetDC(HWindow);
    ClipDC := CreateCompatibleDC(DC);

    { Retrieve the clipboard bitmap }
    ClipBitmap := GetClipBoardData(cf_Bitmap);
    CloseClipBoard;

    { Make sure the retrieve succeeded and make it the selection bitmap }
    if (ClipBitmap <> 0) and
       { Get information about the bitmap }
       (GetObject(ClipBitmap, SizeOf(TBitmap), @BM) <> 0) then
    begin
      ClipBitmap := SelectObject(ClipDC, ClipBitmap);
      PickUpSelection(ClipDC, 0, 0, bm.bmWidth, bm.bmHeight);
      ClipBitmap := SelectObject(ClipDC, ClipBitmap);
      PaintSelection(DC, False);
      DisableUndo;
    end;

    { Clean up }
    DeleteDC(ClipDC);
    ReleaseDC(HWindow, DC);
  end;
end;

{ White out the selected area or release the selection bitmap.
}
procedure TCanvas.Delete;
begin
  SaveUndo;
  if State^.SelectionBM = 0 then
    with State^.Selection do
      Erase(Left, Top, Right-Left, Bottom-Top);
  ReleaseSelection;
end;

{ White out the entire canvas.
}
procedure TCanvas.ClearAll;
var
  R: TRect;			{ The window client area }
begin
  SaveUndo;
  GetClientRect(HWindow, R);
  InvalidateRect(HWindow, @R, False);
  ReleaseSelection;
  Erase(0, 0, State^.BitmapSize.X, State^.BitmapSize.Y);
end;

{ Options }
{ Resize the current bitmap by creating a new bitmap and copying the
  contents of the current bitmap into it according to flag.
}
procedure TCanvas.Resize(CopyFlag: Integer);
var
  OBitmap: HBitmap;
  DC: HDC;
begin
  DisableUndo;
  OBitmap := SelectObject(State^.MemDC, Bitmap);
  UndoBitmap := SelectObject(UndoDC, UndoBitmap);
  DeleteObject(UndoBitmap);

  DC := GetDC(HWindow);
  NewBitmaps(DC);
  ReleaseDC(HWindow, DC);

  BitmapCopy(OBitmap, CopyFlag);

  DeleteObject(OBitmap);
end;

{ Copy the contents of bitmap into the current bitmap according to flag.
}
procedure TCanvas.BitmapCopy(aBitmap: HBitmap; CopyFlag: Integer);
var
  CopyDC: HDC;
  BMinfo: TBitmap;
begin
  GetObject(aBitmap, SizeOf(TBitmap), @BMInfo);
  CopyDC := CreateCompatibleDC(State^.MemDC);
  aBitmap := SelectObject(CopyDC, aBitmap);
  case CopyFlag of
    id_StretchBM:
      begin
	StretchBlt(State^.MemDC, 0, 0, State^.BitmapSize.X,
          State^.BitmapSize.Y, CopyDC, 0, 0, BMInfo.bmWidth,
          BMInfo.bmHeight, SrcCopy);
      end;
    id_PadBM:
      BitBlt(State^.MemDC, 0, 0, State^.BitmapSize.X, State^.BitmapSize.Y,
        CopyDC, 0, 0, SrcCopy);
  end;
  aBitmap := SelectObject(CopyDC, aBitmap);
  DeleteDC(CopyDC);  
end;

{ Window manager responses }
{ Mouse initiated actions }

{ Start the selected drawing tool drawing.
}
procedure TCanvas.WMLButtonDown(var Msg: TMessage);
begin
  if not Drawing then
  begin
    { Let subsequent Mouse Moves and Mouse Ups know that drawing is in 
      progress, i.e., that the initial mouse down occurred in the right
      window.
    }
    Drawing := True;

    SaveUndo;
    if IsRectEmpty(State^.Selection) then
      State^.IsDirtyBitmap := True
    else
      DisableUndo;

    { Tell the current tool to start drawing }
    State^.PaintTool^.MouseDown(HWindow, Integer(Msg.LParamLo),
      Integer(Msg.LParamHi), State);
  end;
end;

{ If drawing is in progress, tell the currently selected tool about the
  Mouse Move.
}
procedure TCanvas.WMMouseMove(var Msg: TMessage);
begin
   if Drawing then
       State^.PaintTool^.MouseMove(Integer(Msg.LParamLo),
	 Integer(Msg.LParamHi));
end;

{ If drawing is in progress, record the altered state of the image by either
  copying the screen bitmap to the off-screen bitmap or high-lighting the
  new selection. Tell the currently selected tool that the mouse is up.
  Enable/disable menus appropriately.
}
procedure TCanvas.WMLButtonUp(var Msg: TMessage);
var
  DC: HDC;				{ For the screen bitmap }
  Menu: HMenu;				{ For the window menu }
begin
  if Drawing then
  begin
    State^.PaintTool^.MouseUp;
    Drawing := False;
    Menu := GetMenu(Parent^.HWindow);
    if IsRectEmpty(State^.Selection) then
    begin
      DisableCCD;
      EnableUndo;
    end
    else
    begin
      DC := GetDC(HWindow);
      PaintSelection(DC, False);
      ReleaseDC(HWindow, DC);
      EnableCCD;
      DisableUndo;
    end;
  end;
end;

{ When the cursor is over the canvas, change the cursor to the cursor
  associated with the selected tool. If the cursor is over the selection
  use the standard arrow cursor.
}
procedure TCanvas.WMSetCursor(var Msg: TMessage);
var
  Pt: TPoint;			{ Cursor position }
  R: TRect;			{ Window client area }
begin
  GetCursorPos(Pt);		{ In global coordinates }
  ScreenToClient(HWindow, Pt);  { In window client local coordinates }
  GetClientRect(HWindow, R);
  if not(PtInRect(R, Pt)) or PtInRect(State^.Selection, Pt) then
    SetCursor(LoadCursor(0, idc_Arrow))
  else
    SetCursor(State^.PaintTool^.Cursor)
end;

{ TCanvasScroller }
procedure TCanvasScroller.BeginView(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  R: TRect;
  DX, DY: Integer;
begin
  TScroller.BeginView(PaintDC, PaintInfo);
  with PCanvas(Window)^.State^ do
  begin
    DX := XPos - Offset.X;
    DY := YPos - Offset.Y;
    if not(IsRectEmpty(Selection)) then
      with Selection do
	SetRect(Selection, Left - DX, Top - DY, Right - DX, Bottom - DY);
    Offset.X := XPos;
    Offset.Y := YPos;
  end;
end;

end.
