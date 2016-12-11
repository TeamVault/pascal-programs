{$A-,B-,E-,F-,G+,I-,K-,N-,O-,P-,Q-,R-,S-,T+,V-,W-,X+}
{$M 8192,8192}

{**********************************************}
{                                              }
{   HeapSpy - Main Module                      }
{   Copyright (c) 1992  Borland International  }
{                                              }
{**********************************************}

program HeapSpy;

{$C MOVEABLE PRELOAD PERMANENT}

{$R HEAPSPY.RES}
{$D HeapSpy Version 1.0}

uses WinTypes, WinPRocs, Strings, Objects, ODialogs, OWindows, BWCC,
 WinDOS, Win31, ToolHelp, HWGlobal, HWDlgs, HWClass, HWHexDmp,
 HWBitmap, HWLocal, HWTPWh, HWHeap, HWGraph, HWRibbon;

{$S 65535}
{$G HeapSpy, System, HWGlobal, HWRibbon}
{$G HWDlgs}
{$G HWClass}
{$G HWHexDmp}
{$G HWBitMap}
{$G HWLocal}
{$G HWTPWh}
{$G HWHeap}
{$G WinDos, Strings}
{$G Objects, OWindows, ODialogs, OMemory, BWCC}

type
  PMDIApp = ^TMDIApp;
  TMDIApp = object(TApplication)
    procedure InitMainWindow; virtual;
 end;

  PHeapSpyMDIWindow = ^THeapSpyMDIWindow;
  THeapSpyMDIWindow = object(TMDIWINDOW)
    StatusLine: PRibbonWindow;
    SpeedBar: PSpeedBar;
    constructor Init(ATitle: Pchar; AMenu: THandle);
    function InitChild: PWindowsObject; virtual;
    procedure GetWindowClass(var WndClass: TWndClass); virtual;
    procedure InitClientWindow; virtual;
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;
    procedure WMMenuSelect(var Msg: TMessage);
      virtual wm_First + wm_MenuSelect;
    procedure WMDestroy(var Msg: TMessage);
      virtual wm_First + wm_Destroy;
    procedure CMAbout(var Msg: Tmessage);
      virtual cm_First + cm_About;
    procedure CMClose(var Msg: TMessage);
      virtual cm_First + cm_Close;
    procedure CMCreateAll(var Msg: TMessage);
      virtual cm_First + cm_CreateAll;
    procedure CMCreateFree(var Msg: TMessage);
      virtual cm_First + cm_CreateFree;
    procedure CMCreateClass(var Msg: TMessage);
      virtual cm_First + cm_CreateClass;
    procedure CMHeapGraph(var Msg: Tmessage);
      virtual cm_First + cm_HeapGraph;
    procedure CMOptions(var Msg: TMessage);
      virtual cm_First + cm_Options;
    procedure CMGDIWalk(var Msg: TMessage);
      virtual cm_First + cm_GDIWalk;
    procedure CMUserWalk(var Msg: TMessage);
      virtual cm_First + cm_UserWalk;
    procedure CMMemInfo(var Msg: TMessage);
      virtual cm_First + cm_meminfo;
    procedure CMHelpContents(var Msg: TMessage); virtual
      cm_First + cm_HelpContents;
    procedure CMListFont(var Msg: TMessage);
      virtual cm_First + cm_ListFont;
    procedure CMHexFont(var Msg: TMessage);
      virtual cm_First + cm_HexFont;
    procedure CreateSpeedbar;
    procedure UpdateSpeedbar(var Msg: TMessage); virtual
      wm_First + user_UpdateSpeed;
  end;

  PHeapSpyMDIClient = ^THeapSpyMDIClient;
  THeapSpyMDIClient = object(TMDIClient)
    procedure TileChildren; virtual;
  end;

constructor THeapSpyMDIWindow.Init(ATitle: Pchar; AMenu: THandle);
begin
  inherited Init(ATitle,AMenu);
  Attr.X := 0;
  Attr.Y := 0;
  StatusLine := New(PRibbonWindow,Init(@Self));
  if Glbl.UseSpeedBar then
    CreateSpeedBar
  else
    SpeedBar := nil;
end;

procedure THeapSpyMDIWindow.CreateSpeedBar;
begin
 SpeedBar := New(PSpeedBar,Init(@Self,StatusLine));
 with SpeedBar^ do
 begin
   AddATool(cm_HelpContents,Pchar(cm_HelpContents));
   AddATool(cm_CreateChild,Pchar(cm_CreateChild));
   AddATool(cm_SaveAs,Pchar(cm_SaveAs));
   AddATool(cm_Options,Pchar(cm_options));
   AddATool(cm_Rebuild,Pchar(cm_rebuild));
 end;
end;

procedure THeapSpyMDIWindow.UpdateSpeedBar;
var
  Rect: TRect;
  SendSizeMsg: Boolean;
  SizeMsg: TMessage;
