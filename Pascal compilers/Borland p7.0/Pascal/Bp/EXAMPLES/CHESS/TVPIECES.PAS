{************************************************}
{                                                }
{   Turbo Vision Chess Demo                      }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit TVPieces;

interface

{$IFDEF DPMI}
uses Objects, Views, Dialogs, ChessDLL, TVChsCmd, Drivers;
{$ELSE}
uses Objects, Views, Dialogs, ChessInf, TVChsCmd, Drivers;
{$ENDIF}

type

{ TGlyphButton }

  { Palette layout }
  { 1 = Button background }
  { 2 = Normal white piece }
  { 3 = Normal black piece }
  { 4 = Selected white piece }
  { 5 = Selected black piece }
  { 6 = Shadow }

  PGlyphButton = ^TGlyphButton;
  TGlyphButton = object(TButton)
    Piece: TPiece;
    Color: TColor;
    constructor Init(var Bounds: TRect; APiece: TPiece; AColor: TColor;
      ATitle: TTitleStr; ACommand: Word; AFlags: Byte);
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    procedure DrawState(Down: Boolean);
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
  end;

{ TPromoteDialog }

  { Palette layout }
  { 1..32 = CGrayDialog }
  { 33 = Button background }
  { 34 = Normal white piece }
  { 35 = Normal black piece }
  { 36 = Selected white piece }
  { 37 = Selected black piece }
  { 38 = Shadow }

  PPromoteDialog = ^TPromoteDialog;
  TPromoteDialog = object(TDialog)
    constructor Init(AColor: TColor);
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

{ TChessPiece}

  PChessPiece = ^TChessPiece;
  TChessPiece = object(TView)
    PieceType: TSquare;
    Location: TLocation;
    InJeopardy: Boolean;
    constructor Init(var Bounds: TRect; APieceType: TSquare; ALocation: TLocation);
    constructor Load(var S:TStream);
    procedure CapturePiece;
    procedure CheckJeopardy(var MoveArray: array of TMove);
    procedure Draw; virtual;
    function GetPromotionPiece: TPiece;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure MoveToSquare(ALocation: TLocation);
    function PerformMove(C: TChange): Boolean;
    procedure RawDraw(var B: TDrawBuffer; BufPos, Line: Integer;
      var XOfs, XLen: Integer);
    procedure SnapToSquare;
    procedure Store(var S: TStream);
  end;

const
  RChessPiece: TStreamRec = (
    ObjType: otChessPiece;
    VmtLink: Ofs(TypeOf(TChessPiece)^);
    Load:    @TChessPiece.Load;
    Store:   @TChessPiece.Store);

  RGlyphButton: TStreamRec = (
    ObjType: otGlyphButton;
    VmtLink: Ofs(TypeOf(TGlyphButton)^);
    Load:    @TGlyphButton.Load;
    Store:   @TGlyphButton.Store);

  RPromoteDialog: TStreamRec = (
    ObjType: otPromoteDialog;
    VmtLink: Ofs(TypeOf(TPromoteDialog)^);
    Load:    @TPromoteDialog.Load;
    Store:   @TPromoteDialog.Store);

implementation

uses App, TVChsUtl, TVBoard;

type
  TPictureType = array[0..2] of
  record
     x : integer;
     s : string[6];
  end;

const
  PiecePicture: array[pKing..pPawn] of TPictureType =

        (((x : 1;   s :  '++++'),
          (x : 1;   s :  'ô Kô'),
          (x : 1;   s :  'õõõõ')),

         ((x : 1;   s :  'éééé'),
          (x : 1;   s :  'ÆÎÎµ'),
          (x : 1;   s :  '³ Q³')),

         ((x : 1;   s :  'ÚÒÒ¿'),
          (x : 1;   s :  '³ R³'),
          (x : 1;   s :  '³  ³')),

         ((x : 2;   s :   'Úê¿'),
          (x : 2;   s :   '³ ³'),
          (x : 2;   s :   '³B³')),

         ((x : 1;   s :  'ÚÄÄ¿'),
          (x : 1;   s :  'Ô¿''³'),
          (x : 2;   s :   '³N³')),

         ((x : 0;   s : ''     ),
          (x : 3;   s :    'P' ),
          (x : 2;   s :   'ððð')));


{ TGlyphButton }

constructor TGlyphButton.Init(var Bounds: TRect; APiece: TPiece;
  AColor: TColor; ATitle: TTitleStr; ACommand: Word; AFlags: Byte);
begin
  inherited Init(Bounds, ATitle, ACommand, AFlags);
  Piece := APiece;
  Color := AColor;
end;

constructor TGlyphButton.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(Piece, SizeOf(Piece));
  S.Read(Color, SizeOf(Color));
end;

procedure TGlyphButton.Draw;
begin
  DrawState(False);
end;

