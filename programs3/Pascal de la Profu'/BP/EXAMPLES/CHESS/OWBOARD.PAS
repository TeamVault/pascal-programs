{************************************************}
{                                                }
{   ObjectWindows Chess Demo                     }
{   Board managment unit                         }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit OWBoard;

interface

uses WinProcs, WinTypes, Objects, OWindows, ODialogs, OWChPiec, ChessDll,
  OWChDlgs, OWConst;

type
  PChessBoard = ^TChessBoard;
  TChessBoard = object(TWindow)
    Game: HChess;
    Squares: array [1..8,1..8] of PChessPiece;
    Pieces: TCollection;
    BoardBitmap: HBitmap;
    WhiteColor: TColorRef;
    BlackColor: TColorRef;
    WhiteBrush: HBrush;
    BlackBrush: HBrush;
    SquareWidth: Word;
    Dragger: PChessPiece;    { if <> nil, we're dragging it }
    QSquare: TLocation;      { if <> (0,0), we're in right-click query }
    BoardDC, DragDC: HDC;
    BoardOldBM, DragBM : HBitmap;
    ValidMoves,
    OpponentMoves,
    ScratchMoves: array [0..(28*16+1)] of TMove;
    CoverDlg: PCoverDlg;
    GameOver: Boolean;
    { Setup and shutdown }
    constructor Init(AParent: PWindowsObject; GH: HChess);
    destructor Done; virtual;
    function  GetClassName: PChar; virtual;
    procedure GetWindowClass(var WC: TWndClass); virtual;
    procedure ResetBoard(GH: HChess);
    procedure SetGameOver(IsOver: Boolean);

    { Board display }
    function  IdealWidth: Word;
    procedure InitBoardBitmap;
    procedure DrawBoard;
    procedure DrawValidMoves(DC: HDC);
    procedure Paint(DC: HDC; var PS: TPaintStruct); virtual;
    procedure WMEraseBkgnd(var Msg: TMessage);
      virtual wm_First + wm_EraseBkgnd;
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;
    procedure Cover(DoIt: Boolean);

    { Conversions }
    function  PieceFromPoint(Pt: TPoint): PChessPiece;
    procedure SquareFromPoint(Pt: TPoint; var Sq: TLocation);
    procedure SquareToRect(Sq: TLocation; var R: TRect);

    { Piece management }
    procedure InsertPiece(Sq: TLocation; P: PChessPiece);
    function  RemovePiece(Sq: TLocation): PChessPiece;
    procedure ExecuteMove(const Move: TMove);
    procedure RetractMove(const Move: TMove);
    procedure ResetValidMoves;

    { Piece dragging routines }
    procedure CancelDrag;
    procedure WMSetCursor(var Msg: TMessage);
      virtual wm_First + wm_SetCursor;
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMMouseMove(var Msg: TMessage);
      virtual wm_First + wm_MouseMove;
    procedure WMLButtonUp(var Msg: TMessage);
      virtual wm_First + wm_LButtonUp;

    { Right mouse queries valid moves to square or of piece }
    procedure WMRButtonDown(var Msg: TMessage);
      virtual wm_First + wm_RButtonDown;
    procedure WMRButtonUp(var Msg: TMessage);
      virtual wm_First + wm_RButtonUp;
  end;

  PBoardFrame = ^TBoardFrame;
  TBoardFrame = object(TWindow)
    Board: PChessBoard;
    FrameWidth: Integer;
    FontWidth, FontHeight: Integer;
    constructor Init(AParent: PWindowsObject; ABoard: PChessBoard);
    function  GetClassName: PChar; virtual;
    procedure GetWindowClass(var WC: TWndClass); virtual;
    procedure SetupWindow; virtual;
    function  IdealWidth: Integer;
    procedure Paint(DC: HDC; var PS: TPaintStruct); virtual;
    procedure WMMove(var Msg: TMessage);
      virtual wm_First + wm_Move;
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;
  end;

  function OtherPlayer(Color: TColor): TColor;

implementation

uses OWUtils, Strings, BWCC;

function OtherPlayer(Color: TColor): TColor;
begin
  if Color = cWhite then
    OtherPlayer := cBlack
  else
    OtherPlayer := cWhite;
end;

constructor TChessBoard.Init(AParent: PWindowsObject; GH: HChess);
begin
  inherited Init(AParent, nil);
  with Attr do
  begin
    X := 0;
    Y := 0;
    W := 200;
    H := 200;
    Style := ws_Child or ws_ClipChildren{or ws_Border};
        { NOT ws_Visible - the parent window will resize us  }
        { to the ideal width and then show us.               }
  end;
  BoardBitmap := 0;
  DragDC := 0;
  BoardDC := CreateMemoryDC;
  Dragger := nil;
  GameOver := False;
  Word(QSquare) := 0;
  WhiteColor := XApp^.GetAppProfileRGB(
                       'Board','WhiteColor',RGB(255,255,255));
  WhiteBrush := CreateSolidBrush(WhiteColor);
  BlackColor := XApp^.GetAppProfileRGB(
                       'Board','BlackColor',RGB(255,0,0));
  BlackBrush := CreateSolidBrush(BlackColor);
  Pieces.Init(32, 4);  { Growth allows for edited boards with > 32 pieces }
  ResetBoard(GH);
  CoverDlg := New(PCoverDlg, Init(@Self, PChar(dlgCoverBoard)));
  if not ChessSettings.CoverBoard then
    CoverDlg^.Lock;
end;

destructor TChessBoard.Done;
var
  Temp: array [0..15] of Char;
begin
  inherited Done;
  Pieces.Done;
  if BoardDC <> 0 then
  begin
    SelectObject(BoardDC, BoardOldBM);
    DeleteDC(BoardDC);
  end;
  if DragDC <> 0 then
  begin
    DeleteObject(SelectObject(DragDC, DragBM));
    DeleteDC(DragDC);
  end;
  if BoardBitmap <> 0 then
    DeleteObject(BoardBitmap);
  DeleteObject(WhiteBrush);
  DeleteObject(BlackBrush);
  XApp^.WriteAppProfileRGB('Board','WhiteColor',WhiteColor);
  XApp^.WriteAppProfileRGB('Board','BlackColor',BlackColor);
end;

function  TChessBoard.GetClassName: PChar;
begin
  GetClassName := 'TPWOWLChessBoard';
end;

procedure TChessBoard.GetWindowClass(var WC: TWndClass);
begin
  inherited GetWindowClass(WC);
  WC.Style := cs_ByteAlignWindow;
  WC.hCursor := 0;
end;

procedure TChessBoard.ResetBoard(GH: HChess);
  procedure DoResize(P : PChessPiece); far;
  var
    R: TRect;
    S: TLocation;
  begin
    P^.GetSquare(S);
    SquareToRect(S, R);
    P^.SetRect(R);
  end;
var
  TempBoard: TBoard;
  Square: TLocation;
begin
  Game := GH;
  Pieces.FreeAll;
  FillChar(Squares, SizeOf(Squares), 0);

  GetBoard(Game, TempBoard);

  SquareWidth := Attr.W div 8;
  for Square.X := 1 to 8 do
    for Square.Y := 1 to 8 do
      if (TempBoard[Square.X, Square.Y].Piece <> pEmpty) then
      begin
        Squares[Square.X,Square.Y] := New(PChessPiece,
             Init(@Self, TempBoard[Square.X, Square.Y], Square));
        Pieces.Insert(Squares[Square.X,Square.Y]);
      end;
  ResetValidMoves;
  GameOver := False;
  if HWindow <> 0 then
  begin
    Pieces.ForEach(@DoResize);
    DrawBoard;
    InvalidateRect(HWindow, nil, False);
  end;
end;

procedure TChessBoard.SetGameOver(IsOver: Boolean);
begin
  if GameOver <> IsOver then
  begin
    GameOver := IsOver;
    DrawBoard;
    InvalidateRect(HWindow, nil, False);
  end;
end;

function TChessBoard.IdealWidth: Word;
var
  Best: Word;
  procedure CheckBitmapSize(P: PChessPiece); far;
  begin
    if Best < P^.BitSize.X then Best := P^.BitSize.X;
    if Best < P^.BitSize.Y then Best := P^.BitSize.Y;
  end;
begin
  Best := 0;
  Pieces.ForEach(@CheckBitmapSize);
  IdealWidth := (Best + 4) * 8;
end;

procedure TChessBoard.InitBoardBitmap;
var
  DC: HDC;
begin
  if BoardBitmap <> 0 then
  begin
    SelectObject(BoardDC, BoardOldBM);
    DeleteObject(BoardBitmap);
  end;

  DC := GetDC(HWindow);
  BoardBitmap := CreateCompatibleBitmap(DC, Attr.W, Attr.H);
  ReleaseDC(HWindow, DC);
  BoardOldBM := SelectObject(BoardDC, BoardBitmap);
  SquareWidth := Attr.W div 8;
end;

procedure TChessBoard.DrawBoard;
var
  OldBrush, SquareBrush : HBrush;
  X, Y: Integer;
  OldFont: HFont;
  LF: TLogFont;

  procedure DoPaint(P: PChessPiece); far;
  begin
    P^.Paint(BoardDC);
  end;

begin
  OldBrush := SelectObject(BoardDC, WhiteBrush);
  PatBlt(BoardDC, 0, 0, Attr.W, Attr.H, PatCopy);

  SelectObject(BoardDC, BlackBrush);
  for Y := 0 to 7 do
    for X := 0 to 7 do
      if Odd(X + Y) then
        PatBlt(BoardDC, X * SquareWidth, Y * SquareWidth,
                      SquareWidth, SquareWidth, PatCopy);

  if GameOver then
  begin
    SaveDC(BoardDC);
    SetBkMode(BoardDC, Transparent);
    SetTextColor(BoardDC, RGB(128,128,128));
    FillChar(LF, SizeOf(LF), 0);
    with LF do
    begin
      lfHeight := SquareWidth * 2;
      lfWidth := SquareWidth;
      lfWeight := FW_Bold;
      lfOutPrecision := out_Character_Precis;
      lfQuality := Proof_Quality;
      if LoWord(GetVersion) = $0003 then
        StrCopy(lfFaceName, 'Tms Rmn')
      else
        StrCopy(lfFaceName, 'Times New Roman');
    end;
    OldFont := SelectObject(BoardDC, CreateFontIndirect(LF));
    TextOut(BoardDC,
            Attr.W div 2 - LoWord(GetTextExtent(BoardDC, 'GAME', 4)) div 2,
            SquareWidth * 2, 'GAME', 4);
    TextOut(BoardDC,
            Attr.W div 2 - LoWord(GetTextExtent(BoardDC, 'OVER', 4)) div 2,
            SquareWidth * 4, 'OVER', 4);
    DeleteObject(SelectObject(BoardDC, OldFont));
    RestoreDC(BoardDC, -1);
  end;

  SelectObject(BoardDC, OldBrush);
  Pieces.ForEach(@DoPaint);
end;

{ Because of the way the board paints from a memory bitmap, we don't
  need the window to erase the background before we paint.  }
procedure TChessBoard.WMEraseBkgnd(var Msg: TMessage);
begin
  Msg.Result := 1;
end;

procedure TChessBoard.DrawValidMoves(DC: HDC);

  procedure TestAndInvert(Test, Show: TLocation);
  var
    R: TRect;
  begin
    if Word(Test) = Word(QSquare) then
    begin
      SquareToRect(Show, R);
      InvertRect(DC, R);
    end;
  end;

var
  X : Integer;
begin
  if Squares[QSquare.X, QSquare.Y] <> nil then
    { Show where this piece can move to }
  begin
    X := 0;
    while (X <= High(ValidMoves)) and
          (ValidMoves[X].Change.Piece <> pEmpty) do
    begin
      with ValidMoves[X].Change do
        TestAndInvert(Source, Dest);
      Inc(X);
    end;
    X := 0;
    while (X <= High(ValidMoves)) and
          (OpponentMoves[X].Change.Piece <> pEmpty) do
    begin
      with OpponentMoves[X].Change do
        TestAndInvert(Source, Dest);
      Inc(X);
    end;
  end
  else
    { Show what pieces can move to this square }
  begin
    X := 0;
    while (X <= High(ValidMoves)) and
          (ValidMoves[X].Change.Piece <> pEmpty) do
    begin
      with ValidMoves[X].Change do
        TestAndInvert(Dest, Source);
      Inc(X);
    end;
    X := 0;
    while (X <= High(OpponentMoves)) and
          (OpponentMoves[X].Change.Piece <> pEmpty) do
    begin
      with OpponentMoves[X].Change do
        TestAndInvert(Dest, Source);
      Inc(X);
    end;
  end;
end;


procedure TChessBoard.Paint(DC: HDC; var PS: TPaintStruct);
  procedure CheckPieces(P: PChessPiece); far;
  var
    Sq: TLocation;
    OldBrush: HBrush;
  begin
    if P^.NeedRedraw then
    begin
      P^.GetSquare(Sq);
      if Odd(Sq.X + Sq.Y) then
        OldBrush := SelectObject(BoardDC, WhiteBrush)
      else
        OldBrush := SelectObject(BoardDC, BlackBrush);
      with P^.Rect do
        PatBlt(BoardDC, Left, Top, Right - Left, Bottom - Top, PatCopy);
      SelectObject(BoardDC, OldBrush);
      P^.Paint(BoardDC);
    end;
  end;
begin
  Pieces.ForEach(@CheckPieces);
  with PS.rcPaint do
    BitBlt(DC, Left, Top, Right - Left, Bottom - Top,
           BoardDC, Left, Top, SrcCopy);
  if Dragger <> nil then
    Dragger^.Paint(DC);
  if Word(QSquare) <> 0 then
    DrawValidMoves(DC);
end;

procedure TChessBoard.WMSize(var Msg: TMessage);

  procedure DoResize(P : PChessPiece); far;
  var
    R: TRect;
    S: TLocation;
  begin
    P^.GetSquare(S);
    SquareToRect(S, R);
    P^.SetRect(R);
  end;

begin
  inherited WMSize(Msg);
  SquareWidth := Attr.W div 8;
  InitBoardBitmap;
  Pieces.ForEach(@DoResize);
  DrawBoard;
  if CoverDlg^.HWindow <> 0 then
    SetWindowPos(CoverDlg^.HWindow, 0, SquareWidth div 2,
                                       SquareWidth div 2,
                                       Attr.W - SquareWidth,
                                       Attr.H - SquareWidth,
                                       swp_NoActivate or swp_NoZOrder);
end;

procedure TChessBoard.Cover(DoIt: Boolean);
begin
  if(CoverDlg <> nil) and
    (CoverDlg^.HWindow <> 0) then
    if DoIt then
      CoverDlg^.Show(sw_Show)
    else
      CoverDlg^.Show(sw_Hide);
end;

function TChessBoard.PieceFromPoint(Pt: TPoint): PChessPiece;
  function DoHitTest(P: PChessPiece): Boolean; far;
  begin
    DoHitTest := P^.HitTest(Pt);
  end;
begin
  PieceFromPoint := PChessPiece(Pieces.FirstThat(@DoHitTest));
end;

procedure TChessBoard.SquareFromPoint(Pt: TPoint; var Sq: TLocation);
var
  Temp: Shortint;
begin
  Temp := (Pt.X div SquareWidth) + 1;
  if Temp in [1..8] then
    Sq.X := Temp
  else
  begin
    Word(Sq) := 0;
    Exit;
  end;
  Temp := (Attr.H - Pt.Y) div SquareWidth + 1;
  if Temp in [1..8] then
    Sq.Y := Temp
  else
    Word(Sq) := 0;
end;

procedure TChessBoard.SquareToRect(Sq: TLocation; var R: TRect);
begin
  R.Left   := (Sq.X - 1) * SquareWidth;
  R.Right  := R.Left + SquareWidth;
  R.Top    := Attr.H - (Sq.Y * SquareWidth);
  R.Bottom := R.Top + SquareWidth;
end;

procedure TChessBoard.ExecuteMove(const Move: TMove);

  function  CreatePromote(P: TPiece; Dest: TLocation): PChessPiece;
  var                    { This function creates the piece specified by }
    X: TSquare;          { P using color info from the piece already on }
  begin                  { on the board at Dest.  This is for           }
    X.Piece := P;        { Pawn Promotion moves only.                   }
    X.Color := Squares[Dest.X, Dest.Y]^.Color;
    InsertPiece(Dest, New(PChessPiece, Init(@Self, X, Dest)));
  end;

begin
  if Move.Change.Piece = pEmpty then Exit;
  with Move, Move.Change do
  begin
    InsertPiece(Dest, RemovePiece(Source)); { Also deletes what's at dest }
    case Move.Kind of
      kEnPassant  : Dispose(RemovePiece(EPCapture), Done);
      kCastling   : InsertPiece(RookDest, RemovePiece(RookSource));
      kPawnPromote: CreatePromote(Piece, Dest);
    end;
  end;
end;

procedure TChessBoard.RetractMove(const Move: TMove);
  procedure CreatePiece(P: TPiece; Color: Boolean; Dest: TLocation);
  var
    X: TSquare;
  begin
    X.Piece := P;
    X.Color := TColor(Color);
    InsertPiece(Dest, New(PChessPiece, Init(@Self, X, Dest)));
  end;
var
  Color: Boolean;   { Color of opponent }
begin
  if Move.Change.Piece = pEmpty then Exit;
  with Move, Move.Change do
  begin
    Color := not Boolean(Squares[Dest.X, Dest.Y]^.Color);
    InsertPiece(Source, RemovePiece(Dest)); {Back out of destination }
    case Move.Kind of
      kNormal     : if Capture then CreatePiece(Contents, Color, Dest);
      kEnPassant  : CreatePiece(Contents, Color, EPCapture);
      kCastling   : InsertPiece(RookSource, RemovePiece(RookDest));
      kPawnPromote:
        begin
          if Capture then CreatePiece(Contents, not Color, Dest);
          CreatePiece(pPawn, Color, Source);
        end;
    end;
  end;
end;


procedure TChessBoard.ResetValidMoves;
var
  Chg: TChange;
  PlayerColor: TColor;
  EmptyMove: TMove;

  procedure DoValids(P : PChessPiece); far;
  begin
    if P^.Color = PlayerColor then
      P^.ResetValidMoves(ValidMoves)  { piece gets its moves from list }
    else
    begin
      P^.ResetValidMoves(EmptyMove);  { clear opponent's move lists }
      if ChessSettings.ShowAttacks then
        P^.CheckJeopardy(ValidMoves)
      else
        P^.CheckJeopardy(EmptyMove);
    end;
  end;

  procedure DoJeopardies(P : PChessPiece); far;
  begin
    if P^.Color = PlayerColor then
      P^.CheckJeopardy(OpponentMoves);
  end;

begin
  Chg.Piece := pEmpty;
  Word(Chg.Source) := 0;
  Word(Chg.Dest) := 0;
  FillChar(EmptyMove, SizeOf(EmptyMove), 0);
  PlayerColor := GetPlayer(Game);
  if ChessSettings.ShowJeopardies or
     ChessSettings.RightClickHints then
  begin
    { Switch players to see which opponent pieces attack ours }
    SetPlayer(Game, OtherPlayer(PlayerColor));
    GetValidMoves(Game, Chg, OpponentMoves);
    SetPlayer(Game, PlayerColor);
    if ChessSettings.ShowJeopardies then
      Pieces.ForEach(@DoJeopardies);
  end
  else
  begin
    OpponentMoves[0] := EmptyMove;    { Clear the jeopardy lists }
    Pieces.ForEach(@DoJeopardies);
  end;
  { Now see what moves our pieces can make }
  GetValidMoves(Game, Chg, ValidMoves);
  Pieces.ForEach(@DoValids);
end;

procedure TChessBoard.WMSetCursor(var Msg: TMessage);
var
  P: TPoint;
  X: PChessPiece;
begin
  DefWndProc(Msg);
  if Msg.Result = 0 then
  begin
    GetCursorPos(P);
    ScreenToClient(HWindow, P);
    X := PieceFromPoint(P);
    if (X <> nil) and X^.CanDrag and (not GameOver) then
      SetCursor(X^.GetCursor)
    else
      SetCursor(LoadCursor(0, PChar(idc_Arrow)));
  end;
end;

procedure TChessBoard.CancelDrag;
var
  NewSq, OldSq : TLocation;
  P: TPoint;
  Chg: TChange;
  R: TRect;
begin
  if Dragger <> nil then
  begin
    Word(NewSq) := 0;     { 0,0 = off board or invalid }
    Longint(P) := 0;
    R := Dragger^.Rect;
    Dragger^.GetSquare(OldSq);
    Dragger^.DragEnd(DragDC, P, NewSq, Chg);
    InvalidateRect(HWindow, @R, False);
    InsertPiece(OldSq, Dragger);  { Go back to original square }
    Dragger := nil;
    ReleaseCapture;
    DeleteObject(SelectObject(DragDC, DragBM));
    DeleteDC(DragDC);
    DragDC := 0;
  end;
end;

procedure TChessBoard.WMLButtonDown(var Msg: TMessage);
var
   R: TRect;
  Sq: TLocation;
  DC: HDC;
begin
  if (Dragger = nil) and not GameOver then
  begin
    Dragger := PieceFromPoint(TPoint(Msg.LParam));
    if (Dragger <> nil) then
      if Dragger^.CanDrag then
      begin
        Dragger^.GetSquare(Sq);
        RemovePiece(Sq);
        UpdateWindow(HWindow);
        SetCapture(HWindow);
        DC := GetDC(HWindow);
        DragDC := CreateCompatibleDC(DC);
        DragBM := SelectObject(DragDC,
                    CreateCompatibleBitmap(DC, Attr.W, Attr.H));
        BitBlt(DragDC, 0, 0, Attr.W, Attr.H, BoardDC, 0, 0, SrcCopy);
        R := Dragger^.Rect;
        Dragger^.DragBegin(DragDC, TPoint(Msg.LParam));
        UnionRect(R, R, Dragger^.Rect);
        with R do
          BitBlt(DC, Left, Top, Right - Left, Bottom - Top,
                 DragDC, Left, Top, SrcCopy);
        ReleaseDC(HWindow, DC);
      end
      else
      begin
        Dragger := nil;
        MessageBeep(0);
      end;
  end;
  DefWndProc(Msg);
end;

procedure TChessBoard.WMMouseMove(var Msg: TMessage);
var
   R: TRect;
  Sq: TLocation;
  DC: HDC;
begin
  if not GameOver then
    if Dragger <> nil then
    begin
      GetClientRect(HWindow, R);
      if PtInRect(R, TPoint(Msg.LParam)) then
      begin
        SquareFromPoint(TPoint(Msg.LParam), Sq);
        with Dragger^.Rect do
          BitBlt(DragDC, Left, Top, Right - Left, Bottom - Top,
                 BoardDC, Left, Top, SrcCopy);
        R := Dragger^.Rect;
        Dragger^.DragContinue(DragDC, TPoint(Msg.LParam), Sq);
        UnionRect(R, R, Dragger^.Rect);
        DC := GetDC(HWindow);
        with R do
          BitBlt(DC, Left, Top, Right - Left, Bottom - Top,
                 DragDC, Left, Top, SrcCopy);
        ReleaseDC(HWindow, DC);
      end
      else
      begin
        Dragger^.DragHide;
        InvalidateRect(HWindow, @Dragger^.Rect, False);
        SetCursor(LoadCursor(HInstance, PChar(curNo)));
      end;
    end;
  if Word(QSquare) <> 0 then
  begin
    Sq := QSquare;
    GetClientRect(HWindow, R);
    if PtInRect(R, TPoint(Msg.LParam)) then
      SquareFromPoint(TPoint(Msg.LParam), QSquare)
    else
      Word(QSquare) := 0;
    if Word(Sq) <> Word(QSquare) then
      InvalidateRect(HWindow, nil, False);
  end;
  DefWndProc(Msg);
end;

procedure TChessBoard.WMLButtonUp(var Msg: TMessage);
var
  NewSq, OldSq: TLocation;
  R: TRect;
  Chg: TChange;
  ValidMove: Boolean;
  PlayerColor : TColor;
  Error : TChessError;
begin
  if Dragger <> nil then
  begin
    GetClientRect(HWindow, R);
    with Dragger^.Rect do
      BitBlt(DragDC, Left, Top, Right - Left, Bottom - Top,
             BoardDC, Left, Top, SrcCopy);
    if PtInRect(R, TPoint(Msg.LParam)) then
      SquareFromPoint(TPoint(Msg.LParam), NewSq)
    else
    begin
      NewSq.X := 0;     { 0 = off board or invalid }
      NewSq.Y := 0;
    end;
    R := Dragger^.Rect;
    Dragger^.GetSquare(OldSq);
    ValidMove := Dragger^.DragEnd(DragDC, TPoint(Msg.LParam), NewSq, Chg);
    InvalidateRect(HWindow, @R, False);
    InsertPiece(OldSq, Dragger);  { Go back to original square }
    ReleaseCapture;
    DeleteObject(SelectObject(DragDC, DragBM));
    DeleteDC(DragDC);
    DragDC := 0;
    if ValidMove and Dragger^.NeedPawnPromote then
    begin
      CoverDlg^.Lock;
      SendMessage(Parent^.HWindow, am_ChoosePawnPromote, 0, Longint(@Chg));
      CoverDlg^.UnLock;
    end;
    Dragger := nil;
            { am_SubmitMove will return a boolean accept/reject response }
    if ValidMove and
       LongBool(SendMessage(Parent^.HWindow, am_SubmitMove, 0, Longint(@Chg))) then
    begin
        { Update the pieces to reflect the attacks of the moved piece in
          its new position.  }
      ResetValidMoves;
    end;
    UpdateWindow(HWindow);
  end;
  DefWndProc(Msg);
end;

procedure TChessBoard.InsertPiece(Sq: TLocation; P: PChessPiece);
var
  R: TRect;
begin
  if Squares[Sq.X,Sq.Y] = P then Exit;
  if (Squares[Sq.X,Sq.Y] <> nil) then
    Dispose(RemovePiece(Sq), Done);
  Pieces.Insert(P);
  P^.SetSquare(Sq);
  Squares[Sq.X, Sq.Y] := P;
  SquareToRect(Sq, R);
  P^.SetRect(R);
  P^.Paint(BoardDC);
  InvalidateRect(HWindow, @R, False);
end;

function TChessBoard.RemovePiece(Sq: TLocation): PChessPiece;
var
  OldBrush: HBrush;
  R: TRect;
begin
  RemovePiece := nil;
  if Squares[Sq.X,Sq.Y] <> nil then
  begin
    RemovePiece := Squares[Sq.X,Sq.Y];
    Pieces.Delete(Squares[Sq.X,Sq.Y]);
    Squares[Sq.X,Sq.Y] := nil;

    if Odd(Sq.X + Sq.Y) then
      OldBrush := SelectObject(BoardDC, WhiteBrush)
    else
      OldBrush := SelectObject(BoardDC, BlackBrush);
    SquareToRect(Sq, R);
    with R do
      PatBlt(BoardDC, Left, Top, Right - Left, Bottom - Top, PatCopy);
    SelectObject(BoardDC, OldBrush);
    InvalidateRect(HWindow, @R, False);
  end;
end;

procedure TChessBoard.WMRButtonDown(var Msg: TMessage);
var
  R: TRect;
  OldQ : TLocation;
begin
  if ChessSettings.RightClickHints then
  begin
    OldQ := QSquare;
    GetClientRect(HWindow, R);
    if PtInRect(R, TPoint(Msg.LParam)) then
      SquareFromPoint(TPoint(Msg.LParam), QSquare)
    else
      Word(QSquare) := 0;
    if Word(OldQ) <> Word(QSquare) then
      InvalidateRect(HWindow, nil, False);
    SetCapture(HWindow);
  end;
  DefWndProc(Msg);
end;

procedure TChessBoard.WMRButtonUp(var Msg: TMessage);
begin
  if ChessSettings.RightClickHints then
  begin
    if Word(QSquare) <> 0 then
      InvalidateRect(HWindow, nil, False);
    FillChar(QSquare, SizeOf(QSquare), 0);
    ReleaseCapture;
  end;
  DefWndProc(Msg);
end;


constructor TBoardFrame.Init(AParent: PWindowsObject;
                              ABoard: PChessBoard);
begin
  inherited Init(AParent, nil);
  Attr.Style := ws_Child or ws_ClipSiblings;
  Board := ABoard;
  FrameWidth := 5;  { arbitrary - This will be calculated in SetupWindow }
end;

function  TBoardFrame.GetClassName: PChar;
begin
  GetClassName := 'TPWChessBoardFrame';
end;

procedure TBoardFrame.GetWindowClass(var WC: TWndClass);
var
  LB: TLogBrush;
begin
  inherited GetWindowClass(WC);
  with WC do
  begin
    Style := cs_ByteAlignWindow;
    GetObject(BWCCGetPattern, SizeOf(LB), @LB);
    hbrBackground := CreateBrushIndirect(LB);
    hCursor := 0;
  end;
end;

procedure TBoardFrame.SetupWindow;
var
  DC : HDC;
  OldFont: HFont;
  TM: TTextMetric;
begin
  inherited SetupWindow;
  DC := GetDC(0);
  OldFont := SelectObject(DC, GetStockObject(ANSI_Fixed_Font));
  GetTextMetrics(DC, TM);
  SelectObject(DC, OldFont);
  ReleaseDC(0, DC);
  FontWidth := TM.tmMaxCharWidth;
  FontHeight := TM.tmHeight;
  if FontWidth < FontHeight then
    FrameWidth := FontHeight
  else
    FrameWidth := FontWidth;
  Inc(FrameWidth);
end;

function TBoardFrame.IdealWidth: Integer;
begin
  IdealWidth := FrameWidth * 2 + Board^.IdealWidth + 6;
end;

procedure TBoardFrame.Paint(DC: HDC; var PS: TPaintStruct);
var
  X, Sq: Integer;
  S: array [0..2] of Char;
  Point: array [0..4] of TPoint;
  OldPen: HPen;
  R: TRect;
begin
  GetClientRect(HWindow, R);
  {White}
  OldPen := SelectObject(DC, CreatePen(ps_Solid, 1, RGB(255,255,255)));
  FillChar(Point, SizeOf(Point), 0);
  Point[0].X := R.Right-1;
  Point[2].Y := R.Bottom;
  PolyLine(DC, Point, 3);
  Point[0].X := R.Right - FrameWidth - 1;
  Point[0].Y := FrameWidth + 1;
  Point[1].X := Point[0].X;
  Point[1].Y := Point[0].X;
  Point[2].X := FrameWidth + 1;
  Point[2].Y := Point[0].X;
  PolyLine(DC, Point, 3);
  {Neutral grey}
  DeleteObject(SelectObject(DC, CreatePen(ps_Solid, 2, RGB(192,192,192))));
  Point[0].X := R.Right - FrameWidth - 2;
  Point[0].Y := FrameWidth + 3;
  Point[1].X := Point[0].X;
  Point[1].Y := Point[0].X;
  Point[2].X := Point[0].Y - 1;
  Point[2].Y := Point[0].X;
  Point[3].X := Point[2].X;
  Point[3].Y := Point[2].X;
  Point[4].X := Point[0].X;
  Point[4].Y := Point[2].X;
  PolyLine(DC, Point, 5);
  {Dark grey}
  DeleteObject(SelectObject(DC, CreatePen(ps_Solid, 1, RGB(128,128,128))));
  Point[0].X := R.Right - FrameWidth - 2;
  Point[0].Y := FrameWidth;
  Point[1].X := Point[0].Y;
  Point[1].Y := Point[0].Y;
  Point[2].X := Point[0].Y;
  Point[2].Y := Point[0].X + 1;
  PolyLine(DC, Point, 3);
  Point[0].X := R.Right-1;
  Point[0].Y := 1;
  Point[1].X := R.Right-1;
  Point[1].Y := R.Bottom-1;
  Point[2].X := 0;
  Point[2].Y := R.Bottom-1;
  PolyLine(DC, Point, 3);
  DeleteObject(SelectObject(DC, OldPen));
  Sq := Board^.SquareWidth;
  SetBkMode(DC, Transparent);
  SetTextColor(DC, 0);
  S[1] := #0;
  for X := 0 to 7 do
  begin
    S[0] := Char(Ord('8')-X);
    TextOut(DC, FrameWidth div 2 - FontWidth div 2,
                FrameWidth + 2 + (X * Sq) + (Sq div 2 - FontHeight div 2),
                S, 1);
    S[0] := Char(Ord('A')+X);
    TextOut(DC, FrameWidth + (X*Sq) + (Sq div 2 - FontWidth div 2),
                FrameWidth + 4 + Sq*8 + FrameWidth div 2 - FontHeight div 2,
                S, 1);
  end;
end;

procedure TBoardFrame.WMMove(var Msg: TMessage);
var
  P: TPoint;
begin
  DefWndProc(Msg);
  P.X := FrameWidth + 3;
  P.Y := P.X;
  ClientToScreen(HWindow, P);
  ScreenToClient(Parent^.HWindow, P);
  SetWindowPos(Board^.HWindow,0,P.X,P.Y,0,0, swp_NoSize or swp_NoZOrder);
end;

procedure TBoardFrame.WMSize(var Msg: TMessage);
var
  P: TPoint;
begin
  DefWndProc(Msg);
  P.X := FrameWidth + 3;
  P.Y := P.X;
  ClientToScreen(HWindow, P);
  ScreenToClient(Parent^.HWindow, P);
  SetWindowPos(Board^.HWindow, 0, P.X, P.Y,
               LoWord(Msg.LParam) - 2 * (FrameWidth + 3),
               HiWord(Msg.LParam) - 2 * (FrameWidth + 3),
               swp_NoActivate or swp_NoZOrder);
end;

end.