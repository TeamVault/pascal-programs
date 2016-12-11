{*******************************************************}
{                                                       }
{       Turbo Pascal for Windows Run-time Library       }
{       Windows 3.1 API Interface Unit                  }
{       Pen Windows Interface unit                      }
{                                                       }
{       Copyright (c) 1992 Borland International        }
{                                                       }
{*******************************************************}

unit PenWin;

{$S-}

interface

uses WinTypes, WinProcs, Win31;

{***** General Pen Windows Definitions ************************************}
type
  TRec = Integer;
  PSYV = ^TSYV;
  TSYV = Longint;
  THRec = THandle;
  TCL = Integer;
  TALC = Longint;
  THKP = Word;

type
  TDF = function(dirq: Integer; InP, OutP: Pointer; Max: Integer;
    Context, Data : Longint): Integer;

const
  BitPenup               = $8000;

function FPenUp(X: LongInt): Boolean;
inline(
  $58/          { POP     AX }
  $5A/          { POP     DX }
  $2D/$00/$80/  { SUB     AX,8000H }
  $1B/$C0/      { SBB     AX,AX }
  $40);         { INC     AX }

{ Default pen cursor to indicate writing, points northwest }
const
 IDC_Pen           = MakeIntResource(32631);

{ alternate select cursor: upsidedown standard arrow, points southeast }
const
  IDC_AltSelect    = MakeIntResource(32501);

const
  rc_WDefault            = $FFFF;
  rc_Ldefault            = $FFFFFFFF;
  rc_WDefaultFlags       = $8000;
  rc_LDefaultFlags       = $80000000;

{ HIWORD(SYV) defines and detection macros }

const
  syvhi_Special          = 0;
  syvhi_ANSI             = 1;
  syvhi_Gesture          = 2;
  syvhi_Kanji            = 3;
  syvhi_Shape            = 4;
  syvhi_UniCode          = 5;
  syvhi_VKey             = 6;

function FIsSpecial(syv: TSYV): Boolean;
function FIsAnsi(syv: TSYV): Boolean;
function FIsGesture(syv: TSYV): Boolean;
function FIsKanji(syv: TSYV): Boolean;
function FIsShape(syv: TSYV): Boolean;
function FIsUniCode(syv: TSYV): Boolean;
function FIsVKey(syv: TSYV): Boolean;


{ Macros to convert between SYV and ANSI }
function ChSyvToAnsi(syv: TSYV): Byte;
function SyvCharacterToSymbol(c: Char): TSYV;
function SyvKanjiToSymbol(c: Char): TSYV;

{ SYV values with special meanings to Pen Windows }

const
  syv_Null               = $00000000;
  syv_Unknown            = $00000001;
  syv_Empty              = $00000003;
  syv_BeginOr            = $00000010;
  syv_EndOr              = $00000011;
  syv_Or                 = $00000012;
  syv_SoftNewLine        = $00000020;
  syv_SpaceNull          = $00010000;

{ SYV values for gestures (map into UNICODE space) }

const
  syv_KKConvert          = $0002FFD4;
  syv_Clear              = $0002FFD5;
  syv_ExtendSelect       = $0002FFD8;
  syv_Undo               = $0002FFD9;
  syv_Copy               = $0002FFDA;
  syv_Cut                = $0002FFDB;
  syv_Paste              = $0002FFDC;
  syv_ClearWord          = $0002FFDD;
  syv_User               = $0002FFDE;  { Reserved }
  syv_Correct            = $0002FFDF;

  syv_Backspace          = $00020008;
  syv_Tab                = $00020009;
  syv_Return             = $0002000D;
  syv_Space              = $00020020;


function FIsStdGesture(syv: TSYV): Boolean;
function FIsAnsiGesture(syv: TSYV): Boolean;


{ Application specific gestures, Circle a-z and Circle A-Z }
const
  syv_AppGestureMask     = $00020000;
  syv_CircleUpA          = $000224B6;
  syv_CircleUpZ          = $000224CF;
  syv_CircleLoA          = $000224D0;
  syv_CircleLoZ          = $000224E9;

{ Gesture Macros }

function FIsLoAppGesture(syv: TSYV): Boolean;
function FIsUpAppGesture(syv: TSYV): Boolean;
function FIsAppGesture(syv: TSYV): Boolean;

function SyvAppGestureFromLoAnsi(Ansi: Char): TSYV;
function SyvAppGestureFromUpAnsi(Ansi: Char): TSYV;
function AnsiFromSyvAppGesture(syv: TSYV): Byte;



{ SYV definitions for shapes }

const
  syv_ShapeLine          = $00040001;
  syv_ShapeEllipse       = $00040002;
  syv_ShapeRect          = $00040003;
  syv_ShapeMin           = syv_ShapeLine;
  syv_ShapeMax           = syv_ShapeRect;