procedure TGlyphButton.DrawState(Down: Boolean);
var
  CButton, CShadow, CPiece: Word;
  Ch, SelCh: Char;
  I, S, Y, T: Integer;
  B: TDrawBuffer;

  procedure DrawPiece(Line: Byte);
  var
    L, SCOff: Integer;
  begin
    if Flags and bfLeftJust <> 0 then L := 1 else
    begin
      L := (S - Length(PiecePicture[Piece][Line].s) - 1) div 2;
      if L < 1 then L := 1;
    end;
    MoveCStr(B[I + L + PiecePicture[Piece][Line].x - 1],
      PiecePicture[Piece][Line].s, CPiece);
    if ShowMarkers and not Down then
    begin
      if State and sfSelected <> 0 then SCOff := 0 else
        if AmDefault then SCOff := 2 else SCOff := 4;
      WordRec(B[0]).Lo := Byte(SpecialChars[SCOff]);
      WordRec(B[S]).Lo := Byte(SpecialChars[SCOff + 1]);
    end;
  end;

begin
  CButton := GetColor($0101);
  CPiece := $0402;
  SelCh := '°';
  if State and sfActive <> 0 then
    if State and sfSelected <> 0 then
    begin
      CPiece := Swap(CPiece);
      SelCh := ' ';
    end;
  if Color = cBlack then CPiece := CPiece + $0101;
  CPiece := GetColor(CPiece);
  CShadow := GetColor(6);
  S := Size.X - 1;
  T := Size.Y div 2 - 2;
  for Y := 0 to Size.Y - 2 do
  begin
    MoveChar(B, SelCh, Byte(CButton), Size.X);
    WordRec(B[0]).Hi := CShadow;
    WordRec(B[0]).Lo := Byte(' ');
    if Down then
    begin
      WordRec(B[1]).Hi := CShadow;
      WordRec(B[1]).Lo := Byte(' ');
      Ch := ' ';
      I := 2;
    end else
    begin
      WordRec(B[S]).Hi := Byte(CShadow);
      if ShowMarkers then Ch := ' ' else
      begin
        if Y = 0 then
          WordRec(B[S]).Lo := Byte('Ü') else
          WordRec(B[S]).Lo := Byte('Û');
        Ch := 'ß';
      end;
      I := 1;
    end;
    if (Y >= T) and (Y <= T + 2) then DrawPiece(Y - T);
    if ShowMarkers and not Down then
    begin
      WordRec(B[1]).Lo := Byte(' ');
      WordRec(B[S - 1]).Lo := Byte(' ');
    end;
    WriteLine(0, Y, Size.X, 1, B);
  end;
  MoveChar(B[0], ' ', Byte(CShadow), 2);
  MoveChar(B[2], Ch, Byte(CShadow), S - 1);
  WriteLine(0, Size.Y - 1, Size.X, 1, B);
end;

function TGlyphButton.GetPalette: PPalette;
const
  P: String[Length(CGlyphButton)] = CGlyphButton;
begin
  GetPalette := @P;
end;

procedure TGlyphButton.HandleEvent(var Event: TEvent);
var
  Down: Boolean;
  Mouse: TPoint;
  ClickRect: TRect;
begin
  GetExtent(ClickRect);
  Inc(ClickRect.A.X);
  Dec(ClickRect.B.X);
  Dec(ClickRect.B.Y);
  if Event.What = evMouseDown then
  begin
    MakeLocal(Event.Where, Mouse);
    if not ClickRect.Contains(Mouse) then ClearEvent(Event)
    else
    begin
      if Flags and bfGrabFocus <> 0 then
        TView.HandleEvent(Event);
      if State and sfDisabled = 0 then
      begin
        Inc(ClickRect.B.X);
        Down := False;
        repeat
          MakeLocal(Event.Where, Mouse);
          if Down <> ClickRect.Contains(Mouse) then
          begin
            Down := not Down;
            DrawState(Down);
          end;
        until not MouseEvent(Event, evMouseMove);
        if Down then
        begin
          Press;
          DrawState(False);
        end;
      end;
      ClearEvent(Event);
    end;
  end;
  inherited HandleEvent(Event);
end;

procedure TGlyphButton.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(Piece, SizeOf(Piece));
  S.Write(Color, SizeOf(Color));
end;

{ TPromoteDialog }

constructor TPromoteDialog.Init(AColor: TColor);
var
  R: TRect;
