{$A-,B-,E-,F-,G+,I-,K-,N-,O-,P-,Q-,R-,S-,T+,V-,W-,X+}

{**********************************************}
{                                              }
{   HeapSpy - HWDlgs Module                    }
{   Copyright (c) 1992  Borland International  }
{                                              }
{**********************************************}

unit HWDlgs;

{$C MOVEABLE DEMANDLOAD DISCARDABLE}

interface

uses Wintypes, WinProcs, Objects, ODialogs, OWindows, BWCC, Strings,
  ToolHelp, HWGlobal;

type
  PModuleDlg = ^TmoduleDlg;
  TModuleDlg = object(TBWCCDlg)
    ModuleName: PChar;
    LB: PListBox;
    constructor Init(AParent: PWindowsObject; AID: PChar; AModuleName: PChar);
    procedure SetupWindow; virtual;
    procedure ListSel(var Msg: Tmessage);
      virtual id_First + id_ModuleList;
    procedure UnloadMod(var Msg: TMessage);
      virtual id_First + 104;
    procedure OK(var Msg: TMessage);
      virtual id_First + id_OK;
    procedure ModuleInfo(var Msg: TMessage);
      virtual id_First + cm_Modinfo;
    procedure Color(var Msg: TMessage);
      virtual wm_First + wm_CtlColor;
  end;

  PModuleInfo = ^TModuleInfo;
  TModuleInfo = object(TBWCCDlg)
    ModuleName: PChar;
    Module: THandle;
    Modl: TModuleEntry;
    Globl: TGlobalEntry;
    CodeSize, DataSize,ResourceSize,OtherSize: LongInt;
    constructor Init(AParent: PWindowsObject; AID, AModuleName: PChar);
    procedure SetupWindow; virtual;
    procedure WMCtlColor(var Msg: TMessage);
      virtual wm_First + wm_CtlColor;
  end;

  PAbtDlg = ^TAbtDlg;
  TAbtDlg = object(TBWCCDlg)
    constructor Init(AParent: PWindowsObject; AnID: PChar);
    procedure GetWindowClass(var WC: TWndClass); virtual;
    function GetClassName: PChar; virtual;
    procedure SetupWindow; virtual;
  end;

  POptionDlg = ^TOptionDlg;
  TOptionDlg = object(TBWCCDlg)
    constructor Init(AParent: PWindowsObject; AnID: PChar);
    procedure OK(var Msg: TMessage);
      virtual id_First + id_OK;
  end;

  PMemDlg = ^TMemDlg;
  TMemDlg = object(TBWCCDlg)
    procedure SetupWindow; virtual;
  end;

implementation

constructor TOptionDlg.Init;
var
  I: Integer;
  T: PWindowsObject;
begin
  inherited Init(APArent, AnID, menu_Options);
  T := New(PCheckBox, InitResource(@Self, 101));
  T := New(PCheckBox,InitResource(@Self, op_SpeedBar));
  for I := 0 to 1 do
    T := New(PRadioButton,InitResource(@Self,op_Vertical + I));
  for I := 0 to 4 do
    T := New(PRadioButton, InitResource(@Self,102 + I));
  TransferBuffer := @Glbl;
end;

procedure TOptionDlg.OK;
var
  Temp: array[0..10] of Char;
begin
  inherited OK(Msg);
  Str(Word(Glbl.RebuildOnActivate), Temp);
  WritePrivateProfileString(OptionsKey, RebuildKey, Temp, INIFile);
  Str(Word(Glbl.UseSpeedBar), Temp);
  WritePrivateProfileString(OptionsKey, SpeedBarKey, Temp, INIFile);
  Str(DefaultSortOpt - cm_sbAddress, Temp);
  WritePrivateProfileString(OptionsKey, SortOptKey, Temp, INIFile);
  Str(TilingMethod - op_vertical, Temp);
  WritePrivateProfileString(OptionsKey, WinTileKey, Temp, INIFile);
  SendMessage(Application^.MainWindow^.HWindow, user_UpdateSpeed, 0, 0);
end;

constructor TAbtDlg.Init;
begin
  inherited Init(APArent,AnID,0);
end;

procedure TAbtDlg.GetWindowClass(var WC: TWndClass);
begin
  inherited GetWindowClass(WC);
end;

function TAbtDlg.GetClassName: PChar;
begin
  GetClassName := 'BORDLG_ABT';
end;

procedure TAbtDlg.SetupWindow;
Var
  M: TMemManInfo;
  H: TSysHeapInfo;
  temp: array[0..20] of Char;
  PercentFree,UserFree: Word;
