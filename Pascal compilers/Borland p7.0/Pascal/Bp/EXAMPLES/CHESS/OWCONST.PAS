{************************************************}
{                                                }
{   ObjectWindows Chess Demo                     }
{   Constant definitions                         }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit OWConst;

interface

const
	bmChessPiecesBaseID     = 	12000;

	curNo		=	100;
	curGrabHandOpen	=	101;

	bmWhiteKing	=	bmChessPiecesBaseID + 1;
	bmWhiteQueen	=	bmChessPiecesBaseID + 2;
	bmWhiteRook	=	bmChessPiecesBaseID + 3;
	bmWhiteBishop	=	bmChessPiecesBaseID + 4;
	bmWhiteKnight	=	bmChessPiecesBaseID + 5;
	bmWhitePawn	=	bmChessPiecesBaseID + 6;
	BlackOfs	=	6;
	bmBlackKing	=	bmWhiteKing + BlackOfs ;
	bmBlackQueen	=	bmWhiteQueen + BlackOfs ;
	bmBlackRook	=	bmWhiteRook + BlackOfs ;
	bmBlackBishop	=	bmWhiteBishop + BlackOfs ;
	bmBlackKnight	=	bmWhiteKnight + BlackOfs ;
	bmBlackPawn	=	bmWhitePawn + BlackOfs ;
        MaskOfs         =       12;
	bmMaskKing	=	bmWhiteKing + MaskOfs ;
	bmMaskQueen	=	bmWhiteQueen + MaskOfs ;
	bmMaskRook	=	bmWhiteRook + MaskOfs ;
	bmMaskBishop	=	bmWhiteBishop + MaskOfs ;
	bmMaskKnight	=	bmWhiteKnight + MaskOfs;
	bmMaskPawn	=	bmWhitePawn + MaskOfs;

	curInvisible	=	curGrabHandOpen + 2;

        wm_User         =       $0400;
        am_SubmitMove   =       wm_User + 150;
        am_ChoosePawnPromote =  wm_User + 151;

        strNoMoreUndos  =       10;
        strNoMoreRedos  =       11;
        cxChessError    =       20;
	cxChessState	=	40;

	cm_NewGame	=	101;
	idMainMenu	=	100;
	cm_UndoMove	=	201;
	cm_RedoMove	=	202;

	dlgInfoPane	=	100;
	dlgBoardFrame	=	101;
	cm_AutoPlay	=	107;
	dlgSettings	=	102;
	idInfoTurn	=	101;
	idInfoTime	=	102;
	idInfoWhite	=	103;
	idInfoBlack	=	104;
	idInfoMode	=	105;
	idInfoValue	=	106;
	idInfoNodes	=	107;
	idInfoNPSec	=	108;
	idMovesListbox	=	109;
	idInfoBestLine	=	110;
	idInfoMsg	=	111;
	idLimitGameTime	=	101;
	idLimitTurnTime	=	102;
	idMatchUserTime	=	103;
	idNoTimeLimit	=	104;
	idTimeLimitGroup	=	200;
	idLimitGameTimeLabel	=	201;
	idLimitGameTimeInput	=	202;
	idLimitTurnTimeLabel	=	203;
	idLimitTurnTimeInput	=	204;
	idShowAttacks	=	301;
	idShowJeopardies	=	302;
	idShowBestLine	=	303;
	idRightClickQueries	=	304;
	idSinglePlayer	=	401;
	idTwoPlayer	=	402;
	idThinkTime	=	501;
	cm_LoadGame	=	102;
	cm_SaveGame	=	103;
	cm_SaveAs	=	104;
	cm_PauseGame	=	105;
	cm_ComputerMove	=	203;
	cm_InputMove	=	204;
	cm_ShowHintMove	=	205;
	cm_Settings	=	301;
	cm_SetColors	=	302;
	idThinkMenu	=	1000;
	cm_StopThinking	=	1001;
        TimeLimitInputLen=5;
	idGameTimeUnit	=	205;
	idTurnTimeUnit	=	206;
	chstrInvalidHandle	=	cxChessError + 1;
	chstrIllegalState	=	cxChessError + 2;
	chstrOutofMemory	=	cxChessError + 3;
	chstrTooManyGames	=	cxChessError + 4;
	chstrInvalidMove	=	cxChessError + 5;
	chstrIllegalMove	=	cxChessError + 6;
	chstrInvalidSyntax	=	cxChessError + 7;
	chstrAmbiguousMove	=	cxChessError + 8;
	chstrNoMovesLeft	=	cxChessError + 9;
	cxSearchState	=	60;
	chstrCheck	=	cxChessState + 1;
	chstrCheckMate	=	cxChessState + 2;
	chstrStalemate	=	cxChessState + 3;
	chstrResigns	=	cxChessState + 4;
	chstrMateFound	=	cxChessState + 5;
	chstr50MoveRule	=	cxChessState + 6;
	chstrRepititionRule	=	cxChessState + 7;
	strLeaveGame	=	101;
	strCancelGame	=	100;
	strWhiteWins	=	102;
	strGameOver	=	103;
	strBlackWins	=	104;
	strLoadError	=	105;
	cxStreamError	=	89;
	ststrError	=	cxStreamError - 1;
	ststrReadError	=	cxStreamError - 3;
	ststrInitError	=	87;
	ststrWriteError	=	cxStreamError - 4;
	ststrGetError	=	cxStreamError - 5;
	ststrPutError	=	cxStreamError - 6;
	strInvalidFile	=	106;
	strNotAChessFile	=	107;
	strSaveError	=	108;
	strStartNewGame	=	109;
	strLoadSavedGame	=	110;
	strWhite	=	111;
	strBlack	=	112;
	strPauseMenu	=	113;
	strResumeMenu	=	114;
	strStaleMate	=	115;
	bmFence	=	300;
	dlgCoverBoard	=	103;
	idCoverGroup	=	101;
	idCoverText	=	102;
	cxGameMode	=	116;
	strOnePlayer	=	116;
	strTwoPlayer	=	117;
	strAutoPlay	=	118;
	strGameTimeExpired	=	121;
	strTurnTimeExpired	=	120;
	strStartupMode	=	119;
	idQueen         =	101;
	idRook          =	102;
	idBishop	=	103;
	idKnight	=	104;
	dlgChoosePawnPromote	=	104;
	idBoardShade	=	101;
	idAllowThinkAhead	=	601;
	idCoverBoard	=	602;
	dlgEnterMove	=	105;
	cm_EnterMove	=	204;
	idEnterMoveEdit	=	101;
	strGamePaused	=	122;
	bmBlaise	=	1100;
	cm_About	=	401;
implementation

end.