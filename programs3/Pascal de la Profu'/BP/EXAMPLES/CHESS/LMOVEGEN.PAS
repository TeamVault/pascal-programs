{************************************************}
{                                                }
{   Chess - Shared DLL Example                   }
{   CHESS.DLL Move generator/Position analysis   }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit LMoveGen;

{$R-,Q-,S-,W-}

interface

uses  GameRec;

procedure CalcAttackTab;
function PieceAttacks(APiece: PieceType; AColor: ColorType;
  ASquare, Square:  SquareType): Boolean;
function Attacks(AColor: ColorType; Square: SquareType): Boolean;

{ Castling types }
type
  CastDirType = (Long,Short);
  CastType = set of CastDirType;

procedure CalcCastling(InColor: ColorType; var Cast: CastType);
function RepeatMove(Move: MoveType): Boolean;

type
  FiftyType = 0..150;

function FiftyMoveCnt: FiftyType;

type
  RepeatType = 1..4;

function Repetition(Immediate: Boolean): RepeatType;

function KillMovGen(Move: MoveType): Boolean;
procedure InitMovGen;
procedure MovGen;

{ Directions }
type
  DirType   = 0..7;

const
  { Move directions used in the Move generation }

  { Rook, Bishop etc. }
  DirTab:    array[DirType] of Integer =
    (1,-1,$10,-$10,$11,-$11,$F,-$F);

  { Knight moves }
  KnightDir: array[DirType] of Integer =
    ($E,-$E,$12,-$12,$1F,-$1F,$21,-$21);

  { Pawn Direction }
  PawnDir:   array[ColorType] of Integer =
    ($10,-$10);

{ Castling moves }
const
  CastMove: array[ColorType,CastDirType] of
    record
      CastNew,CastOld: SquareType;
    end =
    (((CastNew:   2;   CastOld:   4),
      (CastNew:   6;   CastOld:   4)),
     ((CastNew: $72;   CastOld: $74),
      (CastNew: $76;   CastOld: $74)));

implementation

{ Tables for calculating whether a Piece Attacks a Square }
type
  SetOfPiece = byte;
const
  BitTab: array[King..Pawn] of SetOfPiece = (1,2,4,8,$10,$20);

var
  { A constant, which is calculated in CalcAttackTab.
    Gives the squares which a Piece in the middle of the
    table can Move to.

    This is not modified during the game and can safely be
    made global in the chessdll, shared between game contexts.}
  AttackTab: array[-$77..$77] of
    record
      { A set of King..Pawn.
        Gives the Pieces, which can
        Move to the Square }
      PieceSet:  SetOfPiece;
      Direction: Integer;  { The Direction from the Piece to the
                             Square }
    end;

{ Calculates AttackTab }
procedure CalcAttackTab;
var
  Dir: DirType;
  Sq: Integer;
  i: Byte;
begin
   FillChar(AttackTab, sizeof(AttackTab), 0);
   for Dir:=7 downto 0 do
   begin
     for i:=1 to 7 do
       with AttackTab[DirTab[Dir]*i] do
       begin
         if Dir<4 then
           PieceSet:=BitTab[Queen]+BitTab[Rook]
         else
           PieceSet:=BitTab[Queen]+BitTab[Bishop];
         Direction:=DirTab[Dir];
       end;
     with AttackTab[DirTab[Dir]] do
       PieceSet:=PieceSet+BitTab[King];
     with AttackTab[KnightDir[Dir]] do
     begin
       PieceSet:=BitTab[Knight];
       Direction:=KnightDir[Dir];
     end;
   end;
end; { CalcAttachTab }

{ Calculates whether APiece placed On ASquare Attacks the Square }
function PieceAttacks(APiece: PieceType; AColor: ColorType;
  ASquare, Square:  SquareType): Boolean;
var
  Sq: EdgeSquareType;
begin
  if APiece = Pawn then
    { Pawn Attacks }
    PieceAttacks := abs(Square - ASquare - PawnDir[AColor]) = 1

  else
    { Other Attacks: Can the Piece Move to the Square? }
    with AttackTab[Square - ASquare] do
      if (PieceSet and BitTab[APiece]) <> 0 then
        if (APiece = King) or (APiece = Knight) then
          PieceAttacks := true
        else
        begin
          { Are there any blocking Pieces in between? }
          Sq := ASquare;
          repeat
            Sq := Sq + Direction;
          until (Sq = Square) or (CC.Board[Sq].Piece <> Empty);
          PieceAttacks := Sq = Square;
        end
      else
         PieceAttacks := False;
end; { PieceAttacks }