{***** Recognition Error Codes ********************************************}
const
  rec_OEM                = -1024;
  rec_Language           = -48;
  rec_Guide              = -47;
  rec_ParamError         = -46;
  rec_InvalidRef         = -45;
  rec_RectExclude        = -44;
  rec_RectBound          = -43;
  rec_PCM                = -42;
  rec_ResultMode         = -41;
  rec_HWnd               = -40;
  rec_ALC                = -39;
  rec_ErrorLevel         = -38;
  rec_CLVerify           = -37;
  rec_Dict               = -36;
  rec_HRec               = -35;
  rec_BadEventRef        = -33;
  rec_NoCollection       = -32;

  rec_Debug              = -32;

  rec_PointerEvent       = -31;
  rec_BadHPenData        = -9;
  rec_OOM                = -8;
  rec_NoInput            = -7;
  rec_NoTablet           = -6;
  rec_Busy               = -5;
  rec_BufferTooSmall     = -4;
  rec_Abort              = -3;

  rec_Overflow           = -1;

  rec_OK                 = 0;
  rec_TermBound          = 1;
  rec_TermEx             = 2;
  rec_TermPenUp          = 3;
  rec_TermRange          = 4;
  rec_TermTimeOut        = 5;
  rec_Done               = 6;
  rec_TermOEM            = 512;

{***** Pen Driver Structures and Entry points *****************************}

type
  POEMPenInfo = ^TOEMPenInfo;
  TOEMPenInfo = record
    wPdt: Word;
    wValueMax: Word;
    wDistinct: Word;
  end;

const
  pdt_Null               = 0;
  pdt_Pressure           = 1;
  pdt_Height             = 2;
  pdt_AngleXY            = 3;
  pdt_AngleZ             = 4;
  pdt_BarrelRotation     = 5;
  pdt_OEMSpecific        = 16;

  MaxOEMDataWords        = 6;

type
  PPenPacket = ^TPenPacket;
  TPenPacket = record
    wTabletX: Word;
    wTabletY: Word;
    wPDK: Word;
    rgwOemData: array[0..MaxOEMDataWords - 1] of Word;
  end;

type
  TRawHook = function(PenPacket: PPenPacket): Bool;

type
  PPenInfo = ^TPenInfo;
  TPenInfo = record
    cxRawWidth: Word;
    cyRawHeight: Word;
    wDistinctWidth: Word;
    wDistinctHeight: Word;
    nSamplingRate: Integer;
    nSamplingDist: Integer;
    lPdc: Longint;
    cPens: Integer;
    cbOemData: Integer;
    rgoempeninfo: array[0..MaxOEMDataWords - 1] of TOEMPenInfo;
    rgwReserved: array[0..7] of Word;
  end;

const
  pdc_Integrated         = $00000001;
  pdc_Proximity          = $00000002;
  pdc_Range              = $00000004;
  pdc_Invert             = $00000008;
  pdc_Relative           = $00000010;
  pdc_Barrel1            = $00000020;
  pdc_Barrel2            = $00000040;
  pdc_Barrel3            = $00000080;

type
  PStrokeInfo = ^TStrokeInfo;
  TStrokeInfo = record
    cPnt: Word;
    cbPnts: Word;
    wPDK: Word;
    dwTick: Longint;
  end;

type
  PCalbStruct = ^TCalbStruct;
  TCalbStruct = record
    wOffsetX: Integer;
    wOffsetY: Integer;
    wDistinctWidth: Integer;
    wDistinctHeight: Integer;
  end;

{***** DRV_ values for pen driver specific messages ***********************}

const
  drv_SetPenDriverEntryPoints    = drv_Reserved+1;
  drv_RemovePenDriverEntryPoints = drv_Reserved+2;
  drv_SetPenSamplingRate         = drv_Reserved+3;
  drv_SetPenSamplingDist         = drv_Reserved+4;
  drv_GetName                    = drv_Reserved+5;
  drv_GetVersion                 = drv_Reserved+6;
  drv_GetPenInfo                 = drv_Reserved+7;
  drv_GetCalibration             = drv_Reserved+11;
  drv_SetCalibration             = drv_Reserved+12;

procedure UpdatePenInfo(lpPenInfo: PPenInfo);
function EndPenCollection(recEnd: TRec): Bool;
function GetPenHwData(lpPnt: PPoint; lpvOemData: Pointer; cPntMax: Integer;
  wTimeOut: Word; lpsi: PStrokeInfo): TRec;
function GetPenHwEventData(wEventRefBeg: Word; wEventRefEnd: Word;
  lpPnt: PPoint; lpvOemData: Pointer; cPntMax: Integer; lpsi: PStrokeInfo): TRec;

(*  This procedure not exported by PENWIN.DLL or MARS.DLL
procedure PenPacket;
*)

function SetPenHook(hkpOp: THKP; lptn: TRawHook): Bool;

{***** Pen Hardware Constants *********************************************}

