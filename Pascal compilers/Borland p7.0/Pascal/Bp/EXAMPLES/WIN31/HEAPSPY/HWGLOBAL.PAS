{$A-,B-,E-,F-,G+,I-,K-,N-,O-,P-,Q-,R-,S-,T+,V-,W-,X+}

{**********************************************}
{                                              }
{   HeapSpy - HWGlobal Module                  }
{   Copyright (c) 1992  Borland International  }
{                                              }
{**********************************************}

unit HWGlobal;

{$C MOVEABLE PRELOAD PERMANENT}

interface

uses WinTypes, WinProcs, Strings, WinDOS, Objects, ODialogs, OWindows,
  BWCC, CommDlg, ToolHelp, WIN31;

{$I HEAPSPY.INC}
{$I HELPIDS.INC}

const

  { Revision control information }
  AppName: PChar = 'HEAPSPY';
  MajorVersion  = 1;
  MinorVersion  = 0;
  RevisionChar  = ' ';

  { INI Control Info }
  OptionsKey: PChar = 'Options';
  RebuildKey: PChar = 'RebuildOnActivate';
  SortOptKey: PChar = 'DefaultSortOpt';
  WinTileKey: PChar = 'WindowTile';
  SpeedBarKey: PChar = 'UseSpeedbar';
  INIFile: PChar = 'HEAPSPY.INI';

  { Global Options settings }
var
  Glbl: record
    RebuildOnActivate: WordBool;
    UseSpeedBar: WordBool;
    WinTile: array[op_Vertical..op_Horizontal] of WordBool;
    SortOpt: array[cm_sbAddress..cm_sbModule] of WordBool;
  end;

const
  lbn_RDBLCLK = 6;
  lbn_RDBLCLKMask = $00060000;
  user_UpdateSpeed = wm_user + 1001;

  { New Global heap types (internally manufactured) }
  gt_TPWheap = 11;

  LocalUserLit: array[1..32] of PChar = (
    'Class', 'Wnd', 'String', 'Menu', 'Clip', 'CBox', 'Palette', 'ED',
    'BWL', 'OwnerDraw', 'SPB', 'Checkpoint', 'DCE', 'MWP', 'Prop', 'LBIV',
    'Misc', 'Atoms', 'LockInputState', 'HookList', 'UserSeeUserDoAlloc',
    'HotkeyList', 'PopupMenu', '24', '25', '26', '27', '28', '29', '30',
    '31', 'HandleTable');

  LocalGDILit: array[1..10] of PChar = (
    'Pen', 'Brush', 'Font', 'Palette', 'Bitmap', 'RGN', 'DC', 'Disabled_DC',
    'MetaDC', 'Metafile');

  GlobalResLit: array[0..15] of PChar = (
    'UserDefined', 'CursorComponent', 'Bitmap', 'IconComponent', 'Menu',
    'Dialog', 'String', 'FontDir', 'Font', 'Accelerators', 'RCData',
    'ErrTable', 'Cursor', '13', 'Icon', 'NameTable');

  GlobalTypeLit: array[0..11] of PChar = (
    'Private', 'DGroup', 'Data', 'Code', 'Task', 'Resource', 'Module',
    'Free', 'Internal', 'Sentinel', 'BurgerMaster', 'TPW Heap');

var
  WaitCursor: Word;
  ArrowCursor: Word;
  HeapFontLF : TLogFont;
  ListboxFont: HFont;
  HexDumpLF  : TLogFont;
  HexDumpFont: HFont;