{ Calculates whether AColor Attacks the Square }
function Attacks(AColor: ColorType; Square: SquareType): Boolean;

  { Calculates whether AColor Attacks the Square with a Pawn }
  function PawnAttacks(AColor: ColorType;
    Square: SquareType): Boolean;
  var   Sq: EdgeSquareType;
  begin
    PawnAttacks:=true;
    Sq := Square - PawnDir[AColor] - 1;                    { Left Square }
    if (Sq and $88) = 0 then
      with CC.Board[Sq] do
        if (Piece = Pawn) and (Color = AColor) then Exit;
    Sq := Sq + 2;                                         { Right Square }
    if (Sq and $88) = 0 then
      with CC.Board[Sq] do
        if (Piece = Pawn) and (Color = AColor) then Exit;
    PawnAttacks := False;
  end; { PawnAttacks }


var
  i: IndexType;

begin { Attacks }
   Attacks := True;

   { Pawn Attacks }
   if PawnAttacks(AColor,Square) then
      Exit;

   { Other Attacks:  Try all Pieces, starting with the smallest }
   with CC do
     for i := OfficerNo[AColor] downto 0 do
       with PieceTab[AColor,i] do
         if IPiece <> Empty then
           if PieceAttacks(IPiece,AColor,ISquare,Square) then
             Exit;

   Attacks := False;
end; { Attacks }

{ Calculates whether InColor can castle }
procedure CalcCastling(InColor: ColorType; var Cast: CastType);

  function Check(Square: SquareType; InPiece: PieceType): Boolean;
  { Checks whether InPiece is placed On Square and has never moved }
  var
    Dep: DepthType;
  begin
    Check := False;
    with CC, Board[Square] do                             { Check Square }
      if (Piece = InPiece) and (Color = InColor) then
      begin
        Dep := Depth - 1;                              { Check all moves }
        while MovTab[Dep].MovPiece <> Empty do
        begin
          if MovTab[Dep].New1 = Square then Exit;
          Dep := Dep - 1;
        end;
        Check := True;
      end;
  end; { Check }

var
  Square: SquareType;
begin { CalcCastling }
  Square := 0;
  if InColor = Black then Square := $70;
  Cast :=[];
  if Check(Square + 4,King) then
  begin                                                     { Check King }
    if Check(Square  ,Rook) then Cast := Cast +[Long];    { Check a-Rook }
    if Check(Square + 7,Rook) then Cast := Cast +[Short]; { Check h-Rook }
  end;
end; { CalcCastling }

{ Check if Move is a Pawn Move or a capture }
function RepeatMove(Move: MoveType): Boolean;
begin
  with Move do
    RepeatMove := (MovPiece <> Empty) and (MovPiece <> Pawn)
      and (Content = Empty) and not Spe;
end; { RepeatMove }

{ Counts the Number of moves since Last capture or Pawn Move.
  The game is a Draw when FiftyMoveCnt = 100 }
function FiftyMoveCnt: FiftyType;
var   Cnt: FiftyType;
begin
  Cnt := 0;
  with CC do
    while RepeatMove(MovTab[Depth - Cnt]) do
      Inc(Cnt);
  FiftyMoveCnt := Cnt;
end;

{ Calculates how many times the position has occured before.
  The game is a Draw when Repetition = 3.
  MovTab[Back..Depth] contains the previous moves.
  When Immediate is set, only Immediate Repetition is checked }
function Repetition(Immediate: Boolean): RepeatType;
var
  LastDep,CompDep,TraceDep,CheckDep,SameDepth: DepthType;
  TraceSq,CheckSq: SquareType;
  RepeatCount: RepeatType;
label 10;
begin
  with CC do
  begin
    Repetition := 1;
    RepeatCount := 1;
    SameDepth := Depth + 1;                           { Current position }
    CompDep := SameDepth - 4;                { First position to compare }
    LastDep := SameDepth;

    { MovTab[LastDep..Depth] contains previous relevant moves  }
    while RepeatMove(MovTab[LastDep - 1]) and
        ((CompDep < LastDep) or not Immediate) do
      Dec(LastDep);
    if CompDep < LastDep then Exit;             { No Repetition Possible }
    CheckDep := SameDepth;
    repeat
      Dec(CheckDep);                            { Get Next Move to test }
      CheckSq := MovTab[CheckDep].New1;
      TraceDep := CheckDep + 2;                { Check if Move has been }
      while TraceDep < SameDepth do
      begin
        if MovTab[TraceDep].Old = CheckSq then goto 10;
        Inc(TraceDep, 2);
      end;

      { Trace the Move backward to see whether
        it has been 'undone' earlier }
      TraceDep := CheckDep;
      TraceSq := MovTab[TraceDep].Old;
      repeat
        if TraceDep - 2 < LastDep then Exit;
        Dec(TraceDep, 2);
        { Check if Piece has been moved before }
        with MovTab[TraceDep] do
          if TraceSq = New1 then
            TraceSq := Old;
      until (TraceSq = CheckSq) and (TraceDep <= CompDep + 1);
      if TraceDep < CompDep then                   { Adjust evt. CompDep }
      begin
        CompDep := TraceDep;
        if odd(SameDepth - CompDep) then
        begin
          if CompDep = LastDep then Exit;
          Dec(CompDep);
        end;
        CheckDep := SameDepth;
      end;
      { All moves between SAMEDEP and CompDep have been checked,
        so a Repetition is Found }
  10: if CheckDep <= CompDep then
      begin
        Inc(RepeatCount);
        Repetition := RepeatCount;
        if CompDep - 2 < LastDep then Exit;
        SameDepth := CompDep;              { Search for more repetitions }
        Dec(CompDep, 2);
        CheckDep := SameDepth;
      end;
    until False;
  end;  { with CC^ }