begin
  inherited SetupWindow;

  if (GetWinFlags and wf_Enhanced) <> 0 then
    SendDlgItemMsg(ab_WinMode, wm_SetText, 0,
      LongInt(PChar('386 Enhanced Mode')))
  else
    SendDlgItemMsg(ab_WinMode, wm_SetText, 0,
      LongInt(PChar('Standard Mode')));

  Str(GetFreeSpace(0) div 1024,Temp);
  Strcat(Temp,'K');
  SendDlgItemMSg(ab_FreeMem, wm_SetText, 0, LongInt(@TEMP));

  H.dwSize := SizeOf(TSysHeapInfo);
  SystemHeapInfo(@H);
  if H.wUserFreePercent < H.wGDIFreePercent then
    PercentFree := H.wUserFreePercent
  else
    PErcentFree := H.wGDIFreePercent;
  Str(PercentFree,Temp);
  StrCat(Temp,' %');
  SendDlgItemMsg(ab_ResPct, wm_SetText, 0, LongInt(@TEMP));
end;

constructor TModuleDlg.Init;
begin
  inherited Init(Aparent,AID,MENU_HEAP_SELMOD);
  ModuleName := AModuleName;
  ModuleName[0] := #0;
  New(LB,InitResource(@Self,id_ModuleList));
end;


procedure TModuleDlg.ListSel;
begin
 with Msg do
   if lParamHi = LBN_DBLCLK then
   begin
     LB^.GetSelString(ModuleName,8);
     EndDlg(id_OK);
   end;
end;

procedure TModuleDlg.UnloadMod;
var
  ModID: array[0..8] of Char;
  MBStr: array[0..100] of Char;
  MBInfo: pointer;
  LBIdx: Integer;
  TgtModule: THandle;
  Modl: TModuleEntry;
  Tsk: TTaskEntry;
  TermCount: Integer;
