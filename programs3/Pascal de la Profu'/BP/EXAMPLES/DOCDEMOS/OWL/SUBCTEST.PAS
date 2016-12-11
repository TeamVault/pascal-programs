{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program SubClassTest;

{$R DIALTEST.RES}

uses WinTypes, WinProcs, Strings, OWindows, ODialogs;

const
  TheMenu     = 100;
  id_BeepBN   = 102;
  id_Stat     = 104;
  cm_DialTest = 101;

type

  {--------------------------------------------------}
  { Define a button object type for association      }
  {--------------------------------------------------}
  PTestSCButton = ^TTestSCButton;
  TTestSCButton = object(TButton)
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
  end;

  PTestDialog = ^TTestDialog;
  TTestDialog = object(TDialog)
    NumClicks: Integer;
    GButton: PTestSCButton;
    constructor Init(AParent: PWindowsObject; AName: PChar);
    procedure IDBeepBN(var Msg: TMessage); virtual id_First + id_BeepBN;
  end;

  PTestWindow = ^TTestWindow;
  TTestWindow = object(TWindow)
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    procedure CMDialTest(var Msg: TMessage); virtual cm_First + cm_DialTest;
  end;

  TDlgApplication = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

{--------------------------------------------------}
{ TTestDialog method implementations:              }
{--------------------------------------------------}

constructor TTestDialog.Init(AParent: PWindowsObject; AName: PChar);
begin
  inherited Init(AParent, AName);
  GButton := New(PTestSCButton, InitResource(@Self, id_BeepBN));
  NumClicks := 0;
end;

procedure TTestDialog.IDBeepBN(var Msg: TMessage);
var
  Text : array[0..3] of Char;
begin
  Inc(NumClicks);
  Str(NumClicks, Text);
  SetWindowText(GetItemHandle(id_Stat), @Text);
end;

{--------------------------------------------------}
{ TTestWindow method implementations:              }
{--------------------------------------------------}

constructor TTestWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  TWindow.Init(AParent, ATitle);
  Attr.Menu := LoadMenu(HInstance, MakeIntResource(TheMenu));
end;

procedure TTestWindow.CMDialTest(var Msg: TMessage);
var
  TestDlg: PTestDialog;
begin
  Application^.ExecDialog(New(PTestDialog, Init(@Self, 'SUBCLASS_DLG')));
end;

{--------------------------------------------------}
{ TTestSCButton method implementations:            }
{--------------------------------------------------}

procedure TTestSCButton.WMLButtonDown(var Msg: TMessage);
begin
  MessageBeep(0);
  DefWndProc(Msg);
end;

{--------------------------------------------------}
{ TDlgApplication method implementations:          }
{--------------------------------------------------}

procedure TDlgApplication.InitMainWindow;
begin
  MainWindow := New(PTestWindow, Init(nil, 'SubClass Tester'));
end;

{--------------------------------------------------}
{ Main program:                                    }
{--------------------------------------------------}

var
  MyApp: TDlgApplication;
begin
  MyApp.Init('SubClassTest');
  MyApp.Run;
  MyApp.Done;
end.
