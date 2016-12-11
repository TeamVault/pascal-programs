{************************************************}
{                                                }
{   Chess - Shared DLL Example                   }
{   CHESS.DLL Primary search engine.             }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit LEval;

{$R-,Q-,S-,W-}

interface

function FindMove(MaxLevel: integer): integer;
procedure InitPawnStrTables;

implementation

uses Strings, GameRec, LBoard, LMovegen, LMoves, LTimer, TaskMgr, GameTask;

type
  { File numbers }
  FileType = 0..7;
  { Rank numbers }
  RankType = 0..7;

{ Evaluation parameters }
const

  { Value of Pieces used in Evaluation }
  PieceValue: array[Empty..Pawn] of integer =
    (0, $1000, $900, $4C0, $300, $300, $100);

  { Tolerance Width }
  Tolerance = 8;

  { Used to calculate distance to center }
  DistAn: array[0..7] of Integer = (3,2,1,0,0,1,2,3);

  { The Value of a Pawn is the sum of Rank and file values.
    The file Value is equal to PawnFileFactor * (Rank Number + 2) }
  PawnRank: array [RankType] of Integer = (0,0, 0, 2, 4, 8,30,0);
  PassPawnRank: array [RankType] of Integer = (0,0,10,20,40,60,70,0);
  PawnFileFactor:  array [FileType] of Integer = (0,0,2,5,6,2,0,0);

  { Value of castling (Long..Short) }
  CastValue:      array[CastDirType] of Integer = (4,32);

  { Value of exchanging Pieces (not pawns) when ahead }
  ExchangeValue = 32;

  { Pawnstructure values }
  IsolatedPawn  = 20;   { Isolated Pawn. Double isolated Pawn is 3 * 20 }
  DoublePawn    =  8;   { Double Pawn }
  SidePawn      =  6;   { Having a Pawn On the side }
  ChainPawn     =  3;   { Being covered by a Pawn }
  CoverPawn     =  3;   { Covering a Pawn }
  NotMovePawn   =  3;   { Penalty for moving Pawn }

  { Penalty for Bishop blocking d2/e2 Pawn }
  BishopBlockValue   = 20;

  { Bonus for Rook behind passed Pawn }
  RookBehindPassPawn = 16;

  { Values for calculating importance of each Square (AttVal) }
  SquareRankValue: array [RankType] of byte = (0,0,0,0,1,2,4,4);

{ Pawnstructure table.
  One and Dob are SETs of FILEs, and contains
  the FILEs which has One respectively more pawns.
  The table is updated and evaluated at each Ply in the Search.
  FileBitTab is used to lookup a file in a set of FILEs }
type
  SetofFile   = byte;
  PawnBitRec  = record
                  One,Dob: SetofFile;
                 end;
  PawnBitType = array [ColorType] of PawnBitRec;

const
  FileBitTab: array [FileType] of SetofFile = (1,2,4,8,$10,$20,$40,$80);


{ Calculates the Value of the Piece On the Square }
function PiecePosVal(Piece:  PieceType; Color:  ColorType;
  Square: SquareType): Integer;
begin
   PiecePosVal := PieceValue[Piece] + CC.PVTable[Color,Piece,Square];
end;

{ Pawn strength tables }

var
  PawnStrDob: array[0..255] of Byte;
  PawnStrIso: array[0..255] of Byte;

{ Initialize the pawn strength tables }
procedure InitPawnStrTables;
var
  I: Integer;

   function BitCount(B: SetOFFile): Integer; assembler;
   asm
	XOR	AX,AX
	MOV	DL,B
	MOV	CX,8
	CLC
@@1:    SHR	DL,1
	JNC	@@2
	INC	AX
@@2:    JZ	@@3
	LOOP	@@1
@@3:
   end;

begin
  for I := 0 to 255 do
  begin
    PawnStrDob[I] := BitCount(I) * DoublePawn;
    PawnStrIso[I] := BitCount(I) * IsolatedPawn;
  end;
end;

{ Calculate the pawn strength from the pawn strength tables }
function PawnStrVal(var PB: PawnBitRec): Integer; near; assembler;
asm
	XOR	AX,AX
	LES	DI,PB
        MOV	AL,ES:[DI].PawnBitRec.One
	MOV	CX,AX
        MOV	BX,AX
	SHR	CX,1
        SHL	BX,1
        OR	CX,BX
        NOT	CX
        MOV	BX,AX
        AND	BX,CX
        MOV	AL,ES:[DI].PawnBitRec.Dob
        MOV	SI,AX
        MOV	AL,BYTE PTR PawnStrDob[SI]
        ADD	AL,BYTE PTR PawnStrIso[BX]
        ADC	AH,0
	AND	BL,ES:[DI].PawnBitRec.Dob
        ADD	AL,BYTE PTR PawnStrIso[BX]
        ADC	AH,0
        ADD	AL,BYTE PTR PawnStrIso[BX]
        ADC	AH,0
        NEG	AX
end;

