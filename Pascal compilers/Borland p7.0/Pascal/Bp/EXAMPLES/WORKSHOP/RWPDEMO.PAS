{************************************************}
{                                                }
{   Resource Workshop Demo                       }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{
   This example can be compiled with either the "standard" windows look
   or the "Borland look". By default, it uses "standard" windows
   controls. To cause it to use Borland Windows Custom Controls, select
   Options.Compiler and enter BWCC in the Conditional defines field.
}


program RWPDemo;

{$ifdef BWCC}
{$R RWPDEMOB.RES}
{$else}
{$R RWPDEMO.RES}
{$endif}
{$D 'Resource Workshop Demo Program. Copyright (c) Borland 1992'}

uses WinTypes, WinProcs, Objects, OWindows, ODialogs,
{$ifdef BWCC}
  BWCC,
{$endif}
  Strings,  RWPDemoC, RWPDlgs, RWPWnd, WinDOS;

const
  AppName = 'RWPDEMO';
  StatusLineHeight        =  20;
  TextStart               = 200; { Location for hints in status line }
  EditFirst               = cm_EditUndo;
  EnvironmentFirst        = cm_Preferences;
  FileFirst               = cm_New;
  Helpfirst               = cm_Index;
  OptionFirst             = cm_Directories;
  ViewFirst               = cm_All;
  WindowFirst             = cm_TileChildren;
  am_DrawStatusLine       = wm_User + 200;

type
  PRWPApplication = ^RWPApplication;
  RWPApplication = object(TApplication)
    constructor Init(AName: PChar);
    procedure InitMainWindow; virtual;
    procedure Error(ErrorCode: Integer); virtual;
  end;

type
  PRWPWindow = ^TRWPWindow;
  TRWPWindow = object(TMDIWindow)
    BmpStatusBar: HBitmap;
    BmpStatusLine: HBitmap;
    CurrentID: Word;
    CurrentPopup: HMenu;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    destructor  Done; virtual;
    procedure AboutRWP(var Msg: TMessage); virtual cm_First + cm_About_RWP;
    procedure BlastStatusLine(PaintDC: HDC);
    procedure ReconstructStatusLine;
    procedure DefCommandProc(var Msg: TMessage); virtual;
    procedure FileNew(var Msg: TMessage); virtual cm_First + cm_New;
    procedure FileOpen(var Msg: TMessage); virtual cm_First + cm_Open;
    procedure FilePrint(var Msg: TMessage); virtual cm_First + cm_Print;
    function  GetClassName: PChar; virtual;
    procedure GetWindowClass(var WndClass: TWndClass); virtual;
    procedure OpenAFile(FileType: Integer; FileName: PChar);
    procedure OptionsDirectories(var Msg: TMessage); virtual cm_First+cm_Directories;
    procedure OptionsMouse(var Msg: TMessage); virtual cm_First+cm_Mouse;
    procedure OptionsOpen(var Msg: TMessage); virtual cm_First+cm_Options_Open;
    procedure OptionsPreferences(var Msg: TMessage); virtual cm_First+cm_Preferences;
    procedure OptionsSave(var Msg: TMessage); virtual cm_First+cm_Options_Save;
    procedure OptionsSaveAs(var Msg: TMessage); virtual cm_First+cm_Options_Saveas;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure StubDialog(ADialog: PRWPDialog; ACaption: PChar);
    procedure WMDrawStatusLine(var Msg: TMessage); virtual wm_First + am_DrawStatusLine;
    procedure WMMenuSelect(var Msg: TMessage); virtual wm_First + wm_MenuSelect;
    procedure WMEnterIdle(var Msg: TMessage); virtual wm_First + wm_EnterIdle;
    procedure WMSize(var Msg: TMessage); virtual wm_First + wm_Size;
  end;

{------------------------- TRWPApplication implementation ---------------}

constructor RWPApplication.Init(AName: PChar);
begin
  TApplication.Init(AName);
  HAccTable := LoadAccelerators(HInstance, MakeIntResource(Acc_Main));
end;


procedure RWPApplication.InitMainWindow;
begin
  MainWindow := New(PRWPWindow, Init(nil, 'Resource Workshop Demo Program'));
end;

procedure RWPApplication.Error(ErrorCode: Integer);
var
  Title: array [0..40] of char;
  Msg: array [0..80] of char;