const
  pdk_Up                 = $0000;
  pdk_Down               = $0001;
  pdk_Barrel1            = $0002;
  pdk_Barrel2            = $0004;
  pdk_Barrel3            = $0008;
  pdk_Transition         = $0010;
  pdk_Inverted           = $0080;
  pdk_OutOfRange         = $4000;
  pdk_Driver             = $8000;
  pdk_TipMask            = $0001;
  pdk_Switches           = pdk_Down or pdk_Barrel1 or pdk_Barrel2 or
                           pdk_Barrel3;

const
  pcm_Penup              = $00000001;
  pcm_Range              = $00000002;
  pcm_Invert             = $00000020;
  pcm_RectExclude        = $00002000;
  pcm_RectBound          = $00004000;
  pcm_Timeout            = $00008000;
  pcm_AddDefaults        = rc_LDefaultFlags; { $80000000 }

{***** Virtual Event Layer ************************************************}

procedure PostVirtualKeyEvent(vk: Word; fUp: Bool);
procedure PostVirtualMouseEvent(wMouseFlag: Word; xPos, yPos: Integer);
procedure AtomicVirtualEvent(fBegin: Bool);

const
  vwm_MouseMove          = $0001;
  vwm_MouseLeftDown      = $0002;
  vwm_MouseLeftUp        = $0004;
  vwm_MouseRightDown     = $0008;
  vwm_MouseRightUp       = $0010;

{***** RC Definition ******************************************************}

const
  cl_Null                = 0;
  cl_Minimum             = 1;
  cl_Maximum             = 100;
  InkWidth_Minimum       = 0;
  InkWidth_Maximum       = 15;
  enum_Minimum           = 1;
  enum_Maximum           = 4096;
  MaxDictionaries        = 16;

type
  PGuide = ^TGuide;
  TGuide = record
    xOrigin: Integer;
    yOrigin: Integer;
    cxBox: Integer;
    cyBox: Integer;
    cxBase: Integer;
    cyBase: Integer;
    cHorzBox: Integer;
    cVertBox: Integer;
    cyMid: Integer;
  end;

type
  TRCYieldProc = function : Bool;

const
  cbRcLanguageMax        = 44;
  cbRcUserMax            = 32;
  cbRcrgbfAlcMax         = 32;
  cwRcReservedMax        = 8;

type
  PRC = ^TRC;
  TRC = record
    HRec: THRec;
    hw: HWnd;
    wEventRef: Word;
    wRcPreferences: Word;
    lRcOptions: Longint;
    lpfnYield: TRCYieldProc;
    lpUser: array[0..cbRcUserMax-1] of Byte;
    wCountry: Word;
    wIntlPreferences: Word;
    lpLanguage: array[0..cbRcLanguageMax-1] of Char;
    rglpdf: array[0..MaxDictionaries-1] of TDF;
    wTryDictionary: Word;
    clErrorLevel: TCL;
    alc: TALC;
    alcPriority: TALC;
    rgbfAlc: array[0..cbRcrgbfAlcMax-1] of Byte;
    wResultMode: Word;
    wTimeOut: Word;
    lPcm: Longint;
    rectBound: TRect;
    rectExclude: TRect;
    guide: TGuide;
    wRcOrient: Word;
    wRcDirect: Word;
    nInkWidth: Integer;
    rgbInk: TColorRef;
    dwAppParam: Longint;
    dwDictParam: Longint;
    dwRecognizer: Longint;
    rgwReserved: array[0..cwRcReservedMax-1] of Word;
  end;

type
  THPenData = THandle;

type
  PSYC = ^TSYC;
  TSYC = record
    wStrokeFirst: Word;
    wPntFirst: Word;
    wStrokeLast: Word;
    wPntLast: Word;
    fLastSyc: Bool;
  end;
    
const
  wPntAll                = $FFFF;
  iSycNull               = -1;

type
  PSYE = ^TSYE;
  TSYE = record
    syv: TSYV;
    lRecogVal: Longint;
    cl: TCL;
    iSyc: Integer;
  end;

const
  MaxHotSpot             = 8;

type
  PSYG = ^TSYG;
  TSYG = record
    rgpntHotSpots: array[0..MaxHotSpot-1] of TPoint;
    cHotSpot: Integer;
    nFirstBox: Integer;
    lRecogVal: Longint;
    lpsye: PSYE;
    cSye: Integer;
    lpsyc: PSYC;
    cSyc: Integer;
  end;

type
  TEnumProc = function(syv: PSYV; i: Integer; P: Pointer): Integer;

type
  PRCResult = ^TRCResult;
  TRCResult = record
    syg: TSYG;
    wResultsType: Word;
    cSyv: Integer;
    lpsyv: PSYV;
    HSyv: THandle;
    nBaseLine: Integer;
    nMidLine: Integer;
    hPenData: THPenData;
    rectBoundInk: TRect;
    pntEnd: TPoint;
    lprc: PRC;
  end;

