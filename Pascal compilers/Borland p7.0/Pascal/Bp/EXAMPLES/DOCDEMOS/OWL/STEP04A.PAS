{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{$R-} { Turn off range check because Windows message parameters
        don't distinguish between Integer and Word. }

program Step04a;

uses Strings, WinTypes, WinProcs, OWindows, OStdDlgs;

{$R STEPS.RES}

{$I STEPS.INC}

type
  PStepWindow = ^TStepWindow;
  TStepWindow = object(TWindow)
    DragDC: HDC;
    ButtonDown, HasChanged: Boolean;
    ThePen: HPen;
    PenSize: Integer;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    destructor Done; virtual;
    function CanClose: Boolean; virtual;
    procedure CMFileNew(var Msg: TMessage);
      virtual cm_First + cm_FileNew;
    procedure CMFileOpen(var Msg: TMessage);
      virtual cm_First + cm_FileOpen;
    procedure CMFileSave(var Msg: TMessage);
      virtual cm_First + cm_FileSave;
    procedure CMFileSaveAs(var Msg: TMessage);
      virtual cm_First + cm_FileSaveAs;
    procedure CMFilePrint(var Msg: TMessage);
      virtual cm_First + cm_FilePrint;
    procedure CMFileSetup(var Msg: TMessage);
      virtual cm_First + cm_FileSetup;
    procedure SetPenSize(NewSize: Integer);
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMLButtonUp(var Msg: TMessage);
      virtual wm_First + wm_LButtonUp;
    procedure WMMouseMove(var Msg: TMessage);
      virtual wm_First + wm_MouseMove;
    procedure WMRButtonDown(var Msg: TMessage);
      virtual wm_First + wm_RButtonDown;
  end;
  TMyApplication = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

constructor TStepWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  inherited Init(AParent, ATitle);
  Attr.Menu := LoadMenu(HInstance, MakeIntResource(100));
  HasChanged := False;
  ButtonDown := False;
  PenSize := 1;
  ThePen := CreatePen(ps_Solid, PenSize, 0);
end;

destructor TStepWindow.Done;
begin
  DeleteObject(ThePen);
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

procedure TStepWindow.CMFileNew(var Msg: TMessage);
begin
  InvalidateRect(HWindow, nil, True);
end;

procedure TStepWindow.CMFileOpen(var Msg: TMessage);
begin
  MessageBox(HWindow, 'Feature not implemented.', 'File Open', mb_OK);
end;

procedure TStepWindow.CMFileSave(var Msg: TMessage);
begin
  MessageBox(HWindow, 'Feature not implemented.', 'File Save', mb_OK);
end;

procedure TStepWindow.CMFileSaveAs(var Msg: TMessage);
begin
  MessageBox(HWindow, 'Feature not implemented.', 'File Save As', mb_OK);
end;

procedure TStepWindow.CMFilePrint(var Msg: TMessage);
begin
  MessageBox(HWindow, 'Feature not implemented.', 'File Print', mb_OK);
end;

procedure TStepWindow.CMFileSetup(var Msg: TMessage);
begin
  MessageBox(HWindow, 'Feature not implemented.', 'Printer Setup', mb_OK);
end;

procedure TStepWindow.SetPenSize(NewSize: Integer);
begin
  DeleteObject(ThePen);
  ThePen := CreatePen(ps_Solid, NewSize, 0);
  PenSize := NewSize;
end;

procedure TStepWindow.WMLButtonDown(var Msg: TMessage);
begin
  if not ButtonDown then
  begin
    ButtonDown := True;
    SetCapture(HWindow);
    DragDC := GetDC(HWindow);
    SelectObject(DragDC, ThePen);
    MoveTo(DragDC, Msg.LParamLo, Msg.LParamHi);
  end;
end;

procedure TStepWindow.WMLButtonUp(var Msg: TMessage);
begin
  if ButtonDown then
  begin
    ButtonDown := False;
    ReleaseCapture;
    ReleaseDC(HWindow, DragDC);
  end;
end;

procedure TStepWindow.WMMouseMove(var Msg: TMessage);
begin
  if ButtonDown then LineTo(DragDC, Msg.LParamLo, Msg.LParamHi);
end;

procedure TStepWindow.WMRButtonDown(var Msg: TMessage);
var
  InputText: array[0..5] of Char;
  NewSize, ErrorPos: Integer;
begin
  if not ButtonDown then
  begin
    Str(PenSize, InputText);
    if Application^.ExecDialog(New(PInputDialog,
      Init(@Self, 'Line Width', 'Type a new line width:',
      InputText, SizeOf(InputText)))) = id_OK then
    begin
      Val(InputText, NewSize, ErrorPos);
      if ErrorPos = 0 then SetPenSize(NewSize);
    end;
  end;
end;

procedure TMyApplication.InitMainWindow;
begin
  MainWindow := New(PStepWindow, Init(nil, 'Steps'));
end;

var
  MyApp: TMyApplication;

begin
  MyApp.Init('Steps');
  MyApp.Run;
  MyApp.Done;
end.