begin
  if (ErrorCode > 0) and
     (LoadString(HInstance, ErrorCode, Msg, SizeOf(Msg)) > 0) and
     (LoadString(HInstance, ErrorCode+1, Title, SizeOf(Title)) > 0) then
    MessageBox(0, Msg, Title, mb_IconExclamation or mb_OK)
  else
    TApplication.Error(ErrorCode);
end;


{--------------------------- TRWPWindow implementation ------------------}

constructor TRWPWindow.Init(AParent:PWIndowsObject; ATitle:PChar);
begin
  TMDIWindow.Init('RWP Application', LoadMenu(HInstance,
    MakeIntResource(men_Main)));
  BmpStatusBar := LoadBitmap(HInstance, MakeIntResource(bmp_StatusBar));
  BmpStatusLine := 0;
end;

procedure TRWPWindow.AboutRWP(var Msg:TMessage);
begin
  Application^.ExecDialog(New(PRWPDialog, Init(@Self, MakeIntResource(dlg_About))));
end;

procedure TRWPWindow.BlastStatusLine(PaintDC: HDC);
var
  ClientRect: TRect;
  MemDC: HDC;
  OldBmp: THandle;
begin
  GetClientRect(HWindow, ClientRect);
  MemDC := CreateCompatibleDC(PaintDC);
  OldBmp := SelectObject(MemDC, BmpStatusLine);
  with ClientRect do
    BitBlt(PaintDC, 0, Bottom - StatusLineHeight, ClientRect.Right,
      StatusLineHeight, MemDC, 0, 0, SrcCopy);
  SelectObject(MemDC, OldBmp);
  DeleteDC(MemDC);
end;

procedure TRWPWindow.DefCommandProc(var Msg: TMessage);
var
  DC: HDC;
begin
  TMDIWindow.DefCommandProc(Msg);
  if CurrentPopup <> 0 then
  begin
    CurrentPopup := 0;
    CurrentID := 0;
    DC := GetDC(HWindow);
    BlastStatusLine(DC);
    ReleaseDC(HWindow, DC);
  end;
end;

destructor TRWPWindow.Done;
begin
  DeleteObject(BmpStatusLine);
  DeleteObject(BmpStatusBar);
  TMDIWindow.Done;
end;

procedure TRWPWindow.FileNew(var Msg:TMessage);
var
  FileType: Integer;
begin
  if Application^.ExecDialog(New(PFileNew,
    Init(@Self, FileType))) = id_OK then OpenAFile(FileType, nil)
end;

procedure TRWPWindow.FileOpen(var Msg:TMessage);
var
  FileName: array[0..128] of Char;
  FileType: Integer;