const
  rcrt_Default           = $0000;
  rcrt_Unidentified      = $0001;
  rcrt_Gesture           = $0002;
  rcrt_NoSymbolMatch     = $0004;
  rcrt_Private           = $4000;
  rcrt_NoRecog           = $8000;
  rcrt_AlreadyProcessed  = $0008;
  rcrt_GestureTranslated = $0010;
  rcrt_GestureToKeys     = $0020;

  hkp_SetHook            = 0;
  hkp_Unhook             = $FFFF;
  hwr_Results            = 0;
  hwr_AppWide            = 1;

  pen_NoInkWidth         = 0;

const
  rpa_Default            = 1;

{ GetGlobalRC return codes }
const
  ggrc_OK                = 0;
  ggrc_DictBufTooSmall   = 1;
  ggrc_ParamError        = 2;

{ SetGlobalRC return code flags }
const
  sgrc_OK                = $0000;
  sgrc_User              = $0001;
  sgrc_ParamError        = $0002;
  sgrc_RC                = $0004;
  sgrc_Recognizer        = $0008;
  sgrc_Dictionary        = $0010;
  sgrc_INIFile           = $0020;

{ macro }
function GetWEventRef: Word;

function InstallRecognizer(lpszRecogName: PChar): THRec;
procedure UninstallRecognizer(HRec: THRec);
function GetGlobalRC(lprc: PRC; lpDefRecog: PChar; lpDefDict: PChar;
  cbDefDictMax: Integer): Word;
function SetGlobalRC(lprc: PRC; lpDefRecog: PChar; lpDefDict: PChar): Word;
procedure RegisterPenApp(wFlags: Word; fRegister: Bool);
function IsPenAware: Word;
function SetRecogHook(whrHook: Word; hkpPosition: Word; HWndHook: HWnd): Bool;
procedure InitRC(hw: HWnd; lprc: PRC);
function Recognize(lprc: PRC): TRec;
function RecognizeData(lprc: PRC; hPenData: THPenData): TRec;
function TrainInk(lprc: PRC; hPenData: THPenData; lpsyv: PSYV): Bool;
function TrainContext(lprcresult: PRCResult; lpsye: PSYE; cSye: Integer;
  lpsyc: PSYC; cSyc: Integer): Bool;
function ProcessWriting(hw: HWnd; lprc: PRC): TRec;
function CorrectWriting(hw:HWnd; lpBuf:PChar; cbBuf: Word; lprc: PRC;
  dwCwrFlags: Longint; dwReserved: Longint): Bool;
procedure EmulatePen(fPen: Bool);
function GetSymbolMaxLength(lpsyg: PSYG): Integer;
function GetSymbolCount(lpsyg: PSYG): Integer;
procedure FirstSymbolFromGraph(lpsyg: PSYG; lpsyv: PSYV; cSyvMax: Integer;
  lpcSyv: PInteger);
function EnumSymbols(lpsyg: PSYG; wMaxStr: Word; lpEnumFunc: TEnumProc;
  lvData: Pointer): Word;

{***** Miscellaneous Functions ********************************************}

function TPtoDP(lpPnt: PPoint; cPnt: Integer): Bool;
function DPtoTP(lpPnt: PPoint; cPnt: Integer): Bool;
procedure BoundingRectFromPoints(lpPnt: PPoint; cPnt: Integer;
  lpRectBound: PRect);
function SymbolToCharacter(lpsyv: PSYV; cSyv: Integer; lpstr: PStr;
  lpnConv: PInteger): Bool;
function CharacterToSymbol(lpstr: PStr; cSyv: Integer; lpsyv: PSYV): Integer;
function GetVersionPenWin: Word;
function ExecuteGesture(hw: HWnd; syv: TSYV; lprcresult: PRCResult): Bool;

{***** RC Options and Flags  **********************************************}

const
  alc_All                = $000043FF;
  alc_Default            = $00000000;
  alc_LCAlpha            = $00000001;
  alc_UCAlpha            = $00000002;
  alc_Alpha              = $00000003;
  alc_Numeric            = $00000004;
  alc_Alphanumeric       = $00000007;
  alc_Punc               = $00000008;
  alc_Math               = $00000010;
  alc_Monetary           = $00000020;
  alc_Other              = $00000040;
  alc_White              = $00000100;
  alc_NonPrint           = $00000200;
  alc_Gesture            = $00004000;
  alc_UseBitmap          = $00008000;
  alc_DBCS               = $00000400;
  alc_Hiragana           = $00010000;
  alc_Katakana           = $00020000;
  alc_Kanji              = $00040000;
  alc_OEM                = $0FF80000;
  alc_Reserved           = $F0003800;
  alc_NoPriority         = $00000000;
  alc_SysMinimum         = alc_Alphanumeric or
                           alc_Punc or alc_White or
                           alc_Gesture;