begin
  LBIdx := LB^.GetSelIndex;
  if LBIdx < 0 then
  begin
    MessageBox(hWindow,'No module selected','Unload',MB_OK);
    Exit;
  end;
  LB^.GetSelString(ModID,8);
  MBInfo := @MODId;
  WVSPrintF(MBStr, 'Unload %s, Are you sure?', MBInfo);
  if MessageBox(hWindow,MBStr, 'Unload', mb_YesNo or
    mb_IconQuestion) = id_Yes then
  begin
    { Remove the module from Windows}
    Modl.dwSize := SizeOf(TModuleEntry);
    Modl.szModule[0] := #0;
    TgtModule := ModuleFindName(@Modl,ModID);
    if TgtModule <> 0 then
    begin
      Tsk.dwSize := SizeOf(TTaskEntry);
      TaskFirst(@Tsk);
      TermCount := 0;
      repeat
        if Tsk.hModule = TgtModule then
        begin
          TerminateApp(Tsk.hTask,No_UAE_Box);
          Inc(TermCount);
        end;
      until not TaskNext(@Tsk);
      if TermCount = 0 then
        { It's a DLL, so FreeLibrary it}
        for TermCount := 1 to Modl.wUsageFlags do
          FreeLibrary(TgtModule);
    end;
    LB^.DeleteString(LBIdx);
    EndDlg(id_OK);
  end;
end;

procedure TModuleDlg.SetupWindow;
var
  Modl: TModuleEntry;
begin
  inherited SetupWindow;
  Modl.dwSize := SizeOf(TModuleEntry);
  if ModuleFirst(@Modl) then
    repeat
      LB^.AddString(Modl.szModule);
    until not ModuleNext(@Modl);
  LB^.SetSelIndex(0);
end;

procedure TModuleDlg.Color;
begin
  {
  if Msg.lParamHi = CTLCOLOR_LISTBOX then
     begin
     SetTextColor(Msg.wParam,$00800000);
     SetBkMode(Msg.wParam,TRANSPARENT);
     Msg.Result := GetStockObject(LTGRAY_BRUSH);
     end
  else
  }
  DefWndProc(Msg);
end;

procedure TModuleDlg.OK;
begin
  LB^.GetSelString(ModuleName,8);
  inherited OK(Msg);
end;

procedure TModuleDlg.ModuleInfo;
begin
  LB^.GetSelString(ModuleName, 8);
  Application^.ExecDialog(New(PModuleInfo,Init(@Self, 'MODINFO',
    ModuleName)));
end;

constructor TModuleInfo.Init;
begin
  Modl.dwSize := SizeOf(TModuleEntry);
  Modl.szModule[0] := #0;
  Module := ModuleFindName(@Modl, AModuleName);
  if Module = 0 then Fail;
  inherited Init(Aparent, AID, 0);
  ModuleName := AModuleName;
end;


procedure TModuleInfo.WMCtlColor;
begin
  if Msg.lParamHi = ctlColor_Static then
  begin
    SetTextColor(Msg.wParam, $00800000);
    SetBkMode(Msg.wParam, Opaque);
    SetBKColor(Msg.wParam, $00FFFFFF);
    Msg.Result := GetStockObject(ltGray_Brush);
  end
  else
    DefWndProc(Msg);
end;

procedure TModuleInfo.SetupWindow;
var
  Temp: array[0..20] of Char;
begin
  CodeSize := 0;
  DataSize := 0;
  ResourceSize := 0;
  OtherSize := 0;
  inherited SetupWindow;
  Globl.dwSize := SizeOf(TGlobalEntry);
  GlobalFirst(@Globl,GLOBAL_ALL);
  repeat
    with Globl do
      if hOwner = Module then
        case wType of
          gt_Code:
            Inc(CodeSize, dwBlockSize);
          gt_Data, gt_DGroup, gt_Unknown:
            Inc(DataSize, dwBlockSize);
          gt_Resource:
            Inc(ResourceSize, dwBlockSize);
        else
          Inc(OtherSize, dwBlockSize);
        end;
   until not GlobalNext(@Globl,GLOBAL_ALL);
   SendDlgItemMsg(mi_ModName, wm_SetText, 0, LongInt(ModuleName));

   Str(CodeSize,Temp);
   SendDlgItemMsg(mi_Code, wm_SetText, 0, LongInt(@Temp));

   Str(DataSize,Temp);
   SendDlgItemMsg(mi_Data, wm_SetText, 0, LongInt(@Temp));

   Str(ResourceSize,Temp);
   SendDlgItemMsg(mi_Resource, wm_SetText, 0, LongInt(@Temp));

   Str(OtherSize,Temp);
   SendDlgItemMsg(mi_Other, wm_SetText, 0, LongInt(@Temp));
end;

procedure TMemDlg.SetupWindow;
var
  MM: TMemManInfo;
  CVA: array[0..30] of Char;

  function CVP(V: LongInt): LongInt;
  var
    Digits: Integer;
    Commas: Integer;
    NewIdx,CurIdx: Integer;
  begin
    FillChar(CVA, SizeOf(CVA), #0);
    Str(V,CVA);
    Digits := StrLen(CVA);
    CurIdx := Pred(Digits);
    if CVA[0] = '-' then Dec(Digits);
    Commas := CurIdx div 3;
    NewIdx := CurIdx + Commas;
    Commas := 0;
    while CurIdx >= 0 do
    begin
      if (commas = 3) and (CVA[CurIdx] <> '-') then
      begin
        commas := 0;
        CVA[NewIdx] := ',';
        Dec(NewIdx);
      end;
      CVA[NewIdx] := CVA[CurIdx];
      Dec(CurIdx);
      Dec(NewIdx);
      inc(Commas);
    end;
    CVP := LongInt(@CVA);
  end;

begin
  inherited SetupWindow;
  FillChar(MM,SizeOf(MM),0);
  MM.dwSize := SizeOf(MM);
  MemManInfo(@MM);
  with MM do
  begin
    SendDlgItemMsg(101, wm_SetText, 0, CVP(dwLargestFreeBlock));
    SendDlgItemMsg(102, wm_SetText, 0, CVP(dwMaxPagesAvailable));
    SendDlgItemMsg(103, wm_SetText, 0, CVP(dwMaxPagesLockable));
    SendDlgItemMsg(104, wm_SetText, 0, CVP(dwTotalLinearSpace));
    SendDlgItemMsg(105, wm_SetText, 0, CVP(dwTotalUnlockedPages));
    SendDlgItemMsg(106, wm_SetText, 0, CVP(dwFreePages));
    SendDlgItemMsg(107, wm_SetText, 0, CVP(dwTotalPages));
    SendDlgItemMsg(108, wm_SetText, 0, CVP(dwFreeLinearSpace));
    SendDlgItemMsg(109, wm_SetText, 0, CVP(dwSwapFilePages));
    SendDlgItemMsg(110, wm_SetText, 0, CVP(wPageSize));
  end;
end;

end.