begin
  R.Assign(0, 0, 44, 7);
  inherited Init(R, 'Promote Pawn');
  Flags := Flags and not (wfGrow + wfClose + wfZoom);
  Options := Options or ofCentered;
  R.Assign(3, 2, 11, 6);
  Insert(New(PGlyphButton, Init(R, pQueen, AColor, '~Q~', cmQueen,
    bfNormal + bfGrabFocus)));
  Inc(R.A.X, 10); Inc(R.B.X, 10);
  Insert(New(PGlyphButton, Init(R, pRook, AColor, '~R~', cmRook,
    bfNormal + bfGrabFocus)));
  Inc(R.A.X, 10); Inc(R.B.X, 10);
  Insert(New(PGlyphButton, Init(R, pBishop, AColor, '~B~', cmBishop,
    bfNormal + bfGrabFocus)));
  Inc(R.A.X, 10); Inc(R.B.X, 10);
  Insert(New(PGlyphButton, Init(R, pKnight, AColor, '~K~', cmKnight,
    bfNormal + bfGrabFocus)));
  SelectNext(False);
end;

function TPromoteDialog.GetPalette: PPalette;
const
  P: String[Length(CPromoteDialog)] = CPromoteDialog;
begin
  GetPalette := @P;
end;

procedure TPromoteDialog.HandleEvent(var Event: TEvent);
begin
  case Event.What of
    evCommand:
      begin
        case Event.Command of
          cmQueen,
          cmRook,
          cmKnight,
          cmBishop: if State and sfModal <> 0 then EndModal(Event.Command);
        else
          Exit;
        end;
        ClearEvent(Event);
      end;
    evKeyDown:
      case Event.KeyCode of
        kbEnter:
          begin
            Event.What := evBroadcast;
            Event.Command := cmDefault;
            Event.InfoPtr := nil;
            PutEvent(Event);
            ClearEvent(Event);
          end;
        kbEsc: ClearEvent(Event);
      end;
  end;
  inherited HandleEvent(Event);
end;

{ TChessPiece }

constructor TChessPiece.Init(var Bounds: TRect; APieceType: TSquare; ALocation: TLocation);
begin
  inherited Init(Bounds);
  EventMask := EventMask or (evMove + evBroadcast);
  PieceType := APieceType;
  Location := ALocation;
end;

constructor TChessPiece.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(PieceType, SizeOf(PieceType) + SizeOf(TLocation));
end;

procedure TChessPiece.CapturePiece;
begin
  PChessBoard(Owner)^.RemovePiece(@Self, Location);
  Free;
end;

{ CheckJeopardy takes the valid move list of the opponent and looks
  for any move that will capture this piece. }

procedure TChessPiece.CheckJeopardy(var MoveArray: array of TMove);
var
  X: Integer;
  OldState: Boolean;
begin
  OldState := InJeopardy;
  InJeopardy := False;
  X := 0;
  while (not InJeopardy) and
        (X <= High(MoveArray)) and
        (MoveArray[X].Change.Piece <> pEmpty) do
  begin
    InJeopardy := (Word(MoveArray[X].Change.Dest) = Word(Location));
    Inc(X);
  end;
  if OldState xor InJeopardy then  { If state has changed, redraw }
    DrawView;
end;

procedure TChessPiece.Draw;
var
  I: Integer;
  B: TDrawBuffer;
  R: TRect;
  XOfs, XLen: Integer;
  WasVisible: Boolean;

  procedure DoDraws(P: PView);
  var
    Bounds: TRect;
  begin
    while P <> nil do
    begin
      if P^.State and sfVisible <> 0 then
      begin
        P^.GetBounds(Bounds);
        Bounds.Intersect(R);
        if not Bounds.Empty then
          P^.DrawView;
      end;
      P := P^.NextView;
    end;
  end;

begin
  Owner^.Lock;
  WasVisible := State and sfVisible <> 0;
  State := State and not sfVisible;
  GetBounds(R);
  DoDraws(NextView);
  if not WasVisible then
  begin
    Owner^.Unlock;
    Exit;
  end;
  State := State or sfVisible;

  for I := 0 to 2 do
  begin
    RawDraw(B, 0, I, XOfs, XLen);
    if XLen > 0 then
      WriteBuf(XOfs, I, XLen, 1, B[XOfs]);
  end;

  Owner^.Unlock;
end;

function TChessPiece.GetPromotionPiece: TPiece;
var
  P: PWindow;
  Result: Word;
begin
  if PieceType.Piece = pPawn then
  begin
    P := New(PPromoteDialog, Init(PieceType.Color));
    Result := Application^.ExecView(Application^.ValidView(P));
    GetPromotionPiece := TPiece(Result - cmQueen + Ord(pQueen));
    Dispose(P, Done);
  end
  else GetPromotionPiece := PieceType.Piece;
end;

procedure TChessPiece.HandleEvent(var Event: TEvent);
var
  E: TEvent;
  R: TRect;
  P: PChessPiece;
  S: TSquare;