{ macros }
function MpAlcB(lprc: PRC; i: Word): PByte;
function MpIbf(i: Word): Byte;

procedure SetAlcBitAnsi(lprc: PRC; i: Word);
procedure ResetAlcBitAnsi(lprc: PRC; i: Word);
function IsAlcBitAnsi(lprc: PRC; i: Word): Boolean;

const
  rcd_Default            = 0;
  rcd_LR                 = 1;
  rcd_RL                 = 2;
  rcd_TB                 = 3;
  rcd_BT                 = 4;

const
  rco_NoPointerEvent     = $00000001;
  rco_SaveAllData        = $00000002;
  rco_SaveHPenData       = $00000004;
  rco_NoFlashUnknown     = $00000008;
  rco_TabletCoord        = $00000010;
  rco_NoSpaceBreak       = $00000020;
  rco_NoHideCursor       = $00000040;
  rco_NoHook             = $00000080;
  rco_Boxed              = $00000100;
  rco_Suggest            = $00000200;
  rco_DisableGesMap      = $00000400;
  rco_NoFlashCursor      = $00000800;
  rco_ColdRecog          = $00008000;

const
  rcp_LeftHand           = $0001;
  rcp_MapChar            = $0004;

const
  rcor_Normal            = 1;
  rcor_Right             = 2;
  rcor_Upsidedown        = 3;
  rcor_Left              = 4;

  rrm_Stroke             = 0;
  rrm_Symbol             = 1;
  rrm_Word               = 2;
  rrm_NewLine            = 3;
  rrm_Complete           = 16;

  rcip_AllAnsiChar       = $0001;
  rcip_Mask              = $0001;

  cwr_StripCR            = $00000001;
  cwr_StripLF            = $00000002;
  cwr_StripTAB           = $00000004;
  cwr_SingleLineEdit     = $00000007;
  cwr_Title              = $00000010;
  cwr_KKConvert          = $00000020;

const
  map_GestOGES        = rcrt_Gesture or rcrt_GestureTranslated;
  map_GestOVKeys      = rcrt_GestureToKeys or rcrt_AlreadyProcessed;


{ macros }
function IsGestureToGesture(lprcresult: PRCResult): Boolean;
function IsGestureToVkeys(lprcresult: PRCResult): Boolean;
procedure SetAlreadyProcessed(lprcresult: PRCResult);


{***** Pen Data Type ******************************************************}

type
  PPenDataHeader = ^TPenDataHeader;
  TPenDataHeader = record
    wVersion: Word;
    cbSizeUsed: Word;
    cStrokes: Word;
    cPnt: Word;
    cPntStrokeMax: Word;
    rectBound: TRect;
    wPndts: Word;
    nInkWidth: Integer;
    rgbInk: Longint;
  end;

const
  pdts_LOMetric          = $0000;
  pdts_HIMetric          = $0001;
  pdts_HIEnglish         = $0002;
  pdts_ScaleMax          = $0003;
  pdts_Display           = $0003;
  pdts_Arbitrary         = $0004;
  pdts_ScaleMask         = $000F;
  pdts_StandardScale     = pdts_HIEnglish;

  pdts_NoPenInfo         = $0100;
  pdts_NoUpPoints        = $0200;
  pdts_NoOEMData         = $0400;
  pdts_NoColinear        = $0800;
  pdts_Compressed        = $8000;
  pdts_CompressMethod    = $00F0;
  pdts_Compress2ndDeriv  = $0010;

  pdtt_Default           = $0000;
  pdtt_PenInfo           = pdts_NoPenInfo;
  pdtt_UpPoints          = pdts_NoUpPoints;
  pdtt_OEMdata           = pdts_NoOEMData;
  pdtt_Colinear          = pdts_NoColinear;
  pdtt_Compress          = pdts_Compressed;
  pdtt_Decompress        = $4000;
  pdtt_All = pdtt_PenInfo or pdtt_UpPoints or pdtt_OEMdata or pdtt_Colinear;


{ macros }
function DestroyPenData(hPenData: THPenData): Boolean;
procedure EndEnumStrokes(hPenData: THPenData);


function IsPenEvent(Message: Word; lExtraInfo: Longint): Bool;
function GetPenAsyncState(wPDK: Word): Bool;
function GetPenDataInfo(hPenData: THPenData; lppendataheader: PPenDataHeader;
  lpPenInfo: PPenInfo; dwReserved: Longint): Bool;
function GetPenDataStroke(lppendata: PPenDataHeader; wStroke: Word;
  lplpPoint: PPoint; lplpvOem: Pointer; lpsi: PStrokeInfo ): Bool;
function GetPointsFromPenData(hPenData: PPenDataHeader; wStroke, wPnt, cPnt: Word;
  lppoint: PPoint): Bool;
