{************************************************}
{                                                }
{   ObjectWindows Chess Demo                     }
{   Game Pieces                                  }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit OWPieces;

interface

uses WinProcs, WinTypes, Objects, OWindows, Chessdll;

type
  PGamePiece = ^TGamePiece;
  TGamePiece = object(TObject)
    Parent: PWindowsObject;      { the game board }
    Square: TLocation;
    Rect: TRect;
    Bitmap: HBitmap;
    Bitmask: HBitmap;
    BitOfsX: shortint;     { offset to center bitmap}
    BitOfsY: shortint;
    BitSize: TPoint;
    Dragging: Boolean;
    DragHidden: Boolean;
    NeedRedraw: Boolean;
    constructor Init(AParent: PWindowsObject; BitName, MaskName: PChar;
      ASquare: TLocation);
    destructor Done; virtual;
    function  HitTest(P: TPoint): Boolean; virtual;
    procedure Paint(DestDC: HDC);
    procedure RequestRedraw;
    function  GetCursor: HCursor; virtual;
    procedure SetRect(const R: TRect); virtual;
    function  CanDrag: Boolean; virtual;
    procedure DragBegin(DC: HDC; Mouse: TPoint); virtual;
    procedure DragContinue(DC: HDC; Mouse: TPoint; Sq: TLocation); virtual;
    procedure DragHide;  virtual;
    function  DragEnd(DC: HDC; Mouse: TPoint; Sq: TLocation;
      var Move): Boolean; virtual;
  end;

implementation

constructor TGamePiece.Init(AParent: PWindowsObject; BitName, MaskName: PChar;
  ASquare: TLocation);
var
  BI: TBitmap;
begin
  inherited Init;
  Parent := AParent;
  Bitmap  := LoadBitmap(HInstance, BitName);
  Bitmask := LoadBitmap(HInstance, MaskName);
  FillChar(Rect, SizeOf(Rect), 0);
  GetObject(Bitmap, SizeOf(BI), @BI);
  BitOfsX := 0;
  BitOfsY := 0;
  BitSize.X := BI.bmWidth;
  BitSize.Y := BI.bmHeight;
  Square := ASquare;
  Dragging := False;
  DragHidden := False;
  NeedRedraw := False;
end;

destructor TGamePiece.Done;
begin
  DeleteObject(Bitmap);
  DeleteObject(Bitmask);
  inherited Done;
end;

function TGamePiece.HitTest(P: TPoint): Boolean;
begin
  HitTest := PtInRect(Rect, P);
end;

procedure TGamePiece.Paint(DestDC: HDC);
var
  OldBits : HBitmap;
  MemDC : HDC;
begin
  if not DragHidden then
  begin
    MemDC := CreateCompatibleDC(DestDC);
    OldBits := SelectObject(MemDC, BitMask);
    BitBlt(DestDC, Rect.Left + BitOfsX,
               Rect.Top + BitOfsY,
               BitSize.X, BitSize.Y,
           MemDC, 0, 0, SrcAnd);
    SelectObject(MemDC, Bitmap);
    BitBlt(DestDC, Rect.Left + BitOfsX,
               Rect.Top + BitOfsY,
               BitSize.X, BitSize.Y,
           MemDC, 0, 0, SrcPaint);
    SelectObject(MemDC, OldBits);
    DeleteDC(MemDC);
  end;
  NeedRedraw := False;
end;

procedure TGamePiece.RequestRedraw;
begin
  NeedRedraw := True;
  InvalidateRect(Parent^.HWindow, @Rect, False);
end;

function TGamePiece.GetCursor: HCursor;
begin
  GetCursor := LoadCursor(0, idc_Arrow);
end;

procedure TGamePiece.SetRect(const R: TRect);
begin
  Rect := R;
  BitOfsX := ((Rect.Right - Rect.Left) div 2) - (BitSize.X div 2);
  BitOfsY := ((Rect.Bottom - Rect.Top) div 2) - (BitSize.Y div 2);
end;

function TGamePiece.CanDrag : Boolean;
begin
  CanDrag := True;
end;

procedure TGamePiece.DragBegin(DC: HDC; Mouse: TPoint);
begin
  Dragging := True;
  with Rect do
  begin
    Left := Mouse.X - BitSize.X div 2;
    Top := Mouse.Y - BitSize.Y div 2;
    Right := Left + BitSize.X;
    Bottom := Top + BitSize.Y;
  end;
  BitOfsX := 0;
  BitOfsY := 0;
  Paint(DC);
  SetCursor(GetCursor);
end;

procedure TGamePiece.DragContinue(DC: HDC; Mouse: TPoint; Sq: TLocation);
begin
  DragHidden := False;
  OffSetRect(Rect, (Mouse.X - BitSize.X div 2) - Rect.Left,
                   (Mouse.Y - BitSize.Y div 2) - Rect.Top);
  Paint(DC);
  SetCursor(GetCursor);
end;

{ DragEnd
  Result = True means that the destination square is acceptable to this piece.
  Result = False means the destination is unacceptable and the piece wants
  to return to its original location.
  Do not modify the Square field during a drag.
  You may modify Rect during a drag - SetRect will be called after the drag
  is completed to reset the Rect to its true board pixel coordinates.
  Descendents should fill in the Move parameter with relavent info
  (Piecetype, from, to, etc) if the destination is acceptable.
  If a repaint of part of the board is needed, use InvalidateRect. }

function  TGamePiece.DragEnd(DC: HDC; Mouse: TPoint;
                             Sq: TLocation; var Move): Boolean;
begin
  Dragging := False;
  DragEnd := not DragHidden;
  DragHidden := False;
  SetCursor(GetCursor);
end;

procedure TGamePiece.DragHide;
begin
  DragHidden := True;
end;

end.