{************************************************}
{                                                }
{   ObjectWindows Paint demo                     }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Paint;

{ The main program file for the paint program.

  The paint program is a simple drawing program that demonstrates the
  use of the Object Windows Library (OWL) and of programming with the Windows
  Graphics Device Interface (GDI).
}

uses PaintDef, ResDef, PaintDlg, ToolBar, LineBar, Palette, Canvas,
  WinTypes, WinProcs, OWindows, ODialogs, Strings;

{$R PAINT}

{ Global declarations }
const

  FileNameMax = 80;		{ Max length of file names }

type

  {
    The main drawing window. Responsible for creating and maintaining
    subwindows for tool, color and line selection, and for menu management.
  }
  PPaintWin = ^TPaintWin;
  TPaintWin = object(TWindow)
    State: TState;		{ Drawing state of the program }
    Palette: PPalette;		{ Color palette }
    ToolBar: PToolBar;		{ Palette of available tools }
    LineBar: PLineBar;		{ Palette of available line widths }
    Canvas: PCanvas;		{ Window to actually draw on }
    FileName: array [0..FileNameMax] of Char;
                                { File name associated with current window }
    CBChainNext: HWnd;		{ Next window in the clipboard chain }

    { Creation }
    constructor Init;
    function GetClassName: PChar; virtual;
    procedure GetWindowClass(var WndClass: TWndClass); virtual;
    procedure SetUpWindow; virtual;
    function CanClose: Boolean; virtual;

    { Utility }
    procedure SetNames(NewName: PChar);
    procedure UpdateChildren;

    { Window manager interface routines }
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;
    procedure WMChangeCBChain(var Msg: TMessage);
      virtual wm_First + wm_ChangeCBChain;
    procedure WMDrawClipBoard(var Msg: TMessage);
      virtual wm_First + wm_DrawClipBoard;
    procedure WMDestroy(var Msg: TMessage);
      virtual wm_First + wm_Destroy;

    { Menu routines }
    procedure CMFileNew(var Msg: TMessage);
      virtual cm_First + cm_FileNew;
    procedure CMFileOpen(var Msg: TMessage);
      virtual cm_First + cm_FileOpen;
    procedure CMFileSave(var Msg: TMessage);
      virtual cm_First + cm_FileSave;
    procedure CMFileSaveAs(var Msg: TMessage);
      virtual cm_First + cm_FileSaveAs;

    procedure CMEditUndo(var Msg: TMessage);
      virtual cm_First + cm_EditUndo;
    procedure CMEditCut(var Msg: TMessage);
      virtual cm_First + cm_EditCut;
    procedure CMEditCopy(var Msg: TMessage);
      virtual cm_First + cm_EditCopy;
    procedure CMEditPaste(var Msg: TMessage);
      virtual cm_First + cm_EditPaste;
    procedure CMEditDelete(var Msg: TMessage);
      virtual cm_First + cm_EditDelete;
    procedure CMEditClear(var Msg: TMessage);
      virtual cm_First + cm_EditClear;

    procedure CMOptionsSize(var Msg: TMessage);
      virtual cm_First + cm_OptionsSize;

    procedure CMHelpAbout(var Msg: TMessage);
      virtual cm_First + cm_HelpAbout;
  end;

  {
    A paint application.
  }
  TPaintApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

{ TPaintWin }

{ Create a drawing window, initializing its drawing state and associated
  windows.
}
constructor TPaintWin.Init;
begin
  TWindow.Init(nil, 'Paint');

  { Set up the menu bar }
  Attr.Menu := LoadMenu(HInstance, 'PaintMenu');

  { Initialize the drawing state }
  with State do
  begin
    PaintTool := nil;
    MemDC := 0;
    IsDirtyBitmap := False;
    SetRectEmpty(Selection);
    SelectionBM := 0;
    PenSize := 3;
    PenColor := $000000;
    BrushColor := $FFFFFF;
    BitmapSize.X := 640;
    BitmapSize.Y := 480;
  end;

  { Create the associated windows }
  Palette := New(PPalette, Init(@Self, @State));
  ToolBar := New(PToolBar, Init(@Self, @State));
  LineBar := New(PLineBar, Init(@Self, @State));
  Canvas := New(PCanvas, Init(@Self, @State));

  { Set up the file name }
  FileName[0] := #0;

  CBChainNext := 0;
end;

function TPaintWin.GetClassName: PChar;
begin
  GetClassName := 'TPaintWin';
end;