procedure DrawPenData(DC: HDC; lprect: PRect; hPenData: THPenData);
function MetricScalePenData(hPenData: THPenData; wPdts: Word): Bool;
function ResizePenData(hPenData: THPenData;  lprect: PRect): Bool;
function OffsetPenData(hPenData: THPenData; dx, dy: Integer): Bool;
function RedisplayPenData(DC:HDC; hPenData: THPenData; lpDelta: PPoint;
  lpExt: PPoint; nInkWidth: Integer; rgbColor: Longint): Bool;
function CompactPenData(hPenData: THPenData; wTrimOptions: Word): THPenData;
function DuplicatePenData(hPenData:THPenData; gmemFlags: Word): THPenData;
function CreatePenData(lpPenInfo: PPenInfo; cbOemData: Integer;
  wPdtScale: Word; gmemFlags: Word): THPenData;
function AddPointsPenData(hPenData: THPenData; lpPnt: PPoint;
  lpvOemData: Pointer; lpsiNew: PStrokeInfo): THPenData;
function BeginEnumStrokes(hPenData: THPenData): PPenDataHeader;

{***** New Windows Messages ***********************************************}

const
  wm_RCResult            = wm_PenWinFirst+1;
  wm_HookRCResult        = wm_PenWinFirst+2;
  wm_GlobalRCChange      = wm_PenWinFirst+3;
  wm_SKB                 = wm_PenWinFirst+4;
  wm_HEditCtl            = wm_PenWinFirst+5;

{***** Dictionary *********************************************************}

const
  cbDictPathMax          = 255;
  dirq_Query             = 1;
  dirq_Description       = 2;
  dirq_Configure         = 3;
  dirq_Open              = 4;
  dirq_Close             = 5;
  dirq_SetWordLists      = 6;
  dirq_String            = 7;
  dirq_Suggest           = 8;
  dirq_Add               = 9;
  dirq_Delete            = 10;
  dirq_Flush             = 11;
  dirq_RCChange          = 12;
  dirq_SymbolGraph       = 13;
  dirq_Init              = 14;
  dirq_Cleanup           = 15;
  dirq_Copyright         = 16;


  dirq_User              = 4096;

function DictionarySearch(lprc: PRC; lpsye: PSYE; cSye: Integer;
  lpsyv: PSYV; cSyvMax: Integer): Bool;

{***** Handwriting Edit Control *******************************************}

const
  he_GetRC               = 3;
  he_SetRC               = 4;
  he_GetInflate          = 5;
  he_SetInflate          = 6;
  he_GetUnderline        = 7;
  he_SetUnderline        = 8;
  he_GetInkHandle        = 9;
  he_SetInkMode          = 10;
  he_StopInkMode         = 11;
  he_GetRCResultCode     = 12;
  he_DefaultFont         = 13;
  he_CharPosition        = 14;
  he_CharOffset          = 15;

  he_GetRCResult         = 22;

  he_KKConvert           = 30;
  he_GetKKConvert        = 31;
  he_CancelKKConvert     = 32;
  he_FixKKConvert        = 33;

  hekk_Default           = 0;
  hekk_Convert           = 1;
  hekk_Candidate         = 2;

  hep_NoRecog            = 0;
  hep_Recog              = 1;
  hep_WaitForTap         = 2;

  hn_EndRec              = 4;
  hn_DelayedRecogFail    = 5;

  hn_RCResult            = 20;

  hn_EndKKConvert        = 30;


type
  PRectOfs = ^TRectOfs;
  TRectOfs = record
    dLeft: Integer;
    dTop: Integer;
    dRight: Integer;
    dBottom: Integer;
  end;

{***** Boxed Edit Control *************************************************}

type
  PBoxLayout = ^TBoxLayout;
  TBoxLayout = record
    cyCusp: Integer;
    cyEndCusp: Integer;
    Style: Word;
    rgbText: Longint;
    rgbBox: Longint;
    rgbSelect: Longint;
  end;

const
  bxs_None               = 0;
  bxs_Rect               = 1;
  bxs_EndTextmark        = 2;
  bxs_Mask               = 3;

  he_GetBoxLayout        = 20;
  he_SetBoxLayout        = 21;

  bxd_CellWidth          = 12;
  bxd_CellHeight         = 16;
  bxd_BaseHeight         = 13;
  bxd_BaseHorz           = 0;
  bxd_CuspHeight         = 2;
  bxd_EndCuspHeight      = 4;

{***** Screen Keyboard ****************************************************}

type
  PSKBInfo = ^TSKBInfo;
  TSKBInfo = record
    handle: HWnd;
    nPad: Word;
    fVisible: Bool;
    fMinimized: Bool;
    hect: TRect;
    dwReserved: Longint;
  end;

const
  skb_Query              = $0000;
  skb_Show               = $0001;
  skb_Hide               = $0002;
  skb_Center             = $0010;
  skb_Move               = $0020;
  skb_Minimize           = $0040;
  skb_Full               = $0100;
  skb_Basic              = $0200;
  skb_NumPad             = $0400;

