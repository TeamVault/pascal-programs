{************************************************}
{                                                }
{   Turbo Vision Chess Demo                      }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit TVChsCmd;

interface

uses App, Dialogs;

type
  TSettings = record
    TimeMode: Word;    { Game timing mode }
    GameTime: Longint; { Max Game time }
    TurnTime: Longint; { Max Turn time }
    Hints:    Word;    { Hint Options }
    Players:  Word     { Number of players }
  end;

const
  { Move event }
  evMove         = $0400;

  { Game Menu }
  cmRunDemo      = 100;
  cmStop         = 101;

  { Edit menu }
  cmRedo         = 110;
  cmComputerMove = 111;
  cmEnterMove    = 112;
  cmShowHint     = 113;

  { Options Menu }
  cmSettings     = 120;
  cmColors       = 121;

  { Help Menu }
  cmAbout        = 130;

  { Game control }
  cmSubmitMove   = 1000;
  cmMovePiece    = 1001;
  cmUndoMove     = 1002;
  cmClearBoard   = 1003;
  cmFindPiece    = 1004;
  cmGameOver     = 1005;
  cmRegisterSave = 1006;
  cmTimeOptChg   = 1007;

  { Pawn Promotion }
  cmQueen        = 2000;
  cmRook         = 2001;
  cmBishop       = 2002;
  cmKnight       = 2003;

  { Color palettes }
  CChessAppColor      = CAppColor +
    #$1E#$20#$40#$07#$70#$0F#$7F#$78#$18#$20#$70#$07#$7F#$0F#$1E#$7F +
    #$0F#$3E#$20#$40;
  CChessAppBlackWhite = CAppBlackWhite +
    #$07#$07#$07#$07#$70#$0F#$7F#$07#$07#$07#$70#$07#$7F#$0F#$70#$7F +
    #$0F#$70#$07#$07;
  CChessAppMonochrome = CAppMonochrome +
    #$07#$07#$07#$07#$70#$0F#$7F#$07#$07#$07#$70#$07#$7F#$0F#$70#$7F +
    #$0F#$70#$07#$07;

  CChessBoard = #128#129#130#131#132#133#134#146#147;

  CSettingsDlg = CGrayDialog + #135#136;
  CStatusDialog = CCyanDialog + #142#143#144#145;
  CPromoteDialog = CGrayDialog + #137#138#139#140#141;

  CTimeLabel = #33#33#33#33;
  CTimeInput = #34#34#34#34;
  CGlyphButton = #33#34#35#36#37#15;

  CBestLine = #33;
  CWTimerView = #34;
  CBTimerView = #35;
  CGTimerView = #36;

  gmOnePlay  = $0000;
  gmTwoPlay  = $0001;
  gmDemo     = $0002;

  tmGameLimit  = $0000;
  tmTurnLimit  = $0001;
  tmMatchUser  = $0002;
  tmInfinite   = $0003;

  hoAttacks      = $0001;
  hoJeopardies   = $0002;
  hoBestLine     = $0004;
  hoRtClickHints = $0008;
  hoThinkAhead   = $0010;

  plOnePlayer  = $0000;
  plTwoPlayer  = $0001;

  { Stream registration types }

  otChessPiece    = 5001;
  otTimeLabel     = 5002;
  otTimeInput     = 5003;
  otSettingsDlg   = 5004;
  otPromoteDialog = 5005;
  otGlyphButton   = 5006;
  otTimerView     = 5007;

  { Global game settings }

  Settings: TSettings = (
    TimeMode: tmTurnLimit;
    GameTime: 10;
    TurnTime: 10;
    Hints: hoAttacks + hoJeopardies + hoBestLine + hoRtClickHints +
      hoThinkAhead;
    Players: plOnePlayer);

implementation

end.