end { Repetition };

{ Tests whether a Move is Possible.

   On entry :
      Move contains a full description of a Move, which
      has been legally generated in a different position.
      MovTab[Depth - 1] contains Last performed Move.

   On Exit :
      KillMovGen indicates whether the Move is Possible }
function KillMovGen(Move: MoveType): Boolean;
var
  CastSq: SquareType;
  Promote: PieceType;
  CastDir: CastDirType;
  Cast: CastType;
begin
   KillMovGen := False;
   with CC, Move do
   begin
     if Spe and (MovPiece = King) then
     begin
       { Castling }
       CalcCastling(Player,Cast);
       if New1 > Old then
         CastDir := Short
       else
         CastDir := Long;

       { Has King or Rook moved before? }
       if CastDir in Cast then
       begin
         CastSq := (New1 + Old) div 2;
         { Are the squares Empty? }
         if (Board[New1   ].Piece = Empty) then
           if (Board[CastSq].Piece = Empty) then
             if ((New1 > Old) or (Board[New1 - 1 ].Piece = Empty)) then
               { Are the squares unattacked? }
               if not Attacks(Opponent,Old) then
                 if not Attacks(Opponent,New1) then
                   if not Attacks(Opponent,CastSq) then
                     KillMovGen := True;
       end;
     end
     else
     if Spe and (MovPiece = Pawn) then
     begin
       { E.p. capture }
       with MovTab[Depth - 1] do
         { Was the Opponent's Move a 2 Square Move }
         if MovPiece = Pawn then
           if abs(New1 - Old) >= $20 then
             { Is there a Piece On the Square? }
             with Board[Move.Old] do
               if (Piece = Pawn) and (Color = Player) then
                 KillMovGen := Move.New1 = (New1 + Old) div 2;
     end { if }
     else
     begin
       if Spe then                                         { Normal test }
       begin
         Promote := MovPiece;                            { Pawnpromotion }
         MovPiece := Pawn;
       end;

       { Is the Content of Old and New1 squares correct? }
       if (Board[Old].Piece = MovPiece) and
          (Board[Old].Color = Player) and
          (Board[New1].Piece = Content) and
         ((Content = Empty) or
          (Board[New1].Color = Opponent)) then

          { Is the Move Possible? }
          if MovPiece = Pawn then
            if Abs(New1 - Old) < $20 then
              KillMovGen := True
            else
              KillMovGen := Board[(New1 + Old) div 2].Piece = Empty
          else
             KillMovGen := PieceAttacks(MovPiece,Player,Old,New1);
       if Spe then
         MovPiece := Promote;
     end;
  end; { with }
end; { KillMovGen }

{ Movegeneration variables }

{ The move generator.
  InitMovGen generates all Possible moves and places them
  in a Buffer. MovGen will then Generate the moves One by One and
  place them in Next.

  On entry :
     Player contains the Color to Move.
     MovTab[Depth - 1] the Last performed Move.

  On Exit :
     Buffer contains the generated moves.

     The moves are generated in the order :
        Captures
        Castlings
        Non captures
        E.p. captures }
procedure InitMovGen;

  { Stores a Move in Buffer }
  procedure Generate;
  begin
    with CC do
    begin
      BufCount := BufCount + 1;
      Buffer[BufCount] := NextMove;
    end;
  end; { Generate }

  { Generates Pawnpromotion }
  procedure PawnPromotionGen;
  var
    Promote: PieceType;
  begin
    with CC.NextMove do
    begin
      Spe := True;
      for Promote := Queen to Knight do
      begin
        MovPiece := Promote;
        Generate;
      end;
      Spe := False;
    end;
  end; { PawnPromotionGen }

  { Generates captures of the Piece On New1 using PieceTab }
  procedure CapMovGen;
  var
    NextSq,Sq: EdgeSquareType;
    i:  IndexType;
  begin
    with CC, NextMove do
    begin
      Spe := False;
      Content := Board[New1].Piece;
      MovPiece := Pawn;                                  { Pawn captures }
      NextSq := New1 - PawnDir[Player];
      for Sq := NextSq - 1 to NextSq + 1 do if Sq <> NextSq then
      if (Sq and $88) = 0 then
        with Board[Sq] do
          if (Piece = Pawn) and (Color = Player) then
          begin
            Old := Sq;
            if (New1 < 8) or (New1 >= $70) then
              PawnPromotionGen
            else
              Generate;
          end;

      { Other captures, starting with the smallest Pieces }
      for i := OfficerNo[Player] downto 0 do
        with PieceTab[Player,i] do
          if (IPiece <> Empty) and (IPiece <> Pawn) then
            if PieceAttacks(IPiece,Player,ISquare,New1) then
            begin
              Old := ISquare;
              MovPiece := IPiece;
              Generate;
            end;
        end { with };
  end; { CapMovGen }

  { Generates non captures for the Piece On Old }
  procedure NonCapMovGen;
  var
    First,Last,Dir: DirType;
    Direction: Integer;
    NewSq: EdgeSquareType;
  begin
    with CC, NextMove do
    begin
      Spe := False;
      MovPiece := Board[Old].Piece;
      Content := Empty;
      case MovPiece of
        King:
          for Dir := 7 downto 0 do
          begin
            NewSq := Old + DirTab[Dir];
            if (NewSq and $88) = 0 then
              if Board[NewSq].Piece = Empty then
              begin
                New1 := NewSq;
                Generate;
              end;
          end;
        Knight:
          for Dir := 7 downto 0 do
          begin
            NewSq := Old + KnightDir[Dir];
            if (NewSq and $88) = 0 then
              if Board[NewSq].Piece = Empty then
              begin
                New1 := NewSq;
                Generate;
              end;
          end;
        Queen,
        Rook,
        Bishop:
          begin
            First := 7;
            Last := 0;
            if MovPiece = Rook   then First := 3;
            if MovPiece = Bishop then Last := 4;
            for Dir := First downto Last do
            begin
              Direction := DirTab[Dir];
              NewSq := Old + Direction;
              { Generate all non captures in
                    the Direction }
              while (NewSq and $88) = 0 do
              begin
                if Board[NewSq].Piece <> Empty then Break;
                New1 := NewSq;
                Generate;
                NewSq := New1 + Direction;
              end;
            end;
          end;
        Pawn:
          begin
            New1 := Old + PawnDir[Player];          { One Square forward }
            if Board[New1].Piece = Empty then
              if (New1 < 8) or (New1 >= $70) then
                PawnPromotionGen
              else
              begin
                Generate;
                if (Old < $18) or (Old >= $60) then
                begin
                  New1 := New1 + (New1 - Old);     { Two squares forward }
                  if Board[New1].Piece = Empty then
                    Generate;
                end;
              end;
          end;
      end; { case }
    end; { with }
  end; { NonCapMovGen }

var
  CastDir: CastDirType;
  Sq: EdgeSquareType;
  Index: IndexType;

begin { InitMovGen }
  { Reset the Buffer }
  with CC, NextMove do
  begin
    BufCount := 0;
    BufPnt := 0;

    { Generate all captures starting with captures of
      largest Pieces }
    for Index := 1 to PawnNo[Opponent] do
      with PieceTab[Opponent,Index] do
        if IPiece <> Empty then
        begin
          New1 := ISquare;
          CapMovGen;
        end;

    { Castling }
    Spe := True;
    MovPiece := King;
    Content := Empty;
    for CastDir := Short downto Long do
      with CastMove[Player,CastDir] do
      begin
        New1 := CastNew;
        Old := CastOld;
        if KillMovGen(NextMove) then Generate;
      end;

    { Generate non captures, starting with pawns }
    for Index := PawnNo[Player] downto 0 do
      with PieceTab[Player,Index] do
        if IPiece <> Empty then
        begin
          Old := ISquare;
          NonCapMovGen;
        end;

    { E.p. captures }
    with MovTab[Depth - 1] do
      if MovPiece = Pawn then
        if Abs(New1 - Old) >= $20 then
        begin
          NextMove.Spe := True;
          NextMove.MovPiece := Pawn;
          NextMove.Content := Empty;
          NextMove.New1 := (New1 + Old) div 2;
          for Sq := New1 - 1 to New1 + 1 do
            if Sq <> New1 then
              if (Sq and $88) = 0 then
              begin
                NextMove.Old := Sq;
                if KillMovGen(NextMove) then Generate;
              end;
        end;
  end; { with }
end; { InitMovGen }

{ Place Next Move from the Buffer in Next.
  Generate ZeroMove when there is No more moves }
procedure MovGen;
begin
  with CC do
  begin
    if BufPnt >= BufCount then
       NextMove := ZeroMove
    else
    begin
       BufPnt := BufPnt + 1;
       NextMove := Buffer[BufPnt];
    end;
  end;
end; { MovGen }

end.