{ TPW Heap sub-allocator structures }
type
  PTPWSubBlock = ^TTPWSubBlock;
  TTPWSubBlock = record
    Signature: Word; { $5054 }
    Reserved1: Word;
    FreeList : Word;
    Reserved2: Word;
    MemFree  : Word;
    NextHeap : Word;
  end;

  PTPWFreeEntry = ^TTPWFreeEntry;
  TTPWFreeEntry = record
    Next: Word;
    Size: Word;
  end;

  PMyListBox = ^TMyListBox;
  TMyListBox = object(TListBox)
    procedure WMRButtonDown(var Msg: TMessage);
      virtual wm_First + wm_RButtonDown;
    procedure WMRButtonUp(var Msg: TMessage);
      virtual wm_First + wm_RButtonUp;
    procedure WMRButtonDblClk(var Msg: TMessage);
       virtual wm_First + wm_RButtonDblClk;
    procedure WMKeyDown(var Msg: TMessage);
       virtual wm_First + wm_KeyDown;
  end;

  PBWCCDlg = ^TBWCCDlg;
  TBWCCDlg = object(TDialog)
    HelpCtx: LongInt;
    constructor Init(AParent: PWindowsObject; AName: PChar;
      AHelpCtx: LongInt);
    function GetClassName: PChar; virtual;
    procedure WMDestroy(var Msg: TMessage);
      virtual wm_First + wm_Destroy;
    procedure HelpReq(var Msg: TMessage);
      virtual id_First + idHelp;
  end;

  PBasicHexWin = ^TBasicHexWin;
  TBasicHexWin = object(TWindow)
  end;

  PListWin = ^TListWin;
  TListWin = object(TWindow)
    List: PMyListBox;
    PrevChildWnd: hWnd;
    constructor Init(AParent: PWindowsObject; ATitle: PChar;
      AOwnerDraw: Boolean);
    function GetClassName: PChar; virtual;
    procedure GetWindowClass(var WndClass: TWndClass); virtual;
    procedure SetupWindow; virtual;
    function HandleSelect(LeftClick: Boolean): Boolean; virtual;
    function GetItemString(p: pointer): PChar; virtual;
    procedure DeleteItem(p: pointer); virtual;
    procedure BuildList; virtual;
    function Less(p1,p2: pointer): integer; virtual;
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;
    procedure WMSetFocus(var Msg: TMessage);
      virtual wm_First + wm_SetFocus;
    procedure WMMeasureItem(var Msg: TMessage);
      virtual wm_First + wm_MeasureITem;
    procedure WMDrawItem(var Msg: TMessage);
      virtual wm_First + wm_DrawItem;
    procedure WMDeleteItem(var Msg: TMessage);
      virtual wm_First + wm_DeleteItem;
    procedure WMCompareItem(var Msg: TMessage);
      virtual wm_First + wm_CompareItem;
    procedure DefWndProc(var MSg: Tmessage); virtual;
    procedure ListSel(var Msg: TMessage);
      virtual id_First + 101;
    procedure RebuildWindow(var Msg: Tmessage);
      virtual cm_First + cm_Rebuild;
    procedure CMClose(var MSg: TMessage);
      virtual cm_First + cm_Close;
    procedure CMSaveAs(var Msg: Tmessage);
      virtual cm_First + cm_SaveAs;
  end;

  PSortListWin = ^TSortListWin;
  TSortListWin = object(TListWin)
    SortOpt: Word;
    constructor Init(AParent: PWindowsObject; ATitle: PChar; AOwnerDraw: Boolean);
    destructor Done; virtual;
    procedure ChangeSortOpt(NewOpt: Word);
    procedure WMSetFocus(var Msg: TMessage);
      virtual wm_First + wm_SetFocus;
    procedure CMsbAddress(var Msg: TMessage);
      virtual cm_First + cm_sbAddress;
    procedure CMsbHAndle(var Msg: TMessage);
      virtual cm_First + cm_sbHandle;
    procedure CMsbSize(var Msg: TMessage);
      virtual cm_First + cm_sbSize;
    procedure CMsbType(var Msg: TMessage);
      virtual cm_First + cm_sbType;
    procedure CMsbModule(var Msg: TMessage);
      virtual cm_First + cm_sbModule;
    procedure AdjustMenu;
  end;

function StrPad(P: PChar; sz: Integer): PChar;
function GetModuleName(hMod: Word; P: PChar): PChar;
function IsTaskOf(hTask,hMod: Thandle): Boolean;
function IsValidSelector(s: Word): Boolean;
function Compare32(var x1, x2): Integer;
function PtrFromHandle(H: THandle): Pointer;
function DefaultSortOpt: Word;
function TilingMethod: Word;
function DescendantOf(AncestorType, ThisObj: Pointer): Boolean;

function HexB(Dest: PChar; B: Byte): PChar;
function HexW(Dest: PChar; I: Word): PChar;
function HexL(Dest: PChar; L: LongInt): PChar;
function HexPtr(Dest: PChar; P: Pointer): PChar;