procedure TPaintWin.GetWindowClass(var WndClass: TWndClass);
begin
  TWindow.GetWindowClass(WndClass);
  WndClass.hbrBackground := color_AppWorkspace + 1;
  WndClass.hIcon := LoadIcon(HInstance, 'PaintIcon');
end;

procedure TPaintWin.SetupWindow;
begin
  TWindow.SetupWindow;
  if IsClipboardFormatAvailable(cf_Bitmap) then
    EnableMenuItem(Attr.Menu, cm_EditPaste, mf_enabled);
  CBChainNext := SetClipBoardViewer(HWindow);
end;

{ Set the name of the file associated with the window and display it in the
  title bar.
}
procedure TPaintWin.SetNames(NewName: PChar);
var
  Name: array[0..FileNameMax + 10] of Char;     { Title bar has 'Paint -'
                                                  prepended }
begin

  { Create name for title bar }
  StrCopy(Name, 'Paint');
  if StrComp(NewName, '') <> 0 then
  begin
    StrCat(Name, ' - ');
    StrCat(Name, NewName);
  end;

  { Set title bar }
  SetCaption(Name);

  { Set file name }
  StrCopy(FileName, NewName);
end;

procedure TPaintWin.UpdateChildren;
var
  S: Integer;			{ Lower coordinates of Palette }
  R: TRect;			{ Window client area }
begin
  GetClientRect(HWindow, R);
  S := ((R.bottom - 8) div 17) * 3 + 1;
  MoveWindow(Palette^.HWindow, 4, 4, S, R.bottom - 8, True);
  MoveWindow(ToolBar^.HWindow, S + 8, 4, (Ord(MaxTool) + 1) * 31 + 1,
    32, True);
  MoveWindow(LineBar^.HWindow, S + (Ord(MaxTool) + 1) * 31 + 13, 4,
    LineBarWidth, 32, True);
  Canvas^.MoveSelf(S + 8, 40, R.Right - S - 12, R.Bottom - 44, True);
end;

{ Window manager interface routines }

{ Resize the window and resize associated windows proportionately.
}
procedure TPaintWin.WMSize(var Msg: TMessage);
begin
  TWindow.WMSize(Msg);
  UpdateChildren;
end;

{ Update the clipboard chain link, or pass down the message.
}
procedure TPaintWin.WMChangeCBChain(var Msg: TMessage);
begin
  if Msg.WParam = CBChainNext then
    CBChainNext := Msg.lParamLo
  else
    if CBChainNext <> 0 then
      SendMessage(CBChainNext, Msg.Message, Msg.WParam, Msg.lParam);
end;

{ Enable/disable menus to reflect a change in the state of the clipboard.
}
procedure TPaintWin.WMDrawClipBoard(var Msg: TMessage);
begin
  if IsClipboardFormatAvailable(cf_Bitmap) then
    EnableMenuItem(Attr.Menu, cm_EditPaste, mf_enabled)
  else
    EnableMenuItem(Attr.Menu, cm_EditPaste, mf_grayed);
  if CBChainNext <> 0 then
    SendMessage(CBChainNext, Msg.Message, 0, 0);
end;

{ Notify the clipboard chain before dying.
}
procedure TPaintWin.WMDestroy(var Msg: TMessage);
begin
  ChangeClipboardChain(HWindow, CBChainNext);
  TWindow.WMDestroy(Msg);
end;


{ File menu functions }
{ Create a new canvas and destroy the old one.
}
procedure TPaintWin.CMFileNew(var Msg: TMessage);
var
  CurA: TWindowAttr;		{ Save the current window attributes }
begin

  { Make sure the current image is saved if desired. }
  if State.IsDirtyBitmap then
    case AskCancel('Save current image?') of
      id_Yes: CMFileSave(Msg);
      id_Cancel: Exit;
    end;

  { Mark the bitmap as unmodified }
  State.IsDirtyBitmap := False;
  CurA := Canvas^.Attr;

  { Destroy the old canvas }
  Canvas^.Done;

  { Create a new one }
  SetNames('');
  Canvas := PCanvas(Application^.MakeWindow(New(PCanvas, Init(@Self,
    @State))));

  { Size the window appropriately }
  UpdateChildren;
end;

{ Read a bitmap from file into the canvas.
}
procedure TPaintWin.CMFileOpen(var msg: TMessage);
var
  FN: array [0..FileNameMax] of Char;		{ The file name }
  Curs: HCursor;