const
  obm_SKBBtnUp           = 32767;
  obm_SKBBtnDown         = 32766;
  obm_SKBBtnDisabled     = 32765;

  skn_Changed            = 1;

  skn_PosChanged         = 1;
  skn_PadChanged         = 2;
  skn_MinChanged         = 4;
  skn_VisChanged         = 8;
  skn_Terminated         = $FFFF;

function ShowKeyboard(Handle: HWnd; wCommand: Word; lpPnt: PPoint;
  lpSKBInfo: PSKBInfo): Bool;

{***** New ComboBox Notifications  ****************************************}

const
  cbn_EndRec             = 16;
  cbn_DelayedRecogFail   = 17;
  cbn_RcResult           = 18;

implementation

type
  LongRec = record
    Lo, Hi: Word;
  end;

  WordRec = record
    Lo, Hi: Byte;
  end;

{ translations of macros }

function ChSyvToAnsi(syv: Longint): Byte;
begin
  ChSyvToAnsi := WordRec(LongRec(syv).Lo).Lo;
end;

function SyvCharacterToSymbol(c: Char): Longint;
begin
  SyvCharacterToSymbol := Byte(c) or $10000;
end;

function SyvKanjiToSymbol(c: Char): TSYV;
begin
  SyvKanjiToSymbol := Byte(c) or $30000;
end;

function FIsStdGesture(syv: Longint): Boolean;
begin
  FIsStdGesture := (syv = syv_Clear) or (syv = syv_ExtendSelect) or
    (syv = syv_Undo) or (syv = syv_Copy) or (syv = syv_Cut) or
    (syv = syv_Paste) or (syv = syv_ClearWord) or (syv = syv_KKConvert) or
    (syv = syv_User) or (syv = syv_Correct);
end;

function FIsAnsiGesture(syv: TSYV): Boolean;
begin
  FIsAnsiGesture := (syv = syv_Backspace) or (syv = syv_Tab) or
    (syv = syv_Return) or (syv = syv_Space);
end;

{ Gesture macros }

function FIsLoAppGesture(syv: Longint): Boolean;
begin
  FIsLoAppGesture := (syv >= syv_CircleLoA) and (syv <= syv_CircleLoZ);
end;

function FIsUpAppGesture(syv: Longint): Boolean;
begin
  FIsUpAppGesture := (syv >= syv_CircleUpA) and (syv <= syv_CircleUpZ);
end;

function FIsAppGesture(syv: Longint): Boolean;
begin
  FIsAppGesture := (syv >= syv_CircleUpA) and (syv <= syv_CircleLoZ);
end;

function SyvAppGestureFromLoAnsi(Ansi: Char): TSYV;
begin
  SyvAppGestureFromLoAnsi := Byte( (Ord(Ansi) - Ord('a')) + syv_CircleLoA );
end;

function SyvAppGestureFromUpAnsi(Ansi: Char): TSYV;
begin
  SyvAppGestureFromUpAnsi := Byte( (Ord(Ansi) - Ord('A')) + syv_CircleUpA );
end;

function AnsiFromSyvAppGesture(syv: TSYV): Byte;
begin
  if FIsUpAppGesture(syv) then syv := syv_CircleUpA - TSYV('A')
  else syv := syv_CircleLoA - TSYV('a');
  AnsiFromSyvAppGesture := ChSyvToAnsi(syv);
end;

function FIsSpecial(syv: TSYV): Boolean;
begin
  FIsSpecial := LongRec(syv).Hi = syvhi_Special;
end;

function FIsAnsi(syv: TSYV): Boolean;
begin
  FIsAnsi := LongRec(syv).Hi = syvhi_ANSI;
end;

function FIsGesture(syv: TSYV): Boolean;
begin
  FIsGesture := LongRec(syv).Hi = syvhi_Gesture;
end;

function FIsKanji(syv: TSYV): Boolean;
begin
  FIsKanji := LongRec(syv).Hi = syvhi_Kanji;
end;

function FIsShape(syv: TSYV): Boolean;
begin
  FIsShape := LongRec(syv).Hi = syvhi_Shape;
end;

function FIsUniCode(syv: TSYV): Boolean;
begin
  FIsUniCode := LongRec(syv).Hi = syvhi_UniCode;
end;

function FIsVKey(syv: TSYV): Boolean;
begin
  FIsVKey := LongRec(syv).Hi = syvhi_VKey;
end;

function GetWEventRef: Word;
var
  Result: Longint;
begin
  Result := GetMessageExtraInfo;
  GetWEventRef := LongRec(Result).Lo;
end;

function MpAlcB(lprc: PRC; i: Word): PByte;
begin
  MpAlcB := @lprc^.rgbfAlc[ (i and $FF) shr 3 ];
end;

function MpIbf(i: Word): Byte;
begin
  MpIbf := 1 shl (i and 7);
end;