{ Global Help wrapper stuff }
const
  HelpOpen: Boolean = False;
  HelpFID: PChar = 'HEAPSPY.HLP';
  HelpWnd: HWND = 0;

procedure DoHelp(wCommand: Word; dwData: LongInt);
procedure CloseHelp;

function DoFontDialog(AParent: PWindowsObject; LF: PLogFont;
  ATitle: PChar): Bool;
function DoFileSaveDialog(AParent: PWindowsObject; AOptions: LongInt;
  AFileName: PChar; AMaxLen: Integer): Bool;

implementation

function DoFontDialog(AParent: PWindowsObject; LF: PLogFont;
  ATitle: PChar): Bool;
var
  CF: TChooseFont;
begin
  FillChar(CF,Sizeof(CF),0);
  with CF do
  begin
    lStructSize := SizeOf(CF);
    if AParent <> nil then
      hwndOwner := AParent^.HWindow;
    lpLogFont := LF;
    Flags := cf_ScreenFonts or cf_FixedPitchOnly or cf_InitToLogFontStruct;
  end;
  DoFontDialog := ChooseFont(CF);
end;

function DoFileSaveDialog(AParent: PWindowsObject; AOptions: LongInt;
  AFileName: PChar; AMaxLen: Integer): Bool;
var
  OFN: TOpenFileName;
  TempName: array[0..fsFileName] of Char;
  TempExt: array[0..fsExtension] of Char;
begin
  FillChar(OFN,Sizeof(OFN),0);
  with OFN do
  begin
    lStructSize := SizeOf(OFN);
    if AParent <> nil then
      hwndOwner := AParent^.HWindow;
    Flags := AOptions;
    hInstance := System.hInstance;
    lpstrFilter := nil;
    lpstrTitle := nil;

    GetMem(lpstrFile, Succ(fsPathName));
    nMaxFile := Succ(fsPathName);
    lpstrFileTitle := nil;
    nMaxFileTitle := 0 ;
    GetMem(lpstrInitialDir, Succ(fsDirectory));
    FileExpand(lpstrFile, AFileName);
    FileSplit(lpstrFile, lpstrInitialDir, TempName, TempExt);
    lpstrDefExt := @TempExt[1];
    StrCat(StrCopy(lpstrFile, TempName), TempExt);
  end;
  DoFileSaveDialog := GetSaveFileName(OFN);
  StrLCopy(AFileName, OFN.lpstrFile, AMaxLen);
  FreeMem(OFN.lpstrInitialDir, Succ(fsDirectory));
  FreeMem(OFN.lpstrFile, Succ(fsPathName));
end;

function DescendantOf(AncestorType, ThisObj: Pointer): Boolean;
type
  TVMT = record
    dwSize: LongInt;
    DMTOfs: Word;
  end;
var
  DMTOfs, TargetDMT: Word;
begin
  DescendantOf := True;
  DMTOfs := TVMT(ThisObj^).DMTOfs;
  TargetDMT := TVMT(AncestorType^).DMTOfs;
  while DMTOfs <> 0 do
  begin
    if DMTOfs = TargetDMT then Exit;
    DMTOfs := Word(Ptr(DSeg, DMTOfs)^);
  end;
  DescendantOf := False;
end;

procedure DoHelp;
begin
  if HelpWnd = 0 then
    HelpWnd := Application^.MainWindow^.HWindow;
  if WinHelp(HelpWnd,HelpFID,wCommand,dwData) then
    if not HelpOpen then
      HelpOpen := true;
end;

procedure CloseHelp;
begin
  if HelpOpen then
    WinHelp(HelpWnd, HelpFID, help_Quit, 0);
end;

function DefaultSortOpt: Word;
var
  I: Word;
begin
  for I := cm_sbAddress to cm_sbModule do
    if Glbl.SortOpt[I] then
    begin
      DefaultSortOpt := I;
      Exit;
    end;
end;

function TilingMethod: Word;
var
  I: Word;
begin
  for I := op_Vertical to op_Horizontal do
    if Glbl.WinTile[I] then
    begin
      TilingMethod := I;
      Exit;
    end;
end;