begin

  { Make sure the current image is saved if desired }
  if State.IsDirtyBitmap then
    case AskCancel('Save current image?') of
      id_Yes: CMFileSave(msg);
      id_Cancel: Exit;
    end;

  { Create a mask for the file dialog }
  StrCopy(FN, '*.bmp');

  { Prompt for the file and load the bitmap }
  if FileOpenDialog(FN) then
  begin
    Curs := SetCursor(LoadCursor(0, idc_Wait));
    if (Canvas^.Load(FN) <> 0) then
    begin
      SetNames(FN);
      UpdateChildren;
    end;
    SetCursor(Curs);
  end;
end;

{ Save the current bitmap to file.
}
procedure TPaintWin.CMFileSave(var msg: TMessage);
var Curs: HCursor;		{ The current cursor }
begin
  
  { Make sure there is a file name to be saved to }
  if StrComp(FileName, '') = 0 then
    CMFileSaveAs(msg)
  else
  begin
    { Set the cursor while the file is being written }
    Curs := SetCursor(LoadCursor(0, idc_Wait));
    Canvas^.Store(FileName);
    SetCursor(Curs);
  end;
end;

{ Prompt for a file name then save the current bitmap to that file.
}
procedure TPaintWin.CMFileSaveAs(var msg: TMessage);
var
  FN: array[0..FileNameMax] of Char;    { The file name }
  Curs: HCursor;                       	{ The current cursor }
begin
  { Create a mask for the file dialog }
  StrCopy(FN, '*.bmp');

  { Prompt for the file name }
  if FileSaveDialog(FN) then
  begin
    { Set the cursor while the file is being written }
    Curs := SetCursor(LoadCursor(0, idc_Wait));
    if Canvas^.Store(FN) <> 0 then SetNames(FN);
    SetCursor(Curs);
  end;
end;

{ Make sure the bitmap is saved if desired before dying or cancel if desired.
}
function TPaintWin.CanClose: Boolean;
var Msg: TMessage;			{ Bogus to pass on }
begin
  CanClose := True;
  if State.IsDirtyBitmap then
    case AskCancel('Save current image?') of
      id_Yes: CMFileSave(Msg);
      id_Cancel: CanClose := False;
    end;
end;


{ Edit menu functions }

{ Undo the last change to the bitmap.
}
procedure TPaintWin.CMEditUndo(var Msg: TMessage);
begin
  Canvas^.Undo;
end;

{ Copy the current selection to the clipboard and clear it from the screen.
}
procedure TPaintWin.CMEditCut(var Msg: TMessage);
begin
  Canvas^.Cut;
end;

{ Copy the current selection to the clipboard.
}
procedure TPaintWin.CMEditCopy(var Msg: TMessage);
begin
  Canvas^.Copy;
end;

{ Retrieve the contents of the clipboard and make it the current selection.
}
procedure TPaintWin.CMEditPaste(var Msg: TMessage);
begin
  ToolBar^.ToolSelect(SelectTool);
  Canvas^.Paste;
end;

{ Clear the current selection from the screen.
}
procedure TPaintWin.CMEditDelete(var Msg: TMessage);
begin
  Canvas^.Delete;
end;

{ Clear the entire drawing area.
}
procedure TPaintWin.CMEditClear(var Msg: TMessage);
begin
  Canvas^.ClearAll;
end;

{ Options }
procedure TPaintWin.CMOptionsSize(var Msg: TMessage);
var
  SizeBMInfo: TSizeBMInfo;
begin
  with SizeBMInfo, State do
    begin
      Width := BitmapSize.X;
      Height := BitmapSize.Y;
      CurrentBMFlag := id_PadBM;
    end;
  if Application^.ExecDialog(New(PSizeBMDialog, Init(@Self, 'SizeBMDialog',
    @SizeBMInfo))) = id_OK then
  begin
    with State, SizeBMInfo do
    begin
      BitmapSize.X := Width;
      BitmapSize.Y := Height;
    end;
    Canvas^.Resize(SizeBMInfo.CurrentBMFlag);
    WMSize(Msg);
  end;
end;
  

{ Help }
{ Display the 'About Box'.
}
procedure TPaintWin.CMHelpAbout(var Msg: TMessage);
begin
  Application^.ExecDialog(New(PDialog, Init(@Self, 'AboutDialog')));
end;

{ TPaintApp }

{ Create the main window for the paint application.
}
procedure TPaintApp.InitMainWindow;
begin
  MainWindow := New(PPaintWin, Init);
end;

var
  PaintApp: TPaintApp;

begin
  PaintApp.Init('Paint');
  PaintApp.Run;
  PaintApp.Done;
end.
