{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program DialTest;

{$R DIALTEST.RES}
         
uses WinTypes, WinProcs, OWindows, ODialogs;

const
  TheMenu     = 100;
  id_LB1      = 151;
  id_BN1      = 152;
  cm_DialTest = 101;

type
  PTestDialog = ^TTestDialog;
  TTestDialog = object(TDialog)
    procedure IDBN1(var Msg: TMessage); virtual id_First + id_BN1;
    procedure IDLB1(var Msg: TMessage); virtual id_First + id_LB1;
  end;

  PTestWindow = ^TTestWindow;
  TTestWindow = object(TWindow)
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    procedure CMDialTest(var Msg: TMessage); virtual cm_First + cm_DialTest;
  end;

  TDlgApplication = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

{ TTestDialog }
procedure TTestDialog.IDBN1(var Msg: TMessage);
var
  TextItem : PChar;
begin
  TextItem := 'Item 1';
  SendDlgItemMsg(id_LB1, lb_AddString, 0, Longint(TextItem));
  TextItem := 'Item 2';
  SendDlgItemMsg(id_LB1, lb_AddString, 0, Longint(TextItem));
  TextItem := 'Item 3';
  SendDlgItemMsg(id_LB1, lb_AddString, 0, Longint(TextItem));
  TextItem := 'Item 4';
  SendDlgItemMsg(id_LB1, lb_AddString, 0, Longint(TextItem));
  TextItem := 'Item 5';
  SendDlgItemMsg(id_LB1, lb_AddString, 0, Longint(TextItem));
  TextItem := 'Item 6';
  SendDlgItemMsg(id_LB1, lb_AddString, 0, Longint(TextItem));
  TextItem := 'Item 7';
  SendDlgItemMsg(id_LB1, lb_AddString, 0, Longint(TextItem));
end;

procedure TTestDialog.IDLB1(var Msg: TMessage);
var
  Idx: Integer;
  SelectedText: array[0..10] of Char;
begin
  if Msg.LParamHi = lbn_SelChange then
  begin
    Idx := SendDlgItemMsg(id_LB1, lb_GetCurSel, 0, Longint(0));
    SendDlgItemMsg(id_LB1, lb_GetText, Idx, Longint(@SelectedText));
    MessageBox(HWindow, SelectedText, 'List Box Notification', MB_OK);
  end;
end;

{ TTestWindow }
constructor TTestWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  inherited Init(AParent, ATitle);
  Attr.Menu := LoadMenu(Hinstance, MakeIntResource(TheMenu));
end;

procedure TTestWindow.CMDialTest(var Msg: TMessage);
begin
  Application^.ExecDialog(New(PTestDialog, Init(@Self, 'DIAL1')));
end;

{ TDlgApplication }
procedure TDlgApplication.InitMainWindow;
begin
  MainWindow := New(PTestWindow, Init(nil, 'Dialog Tester'));
end;

var
  MyApp: TDlgApplication;
begin
  MyApp.Init('DialTest');
  MyApp.Run;
  MyApp.Done;
end.