function IsValidSelector(S: Word): Boolean; assembler;
asm
	XOR	AX,AX  { assume failure }
	CMP	S,0    { 386 bug workaround: LAR on a 0 selector doesn't work }
	JE	@1
	LAR	BX,S   { Get Access rights }
	JNZ	@1     { Zero flag is clear if the selector is invalid }
	INC	AX
@1:
end;

function PtrFromHandle(H: THandle): Pointer; assembler;
asm
	MOV	DX,H
	AND	DX,0FFF8H
	MOV	AX,DS
	AND	AX,7
	OR	DX,AX
	PUSH	DX
	CALL	IsValidSelector
	OR	AL,AL
	JNZ	@1
	XOR	DX,DX
@1:	XOR	AX,AX
end;

function StrPad(P: PChar; sz: Integer): PChar;
var
  I, Len: Integer;
begin
  Len := StrLen(P);
  for I := Len to Pred(Sz) do P[I] := ' ';
  P[sz] := #0;
  StrPad := P;
end;

function GetModuleName(hMod: Word; P: PChar): PChar;
var
  Modl: TModuleEntry;
  Tsk : TTaskEntry;
  Temp: array[0..128] of Char;
begin
  Tsk.dwSize := Sizeof(TTaskEntry);
  Modl.dwSize := Sizeof(TModuleEntry);
  if ModuleFindHandle(@Modl,hMod) <> 0 then
    StrCopy(P,Modl.szModule)
  else if TaskFindHandle(@Tsk,hMod) then
    StrCopy(P,Tsk.szModule)
  else
    P[0] := #0;
  GetModuleName := P;
end;

function IsTaskOf(hTask,hMod: Thandle): Boolean;
var
  Tsk : TTaskEntry;
begin
  IsTaskOf := false;
  Tsk.dwSize := Sizeof(TTaskEntry);
  if TaskFindHandle(@Tsk,hTask) then
    IsTaskOf := Tsk.hModule = hMod;
end;


function Compare32(var x1,x2): Integer;
var
  a1: array[0..3] of byte absolute x1;
  a2: array[0..3] of byte absolute x2;
  i: Integer;
begin
  Compare32 := 0;
  for i := 3 downto 0 do
    if a1[i] <> a2[i] then
    begin
      if a1[i] < a2[i] then Compare32 := -1 else Compare32 := 1;
      Exit;
    end;
end;

type
  LongRemap = record
    case Word of
      0:(Long: LongInt);
      1:(LoWord, HiWord: Word);
   end;

function HexB(Dest: PChar; B: Byte): PChar;
const
  h: array[0..15] of Char = '0123456789ABCDEF';
begin
  Dest[0] := h[b shr 4];
  Dest[1] := h[b and $0F];
  Dest[2] := #0;
  HexB := Dest;
end;

function HexW(Dest: PChar; I: Word): PChar;
begin
  HexB(Dest, Hi(I));
  HexB(@Dest[2], Lo(I));
  HexW := Dest;
end;

function HexL(Dest: PChar; l:LongInt): PChar;
var
  lr: LongRemap absolute l;
begin
  HexW(Dest, lr.hiWord);
  HexW(@Dest[4], lr.loWord);
  HexL := Dest;
end;

function HexPtr(Dest: PChar; p:Pointer) :PChar;
var
  lr: longremap absolute p;
begin
  HexW(Dest, lr.hiWord);
  Dest[4] := ':';
  HexW(@Dest[5], lr.loWord);
end;

constructor TBWCCDlg.Init(AParent: PWindowsObject; AName: PChar;
  AHelpCtx: LongInt);
begin
  HelpCtx := AHelpCtx;
  inherited Init(AParent,AName);
end;

function TBWCCDlg.GetClassName: PChar;
begin
  GetClassNAme := 'BorDlg';
end;

procedure TBWCCDlg.WMDestroy;
begin
  inherited WMDestroy(Msg);
end;

procedure TBWCCDlg.HelpReq;
begin
 if HelpCtx <> 0 then
   DoHelp(HELP_CONTEXT,helpCtx)
 else
   DoHelp(HELP_INDEX,0);
end;

constructor TListWin.Init;
begin
  inherited Init(AParent, ATitle);
  New(List,Init(@Self,101,0,0,100,100));
  PrevChildWnd := 0;
  with List^.Attr do
  begin
    Style := Style or lbs_Sort;
    Style := Style or lbs_NoIntegralHeight;
    Style := Style and (not (ws_Border));
    Style := Style or ws_HScroll;
    if AOwnerDraw then
    begin
      Style := Style or lbs_OwnerDrawVariable;
      Style := Style and (not lbs_HasStrings);
    end;
  end;
end;


procedure TListWin.SetupWindow;
begin
  inherited SetupWindow;
  SendMessage(List^.HWindow, wm_SetFont, ListBoxFont, 0);
  if not glbl.RebuildOnActivate then BuildList;
  SendMessage(List^.HWindow, lb_SetCurSel, 0, 0);
  SendMessage(List^.HWindow, lb_SetHorizontalExtent, 1000, 0);
end;

procedure TListWin.BuildList;
begin
  { This abstract window doesn't know HOW to build a list }
end;

function TListWin.HandleSelect(LeftClick: Boolean): Boolean;
begin
  HandleSelect := false;
end;

procedure TListWin.ListSel;
begin
  if (Msg.lParamHi = lbn_DblClk) or (Msg.lParamHi = lbn_rDblClk) then
  begin
    if not HandleSelect(Msg.lParamHi = lbn_DblClk) then
      BWCCMessageBox(HWindow, 'This function has not been implemented',
        'Inspector', mb_IconStop + mb_OK);
  end
  else
    DefWndProc(MSg);
end;

procedure TListWin.WMSize;
begin
  inherited WMSize(MSg);
  if Msg.wPAram <> SizeIconic then
    MoveWindow(List^.HWindow, 0, 0, Msg.lParamLo, Msg.LparamHi, True);
end;

procedure TListWin.WMSetFocus;
begin
  DefWndProc(Msg);
  SetFocus(List^.HWindow);
end;

procedure TListWin.CMClose;
begin
  Destroy;
end;

procedure TListWin.CMSaveAs;
var
  F: text;
  P: Pointer;
  Txt: PChar;
  Idx: Integer;
  FileName: array[0..80] of Char;
begin
  StrCopy(FileName, 'HEAPSPY.LOG');
  if not DoFileSaveDialog(@Self, ofn_HideReadOnly, FileName, 80) then Exit;
  Assign(F, FileName);
  Append(F);
  if IOResult <> 0 then
    Rewrite(f);
  Writeln(F, '*** Log of ', Attr.Title, ' ***');
  for Idx := 0 to Pred(List^.GetCount) do
  begin
    P := Pointer(SendMessage(List^.HWindow, lb_GetItemData, idx, 0));
    Txt := GetItemString(p);
    Writeln(F, Txt);
    StrDispose(Txt);
  end;
  Writeln(F);
  Close(F);
end;

function TListWin.GetClassName: PChar;
begin
  GetClassName := 'HWListWin';
end;

procedure TListWin.GetWindowClass(var WndClass: TWndClass);
begin
  inherited GetWindowClass(WndClass);
  WndClass.hIcon := LoadIcon(hInstance, PChar(ico_Module));
end;

function TListWin.GetItemString(P: Pointer): PChar;
begin
end;

procedure TListWin.WMMeasureItem;
begin
 with PMeasureItemStruct(Msg.lPAram)^ do
   itemHeight := Abs(HeapFontLF.lfHeight) + 2;
end;

procedure TListWin.WMDrawItem;
var
  Txt: PChar;
  DoInvert: Boolean;
begin
  with PDrawItemStruct(Msg.lParam)^ do
    if (CtlType = odt_LISTBOX) and (CtlID = 101) then
    begin
      DoInvert := itemAction = oda_Select;
      if (((ItemAction and oda_DrawEntire) <> 0) and
        (itemID <> $FFFF)) then
      begin
        if (itemstate and ods_Selected) = ods_Selected then
          DoInvert := true;
        Txt := GetItemString(Pointer(ItemData));
        TextOut(hDC, 0, rcItem.Top, Txt, StrLen(Txt));
        StrDispose(Txt);
      end;
      if DoInvert then
        InvertRect(hDC,rcItem);
    end
    else
      DefWndProc(Msg);
end;

procedure TListWin.DeleteItem;
begin
end;

{- A simple comparison of the values of the PointerS.  Should normally
   be overridden by a descendant }
function TListWin.Less(p1,p2: Pointer): Integer;
begin
  if LongInt(P1) < LongInt(P2) then Less := -1
  else if LongInt(P1) > LongInt(P2) then Less := 1
  else Less := 0;
end;

procedure TListWin.WMCompareItem;
begin
  with Msg do
    Msg.Result := Less(Pointer(PCompareItemStruct(lParam)^.itemdata1),
      Pointer(PCompareItemStruct(lParam)^.itemdata2));
end;

procedure TListWin.WMDeleteItem;
begin
  DeleteItem(Pointer((PDeleteItemStruct(Msg.lParam)^.itemData)));
end;

procedure TListWin.RebuildWindow(var Msg: TMessage);
begin
  SendMessage(List^.HWindow, lb_ResetContent, 0, 0);
  SendMessage(List^.HWindow, wm_SetRedraw, 0, 0);
  BuildList;
  if Msg.Message <> wm_MDIActivate then
  begin
    SendMessage(List^.HWindow, lb_SetCurSel, 0 ,0);
    SendMessage(List^.HWindow, wm_SetRedraw, 1, 0);
    InvalidateRect(List^.HWindow, nil, True);
  end;
end;

procedure TListWin.DefWndProc;
var
  TopPos,
  LastPos: Integer;
begin
  with Msg do
  case Message of
    wm_MDIActivate:
      begin
        if wParam = 0 then
          PrevChildWnd := 0
        else
        begin
          PrevChildWnd := lParamHi;
          if (PrevChildWnd = 0) then
            PrevChildWnd := HWindow;
          if glbl.RebuildOnActivate then
          begin
            TopPos := SendMessage(List^.HWindow,LB_GetTopIndex,0,0);
            LastPos := List^.GetSelIndex;
            RebuildWindow(Msg);
            List^.SetSelIndex(LastPos);
            SendMessage(List^.HWindow,LB_SetTopIndex,TopPos,0);
            SendMessage(List^.HWindow,wm_SETREDRAW,1,0);
            InvalidateRect(List^.HWindow,nil,true);
          end;
        end;
        inherited DefWndProc(Msg);
      end;
   wm_MouseActivate:
     if (HWindow <> PrevChildWnd) and (lParamLo = HTClient) then
       Result := MA_ACTIVATEANDEAT
     else
       Result := MA_ACTIVATE;
   wm_SetCursor:
     begin
       PrevChildWnd := HWindow;
       inherited DefWndProc(Msg);
     end;
   else
     inherited DefWndProc(Msg);
   end;
end;

constructor TSortListWin.Init;
begin
  SortOpt := DefaultSortOpt;
  inherited Init(AParent, ATitle, AOwnerDraw);
end;

destructor TSortListWin.Done;
begin
  SortOpt := 0;
  AdjustMenu;
  inherited Done;
end;

procedure TSortListWin.AdjustMenu;
var
  Menu: hMenu;
  CtlID: Word;
  Wnd : HWND;
begin
  Wnd := Application^.MainWindow^.HWindow;
  if Wnd = 0 then Exit;
  Menu := GetMenu(Wnd);
  if Menu = 0 then Exit;
  for CtlID := cm_sbAddress to cm_sbModule do
    CheckMenuItem(Menu, CtlID, mf_ByCommand or mf_Unchecked);
  if SortOpt <> 0 then
    CheckMenuItem(Menu, SortOpt, mf_ByCommand or mf_Checked);
end;


procedure TSortListWin.ChangeSortOpt;
var
  OldSortOpt: Word;
  Msg: TMessage;
begin
  OldSortOpt := SortOpt;
  SortOpt := NewOpt;
  AdjustMenu;
  if OldSortOpt <> SortOpt then RebuildWindow(Msg);
end;

procedure TSortListWin.CMsbAddress(var Msg: TMessage);
begin
  ChangeSortOpt(cm_sbAddress);
end;

procedure TSortListWin.CMsbHAndle(var Msg: TMessage);
begin
  ChangeSortOpt(cm_sbHandle);
end;

procedure TSortListWin.CMsbSize(var Msg: TMessage);
begin
  ChangeSortOpt(cm_sbSize);
end;

procedure TSortListWin.CMsbType(var Msg: TMessage);
begin
  ChangeSortOpt(cm_sbType);
end;

procedure TSortListWin.CMsbModule(var Msg: TMessage);
begin
  ChangeSortOpt(cm_sbModule);
end;

procedure TSortListWin.WMSetFocus;
begin
  inherited WMSetFocus(Msg);
  AdjustMenu;
end;

procedure TMyListBox.WMRButtonDown(var Msg: TMessage);
begin
  SetFocus(Parent^.HWindow);
  SendMessage(HWindow, wm_LButtonDown, Msg.wParam, Msg.lParam);
end;

procedure TMyListBox.WMRButtonUp(var Msg: TMessage);
begin
  SendMessage(HWindow, wm_LButtonUp,Msg.wParam,Msg.lParam);
end;

procedure TMyListBox.WMRButtonDblClk(var Msg: TMessage);
begin
  SendMessage(Parent^.HWindow,wm_COMMAND,101,lbn_RDBLCLKMask or HWindow);
end;

procedure TMyListBox.WMKeyDown(var Msg: TMessage);
{ an apparent bug in Windows 3.1 causes a VK_NEXT keypress to be
  non-functional in a ownerdraw-variable list box}
var
  SelItem,TopItem,MaxItem: Integer;
  ItemHeight,ItemsPerPage: Integer;
  PageDim: TRect;
begin
  if Msg.wParam = vk_Return then
     PostMessage(Parent^.HWindow, wm_Command, Attr.ID,
       (lbn_DBLCLK shl 16) or HWindow);
  if Msg.wParam <> vk_Next then
  begin
    DefWndProc(Msg);
    Exit;
  end;
  MaxItem := Pred(GetCount);
  ItemHeight := SendMessage(HWindow, lb_GetItemHeight, 0, 0);
  GetClientRect(HWindow,PageDim);
  with PageDim do
    ItemsPerPage := Pred(Bottom div ItemHeight);
  SelItem := GetSelIndex;
  if SelItem = MaxItem then Exit;
  Inc(SelItem,ItemsPerPage);
  if SelItem >= GetCount then SelItem := MaxItem;
  SendMessage(HWindow, wm_SetRedraw, 0, 0);
  SendMessage(HWindow, lb_SetCurSel, SelItem, 0);
  SendMessage(HWindow, wm_SetRedraw, 1 ,0);
  InvalidateRect(HWindow, nil, True);
end;

procedure LoadINIStuff;
var
  Temp: Word;
begin
  Temp := GetPrivateProfileInt(OptionsKey, RebuildKey, 0, INIFile);
  if Temp > 1 then Temp := 0;
  Glbl.RebuildOnActivate := WordBool(Temp);

  Temp := GetPrivateProfileInt(OptionsKey, SpeedBarKey, 1, INIFile);
  if Temp > 1 then Temp := 0;
  Glbl.UseSpeedBar := WordBool(Temp);

  FillChar(Glbl.SortOpt,Sizeof(Glbl.SortOpt),0);
  Temp := GetPrivateProfileInt(OptionsKey, SortOptKey, 0, INIFile);
  if Temp > 4 then Temp := 0;
  Inc(Temp,cm_sbAddress);
  Glbl.SortOpt[Temp] := True;

  FillChar(Glbl.WinTile, Sizeof(Glbl.WinTile), 0);
  Temp := GetPrivateProfileInt(OptionsKey, WinTileKey, 0, INIFile);
  if Temp > 1 then Temp := 0;
  Inc(Temp, op_Vertical);
  Glbl.WinTile[Temp] := True;
end;

var
  SaveExit: Pointer;

procedure UnitExit; far;
begin
  ExitProc := SaveExit;
  if ListBoxFont <> 0 then DeleteObject(ListBoxFont);
  if HexDumpFont <> 0 then DeleteObject(HexDumpFont);
end;

begin
  ListBoxFont := GetStockObject(Ansi_Fixed_Font);
  GetObject(ListBoxFont, SizeOf(TLogFont), @HeapFontLF);
  ListBoxFont := CreateFontIndirect(HeapFontLF);

  HexDumpFont := GetStockObject(Oem_Fixed_Font);
  GetObject(HexDumpFont, SizeOf(TLogFont), @HexDumpLF);
  HexDumpFont := CreateFontIndirect(HexDumpLF);

  SaveExit := ExitProc;
  ExitProc := @UnitExit;
  WaitCursor := LoadCursor(0, PChar(idc_Wait));
  ArrowCursor := LoadCursor(0, PChar(idc_Arrow));
  LoadINIStuff;
end.