begin
  inherited HandleEvent(Event);
  case Event.What of
    evMouseDown:
      if PChessBoard(Owner)^.CanMovePiece(PieceType.Color) then
      begin
        MakeFirst;
        R.Assign(0, 0, Owner^.Size.X, Owner^.Size.Y);
        Show;
        DragView(Event, dmDragMove, R, Size, Size);
        Hide;
        SnapToSquare;
      end;
    evMove:
      case Event.Command of
        cmMovePiece:
          with PMove(Event.InfoPtr)^ do
            if (Kind in [kNormal, kEnPassant, kPawnPromote, kCastling]) and
              (Word(Change.Source) = Word(Location)) then
            begin
              if (Kind = kPawnPromote) and (PieceType.Piece = pPawn) then
                PieceType.Piece := Change.Piece;
              MoveToSquare(Change.Dest);
            end
            else if (PieceType.Piece = Contents) and Capture and
              (Word(Change.Dest) = Word(Location)) then
              CapturePiece
            else if (Kind = kCastling) and (PieceType.Piece = pRook) and
              (Word(RookSource) = Word(Location)) then
              MoveToSquare(RookDest)
            else if (Kind = kEnPassant) and (PieceType.Piece = Contents) and
              Capture and (Word(EPCapture) = Word(Location)) then
              CapturePiece;
        cmUndoMove:
          with PMove(Event.InfoPtr)^ do
            if (Word(Change.Dest) = Word(Location)) then
            begin
              if (Kind = kPawnPromote) and (Change.Piece = PieceType.Piece) then
                PieceType.Piece := pPawn;
              MoveToSquare(Change.Source);
              if Capture then
              begin
                S.Piece := Contents;
                if PieceType.Color = cWhite then
                  S.Color := cBlack else S.Color := cWhite;
                case Kind of
                  kNormal:
                    begin
                      SquareToLocal(Change.Dest, R.A, Owner^.Size.Y);
                      R.Assign(R.A.X, R.A.Y, R.A.X + 6, R.A.Y + 3);
                      P := New(PChessPiece, Init(R, S, Change.Dest));
                    end;
                  kEnPassant:
                    begin
                      SquareToLocal(EPCapture, R.A, Size.Y);
                      R.Assign(R.A.X, R.A.Y, R.A.X + 6, R.A.Y + 3);
                      P := New(PChessPiece, Init(R, S, EPCapture));
                    end;
                end;
                PChessBoard(Owner)^.InsertPiece(P, P^.Location);
              end;
            end
            else if (Kind = kCastling) and (PieceType.Piece = pRook) and
              (Word(RookDest) = Word(Location)) then
              MoveToSquare(RookSource);
        cmFindPiece:
          if Event.InfoWord = Word(Location) then
            ClearEvent(Event);
      end;
    evBroadcast:
      case Event.Command of
        cmRegisterSave: PCollection(Event.InfoPtr)^.Insert(@Self);
      end;
  end;
end;

procedure TChessPiece.MoveToSquare(ALocation: TLocation);
var
  Point: TPoint;
begin
  PChessBoard(Owner)^.MovePiece(@Self, Location, ALocation);
  Location := ALocation;
  SquareToLocal(Location, Point, Owner^.Size.Y);
  MoveTo(Point.X, Point.Y);
end;

function TChessPiece.PerformMove(C: TChange): Boolean;
var
  Result: TChessError;
begin
  PerformMove := True;
  Result := PChessBoard(Owner)^.ValidateMove(C);
  case Result of
    ceOK: Message(Owner, evMove, cmSubmitMove, @C);
    ceAmbiguousMove:
      begin
        C.Piece := GetPromotionPiece;
        Message(Owner, evMove, cmSubmitMove, @C);
      end;
  else
    PerformMove := False;
  end;
end;

procedure TChessPiece.RawDraw(var B: TDrawBuffer; BufPos, Line: Integer;
  var XOfs, XLen: Integer);
var
  Color: Word;
begin
  if PieceType.Color = cBlack then
    Color := $0404 else Color := $0505;
  if InJeopardy then Color := Color + $0202;
  Color := GetColor(Color);
  XOfs := PiecePicture[PieceType.Piece][Line].x;
  XLen := Length(PiecePicture[PieceType.Piece][Line].s);
  if XLen > 0 then
    MoveStr(B[BufPos + XOfs], PiecePicture[PieceType.Piece][Line].s, Color);
end;

procedure TChessPiece.SnapToSquare;
var
  S: TLocation;
  P: TPoint;
  C: TChange;
begin
  P.X := Origin.X + (Size.X div 2);
  P.Y := Origin.Y + (Size.Y div 2);
  PointInSquare(P, S);
  C.Piece := pEmpty;
  C.Source := Location;
  C.Dest := S;
  if not PerformMove(C) then
  begin
    SquareToLocal(Location, P, Owner^.Size.Y);
    MoveTo(P.X, P.Y);
  end;
  PChessBoard(Owner)^.DrawSurface;
end;

procedure TChessPiece.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(PieceType, SizeOf(PieceType) + SizeOf(TLocation));
end;

end.