begin
  FillChar(Filename, sizeof(FileName), #0);
  StrCopy(Filename, '*.txt');
  FileType := FileWindow;
  if Application^.ExecDialog(New(PFileOpen,
    Init(@Self, FileType, FileName))) = id_OK then
    OpenAFile(FileType,FileName)
end;

procedure TRWPWindow.FilePrint(var Msg:TMessage);
begin
  StubDialog(New(PRWPDialog, Init(@Self,MakeIntResource(dlg_Print))),'Print');
end;

function TRWPWindow.GetClassName: PChar;
begin
  GetClassName := 'RWPWindow';
end;

procedure TRWPWindow.GetWindowClass(var WndClass: TWndClass);
begin
  TMDIWindow.GetWindowClass(WndClass);
  WndClass.HIcon := LoadIcon(HInstance, MakeIntResource(ico_RWPDemo));
  WndClass.HBrBackground := color_AppWorkspace + 1;
end;

procedure TRWPWindow.OpenAFile(FileType: Integer; FileName: PChar);
begin
  with PRWPApplication(Application)^ do
    case FileType of
      ScribbleWindow:
        MakeWindow(new(PScribbleWindow, Init(@Self, FileName)));
      FileWindow:
        MakeWindow(new(PEditWindow, Init(@Self, FileName)));
      GraphWindow:
        MakeWindow(new(PGraphWindow, Init(@Self, FileName)));
    end;
end;

procedure TRWPWindow.OptionsDirectories(var Msg:TMessage);
begin
  StubDialog(new(PDlgDirectories,
    Init(@Self, MakeIntResource(dlg_Options_Directories))), 'Directories');
end;

procedure TRWPWindow.OptionsMouse(var Msg:TMessage);
begin
  StubDialog(new(PRWPDialog,
    Init(@Self, MakeIntResource(dlg_MouseDialog))), 'Mouse');
end;

procedure TRWPWindow.OptionsOpen(var Msg:TMessage);
begin
  StubDialog(new(PRWPDialog,
    Init(@Self, MakeIntResource(dlg_Options_Open))), 'Options Open');
end;

procedure TRWPWindow.OptionsPreferences(var Msg:TMessage);
begin
  StubDialog(new(PRWPDialog,
    Init(@Self, MakeIntResource(dlg_Preferences))), 'Preferences');
end;

procedure TRWPWindow.OptionsSave(Var Msg: TMessage);
begin
  MessageBox(HWindow, 'Feature not implemented', 'Options Save', mb_OK);
end;

procedure TRWPWindow.OptionsSaveAs(var Msg:TMessage);
begin
  StubDialog(new(PRWPDialog,
    Init(@Self,MakeIntResource(dlg_Options_SaveAs))), 'Options SaveAs');
end;

procedure TRWPWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
begin
  TMDIWindow.Paint(PaintDC, PaintInfo);
  BlastStatusLine(PaintDC);
end;

procedure TRWPWindow.StubDialog(ADialog: PRWPDialog; ACaption: PChar);
begin
  if Application^.ExecDialog(ADialog) = id_Ok then
    MessageBox(HWindow, 'Feature not implemented', ACaption, mb_OK);
end;

procedure TRWPWindow.WMDrawStatusLine(var Msg: TMessage);
var
  DC: HDC;
  Rect: TRect;
  Str: array[0..128] of Char;
  StrID: Integer;
  hOld: HFont;
  TextHeight: Integer;
begin
  if CurrentID <> 0 then
  begin
    case CurrentID of
      cm_New: StrID := sth_FileNew;
      cm_Open: StrID := sth_FileOpen;
      cm_Save: StrID := sth_FileSave;
      cm_SaveAs: StrID := sth_FileSaveAs;
      cm_Print: StrID := sth_FilePrint;
      cm_Exit: StrID := sth_FileExit;
      cm_EditUndo: StrID := sth_EditUndo;
      cm_EditCut: StrID := sth_EditCut;
      cm_EditCopy: StrID := sth_EditCopy;
      cm_EditPaste: StrID := sth_EditPaste;
      cm_EditDelete: StrID := sth_EditDelete;
      cm_EditClear: StrID := sth_EditClear;
      cm_Options_Open: StrID := sth_OptionsOpen;
      cm_all: StrID := sth_ViewAll;
      cm_By: StrID := sth_ViewBy;
      cm_Some: StrID := sth_ViewSome;
      cm_Directories: StrID := sth_OptionsDirectory;
      cm_Options_Save: StrID := sth_OptionsSave;
      cm_Options_SaveAs: StrID := sth_OptionsSaveAs;
      cm_Preferences: StrID := sth_EnvironmentPreferences;
      cm_Mouse: StrID := sth_EnvironmentMouse;
      cm_TileChildren: StrID := sth_WindowTile;
      cm_CascadeChildren: StrID := sth_WindowCascade;
      cm_ArrangeIcons: StrID := sth_WindowArrange;
      cm_CloseChildren: StrID := sth_WindowCloseAll;
      cm_Index: StrID := sth_HelpIndex;
      cm_Topic_Search: StrID := sth_HelpTopic;
      cm_Glossary: StrID := sth_HelpGlossary;
      cm_Using_Help: StrID := sth_HelpUsing;
      cm_About_RWP: StrID := sth_HelpAbout;
      else
        Exit;
    end
  end
  else
  if CurrentPopup <> 0 then
  begin
    case GetMenuItemID(CurrentPopup, 0) of
      FileFirst: StrID := sth_File;
      EditFirst: StrID := sth_Edit;
      ViewFirst: StrID := sth_View;
      WindowFirst: StrID := sth_Window;
      OptionFirst: StrID := sth_Option;
      EnvironmentFirst: StrID := sth_OptionsEnvironment;
      HelpFirst: StrID := sth_Help;
      else
        Exit;
    end;
  end;

  DC := GetDC(HWindow);
  BlastStatusLine(DC);
  if (CurrentPopup <> 0) or (CurrentID <> 0) then
  begin
    hOld := SelectObject(DC, GetStockObject(ANSI_VAR_FONT));
    LoadString(HInstance, StrID, Str, Sizeof(Str));
    GetClientRect(HWindow, Rect);
    SetBKColor(DC, RGB(192, 192, 192));
    TextHeight :=  HiWord( GetTextExtent( DC, Str, 1) );
    TextOut(DC, TextStart+10,
      Rect.bottom - StatusLineHeight + ( ( StatusLineHeight - TextHeight ) div 2),
      Str, strlen(Str));
    SelectObject(DC, hOld);
  end;
  ReleaseDC(HWindow, DC);
end;

procedure TRWPWindow.WMMenuSelect(var Msg: TMessage);
begin
  if Msg.LParamLo = $FFFF then
  begin
    CurrentPopup := 0;
    CurrentID := 0;
  end
  else
  if (Msg.LParamLo and mf_Popup) <> 0 then
  begin
   CurrentPopup := Msg.WParam;
    CurrentID := 0;
  end
  else
    CurrentID := Msg.WParam;
  PostMessage(HWindow,am_DrawStatusLine, 0, 0);
end;

procedure TRWPWindow.WMEnterIdle(var Msg: TMessage);
{ If the user pressed the F1 key, and a Dialog box is active (and idle), send
  an ID_Help message to the dialog, to get the behavior associated with
  pressing the help button in that dialog }
begin
 if ( Msg.WParam = Msgf_DialogBox) and ( ( GetKeyState( Vk_F1) and $8000) <> 0) then
   SendMessage( Msg.LParamLo, wm_Command, Id_Help, 0);
end;

procedure TRWPWindow.WMSize(var Msg: TMessage);
var
  Rect: TRect;
begin
  TMDIWindow.WMSize(Msg);
  GetClientRect(HWindow, Rect);
  SetWindowPos(ClientWnd^.HWindow, 0, 0, 0, Rect.Right,
    Rect.Bottom - StatusLineHeight, swp_NoZOrder);
  ReconstructStatusLine;
end;

procedure TRWPWindow.ReconstructStatusLine;
var
  Bmp: HBitmap;
  DC: HDC;
  DestDC: HDC;
  OldSrc: HBitmap;
  OldDest: HBitmap;
  Rect: TRect;
  SrcDC: HDC;
begin
  GetClientRect(HWindow, Rect);
  DC := GetDC(HWindow);
  SrcDC := CreateCompatibleDC(DC);
  DestDC := CreateCompatibleDC(DC);
  ReleaseDC(HWindow, DC);

  Bmp := LoadBitmap(HInstance, MakeIntResource(bmp_StatusLine));
  OldSrc := SelectObject(SrcDC, Bmp);
  if BmpStatusLine <> 0 then
    DeleteObject(BmpStatusLine);
  BmpStatusLine := CreateCompatibleBitmap(DC, Rect.Right, StatusLineHeight);
  OldDest := SelectObject(DestDC, BmpStatusLine);
  BitBlt(DestDC, 0, 0, 5, StatusLineHeight, SrcDC, 0, 0, srcCopy);
  StretchBlt(DestDC, 5, 0, Rect.Right - 5, StatusLineHeight,
             SrcDC, 6, 0, 20, StatusLineHeight, srcCopy);
  BitBlt(DestDC, Rect.Right - 5, 0, 5, StatusLineHeight, SrcDC, 59, 0, srcCopy);

  SelectObject(SrcDC, BmpStatusBar);
  BitBlt(DestDC, 40, 0, 10, StatusLineHeight,
         SrcDC, 0, 0, SrcCopy);
  BitBlt(DestDC, 100, 0, 10, StatusLineHeight,
         SrcDC, 0, 0, SrcCopy);
  BitBlt(DestDC, TextStart, 0, 10, StatusLineHeight,
         SrcDC, 0, 0, SrcCopy);

  SelectObject(SrcDC, OldSrc);
  BmpStatusLine := SelectObject(DestDC, OldDest);
  DeleteDC(SrcDC);
  DeleteDC(DestDC);
  DeleteObject(Bmp);
end;

var
  RWPApp:RWPApplication;

begin
  RWPApp.Init(AppName);
  RWPApp.Run;
  RWPApp.Done;
end.