procedure SetAlcBitAnsi(lprc: PRC; i: Word);
var
  P: PByte;
begin
  P := MpAlcB(lprc, i);
  P^ := P^ or MpIbf(i);
end;

procedure ResetAlcBitAnsi(lprc: PRC; i: Word);
var
  P: PByte;
begin
  P := MpAlcB(lprc, i);
  P^ := P^ and not MpIbf(i);
end;

function IsAlcBitAnsi(lprc: PRC; i: Word): Boolean;
begin
  IsAlcBitAnsi := MpAlcB(lprc,i)^ and MpIbf(i) <> 0;
end;

function IsGestureToGesture(lprcresult: PRCResult): Boolean;
begin
  IsGestureToGesture :=
    (lprcresult^.wResultsType and map_GestOGES) = map_GestOGES;
end;

function IsGestureToVkeys(lprcresult: PRCResult): Boolean;
begin
  IsGestureToVkeys :=
    (lprcresult^.wResultsType and map_GestOVKeys) = map_GestOVKeys;
end;

procedure SetAlreadyProcessed(lprcresult: PRCResult);
begin
  lprcresult^.wResultsType :=
    (lprcresult^.wResultsType and (not rcrt_GestureToKeys)) or rcrt_AlreadyProcessed;
end;

function DestroyPenData(hPenData: THPenData): Boolean;
begin
  DestroyPenData := GlobalFree(hPenData) = 0;
end;

procedure EndEnumStrokes(hPenData: THPenData);
begin
  GlobalUnlock(hPenData);
end;

procedure UpdatePenInfo;                     external 'PENWIN' index 207;
function EndPenCollection;                   external 'PENWIN' index 137;
function GetPenHwData;                       external 'PENWIN' index 138;
function GetPenHwEventData;                  external 'PENWIN' index 139;
function SetPenHook;                         external 'PENWIN' index 115;
procedure PostVirtualKeyEvent;               external 'PENWIN' index 102;
procedure PostVirtualMouseEvent;             external 'PENWIN' index 101;
procedure AtomicVirtualEvent;                external 'PENWIN' index 104;
function InstallRecognizer;                  external 'PENWIN' index 14;
procedure UninstallRecognizer;               external 'PENWIN' index 15;
function GetGlobalRC;                        external 'PENWIN' index 151;
function SetGlobalRC;                        external 'PENWIN' index 150;
procedure RegisterPenApp;                    external 'PENWIN' index 111;
function IsPenAware;                         external 'PENWIN' index 110;
function SetRecogHook;                       external 'PENWIN' index 114;
procedure InitRC;                            external 'PENWIN' index 10;
function Recognize;                          external 'PENWIN' index 11;
function RecognizeData;                      external 'PENWIN' index 12;
function TrainInk;                           external 'PENWIN' index 16;
function TrainContext;                       external 'PENWIN' index 17;
function ProcessWriting;                     external 'PENWIN' index 170;
function CorrectWriting;                     external 'PENWIN' index 172;
procedure EmulatePen;                        external 'PENWIN' index 173;
function GetSymbolMaxLength;                 external 'PENWIN' index 121;
function GetSymbolCount;                     external 'PENWIN' index 122;
procedure FirstSymbolFromGraph;              external 'PENWIN' index 123;
function EnumSymbols;                        external 'PENWIN' index 124;
function TPtoDP;                             external 'PENWIN' index 132;
function DPtoTP;                             external 'PENWIN' index 131;
procedure BoundingRectFromPoints;            external 'PENWIN' index 13;
function SymbolToCharacter;                  external 'PENWIN' index 125;
function CharacterToSymbol;                  external 'PENWIN' index 126;
function GetVersionPenWin;                   external 'PENWIN' index 402;
function ExecuteGesture;                     external 'PENWIN' index 418;
function IsPenEvent;                         external 'PENWIN' index 135;
function GetPenAsyncState;                   external 'PENWIN' index 144;
function GetPenDataInfo;                     external 'PENWIN' index 211;
function GetPenDataStroke;                   external 'PENWIN' index 219;
function GetPointsFromPenData;               external 'PENWIN' index 221;
procedure DrawPenData;                       external 'PENWIN' index 214;
function MetricScalePenData;                 external 'PENWIN' index 215;
function ResizePenData;                      external 'PENWIN' index 222;
function OffsetPenData;                      external 'PENWIN' index 216;
function RedisplayPenData;                   external 'PENWIN' index 242;
function CompactPenData;                     external 'PENWIN' index 223;
function DuplicatePenData;                   external 'PENWIN' index 218;
function CreatePenData;                      external 'PENWIN' index 210;
function AddPointsPenData;                   external 'PENWIN' index 212;
function BeginEnumStrokes;                   external 'PENWIN' index 213;
function DictionarySearch;                   external 'PENWIN' index 420;
function ShowKeyboard;                       external 'PENWIN' index 250;

end.