{ Finds a move in the position.
  On exit :
     MAINLINE contains principal variation.
     MAINEVALU contains evaluation of the line
}
function FindMove(MaxLevel: Integer): Integer;
var
  { Value of root position in the Search }
  RootValue: MaxType;

  { Total material and material advantage }
  TotalMaterial,PawnTotalMaterial,Material: Integer;

  { Material Level of the game (early middlegame = 43 - 32, endgame = 0) }
  MaterialLevel: 0..60;

  PawnBit: array[-1..MaxPly] of PawnBitType;

  Mating: Boolean;   { Mating Evaluation function is used }

  { Calculates Piece-Value table for the static Evaluation function }
  procedure CalcPVTable;
  type
    { Pawn table, containing the squares with a Pawn }
      PawnTabType = array[RankType] of SetofFile;

  var
    PawnTab:      array[ColorType] of PawnTabType;

    { Bit tables for static Pawn structure Evaluation }
    PawnFileTab, Bit,
    OpPassTab, BehindOpPass,
    LeftSideTab, RightSideTab ,SideTab,
    LeftChainTab, RightChainTab,ChainTab,
    LeftCoverTab, RightCoverTab: SetofFile;

    { Importance of an attack of the Square }
    AttackValue:  array[ColorType,SquareType] of 0..120;

    { Value of squares controlled from the Square }
    PVControl: array[ColorType,Rook..Bishop,SquareType] of 0..250;

    LosingColor: ColorType;   { The Color which is being mated }
    PosVal: Integer;          { The positional Value of Piece }
    AttVal: Integer;          { The attack Value of the sqaure }
    Line: FileType;           { The file of the Piece }
    Rank, Row: RankType;      { The Rank and Row of the Piece }
    Dist,                     { Distance to center }
    KingDist: 0..14;          { Distance to opponents King }
    Cast: CastType;           { Possible castlings }
    Direct: Boolean;          { Indicates Direct attack }
    Cnt: Integer;             { Counter for attack values }
    StrVal: Integer;          { Pawnstructure Value }
    Color,
    OppColor: ColorType;      { Color and opponents Color }
    PieceCount: PieceType;    { Piece counter }
    Square: SquareType;       { Square counter }
    Dir: DirType;             { Direction counter }
    Sq: EdgeSquareType;       { Square counter }
    Temp,Temp2: Integer;      { Temporaries }
    TempColor: ColorType;

  begin
    { Calculate SAMMAT, PAWNSAMMAT and Material }
    Mating := False;
    TotalMaterial := 0;
    PawnTotalMaterial := 0;
    Material := 0;
    with CC do
    begin
      for Square := 0 to $77 do
        if (Square and $88) = 0 then
          with Board[Square] do
            if Piece <> Empty then
              if Piece <> King then
              begin
                Temp := PieceValue[Piece];
                TotalMaterial := TotalMaterial + Temp;
                if Piece = Pawn then
                  PawnTotalMaterial := PawnTotalMaterial + PieceValue[Pawn];
                if Color = White then Temp := -Temp;
                Material := Material - Temp;
              end;
      MaterialLevel := Max(0,TotalMaterial - $2000) div $100;

      { set Mating if weakest Player has less that the equivalence of
        two Bishops and the advantage is at least a Rook for a Bishop }
      if Material < 0 then
        LosingColor := White
      else
        LosingColor := Black;
      Mating := ((TotalMaterial - abs(Material)) div 2 <=
        PieceValue[Bishop] * 2) and (Abs(Material) >= PieceValue[Rook] -
        PieceValue[Bishop]);

      { Calculate ATTACKVAL (importance of each Square) }
      for Rank := 0 to 7 do
        for Line := 0 to 7 do
        begin
          Square := Rank shl 4 + Line;

          { Center importance }
          AttVal := Max(0,8 - 3 * (DistAn[Rank] + DistAn[Line]));

          { Rank importance }
          for Color := White to Black do
          begin
            AttackValue[Color,Square] := SquareRankValue[Rank] * 3 *
                                         (MaterialLevel + 8) shr 5 + AttVal;
            Square := Square xor $70;
          end;
        end; { for }
       for Color := White to Black do
       begin
         OppColor := ColorType(1 - ord(Color));
         CalcCastling(OppColor,Cast);
         if not (Short in Cast) and (MaterialLevel > 0) then
            { Importance of the 8 squares around the Opponent's King }
            with PieceTab[OppColor,0] do
               for Dir := 0 to 7 do
               begin
                 Sq := ISquare + DirTab[Dir];
                 if (Sq and $88) = 0 then
                    AttackValue[Color,Sq] := AttackValue[Color,Sq] +
                      12 * (MaterialLevel + 8) shr 5;
               end;
       end; { for }

       { Calculate PVControl }
       for Square := $77 downto 0 do
         if (Square and $88) = 0 then
           for Color := White to Black do
             for PieceCount := Rook to Bishop do
                PVControl[Color,PieceCount,Square] := 0;

       for Square := $77 downto 0 do
         if (Square and $88) = 0 then
           for Color := White to Black do
           begin
             for Dir := 7 downto 0 do
             begin
               if Dir < 4 then
                  PieceCount := Rook
               else
                  PieceCount := Bishop;
               { Count Value of all Attacks from the Square in
                 the Direction.
                 The Value of attacking a Square is Found in ATTACKVAL.
                 Indirect Attacks (e.g. a Rook attacking through
                 another Rook) counts for a Normal attack,
                 Attacks through another Piece counts half }
               Cnt := 0;
               Sq := Square;
               Direct := True;
               repeat
                  { Get Next Square }
                  Sq := Sq + DirTab[Dir];
                  if (Sq and $88) <> 0 then Break;
                  Temp:=AttackValue[Color,Sq];
                  if Direct then                     { Add AttackValue }
                     Inc(Cnt, Temp)
                  else
                     Inc(Cnt, Temp shr 1);
                  with Board[Sq] do
                    if Piece <> Empty then
                      if (Piece <> PieceCount) and (Piece <> Queen) then
                         Direct := False;
               until Board[Sq].Piece = Pawn;
               Inc(PVControl[Color,PieceCount,Square],Cnt shr 2);
             end { for Dir };
          end { for Color };

       { Calculate PVTable, Value by Value }
       for Square := $77 downto 0 do
         if (Square and $88) = 0 then
         begin
           for Color := White to Black do
           begin
             OppColor := ColorType(1 - ord(Color));
             Line := Square and 7;
             Row := Square shr 4;
             Rank := Row;
             if Color = Black then Rank := 7 - Rank;
             Dist := DistAn[Rank] + DistAn[Line];
             with PieceTab[OppColor,0] do
                KingDist := abs(Square shr 4 - ISquare shr 4) +
                  (Square - ISquare) and 7;
             for PieceCount := King to Pawn do
             begin
                { Calculate POSITIONAL Value for the Piece On the Square }
                PosVal := 0;
                if Mating and (PieceCount <> Pawn) then
                begin
                  { Mating Evaluation }
                  if PieceCount = King then
                    if Color = LosingColor then
                    begin
                      PosVal := 128 - 16 * DistAn[Rank] - 12 * DistAn[Line];
                      if DistAn[Rank] = 3 then
                        PosVal := PosVal - 16;
                    end
                    else
                    begin
                      PosVal := 128 - 4 * KingDist;
                      if (DistAn[Rank] >= 2) or (DistAn[Line] = 3) then
                        PosVal := PosVal - 16;
                    end;
                end { Mating }
                else
                begin
                  Temp := PVControl[Color,Rook,Square];
                  Temp2:= PVControl[Color,Bishop,Square];

                  { Normal Evaluation function }
                  case PieceCount of
                     King:
                       if MaterialLevel <= 0 then PosVal := -2 * Dist;
                     Queen:
                       PosVal := (Temp + Temp2) shr 2;
                     Rook:
                       PosVal := Temp;
                     Bishop:
                       PosVal := Temp2;
                     Knight:
                       begin
                         Cnt := 0;
                         for Dir := 0 to 7 do
                         begin
                           Sq := Square + KnightDir[Dir];
                           if (Sq and $88) = 0 then
                             Cnt := Cnt + AttackValue[Color,Sq];
                         end;
                         PosVal := Cnt shr 1 - Dist * 3;
                       end;
                     Pawn:
                       if (Rank <> 0) and (Rank <> 7) then
                         PosVal := PawnRank[Rank] + PawnFileFactor[Line] *
                           (Rank + 2) - 12;
                  end { case };
                end; { else }
                PVTable[Color,PieceCount,Square] := PosVal;
             end { for PieceCount };
           end { for Color };
       end { for Square };

       { Calculate PawnTab (indicates which squares contain pawns) }
       for Color := White to Black do
         for Rank := 0 to 7 do
           PawnTab[Color,Rank] := 0;
       for Square := $77 downto 0 do
         if (Square and $88) = 0 then
           with Board[Square] do
             if Piece = Pawn then
             begin
               Rank := Square shr 4;
               if Color = Black then Rank := 7 - Rank;
               PawnTab[Color,Rank] :=
                 PawnTab[Color,Rank] or FileBitTab[Square and 7];
             end; { if }
       for Color := White to Black do   { Initialize PawnBit }
         with PawnBit[-1,Color] do
         begin
           One := 0;
           Dob := 0;
           for Rank := 1 to 6 do
           begin
             Temp := PawnTab[Color,Rank];
             Dob := Dob or One and Temp;
             One := One or Temp;
           end;
         end;

       { Calculate PawnStructureValue }
       RootValue := PawnStrVal(PawnBit[-1,Player]) - PawnStrVal(PawnBit[-1,Opponent]);

       { Calculate static Value for Pawn structure }
       for Color := White to Black do
       begin
         OppColor := ColorType(1 - ord(Color));
         PawnFileTab := 0;
         LeftSideTab := 0;
         RightSideTab := 0;
         OpPassTab := $FF;
         BehindOpPass := 0;
         for Rank := 1 to 6 do { Squares where opponents pawns are passed pawns }
         begin
           OpPassTab := OpPassTab and not (PawnFileTab or
                               LeftSideTab or RightSideTab);
           { Squares behind the opponents passed pawns }
           BehindOpPass := BehindOpPass or
                          (OpPassTab and PawnTab[OppColor,7 - Rank]);
           { Squares which are covered by a Pawn }
           LeftChainTab := LeftSideTab;
           RightChainTab := RightSideTab;
           PawnFileTab  := PawnTab[Color,Rank];         { Squares with pawns }
           { Squares with a Pawn beside them }
           LeftSideTab  := (PawnFileTab shl 1) and $FF;
           RightSideTab := (PawnFileTab shr 1) and $FF;
           SideTab      := LeftSideTab  or RightSideTab;
           ChainTab     := LeftChainTab or RightChainTab;
           { Squares covering a Pawn }
           Temp := PawnTab[Color,Succ(Rank)];
           LeftCoverTab := (Temp shl 1) and $FF;
           RightCoverTab := (Temp shr 1) and $FF;
           Sq := Rank shl 4;
           if Color = Black then Sq := Sq xor $70;
           Bit := 1;
           while Bit <> 0 do
           begin
             StrVal := 0;
             if (Bit and SideTab) <> 0 then
               StrVal := SidePawn
             else if (Bit and ChainTab) <> 0 then
               StrVal := ChainPawn;
             if (Bit and LeftCoverTab) <> 0 then
               StrVal := StrVal + CoverPawn;
             if (Bit and RightCoverTab) <> 0 then
               StrVal := StrVal + CoverPawn;
             if (Bit and PawnFileTab) <> 0 then
               StrVal := StrVal + NotMovePawn;
             PVTable[Color,Pawn,Sq] := PVTable[Color,Pawn,Sq] + StrVal;
             if (MaterialLevel <= 0) or (OppColor <> ProgramColor) then
             begin
               if (Bit and OpPassTab) <> 0 then                 { Passed pawns }
                 PVTable[OppColor,Pawn,Sq] :=
                   PVTable[OppColor,Pawn,Sq] + PassPawnRank[7 - Rank];
               if (Bit and BehindOpPass) <> 0 then { Rooks behind passed pawns }
               begin
                 Temp := Sq xor $10;
                 for TempColor := Black to White do
                 begin
                   PVTable[TempColor,Rook,Sq] :=
                     PVTable[TempColor,Rook,Sq] + RookBehindPassPawn;
                   if Rank = 6 then
                     PVTable[TempColor,Rook,Temp] :=
                       PVTable[TempColor,Rook,Temp] + RookBehindPassPawn;
                 end; { for }
               end; { if }
             end; { if }
             Sq := Succ(Sq);
             Bit := (Bit shl 1) and $FF;
           end; { while }
         end; { for }
       end; { for }

       { Calculate penalty for blocking center pawns with a Bishop }
       for Sq := 3 to 4 do
       begin
         with Board[Sq + $10] do
           if (Piece = Pawn) and (Color = White) then
             PVTable[White,Bishop,Sq + $20] :=
               PVTable[White,Bishop,Sq + $20] - BishopBlockValue;
         with Board[Sq + $60] do
           if (Piece = Pawn) and (Color = Black) then
             PVTable[Black,Bishop,Sq + $50] :=
               PVTable[Black,Bishop,Sq + $50] - BishopBlockValue;
       end; { for }

       { Calculate RootValue }
       for Square := $77 downto 0 do
         if (Square and $88) = 0 then
           with Board[Square] do
             if Piece <> Empty then
               if Color = Player then
                 RootValue := RootValue + PiecePosVal(Piece,Player,Square)
               else
                 RootValue := RootValue - PiecePosVal(Piece,Opponent,Square);
    end;  { with CC^ }
  end; { CalcPVTable }


  { Updates PawnBit and calculates Value when a Pawn is
    removed from Line }
  function DecPawnStrVal(Color: ColorType; Line: FileType): Integer;
  var
    Temp: Integer;
  begin
    with PawnBit[CC.Depth,Color] do
    begin
       Temp := not FileBitTab[Line];
       One := One and Temp or Dob;
       Dob := Dob and Temp;
    end;
    DecPawnStrVal := PawnStrVal(PawnBit[CC.Depth,Color]) -
      PawnStrVal(PawnBit[Pred(CC.Depth),Color]);
  end; { DecPawnStrVal }

  { Updates PawnBit and calculates Value when a Pawn moves
    from Old to New1 file }
  function MovePawnStrVal(Color: ColorType; New1, Old: FileType): Integer;
  var
    Temp, Temp2: Integer;
  begin
     with PawnBit[CC.Depth,Color] do
     begin
        Temp := FileBitTab[New1];
        Temp2 := not FileBitTab[Old];
        Dob := Dob or One and Temp;
        One := One and Temp2 or Dob or Temp;
        Dob := Dob and Temp2;
     end; { with }
     MovePawnStrVal := PawnStrVal(PawnBit[CC.Depth,Color]) -
       PawnStrVal(PawnBit[Pred(CC.Depth),Color]);
  end; { MovePawnStrVal }

  { Calculates STATIC Evaluation of the Move }
  function StateValu(MoveIt: MoveType): Integer;
  var
    Value: Integer;
    CastSquare,CornerSquare,EpSquare: SquareType;
  begin { StateValu }
    with CC, MoveIt do
    begin
      Value := 0;
      if Spe then
        if MovPiece = King then
        begin
          GenCastSquare(New1,CastSquare,CornerSquare);          { Castling }
          Value := PiecePosVal(Rook,Player,CastSquare) -
                   PiecePosVal(Rook,Player,CornerSquare);
          if New1 > Old then
            Inc(Value, CastValue[Short])
          else
            Inc(Value, CastValue[Long]);
        end
        else
          if MovPiece = Pawn then
          begin
            EpSquare := New1 - PawnDir[Player];             { E.p. capture }
            Value := PiecePosVal(Pawn,Opponent,EpSquare);
          end
          else
            { Pawnpromotion }
            Value := PiecePosVal(MovPiece,Player,Old) -
              PiecePosVal(Pawn, Player, Old) +
              DecPawnStrVal(Player, Old and 7);
      if Content <> Empty then                              { Normal moves }
      begin
        Value := Value + PiecePosVal(Content,Opponent,New1);
        { Penalty for exchanging Pieces when behind in material }
        if abs(MainEvalu) >= $100 then
          if Content <> Pawn then
            if (ProgramColor = Opponent) = (MainEvalu >= 0) then
              Dec(Value,ExchangeValue);
      end; { if }
      PawnBit[Depth] := PawnBit[Pred(Depth)];          { Calculate PawnBit }
      if (MovPiece = Pawn) and ((Content <> Empty) or Spe) then
        Value := Value + MovePawnStrVal(Player,New1 and 7,Old and 7);
      if (Content = Pawn) or Spe and (MovPiece = Pawn) then
        Value := Value - DecPawnStrVal(Opponent,New1 and 7);
      { Calculate Value of Move }
      StateValu := Value + PiecePosVal(MovPiece,Player,New1) -
        PiecePosVal(MovPiece,Player,Old);
    end; { with }
  end; { StateValu }

  var
    KillingMove: array[ 0..MaxPly,0..1] of MoveType;
    CheckTab: array[-1..MaxPly] of Boolean;       { Table of checks }
    { Square of eventual pawn On 7th Rank }
    PassedPawn: array[-2..MaxPly] of EdgeSquareType;

  { Initializes KillingMove, CheckTab and PassedPawn }
  procedure ClearKillMove;
  const
    rank7: array[ColorType] of SquareType = ($60, $10);
  var
    Dep: DepthType;
    Col: ColorType;
    Sq: SquareType;
    i : byte;
  begin
    {Clear KillingMove }
    FillChar(KillingMove, SizeOf(KillingMove), 0);
    CheckTab[-1] := False;                        { No Check at First Ply }
    PassedPawn[-2] := -1;
    PassedPawn[-1] := -1;
    { Place eventual pawns On 7th Rank in PassedPawn }
    for Col := White to Black do
      for Sq := rank7[Col] to rank7[Col] + 7 do
        with CC, Board[Sq] do
          if (Piece = Pawn) and (Color = Col) then
            if Col = Player then
              PassedPawn[-2] := Sq
            else
              PassedPawn[-1] := Sq;
  end; { ClearKillMove }

  var
    SkipSearch: Boolean;

  { Communicates with the user }
  procedure CallSmallTalk;
  var
    SearchStateDepth: DepthType;
    StoredMove: MoveType;
    Msg: Word;
    OpAn: Boolean;

     { Backup the Search and setup Talk surroundings }
     procedure GetProgramState;
     var
       OldPlayer: ColorType;
     begin
       with CC do
       begin
          SearchStateDepth := Depth;
          while Depth > 0 do
          begin
             Dec(Depth);
             OldPlayer := Opponent;
             Opponent := Player;
             Player   := OldPlayer;
             Perform(MovTab[Depth],True);
          end;
          Dec(Depth);
          if OpAn then
            TakeBackMove(MovTab[Depth]);
        end;
     end; { GetProgramState }

     { Restore the Search surroundings }
     procedure GetSearchState;
     var
       OldPlayer: ColorType;
     begin
       with CC do
       begin
         if OpAn then
           MakeMove(MovTab[Depth + 1]);
         Inc(Depth);
         while Depth < SearchStateDepth do
         begin
           Perform(MovTab[Depth],False);
           OldPlayer := Player;
           Player   := Opponent;
           Opponent := OldPlayer;
           Inc(Depth);
         end;
       end;
     end; { GetSearchState }

     function WaitFor(Send, Receive: Word): Word;
     var
       Msg: Word;
     begin
       repeat
         Msg := Message(Send);
       until Msg in [tmAbort, Receive];
       WaitFor := Msg;
     end;

  begin { CallSmallTalk }
   with CC do
   begin
     if TaskTimer.TimeExpired then
     begin
       OpAn := OppAnalysis in State;
       GetProgramState;           {  Save Search surroundings }
       StoredMove := MovTab[Depth + 1];

       Msg := Message(tmTimeExpired);
       case Msg of
         tmEnterMove:
           begin
             SkipSearch := True;
             Include(State, MovePending);
             if (OppAnalysis in State) and EqMove(KeyMove,StoredMove) then
             begin
               Exclude(State, MovePending);
     	       Exclude(State, OppAnalysis);
               SkipSearch := False;
               EnterKeyMove;
               repeat until Message(tmFindMove) = tmFindMove;
               Include(State, Analysis);
               if WaitFor(tmFindMove, tmResume) <> tmAbort then
                 Clock.Start
               else
               begin
                 Exclude(State, Analysis);
                 SkipSearch := True;
               end;
             end;
           end;
         tmAbort:
           begin
             Exclude(State, Analysis);
             Exclude(State, OppAnalysis);
             SkipSearch := True;
           end;
         tmResume:
           SkipSearch := False;
       end;
       GetSearchState;            {  Restore Search surroundings }
     end;
   end;
  end;

  type
    InfType = record
      PrincipVar: Boolean;      { Principal Variation Search }
      Value,                    { Static incremental Evaluation }
      Evaluation: MaxType;      { Evaluation of position }
    end;

  var
    StartInf: InfType;          { Inf at First Ply }
    AlphaWindow: MaxType;       { Alpha window Value }
    RepeatEvalu: MaxType;       { MainEvalu at Ply One }

  { Performs the Search.
    On entry :
       Player is Next to Move.
       MovTab[Depth - 1] contains Last Move.
       Alpha, Beta contains the Alpha - Beta window.
       Ply contains the Depth of the Search.
       Inf contains various informations.

    On Exit :
       BestLine contains the principal variation.
       Search contains the Evaluation for Player }
  function Search(Alpha, Beta: MaxType; Ply: Integer; Inf: InfType;
    var BestLine: LineType): MaxType;
  var
    Line: LineType;            { Best Line at Next Ply }
    CaptureSearch: Boolean;    { Indicates capture Search }
    MaxVal: MaxType;           { Maximal Evaluation (returned in Search) }
    NextPly: Integer;          { Depth of Search at Next Ply }
    NextInf: InfType;          { Information at Next Ply }
    ZeroWindow: Boolean;       { Zero-Width Alpha-Beta-window }

    { Move type }
    MovGenType: (Main, SpecialCap, Kill, Normal);

    { Update KillingMove using BestMove }
    procedure UpdateKill(BestMove: MoveType);
    begin
      with CC, BestMove do
        if MovPiece <> Empty then
        begin
          { Update KillingMove unless the Move is a capture of
            Last moved Piece }
          if (MovTab[Depth - 1].MovPiece = Empty) or
              (New1 <> MovTab[Depth - 1].New1) then
            if (KillingMove[Depth,0].MovPiece = Empty) or
              EqMove(BestMove,KillingMove[Depth,1]) then
            begin
              KillingMove[Depth,1] := KillingMove[Depth,0];
              KillingMove[Depth,0] := BestMove;
            end
            else
              if not EqMove(BestMove,KillingMove[Depth,0]) then
                KillingMove[Depth,1] := BestMove;
        end; { if }
    end; { UpdateKill }


    { Test if Move has been generated before }
    function GeneratedBefore: Boolean;
    var
      i: 0..1;
    begin
      GeneratedBefore := True;
      with CC do
      begin
        if MovGenType <> Main then
        begin
          if EqMove(MovTab[Depth],BestLine[Depth]) then Exit;
          if not CaptureSearch then
            if MovGenType <> Kill then
              for i := 0 to 1 do
                if EqMove(MovTab[Depth], KillingMove[Depth,i]) then Exit;
        end;
      end;
      GeneratedBefore := False;
    end; { GeneratedBefore }

    { Tests Cut-off. CutVal contains the maximal Possible Evaluation }
    function Cut(CutVal: MaxType): Boolean;
    begin
      Cut := False;
      if CutVal <= Alpha then
      begin
        Cut := True;
        if MaxVal < CutVal then MaxVal := CutVal;
      end;
    end; { Cut }

    { Performs Move, calculates Evaluation, tests Cut-off etc. }
    function Update: Boolean;
    var
      Selection: Boolean;
    label AcceptMove,TakeBackMove,CutMove;
    begin    { Update }
      with CC do
      begin
        with MovTab[Depth] do
        begin
          Inc(Nodes);
          NextPly := Ply - 1;                         { Calculate next ply }
          { MateSearch }
          if Level = MateSearch then
          begin
            { Perform Move On the Board }
            Perform(MovTab[Depth],False);

            { Check if Move is Legal }
            if Attacks(Opponent,PieceTab[Player,0].ISquare) then
              goto TakeBackMove;
            if Depth = 0 then
              LegalMoves := LegalMoves + 1;
            CheckTab[Depth] := False;
            PassedPawn[Depth] := -1;
            NextInf.Value := 0;
            NextInf.Evaluation := 0;
            if NextPly <= 0 then { Calculate Check and Perform evt. Cut-off }
            begin
              if NextPly = 0 then
              CheckTab[Depth] := Attacks(Player,PieceTab[Opponent,0].ISquare);
              if not CheckTab[Depth] then
              begin
                if Cut(NextInf.Value) then goto TakeBackMove;
              end;
           end;
           goto AcceptMove;
         end;

         { Make special limited CaptureSearch at First iteration }
         if MaxDepth <= 1 then
           if CaptureSearch and (Depth >= 2) then
             if not ((Content < MovPiece) or (MovGenType = SpecialCap) or
                 (Old = MovTab[Depth - 2].New1)) then
               goto CutMove;

         { Calculate Next static incremental Evaluation }
         NextInf.Value := -Inf.Value + StateValu(MovTab[Depth]);

         { Calculate CheckTab (only checks with moved Piece are calculated).
           Giving Check does not Count as a Ply }
         CheckTab[Depth] := PieceAttacks(MovPiece,Player,New1,
           PieceTab[Opponent, 0].ISquare);
         if CheckTab[Depth] then NextPly := Ply;

         { Calculate PassedPawn. Moving a Pawn to 7th Rank does not Count
           as a Ply }
         PassedPawn[Depth] := PassedPawn[Depth - 2];
         if MovPiece = Pawn then
           if (New1 < $18) or (New1 >= $60) then
           begin
             PassedPawn[Depth] := New1;
             NextPly := Ply;
           end;

           { Perform Selection at Last Ply and in capture Search }
           Selection := (NextPly <= 0) and not CheckTab[Depth] and
             (Depth > 0);
           if Selection then                            { Check Evaluation }
           if Cut(NextInf.Value + 0) then goto CutMove;

           { Perform Move On the Board }
           Perform(MovTab[Depth],False);

           { Check if move is legal }
           if Attacks(Opponent,PieceTab[Player,0].ISquare) then
             goto TakeBackMove;
           if PassedPawn[Depth] >= 0 then               { Check PassedPawn }
             with Board[PassedPawn[Depth]] do
               if (Piece <> Pawn) or (Color <> Player) then
                 PassedPawn[Depth] := -1;

           { Count Number of Legal moves at Ply 0 }
           if Depth = 0 then
             LegalMoves := LegalMoves + 1;

           { Calculate Random }
           if Depth = 0 then
             NextInf.Value := NextInf.Value + Random(4);

           { Calculate the Evaluation for the position }
           NextInf.Evaluation := NextInf.Value;
         end { with };

      AcceptMove:
         Update := False;
         Exit;

      TakeBackMove:
         Perform(MovTab[Depth],True);

      CutMove:
       end;  { with CC^ }
       Update := True;
    end { Update };

    { Calculate Draw bonus/penalty, and set Draw if the game is a Draw }
    function DrawGame: Boolean;
    var
      DrawCount: 0..4;
      SearchRepeat: RepeatType;
      SearchFifty: FiftyType;
    begin
      DrawGame := False;
      with CC do
      begin
        if Depth = 1 then
        begin
          SearchFifty := FiftyMoveCnt;
          SearchRepeat := Repetition(False);

          { 3rd Repetition is Draw }
          if SearchRepeat >= 3 then
          begin
            DrawGame := True;
            NextInf.Evaluation := 0;
            Exit;
          end;
          DrawCount := 0;
          if SearchFifty >= 96 then
            { 48 moves without Pawn }
            DrawCount := 3
          else if SearchRepeat >= 2 then
            { 2nd Repetition }
            DrawCount := 2
          else

          { 10 moves without Pawn }
          if SearchFifty >= 20 then
            DrawCount := 1;
          Inc(NextInf.Value, (RepeatEvalu div 4) * DrawCount);
          Inc(NextInf.Evaluation, (RepeatEvalu div 4) * DrawCount);
        end; { if }

        if Depth >= 3 then
        begin
          SearchRepeat := Repetition(True);
          if SearchRepeat >= 2 then
          begin
            { Immediate Repetition }
            DrawGame := True;
            NextInf.Evaluation := 0;
            Exit;
          end;
        end; { if }
      end; { with }
    end; { DrawGame }

    { Update BestLine and MainEvalu using Line and MaxVal }
    procedure UpdateBestLine;
    begin
      BestLine := Line;
      with CC do
      begin
        BestLine[Depth] := MovTab[Depth];
        if Depth = 0 then
        begin
          MainEvalu := MaxVal;
          if Level = MateSearch then
            MaxVal := AlphaWindow;
        end;
      end;
    end { UpdateBestLine };


    { The inner loop of the Search procedure. MovTab[Depth] contains
      the Move }
    function LoopBody: Boolean;
    var
      OldPlayer:    ColorType;
      LastAnalysis: Boolean;
    label RepeatSearch,NotSearch;
    begin    { LoopBody }
      LoopBody := False;
      if GeneratedBefore then Exit;
      with CC do
      begin

        { Initialize Line }
        if Depth < MaxPly then
        begin
          Line[Depth + 1] := ZeroMove;
          if MovGenType = Main then
            Line := BestLine;
        end;

        { PrincipVar indicates Principal Variation Search.
          ZeroWindow indicates zero - Width Alpha - Beta window }
        NextInf.PrincipVar := False;
        ZeroWindow := False;
        if Inf.PrincipVar then
          if MovGenType = Main then
            NextInf.PrincipVar := BestLine[Depth + 1].MovPiece <> Empty
          else
            ZeroWindow := MaxVal >= Alpha;

      RepeatSearch :

        { Update and test Cut-off }
        if Update then Exit;

        { Stop evt. Search }
        if Level = MateSearch then
           if (NextPly <= 0) and not CheckTab[Depth] then goto NotSearch;
        if DrawGame then goto NotSearch;
        if Depth >= MaxPly then goto NotSearch;

        { Analyse NextPly using a recursive call to Search }
        OldPlayer := Player; Player := Opponent; Opponent := OldPlayer;
        Inc(Depth);
        if ZeroWindow then
          NextInf.Evaluation := -Search(-Alpha - 1,- Alpha,NextPly,NextInf,Line)
        else
          NextInf.Evaluation := -Search(-Beta,- Alpha,NextPly,NextInf,Line);
        Dec(Depth);
        OldPlayer := Opponent;   Opponent := Player;   Player := OldPlayer;

      NotSearch :
        { Take Back Move }
        Perform(MovTab[Depth], True);
        if SkipSearch then
        begin
           LoopBody := True;
           Exit;
        end;
        LastAnalysis := Analysis in State;

        { Check elapsed tic time and test SkipSearch }
        CallSmallTalk;

        if (not SkipSearch) and (Analysis in State) {and ((Depth = 0) or
            not LastAnalysis) {and (MainEvalu > AlphaWindow)} then
          SkipSearch := Clock.TimeExpired;

        if (Analysis in State) and (MaxDepth <= 1) then
          SkipSearch := False;

        { Update MaxVal }
        MaxVal := Max(MaxVal,NextInf.Evaluation);

        { Update evt. BestLine }
        if EqMove(BestLine[Depth],MovTab[Depth]) then
          UpdateBestLine;

        { Update Alpha and test Cut-off }
        if Alpha < MaxVal then
        begin
          UpdateBestLine;
          if MaxVal >= Beta then
          begin
            { Cut-off }
            LoopBody := True;
            Exit;
          end;

          { Adjust MaxVal (Tolerance Search) }
          if (Ply >= 2) and Inf.PrincipVar and not ZeroWindow then
            MaxVal := Min(MaxVal + Tolerance,Beta - 1);
          Alpha := MaxVal;
          if ZeroWindow and not SkipSearch then
          begin
            { repeat Search with full window }
            ZeroWindow := False;
            goto RepeatSearch;
          end;
        end;
      end;  { with CC^ }
      LoopBody := SkipSearch;
    end { LoopBody };


    { Generate Pawn promotions }
    function PawnPromotionGen: Boolean;
    var   Promote: PieceType;
    begin
      PawnPromotionGen := True;
      with CC, MovTab[Depth] do
      begin
        Spe := True;
        for Promote := Queen to Knight do
        begin
          MovPiece := Promote;
          if LoopBody then Exit;
        end;
        Spe := False;
      end;
      PawnPromotionGen := False;
    end; { PawnPromotionGen }

    { Generates captures of the Piece On NewSq }
    function CapMovGen(NewSq: SquareType): Boolean;
    var
      NextSq, Sq: EdgeSquareType;
      i:  IndexType;
    begin
      CapMovGen := True;
      with CC, MovTab[Depth] do
      begin
        Content := Board[NewSq].Piece;
        Spe := False;
        New1 := NewSq;

        { Pawn captures }
        MovPiece := Pawn;
        NextSq := New1 - PawnDir[Player];
        for Sq := NextSq - 1 to NextSq + 1 do
          with Board[Sq] do
            if (Sq <> NextSq) and ((Sq and $88) = 0) and
              (Piece = Pawn) and (Color = Player) then
            begin
              Old := Sq;
              if (New1 < 8) or (New1 >= $70) then
              begin
                if PawnPromotionGen then Exit;
              end
              else
                if LoopBody then Exit;
            end;

        { Other captures }
        for i := OfficerNo[Player] downto 0 do
          with PieceTab[Player,i] do
            if (IPiece <> Empty) and (IPiece <> Pawn) and
              PieceAttacks(IPiece, Player, ISquare, NewSq) then
            begin
              Old := ISquare;
              MovPiece := IPiece;
              if LoopBody then Exit;
            end;
      end;
      CapMovGen := False;
    end; { CapMovGen }

    { Generates non captures for the Piece On OldSq }
    function NonCapMovGen(OldSq: SquareType): Boolean;
    var
      First, Last, Dir: DirType;
      Direction: Integer;
      NewSq: EdgeSquareType;
    begin
      NonCapMovGen := True;
      with CC, MovTab[Depth] do
      begin
        Spe := False;
        Old := OldSq;
        MovPiece := Board[OldSq].Piece;
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
                  if LoopBody then Exit;
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
                  if LoopBody then Exit;
                end;
            end;
          Queen,
          Rook,
          Bishop:
            begin
              First := 7;
              Last := 0;
              if MovPiece = Rook then First := 3;
              if MovPiece = Bishop then Last := 4;
              for Dir := First downto Last do
              begin
                Direction := DirTab[Dir];
                NewSq := Old + Direction;
                while (NewSq and $88) = 0 do
                begin
                  if Board[NewSq].Piece <> Empty then Break;
                  New1 := NewSq;
                  if LoopBody then Exit;
                  NewSq := New1 + Direction;
                end;
              end;
            end;
          Pawn:
            begin
              { One Square forward }
              New1 := Old + PawnDir[Player];
              if Board[New1].Piece = Empty then
                if (New1 < 8) or (New1 >= $70) then
                begin
                  if PawnPromotionGen then Exit;
                end
                else
                begin
                  if LoopBody then Exit;
                  if (Old < $18) or (Old >= $60) then
                  begin
                    { Two squares forward }
                    New1 := New1 + (New1 - Old);
                    if Board[New1].Piece = Empty then
                       if LoopBody then Exit;
                  end;
                end;
            end;
        end { case };
      end { with };
      NonCapMovGen := False;
    end { NonCapMovGen };

    { Castling moves }
    function CastlingMovGen: Boolean;
    var
      CastDir: CastDirType;
    begin
      CastlingMovGen := True;
      with CC, MovTab[Depth] do
      begin
        Spe := True;
        MovPiece := King;
        Content := Empty;
        for CastDir := Short downto Long do
          with CastMove[Player,CastDir] do
          begin
            New1 := CastNew;
            Old := CastOld;
            if KillMovGen(MovTab[Depth]) then
              if LoopBody then Exit;
          end;
      end;
      CastlingMovGen := False;
    end; { CastlingMovGen }

    { E.p. captures }
    function EpCapMovGen: Boolean;
    var
      Sq: EdgeSquareType;
    begin
      EpCapMovGen := True;
      with CC, MovTab[Depth - 1] do
        if MovPiece = Pawn then
          if abs(New1 - Old) >= $20 then
          begin
            MovTab[Depth].Spe := True;
            MovTab[Depth].MovPiece := Pawn;
            MovTab[Depth].Content := Empty;
            MovTab[Depth].New1 := (New1 + Old) div 2;
            for Sq := New1 - 1 to New1 + 1 do if Sq <> New1 then
              if (Sq and $88) = 0 then
              begin
                MovTab[Depth].Old := Sq;
                if KillMovGen(MovTab[Depth]) then
                  if LoopBody then Exit;
              end;
          end;
      EpCapMovGen := False;
    end { EpCapMovGen };


    { Generates the Next Move to be analysed.
      Controls the order of the movegeneration.
         The moves are generated in the order :
         Main variation
         Captures of Last moved Piece
         Killing moves
         Other captures
         Pawnpromovtions
         Castling
         Normal moves
         E.p. captures
    }
    procedure SearchMovGen;
    var
      Index: IndexType;
      KillNo: 0..1;
    begin
      with CC, MovTab[Depth] do
      begin
        { Generate Move from Main variation }
        if BestLine[Depth].MovPiece <> Empty then
        begin
          MovTab[Depth] := BestLine[Depth];
          MovGenType := Main;
          if LoopBody then Exit;
        end;

        { Captures of Last moved Piece }
        with MovTab[Depth - 1] do
          if MovPiece <> Empty then if MovPiece <> King then
          begin
            MovGenType := SpecialCap;
            if CapMovGen(New1) then Exit;
          end;

        { Killing moves }
        MovGenType := Kill;
        if not CaptureSearch then
          for KillNo := 0 to 1 do
          begin
            MovTab[Depth] := KillingMove[Depth,KillNo];
            if MovPiece <> Empty then
              if KillMovGen(MovTab[Depth]) then
                if LoopBody then Exit;
          end;

        { Captures }
        MovGenType := Normal;
        for Index := 1 to PawnNo[Opponent] do
          with PieceTab[Opponent,Index] do
            if IPiece <> Empty then
              with MovTab[Depth - 1] do
                if (MovPiece = Empty) or (ISquare <> New1) then
                  if CapMovGen(ISquare) then Exit;

        { Pawn promotions }
        if CaptureSearch then
          if PassedPawn[Depth - 2] >= 0 then
            with Board[PassedPawn[Depth - 2]] do
              if (Piece = Pawn) and (Color = Player) then
                if NonCapMovGen(PassedPawn[Depth - 2]) then Exit;

        { Non-captures }
        if not CaptureSearch then
        begin
          { Castling }
          if CastlingMovGen then Exit;

          { other moves }
          for Index := PawnNo[Player] downto 0 do
            with PieceTab[Player,Index] do
              if IPiece <> Empty then
                if NonCapMovGen(ISquare) then Exit;
        end;

        { E.p. captures }
        if EpCapMovGen then Exit;
      end;
    end { SearchMovGen };

  label Stop;
  begin { Search }
    with CC do
    begin

     { Perform CaptureSearch if Ply<=0 and not Check }
     CaptureSearch := (Ply <= 0) and not CheckTab[Depth - 1];
     if CaptureSearch then                     { Initialize MaxVal }
     begin
       MaxVal := -Inf.Evaluation;
       if Alpha < MaxVal then
       begin
         Alpha := MaxVal;
         if MaxVal >= Beta then goto Stop;
       end;
     end
     else
       MaxVal := -(LoseValue - Depth * DepthFactor);
     SearchMovGen;   { The Search loop }
     if SkipSearch then goto Stop;
     if MaxVal = -(LoseValue - Depth * DepthFactor) then   { test stalemate }
       if not Attacks(Opponent,PieceTab[Player,0].ISquare) then
       begin
         MaxVal := 0;
         goto Stop;
       end;
     UpdateKill(BestLine[Depth]);
    end;  { with }
  Stop:
    Search := MaxVal;
  end { Search };

  { Perform the Search }
  function CallSearch(Alpha,Beta: MaxType): MaxType;
  var
    MaxVal: MaxType;
  begin
    with CC do
    begin
      StartInf.PrincipVar := MainLine[0].MovPiece <> Empty;
      LegalMoves := 0;
      MaxVal := Search(Alpha,Beta,MaxDepth,StartInf,MainLine);
      if LegalMoves = 0 then MainEvalu := MaxVal;
      CallSearch := MaxVal;
    end;
  end; { CallSearch }

  { Checks whether the Search Time is used }
  function TimeUsed: Boolean;
  begin
    TimeUsed := False;
    with CC do
      if Analysis in State then
        TimeUsed := Clock.TimeExpired;
  end; { TimeUsed }

var
  MaxVal: MaxType;
  CalcPVTime: real;
begin { FindMove }
  with CC do
  begin

    { Initialize variables }
    Clock.Start;
    Nodes := 0;
    SkipSearch := False;
    ClearKillMove;

    { Calculate the P-V table }
    CalcPVTable;
    CalcPVTime := Clock.GetElapsedTime;

    { Initiate the search }
    StartInf.Value := -RootValue;
    StartInf.Evaluation := -RootValue;
    MaxDepth := 0;
    MainLine[0] := ZeroMove;
    MainEvalu := RootValue;
    AlphaWindow := MaxInt;

    { The iterative search loop }
    repeat

      { Update various variables }
      if MaxDepth <= 1 then RepeatEvalu := MainEvalu;
      AlphaWindow := Min(AlphaWindow,MainEvalu - $80);
      if Level = MateSearch then
      begin
        AlphaWindow := $6000;
        if MaxDepth > 0 then Inc(MaxDepth);
      end;
      Inc(MaxDepth);

      { Perform the search }
      MaxVal := CallSearch(AlphaWindow,$7F00);
      if (MaxVal <= AlphaWindow) and not SkipSearch and
        (Level <> MateSearch) and (LegalMoves > 0) then
      begin

        { repeat the search if the value falls below the Alpha - window }
        MainEvalu := AlphaWindow;
        MaxVal := CallSearch(-$7F00,AlphaWindow - Tolerance * 2);
        LegalMoves := 2;
      end;
    until SkipSearch or TimeUsed or (MaxDepth >= MaxLevel) or
      (LegalMoves <= 1) or (abs(MainEvalu) >= MateValue - 24 * DepthFactor);
    Clock.Stop;
  end; { with }
end; { FindMove }

end.