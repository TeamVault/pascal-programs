{************************************************}
{                                                }
{   Resource Workshop Demo library               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

library BitBtn;

uses WinTypes, WinProcs, Strings, CustCntl, BitBtnCo;

{$R BITBTN.RES}

{ ==============================================================
  Bitmaped button custom control.
  ============================================================== }

const
  ofReserved    = 0;  { Used by the dialog manager }
  ofState       = 2;
  ofDownBits    = 4;
  ofUpBits      = 6;
  ofFocUpBits   = 8;
  ofSize        = 10; { Amount of window extra bytes to use }

const
  bdBorderWidth = 1;

const
  bsDisabled    = $0001;
  bsFocus       = $0002;
  bsKeyDown     = $0004;
  bsMouseDown   = $0008;
  bsMouseUpDown = $0010;
  bsDefault     = $0020;

{ GetAppInstance -----------------------------------------------
    Returns a handle to the current client application.
  -------------------------------------------------------------- }
function GetAppInstance: THandle; near; assembler;
asm
	PUSH	SS
	CALL	GlobalHandle
end;

{ IsWorkshopWindow ---------------------------------------------
    Returns true if the window belongs to Resource Workshop.
    Used to determine if the control is being edited; allowing
    the LoadResRW function to be called.
  -------------------------------------------------------------- }
function IsWorkshopWindow(Wnd: HWnd): Boolean;
var
  Parent: HWnd;
  ClassName: array[0..80] of Char;
begin
  Parent := Wnd;
  repeat
    Wnd := Parent;
    Parent := GetParent(Wnd);
  until Parent = 0;
  GetClassName(Wnd, ClassName, SizeOf(ClassName));
  IsWorkshopWindow := StrComp(ClassName, 'rwswnd') = 0;
end;

{ LoadResRW ----------------------------------------------------
    Load a resource from Resource Workshop. Initialized by
    ListClasses below.
  -------------------------------------------------------------- }
var
  LoadResRW: TLoad;

{ LoadBitmapRW -------------------------------------------------
    Load a bitmap from Resource Workshop.  *MUST* be called from
    inside resource workshop (IsWorkshopWindow must be true).
  -------------------------------------------------------------- }
function LoadBitmapRW(szTitle: PChar): HBitmap;
var
  Res: THandle;
  Bits: PBitMapInfoHeader;
  DC: HDC;
  nColors: Integer;

function GetDInColors(BitCount: Integer): Integer;
begin
  case BitCount of
    1, 3, 4, 8: GetDInColors := 1 shl BitCount;
  else
    GetDInColors := 0;
  end;
end;

begin
  LoadBitmapRW := 0;
  Res := LoadResRW(rt_Bitmap, szTitle);
  if Res <> 0 then
  begin
    Bits := GlobalLock(Res);
    if Bits^.biSize = SizeOf(TBitMapInfoHeader) then
    begin
      nColors := GetDInColors(Bits^.biBitCount);
      DC := GetDC(0);
      if DC <> 0 then
      begin
	LoadBitmapRW := CreateDIBitmap(DC, Bits^, cbm_Init,
	  Pointer(LongInt(Bits) + SizeOf(Bits^) +
	  nColors * SizeOf(TRGBQuad)), PBitmapInfo(Bits)^,
	  dib_RGB_Colors);
	ReleaseDC(0, DC);
      end;
    end;
    GlobalUnlock(Res);
    GlobalFree(Res);
  end;
end;

{ BitButtonWinFn -----------------------------------------------
    Button window procedure.
  -------------------------------------------------------------- }
function BitButtonWinFn(HWindow: HWnd; Message: Word; wParam: Word;
  lParam: Longint): Longint; export;
var
  DC: HDC;
  BitsNumber: Integer;
  Bitmap: TBitmap;
  Rect: TRect;
  Pt: TPoint;
  PS: TPaintStruct;

{ Get ----------------------------------------------------------
    Get a window instance word.
  -------------------------------------------------------------- }
function Get(Ofs: Integer): Word;
begin
  Get := GetWindowWord(HWindow, Ofs);
end;

{ SetWord ------------------------------------------------------
    Set the value of a window instance word.
  -------------------------------------------------------------- }
procedure SetWord(Ofs: Integer; Val: Word);
begin
  SetWindowWord(HWindow, Ofs, Val);
end;

{ State --------------------------------------------------------
    Get the button's state word.
  -------------------------------------------------------------- }
function State: Word;
begin
  State := Get(ofState);
end;

{ DownBits -----------------------------------------------------
    Get the "down" bitmap of the button.
  -------------------------------------------------------------- }
function DownBits: Word;
begin
  DownBits := Get(ofDownBits);
end;

{ UpBits -------------------------------------------------------
    Get the "up" bitmap of the button.
  -------------------------------------------------------------- }
function UpBits: Word;
begin
  UpBits := Get(ofUpBits);
end;

{ FocUpBits ----------------------------------------------------
    Get the "focused up" bitmap of the button.
  -------------------------------------------------------------- }
function FocUpBits: Word;
begin
  FocUpBits := Get(ofFocUpBits);
end;

{ GetState -----------------------------------------------------
    Get the value of a state bit.
  -------------------------------------------------------------- }
function GetState(AState: Word): Boolean;
begin
  GetState := (State and AState) = AState;
end;

{ Paint --------------------------------------------------------
    Paint the button.  Called in responce to a WM_PAINT message
    and whenever the button changes state (called by Repaint).
  -------------------------------------------------------------- }
procedure Paint(DC: HDC);
const
  coGray = $00C0C0C0;
var
  MemDC: HDC;
  Bits, Oldbitmap: HBitmap;
  BorderBrush, OldBrush: HBrush;
  LogBrush: TLogBrush;
  Frame: TRect;
  Height, Width: Integer;
begin
  if (State and (bsMouseDown + bsKeyDown) <> 0) and
      not GetState(bsMouseUpDown) then
    Bits := DownBits
  else
    if GetState(bsFocus) then
      Bits := FocUpBits
    else
      Bits := UpBits;

  { Draw border }
  GetClientRect(HWindow, Frame);
  Height := Frame.bottom - Frame.top;
  Width := Frame.right - Frame.left;

  if GetState(bsDefault) then
    BorderBrush := GetStockObject(Black_Brush)
  else BorderBrush := GetStockObject(White_Brush);
  OldBrush := SelectObject(DC, BorderBrush);
  PatBlt(DC, Frame.left, Frame.top, Width, bdBorderWidth, PatCopy);
  PatBlt(DC, Frame.left, Frame.top, bdBorderWidth, Height, PatCopy);
  PatBlt(DC, Frame.left, Frame.bottom - bdBorderWidth, Width,
    bdBorderWidth, PatCopy);
  PatBlt(DC, Frame.right - bdBorderWidth, Frame.top, bdBorderWidth,
    Height, PatCopy);
  SelectObject(DC, OldBrush);

  { Draw bitmap }
  MemDC := CreateCompatibleDC(DC);
  OldBitmap := SelectObject(MemDC, Bits);
  GetObject(Bits, Sizeof(Bitmap), @Bitmap);
  if GetState(bsDisabled) then
  begin
    { Gray out the button }
    OldBrush := SelectObject(DC, CreateSolidBrush(coGray));
    PatBlt(DC, bdBorderWidth, bdBorderWidth, Bitmap.bmWidth,
      Bitmap.bmHeight, PatCopy);
    DeleteObject(SelectObject(DC, OldBrush));

    { Draw the bitmap through a checked brush }
    LogBrush.lbStyle := bs_Pattern;
    LogBrush.lbHatch := LoadBitmap(HInstance, MakeIntResource(btDisableBits));
    OldBrush := SelectObject(DC, CreateBrushIndirect(LogBrush));
    BitBlt(DC, bdBorderWidth, bdBorderWidth, Bitmap.bmWidth,
      Bitmap.bmHeight, MemDC, 0, 0, $00A803A9 {DPSoa});
    DeleteObject(SelectObject(DC, OldBrush));
    DeleteObject(LogBrush.lbHatch);
  end
  else
    BitBlt(DC, bdBorderWidth, bdBorderWidth, Bitmap.bmWidth,
      Bitmap.bmHeight, MemDC, 0, 0, srcCopy);
  SelectObject(MemDC, OldBitmap);

  DeleteDC(MemDC);
end;

{ Repaint ------------------------------------------------------
    Repaint the button. Called whenever the button changes
    state.
  -------------------------------------------------------------- }
procedure Repaint;
var
  DC: HDC;
begin
  DC := GetDC(HWindow);
  Paint(DC);
  ReleaseDC(HWindow, DC);
end;

{ SetState -----------------------------------------------------
    Sets the value of a state bit.  If the word changes value
    the button is repainted.
  -------------------------------------------------------------- }
procedure SetState(AState: Word; Enable: Boolean);
var
  OldState, NewState: Word;
begin
  OldState := State;
  if Enable then NewState := OldState or AState
  else NewState := OldState and not AState;
  if NewState <> OldState then
  begin
    SetWord(ofState, NewState);
    Repaint;
  end;
end;

{ InMe ---------------------------------------------------------
    Returns true if the given point is in within the border of
    the button.
  -------------------------------------------------------------- }
function InMe(lPoint: Longint): Boolean;
var
  R: TRect;
  Point: TPoint absolute lPoint;
begin
  GetClientRect(HWindow, R);
  InflateRect(R, -bdBorderWidth, -bdBorderWidth);
  InMe := PtInRect(R, Point);
end;

{ ButtonPressed ------------------------------------------------
    Called when the button is pressed by either the keyboard or
    by the mouse.
  -------------------------------------------------------------- }
procedure ButtonPressed;
begin
  SetState(bsMouseDown + bsMouseUpDown + bsKeyDown, False);
  SendMessage(GetParent(HWindow), wm_Command, GetDlgCtrlID(HWindow),
	Longint(HWindow));
end;

{ LoadBits -----------------------------------------------------
    Load the bitmap for the button or the "NO BITMAP" version
    if it does not exist.
  -------------------------------------------------------------- }
procedure LoadBits(Wrd: Word; MapNumber: Word);
var
  MapBits: HBitmap;
begin
  MapBits := LoadBitmap(HInstance, pChar(MapNumber));
  if MapBits = 0 then
    if IsWorkshopWindow(HWindow) then
      MapBits := LoadBitmapRW(pChar(MapNumber))
    else
      MapBits := LoadBitmap(GetAppInstance, pChar(MapNumber));
  if MapBits = 0 then
    MapBits := LoadBitmap(HInstance, pChar(MapNumber - Get(gww_ID)));
  SetWord(Wrd, MapBits);
end;

begin
  BitButtonWinFn := 0;
  case Message of
    wm_Create:
      begin
	{ Detect EGA monitor }
	DC := GetDC(0);
	if (GetSystemMetrics(sm_CYScreen) < 480) or
	    (GetDeviceCaps(DC, numColors) < 16) then
	  BitsNumber := 2000 + Get(gww_ID)
	else
	  BitsNumber := 1000 + Get(gww_ID);
	ReleaseDC(0, DC);

	{ Load bitmaps from resource }
	LoadBits(ofUpBits, BitsNumber);
	LoadBits(ofDownBits, BitsNumber + 2000);
	LoadBits(ofFocUpBits, BitsNumber + 4000);

	{ Adjust size of button to size of bitmap }
	GetObject(DownBits, SizeOf(Bitmap), @Bitmap);
	GetWindowRect(HWindow, Rect);
	Pt.X := Rect.Left;
	Pt.Y := Rect.Top;
	ScreenToClient(PCreateStruct (lParam)^.hwndParent, Pt);
	  MoveWindow(HWindow, Pt.X, Pt.Y,
	  Bitmap.bmWidth + bdBorderWidth * 2,
	  Bitmap.bmHeight + bdBorderWidth * 2, False);

	{ Intialize button state }
	with PCreateStruct(lParam)^ do
	begin
	  if style and $1F = bs_DefPushButton then
		SetState(bsDefault, True);
	  if style and ws_Disabled <> 0 then
		SetState(bsDisabled, True);
	end;
	  end;
    wm_NCDestroy:
      begin
	{ Destroy all saved bitmaps before the button is destroyed }
	BitButtonWinFn := DefWindowProc(HWindow, Message, wParam, lParam);
	DeleteObject(UpBits);
	DeleteObject(DownBits);
	DeleteObject(FocUpBits);
      end;
    wm_Paint:
      begin
	BeginPaint(HWindow, PS);
	Paint(PS.hDC);
	EndPaint(HWindow, PS);
      end;
    wm_EraseBkGnd:
      begin
	{ Squelch the painting of the background to eliminate flicker }
      end;
    wm_Enable:
      SetState(bsDisabled, wParam <> 0);
    wm_SetFocus:
      SetState(bsFocus, True);
    wm_KillFocus:
      SetState(bsFocus or bsKeyDown or bsMouseDown or bsMouseUpDown, False);
    wm_KeyDown:
      if (wParam = $20) and not GetState(bsKeyDown) and
	  not GetState(bsMouseDown) then
	SetState(bsKeyDown, True);
    wm_KeyUp:
      if (wParam = $20) and GetState(bsKeyDown) then
        ButtonPressed;
    wm_LButtonDblClk, wm_LButtonDown:
      if InMe(lParam) and not GetState(bsKeyDown) then
      begin
	if GetFocus <> HWindow then SetFocus(HWindow);
	SetState(bsMouseDown, True);
	SetCapture(HWindow);
      end;
    wm_MouseMove:
      if GetState(bsMouseDown) then
	SetState(bsMouseUpDown, not InMe(lParam));
    wm_LButtonUp:
      if GetState(bsMouseDown) then
      begin
	ReleaseCapture;
	if not GetState(bsMouseUpDown) then ButtonPressed
	else SetState(bsMouseDown + bsMouseUpDown, False);
      end;

    { *** Handling the rest of these messages are what, at least for
          the dialog manager, makes a push button a push button.  ***}
    wm_GetDlgCode:
      { Sent by the dialog manager to determine the control kind of
	a child window.  Returning dlgc_DefPushButton or
	dlgc_UndefPushButton causes the dialog manager to treat the
	control like a button, sending the bm_SetStyle message to
	move the default button style to the currenly focused button.

        The dlgc_Button constant is not documented by Microsoft
        (however, it is documented for OS/2 PM, and appears to work
        the same). If this constant is or'd in, the windows dialog
        manager will take care of all accelerator key processing,
        sending bm_SetState and bm_SetStyle messages when an
        acclerator key is pressed. There is a side effect to using
        the message, however, the dialog manager messes with the word
        at offset 0 from the user Window words. }

      if GetState(bsDefault) then
	BitButtonWinFn:= dlgc_DefPushButton or dlgc_Button
      else
	BitButtonWinFn := dlgc_UndefPushButton or dlgc_Button;
    bm_GetState:
      BitButtonWinFn := Integer(GetState(bsKeyDown));
    bm_SetState:
      SetState(bsKeyDown, wParam <> 0);
    bm_SetStyle:
      { Sent by the dialog manager when the button receives or looses
	focus and is not the default button, or when another button
	receives the focus and this button is the default button. }
      SetState(bsDefault, wParam = bs_DefPushButton);
  else
    BitButtonWinFn := DefWindowProc(HWindow, Message, wParam, lParam);
  end;
end;

{ ==============================================================
  Custom contol interface routines.
  ============================================================== }

{ BitBtnInfo ---------------------------------------------------
   Return the information about the capabilities of the
   bit button class.
  -------------------------------------------------------------- }
function BitBtnInfo: THandle; export;
var
  hInfo: THandle;
  Info: PRWCtlInfo;
begin
  hInfo := GlobalAlloc(gmem_Share or gmem_ZeroInit,
    SizeOf(TRWCtlInfo));
  if hInfo <> 0 then
  begin
    Info := GlobalLock(hInfo);
    with Info^ do
    begin
      wVersion := $100;         { Version 1.00 }
      wCtlTypes := 2;           { 2 types }
      StrCopy(szClass, 'BitButton');
      StrCopy(szTitle, 'Button');

      { Normal (Un-default) push button type }
      with ctType[0] do
      begin
	wWidth := 63 or $8000;
	wHeight := 39 or $8000;
	StrCopy(szDescr, 'Push Button');
	dwStyle := bs_PushButton or ws_TabStop;
	hToolBit := LoadBitmap(HInstance, MakeIntResource(btUndefBits));
	hDropCurs := LoadCursor(HInstance, MakeIntResource(crUndefCurs));
      end;

      { Default push button type }
      with ctType[1] do
      begin
	wWidth := 63 or $8000;
	wHeight := 39 or $8000;
	StrCopy(szDescr, 'Default Push Button');
	dwStyle := bs_DefPushButton or ws_TabStop;
	hToolBit := LoadBitmap(HInstance, MakeIntResource(btDefBits));
	hDropCurs := LoadCursor(HInstance, MakeIntResource(crDefCurs));
      end;
    end;
    GlobalUnlock(hInfo);
  end;
  BitBtnInfo := hInfo;
end;

type
  PParamRec = ^TParamRec;
  TParamRec = record
    CtlStyle: THandle;
    IdToStr: TIdToStr;
    StrToId: TStrToId;
  end;

{ BitBtnStyleDlg -----------------------------------------------
    Style dialog's dialog hook.  Used by the dialog and called
    when the control is double-clicked inside the dialog
    editor.
  -------------------------------------------------------------- }
function BitBtnStyleDlg(HWindow: HWnd; Message: Word; wParam: Word;
  lParam: Longint): Longint; export;
const
  Prop = 'Prop';
var
  hRec: THandle;
  Rec: PParamRec;
  Style: PCtlStyle;
  S: array[0..256] of Char;
  Radio: Integer;
begin
  case Message of
    wm_InitDialog:
      begin
	hRec := LoWord(lParam);
	Rec := GlobalLock(hRec);
	Style := GlobalLock(Rec^.CtlStyle);
	SetProp(HWindow, Prop, hRec);
	with Rec^, Style^ do
	begin
	  { Set caption }
	  SetDlgItemText(HWindow, idCaption, szTitle);

	  { Set control id }
	  IdToStr(wId, S, SizeOf(S));
	  SetDlgItemText(HWindow, idControlId, S);

	  { Set type radio buttons }
	  if dwStyle and $F = bs_DefPushButton then
	    Radio := idDefaultButton
	  else
            Radio := idPushButton;
	  CheckRadioButton(HWindow, idDefaultButton, idPushButton,
	    Radio);

	  { Initialize Tab Stop check box }
	  CheckDlgButton(HWindow, idTabStop,
	    Integer(dwStyle and ws_TabStop <> 0));

	  { Initialize Disabled check box }
	  CheckDlgButton(HWindow, idDisabled,
	    Integer(dwStyle and ws_Disabled <> 0));

	  { Initialize Group check box }
	  CheckDlgButton(HWindow, idGroup,
	    Integer(dwStyle and ws_Group <> 0));
	end;
	GlobalUnlock(Rec^.CtlStyle);
	GlobalUnlock(hRec);
      end;
    wm_Command:
      case wParam of
	idCancel:
	  EndDialog(HWindow, 0);
	idOk:
	  begin
	    hRec := GetProp(HWindow, Prop);
	    Rec := GlobalLock(hRec);
	    Style := GlobalLock(Rec^.CtlStyle);
	    with Rec^, Style^ do
	    begin
	      { Get caption }
	      GetDlgItemText(HWindow, idCaption, szTitle, SizeOf(szTitle));

	      { Get control id }
	      GetDlgItemText(HWindow, idControlId, S, SizeOf(S));
	      wId := StrToId(S);

	      { Get button type }
	      if IsDlgButtonChecked(HWindow, idDefaultButton) <> 0 then
		dwStyle := bs_DefPushButton
	      else
                dwStyle := bs_PushButton;

	      { Get tab stop }
	      if IsDlgButtonChecked(HWindow, idTabStop) <> 0 then
		dwStyle := dwStyle or ws_TabStop;

	      { Get disabled }
	      if IsDlgButtonChecked(HWindow, idDisabled) <> 0 then
		dwStyle := dwStyle or ws_Disabled;

	      { Get group }
	      if IsDlgButtonChecked(HWindow, idGroup) <> 0 then
		dwStyle := dwStyle or ws_Group;
	    end;
	    GlobalUnlock(Rec^.CtlStyle);
	    GlobalUnlock(hRec);
	    EndDialog(HWindow, 1);
	  end;
      else
	BitBtnStyleDlg := 0;
      end;
    wm_Destroy:
      RemoveProp(HWindow, Prop);
  else
    BitBtnStyleDlg := 0;
  end;
end;

{ BitBtnStyle --------------------------------------------------
    The function will bring up a dialog box to modify the style
    of the button.  Called when the button is double-clicked in
    the dialog editor.
  -------------------------------------------------------------- }
function BitBtnStyle(hWindow: HWnd; CtlStyle: THandle;
  StrToId: TStrToId; IdToStr: TIdToStr): Bool; export;
var
  hRec: THandle;
  Rec: PParamRec;
  hFocus: HWnd;
begin
  BitBtnStyle := False;
  hRec := GlobalAlloc(gmem_Share, SizeOf(TParamRec));
  if hRec <> 0 then
  begin
    Rec := GlobalLock(hRec);
    Rec^.IdToStr := IdToStr;
    Rec^.StrToId := StrToId;
    Rec^.CtlStyle := CtlStyle;
    GlobalUnlock(hRec);

    hFocus := GetFocus;
    BitBtnStyle := Bool(DialogBoxParam(HInstance,
      MakeIntResource(idButtonStyle), HWindow, @BitBtnStyleDlg,
      hRec));
    if hFocus <> 0 then SetFocus(hFocus);
    GlobalFree(hRec);
  end;
end;

{ BitBtnFlags --------------------------------------------------
    Called to decompose the style double word into the .RC
    script expression that it represents.  This only needs to
    decompose the style bits added to the style double word,
    it need not decompose the, for example, the ws_XXX bits.
    The expression returned must be a valid .RC expression
    (i.e. C syntax, case sensitive).
  -------------------------------------------------------------- }
function BitBtnFlags(Style: LongInt; Buff: PChar;
  BuffLength: Word): Word; export;
begin
  if Style and $F = bs_DefPushButton then
    StrLCopy(Buff, 'BS_DEFPUSHBUTTON', BuffLength)
  else StrLCopy(Buff, 'BS_PUSHBUTTON', BuffLength);
  BitBtnFlags := StrLen(Buff);
end;

{ ListClasses --------------------------------------------------
    Called by Resource Workshop retrieve the information
    necessary to edit the custom controls contain in this DLL.
    This is an alternative to the Microsoft xxxStyle convention.
  -------------------------------------------------------------- }
function ListClasses(szAppName: PChar; wVersion: Word;
  fnLoad: TLoad; fnEdit: TEdit): THandle; export;
var
  hClasses: THandle;
  Classes: PCtlClassList;
begin
  LoadResRW := fnLoad;
  hClasses := GlobalAlloc(gmem_Share or gmem_ZeroInit,
    SizeOf(Integer) + SizeOf(TRWCtlClass));
  if hClasses <> 0 then
  begin
    Classes := GlobalLock(hClasses);
    with Classes^ do
    begin
      nClasses := 1;
      with Classes[0] do
      begin
	fnInfo  := BitBtnInfo;
	fnStyle := BitBtnStyle;
	fnFlags := BitBtnFlags;
      end;
    end;
    GlobalUnlock(hClasses);
  end;
  ListClasses := hClasses;
end;

exports
  ListClasses,
  BitButtonWinFn;

var
  Class: TWndClass;

begin
  with Class do
  begin
    lpszClassName := 'BitButton';
    hCursor       := LoadCursor(0, idc_Arrow);
    lpszMenuName  := nil;
    style         := cs_HRedraw or cs_VRedraw or cs_DblClks or cs_GlobalClass;
    lpfnWndProc   := TFarProc(@BitButtonWinFn);
    hInstance     := System.hInstance;
    hIcon         := 0;
    cbWndExtra    := ofSize;
    cbClsExtra    := 0;
    hbrBackground := 0;
  end;
  RegisterClass(Class);
end.