begin
  SendSizeMsg := False;
  if glbl.UseSpeedBar and (SpeedBar = nil) then
  begin
    CreateSpeedBar;
    Application^.MakeWindow(SpeedBar);
    SendSizeMsg := True;
  end
  else if (not glbl.UseSpeedBar) and (SpeedBar <> nil) then
  begin
    SpeedBar^.Free;
    SpeedBar := nil;
    SendSizeMsg := True;
  end;
  if SendSizeMsg then
  begin
    GetClientRect(hWindow,Rect);
    SizeMsg.lParamLo := Rect.Right;
    SizeMsg.lParamHi := Rect.Bottom;
    WMSize(SizeMsg);
  end;
end;

procedure THeapSpyMDIWindow.WMSize(var Msg: TMessage);
var
  ClientX,ClientY,
  StatusX,StatusY,
  SpeedX,SpeedY,
  ClientW,ClientH,
  StatusW,StatusH,
  SpeedW,SpeedH: integer;
begin
  ClientX := 0; ClientY := 0;
  ClientW := Msg.lParamLo;  ClientH := Msg.lParamHi;

  if StatusLine <> nil then
  with StatusLine^ do
  begin
    StatusX := ClientX-1; StatusY := ClientH-Height;
    StatusW := ClientW+2;  StatusH := Height+1;
    Dec(ClientH,Height);
    if StatusLine^.hWindow <> 0 then
      MoveWindow(StatusLine^.hWindow,StatusX,StatusY,StatusW,StatusH,True);
  end;

  if SpeedBar <> nil then
  begin
    SpeedX := ClientX;
    Dec(ClientY);
    SpeedY := ClientY;
    SpeedW := ClientW+1;
    SpeedH := SpeedBar^.Attr.H;
    Inc(ClientY,SpeedH);
    Dec(ClientH,Pred(SpeedH));
    if SpeedBar^.hWindow <> 0 then
       MoveWindow(SpeedBar^.hWindow,SpeedX,SpeedY,SpeedW,SpeedH,True);
  end;

  if (ClientWnd <> nil) and (ClientWnd^.HWindow <> 0) then
    MoveWindow(ClientWnd^.HWindow, ClientX,ClientY,ClientW,ClientH,True);
end;

procedure THeapSpyMDIWindow.WMMenuSelect;
var
  HelpText: array[0..80] of char;
  I, StrIdx: word;
const
  Popuphandles: array[0..5] of word = (0,0,0,0,0,0);
begin
 if PopupHandles[0] = 0 then
   for i := 0 to 5 do
     PopupHandles[i] := GetSubMenu(Attr.Menu,i);

  if StatusLine = nil then exit;

  HelpText[0] := #0;
  if Msg.LParamLo <> $FFFF then
  begin
    StrIdx := Msg.wParam;
    if (Msg.lParamLo and MF_POPUP) <> 0 then
    begin
      I := 0;
      StrIdx := 0;
      repeat
        if PopupHandles[I] = Msg.wParam then StrIdx := 1000+i;
        inc(I);
      until (I > 5) or (StrIdx <> 0);
    end;
    if (StrIdx >= $0F00) and (StrIdx <= $0F0A) then
      StrCopy(HelpText,'Make this window Current')
    else if (StrIdx <> 0) and (StrIdx < $F000) then
      LoadString(hInstance,StrIdx,HelpText,80);
  end;
  StatusLine^.SetHelpText(HelpText);
  DefWndProc(Msg);
end;

procedure THeapSpyMDIWindow.GetWindowClass;
begin
  inherited GetWindowClass(WndClass);
  WndClass.hIcon := LoadIcon(HInstance, PChar(ico_Main));
  WndClass.hbrBackground := COLOR_APPWORKSPACE+1;
end;

function THeapSpyMDIWindow.InitChild;
var
  ModuleName: array[0..30] of char;
begin
  InitChild := nil;
  if Application^.ExecDialog(New(PModuleDlg, Init(@Self, 'SELMOD',
      ModuleName))) = id_OK then
    if ModuleName[0] <> #0 then
    begin
      UpdateWindow(ClientWnd^.hWindow);
      InitChild := New(PHeapWin,Init(@Self,ModuleName));
    end;
end;

procedure THeapSpyMDIWindow.CMClose;
var
  ChildWin: LongInt;
begin
 ChildWin := SendMessage(hWindow,WM_MDIGETACTIVE,0,0);
 if LoWord(ChildWin) <> 0 then
    SendMessage(ClientWnd^.hWindow,WM_MDIDESTROY,LoWord(ChildWin),0);
end;

procedure THeapSpyMDIWindow.CMCreateAll;
begin
  Application^.MakeWindow(New(PHeapWin,Init(@Self,'All Heap Blocks')));
end;

procedure THeapSpyMDIWindow.CMCreateFree(var Msg: TMEssage);
begin
  Application^.MakeWindow(New(PHeapWin,Init(@Self,'Free Blocks')));
end;

procedure THeapSpyMDIWindow.CMHeapGraph;
var
  GraphWin: PWindowsObject;

  function IsAGraphWin(PWin: PWindowsObject): Boolean; far;
  begin
    IsAGraphWin := TypeOf(PWin^) = TypeOf(TBarGraphWin);
  end;

