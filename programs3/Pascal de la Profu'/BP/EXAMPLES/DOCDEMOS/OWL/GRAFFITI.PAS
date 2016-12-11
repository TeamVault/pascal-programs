{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{$R-} { Turn off range check because Windows message parameters
        don't distinguish between Integer and Word. }

program Graffiti;

{$M 8192, 16384}

uses Strings, WinTypes, WinProcs, WinDos, Objects, OWindows, ODialogs,
  OStdDlgs, PenPal, GrafLine, Pen, OPrinter, BWCC;

{$R GRAFFITI.RES}

{$I GRAFFITI.INC}

type
  TMyApplication = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

  PGrafWindow = ^TGrafWindow;
  TGrafWindow = object(TMDIWindow)
    constructor Init(ATitle: PChar; AMenu: HMenu);
    procedure CMAbout(var Msg: TMessage);
      virtual cm_First + cm_About;
    function InitChild: PWindowsObject; virtual;
    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
  end;

  PStepWindow = ^TStepWindow;
  TStepWindow = object(TWindow)
    DragDC: HDC;
    ButtonDown: Boolean;
    FileName: array[0..fsPathName] of Char;
    HasChanged, IsNewFile: Boolean;
    Drawing: PCollection;
    CurrentLine: PLine;
    ThePen: PPen;
    PenPalette: PPenPalette;
    Printer: PPrinter;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    destructor Done; virtual;
    function CanClose: Boolean; virtual;
    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMLButtonUp(var Msg: TMessage);
      virtual wm_First + wm_LButtonUp;
    procedure WMMouseMove(var Msg: TMessage);
      virtual wm_First + wm_MouseMove;
    procedure WMRButtonDown(var Msg: TMessage);
      virtual wm_First + wm_RButtonDown;
    procedure WMMDIActivate(var Msg: TMessage);
      virtual wm_First + wm_MDIActivate;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure FileNew(var Msg: TMessage);
      virtual cm_First + cm_New;
    procedure FileOpen(var Msg: TMessage);
      virtual cm_First + cm_Open;
    procedure FileSave(var Msg: TMessage);
      virtual cm_First + cm_Save;
    procedure FileSaveAs(var Msg: TMessage);
      virtual cm_First + cm_SaveAs;
    procedure LoadFile;
    procedure SaveFile;
    procedure CMPen(var Msg: TMessage);
      virtual cm_First + cm_Pen;
    procedure CMPrint(var Msg: TMessage);
      virtual cm_First + cm_Print;
    procedure CMSetup(var Msg: TMessage);
      virtual cm_First + cm_Setup;
    procedure CMShowPal(var Msg: TMessage);
      virtual cm_First + cm_ShowPal;
    procedure CMHidePal(var Msg: TMessage);
      virtual cm_First + cm_HidePal;
    procedure CMUndo(var Msg: TMessage);
      virtual cm_First + cm_Undo;
  end;

procedure StreamRegistration;
begin
  RegisterType(RCollection);
end;

{--------------------------------------------------}
{ TStepWindow's method implementations:            }
{--------------------------------------------------}

constructor TStepWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  inherited Init(AParent, ATitle);
  EnableAutoCreate;
  Attr.Menu := LoadMenu(HInstance, MakeIntResource(100));
  ButtonDown := False;
  ThePen := New(PPen, Init(ps_Solid, 1, RGB(0, 0, 0)));
  Drawing := New(PCollection, Init(50, 50));
  HasChanged := False;
  IsNewFile := True;
  PenPalette := New(PPenPalette, Init(@Self, 'Pen Palette', ThePen));
  Printer := New(PPrinter, Init);
  Scroller := New(PScroller, Init(@Self, 10, 10, 640, 480));
  with Scroller^ do
  begin
    HasHScrollBar := True;
    HasVScrollBar := True;
  end;
end;

destructor TStepWindow.Done;
begin
  Dispose(Drawing, Done);
  Dispose(ThePen, Done);
  inherited Done;
end;

function TStepWindow.CanClose: Boolean;
var
  Reply: Integer;
begin
  CanClose := True;
  if HasChanged then
  begin
    Reply := MessageBox(HWindow, 'Do you want to save?',
      'Drawing has changed', mb_YesNo or mb_IconQuestion);
    if Reply = id_Yes then CanClose := False;
  end;
end;

procedure TStepWindow.GetWindowClass(var AWndClass: TWndClass);
begin
  inherited GetWindowClass(AWndClass);
  AWndClass.hIcon := LoadIcon(HInstance, 'STEPICON');
end;

procedure TStepWindow.WMLButtonDown(var Msg: TMessage);
begin
  if not ButtonDown then
  begin
    HasChanged := True;
    ButtonDown := True;
    SetCapture(HWindow);
    DragDC := GetDC(HWindow);
    ThePen^.Select(DragDC);
    MoveTo(DragDC, Msg.LParamLo, Msg.LParamHi);
    CurrentLine := New(PLine, Init(ThePen));
    Drawing^.Insert(CurrentLine);
  end;
  inherited WMLButtonDown(Msg);
end;

procedure TStepWindow.WMMouseMove(var Msg: TMessage);
begin
  if ButtonDown then
  begin
    LineTo(DragDC, Integer(Msg.LParamLo), Integer(Msg.LParamHi));
    CurrentLine^.AddPoint(Scroller^.XPos + Msg.LParamLo, Scroller^.YPos + Msg.LParamHi);
  end;
end;

procedure TStepWindow.WMLButtonUp(var Msg: TMessage);
begin
  if ButtonDown then
  begin
    CurrentLine^.AddPoint(Scroller^.XPos + Msg.LParamLo, Scroller^.YPos + Msg.LParamHi);
    ButtonDown := False;
    ReleaseCapture;
    ReleaseDC(HWindow, DragDC);
  end;
end;

procedure TStepWindow.WMRButtonDown(var Msg: TMessage);
begin
  ThePen^.ChangePen;
end;

procedure TStepWindow.WMMDIActivate(var Msg: TMessage);
begin
  if Msg.wParam = 0 then PenPalette^.Show(sw_Hide)
  else PenPalette^.Show(sw_ShowNA);
end;

procedure TStepWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);

  procedure DrawIt(P: PLine); far;
  begin
    P^.Draw(PaintDC);
  end;

begin
 Drawing^.ForEach(@DrawIt);
end;

procedure TStepWindow.CMPen(var Msg: TMessage);
begin
  ThePen^.ChangePen;
end;

procedure TStepWindow.FileNew(var Msg: TMessage);
begin
  Drawing^.FreeAll;
  InvalidateRect(HWindow, nil, True);
  HasChanged := False;
  IsNewFile := True;
end;

procedure TStepWindow.FileOpen(var Msg: TMessage);
begin
  if CanClose then
    if Application^.ExecDialog(New(PFileDialog,
        Init(@Self, MakeIntResource(sd_FileOpen),
        StrCopy(FileName,'*.PTS')))) = id_Ok then
      LoadFile;
end;

procedure TStepWindow.FileSave(var Msg: TMessage);
begin
  if IsNewFile then FileSaveAs(Msg) else SaveFile;
end;

procedure TStepWindow.FileSaveAs(var Msg: TMessage);
var
  FileDlg: PFileDialog;
begin
  if IsNewFile then StrCopy(FileName, '');
  if Application^.ExecDialog(New(PFileDialog,
    Init(@Self, MakeIntResource(sd_FileSave), FileName))) = id_Ok then SaveFile;
end;

procedure TStepWindow.LoadFile;
var
  TempColl: PCollection;
  TheFile: TDosStream;
begin
  TheFile.Init(FileName, stOpen);
  TempColl := PCollection(TheFile.Get);
  TheFile.Done;
  if TempColl <> nil then
  begin
    Dispose(Drawing, Done);
    Drawing := TempColl;
    InvalidateRect(HWindow, nil, True);
  end;
  HasChanged := False;
  IsNewFile := False;
end;

procedure TStepWindow.SaveFile;
var
  TheFile: TDosStream;
begin
  TheFile.Init(FileName, stCreate);
  TheFile.Put(Drawing);
  TheFile.Done;
  IsNewFile := False;
  HasChanged := False;
end;

procedure TStepWindow.CMPrint(var Msg: TMessage);
var
  P: PPrintOut;
begin
  if IsNewFile then StrCopy(FileName, 'Untitled');
  P := New(PWindowPrintout, Init(FileName, @Self));
  Printer^.Print(@Self, P);
  Dispose(P, Done);
end;

procedure TStepWindow.CMSetup(var Msg: TMessage);
begin
  Printer^.Setup(@Self);
end;

procedure TStepWindow.CMShowPal(var Msg: TMessage);
begin
  PenPalette^.Show(sw_ShowNA);
end;

procedure TStepWindow.CMHidePal(var Msg: TMessage);
begin
  PenPalette^.Show(sw_Hide);
end;

procedure TStepWindow.CMUndo(var Msg: TMessage);
begin
  with Drawing^ do if Count > 0 then AtFree(Count - 1);
  InvalidateRect(HWindow, nil, True);
end;

{--------------------------------------------------}
{ TGrafWindow's method implementations:            }
{--------------------------------------------------}

constructor TGrafWindow.Init(ATitle: PChar; AMenu: HMenu);
begin
  inherited Init(ATitle, AMenu);
  ChildMenuPos := 3;
  StreamRegistration;
end;

procedure TGrafWindow.CMAbout(var Msg: TMessage);
begin
  Application^.ExecDialog(New(PDialog, Init(@Self, 'ABOUTBOX')));
end;

function TGrafWindow.InitChild: PWindowsObject;
begin
  InitChild := New(PStepWindow, Init(@Self, 'Untitled'));
end;

procedure TGrafWindow.GetWindowClass(var AWndClass: TWndClass);
begin
  inherited GetWindowClass(AWndClass);
  AWndClass.hIcon := LoadIcon(HInstance, 'GrafIcon');
end;

{--------------------------------------------------}
{ TMyApplication's method implementations:         }
{--------------------------------------------------}

procedure TMyApplication.InitMainWindow;
begin
  MainWindow := New(PGrafWindow, Init('Graffiti',
    LoadMenu(HInstance, MakeIntResource(100))));
end;

{--------------------------------------------------}
{ Main program:                                    }
{--------------------------------------------------}

var
  MyApp: TMyApplication;

begin
  MyApp.Init('Graffiti');
  MyApp.Run;
  MyApp.Done;
end.