begin
  GraphWin := FirstThat(@IsAGraphWin);
  if GraphWin <> nil then
    SendMessage(ClientWnd^.hWindow,WM_MDIACTIVATE,GraphWin^.hWindow,0)
  else
    Application^.MakeWindow(New(PBarGraphWin,Init(@Self,'Heap Usage')));
end;

procedure THeapSpyMDIWindow.CMCreateClass;
var
  ClassWin: PWindowsObject;

  function IsAClassWin(PWin: PWindowsObject): Boolean; far;
  begin
    IsAClassWin := TypeOf(PWin^) = TypeOf(TClassWin);
  end;

begin
  ClassWin := FirstThat(@IsAClassWin);
  if ClassWin <> nil then
    SendMessage(ClientWnd^.hWindow,WM_MDIACTIVATE,ClassWin^.hWindow,0)
  else
    Application^.MakeWindow(New(PClassWin,Init(@Self,'Window Classes',True)));
end;

procedure THeapSpyMDIWindow.CMUserWalk;
var
  SHI: TSysHeapInfo;
begin
  SHI.dwSize := SizeOf(TSysHeapInfo);
  SystemHeapInfo(@SHI);
  Application^.MakeWindow(New(PLocalWin,Init(@Self,SHI.hUserSegment,'USER')));
end;

procedure THeapSpyMDIWindow.CMGDIWalk;
var
  SHI: TSysHeapInfo;
begin
  SHI.dwSize := SizeOf(TSysHeapInfo);
  SystemHeapInfo(@SHI);
  Application^.MakeWindow(New(PLocalWin,Init(@Self,SHI.hGDISegment,'GDI')));
end;

procedure THeapSpyMDIWindow.CMAbout;
begin
  Application^.ExecDialog(New(PAbtDlg,Init(@Self,'About')));
end;

procedure THeapSpyMDIWindow.CMOptions;
begin
  Application^.ExecDialog(New(POptionDlg,Init(ClientWnd,'HWOPTIONS')));
end;

procedure THeapSpyMDIWindow.CMListFont;
var
  Dummy: LongInt;

  procedure UpdateFont(Item: PWindowsObject); far;
  begin
    if DescendantOf(TypeOf(TListWin), TypeOf(Item^)) then
    with PListWin(Item)^ do begin
      SendMessage(List^.hWindow,WM_SETFONT,ListBoxFont,1);
      RebuildWindow(Msg);
    end;
  end;

begin
  if DoFontDialog(@Self,@HeapFontLF,'Heap List Font') then
  begin
    if ListBoxFont <> 0 then
      DeleteObject(ListBoxFont);
    ListBoxFont := CreateFontIndirect(HeapFontlf);
    Application^.MainWindow^.ForEach(@UpdateFont);
  end;
end;

procedure THeapSpyMDIWindow.CMHexFont;
var
  Dummy: LongInt;

  procedure UpdateFont(Item: PWindow); far;
  begin
    if DescendantOf(TypeOf(TBasicHexWin),TypeOf(Item^)) then
      SendMessage(Item^.hWindow,WM_SETFONT,HexDumpFont,1);
  end;

begin
  if DoFontDialog(@Self,@HexDumpLF,'Hex Dump Font') then
  begin
    if HexDumpFont <> 0 then
      DeleteObject(HexDumpFont);
    HexDumpFont := CreateFontIndirect(HexDumplf);
    Application^.MainWindow^.ForEach(@UpdateFont);
  end;
end;


procedure THeapSpyMDIWindow.CMHelpContents;
begin
  DoHelp(help_Index, 0);
end;

procedure THeapSpyMDIWindow.CMMemInfo;
begin
  Application^.ExecDialog(New(PMemDlg, Init(@Self, 'MEMINFO',
    menu_Heap_MemInfo)));
end;

procedure THeapSpyMDIWindow.InitClientWindow;
begin
  ClientWnd := New(PHeapSpyMDIClient, Init(@Self));
  with clientwnd^.Attr do
    Style := Style or ws_VScroll or ws_HScroll;
end;

procedure THeapSpyMDIWindow.WMDestroy;
begin
  CloseHelp;
  inherited WMDestroy(Msg);
end;


procedure THeapSpyMDIClient.TileChildren;
begin
  if TilingMethod = op_vertical then
    SendMessage(HWindow, wm_MDITile, MDITile_Vertical, 0)
  else
    SendMessage(HWindow, wm_MDITile, MDITile_Horizontal, 0);
end;

procedure TMDIApp.InitMainWindow;
begin
  MainWindow := New(PHeapSpyMDIWindow, Init('Heap Spy',
    LoadMenu(HInstance, PChar(mnu_main))));
  PMDIWindow(MainWindow)^.ChildMenuPos := 5;
end;

var
  MDIApp: TMDIApp;

const
  Copyright: PChar = 'Copyright (c) 1992  Borland International';

begin
  if Copyright <> nil then;
  if LoWord(GetVersion) <> $0A03 then
    MessageBox(0,'This application requires Windows 3.1', AppName,
      mb_OK or mb_IconHand)
  else
  begin
    MDIApp.Init(AppName);
    MDIApp.Run;
    MDIApp.Done;
  end;
end.
