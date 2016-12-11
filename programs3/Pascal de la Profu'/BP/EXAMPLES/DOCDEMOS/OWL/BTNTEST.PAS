{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program BtnTest;

uses WinTypes, WinProcs, OWindows, ODialogs;
         
const
  id_Push1  = 101;
  id_Rad1   = 102;
  id_Rad2   = 103;
  id_Check1 = 104;
  id_Group1 = 105;

type
  TestApplication = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

  PTestWindow = ^TestWindow;

  TestWindow = object(TWindow)
    Rad1, Rad2: PRadioButton;
    Check1: PCheckBox;
    Group1: PGroupBox;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    procedure HandlePush1Msg(var Msg: TMessage);
      virtual id_First + id_Push1;
    procedure HandleCheck1Msg(var Msg: TMessage);
      virtual id_First + id_Check1;
    procedure HandleGroup1Msg(var Msg: TMessage);
      virtual id_First + id_Group1;
  end;

{ --------TestWindow methods------------------ }
constructor TestWindow.Init(AParent: PWindowsObject; ATitle: PChar);
var
  AButt: PButton;
begin
  inherited Init(AParent, ATitle);
  AButt := New(PButton, Init(@Self, id_Push1, 'State of Check Box',
    88, 48, 296, 24, False));
  Check1 := New(PCheckBox, Init(@Self, id_Check1, 'Check Box Text',
    158, 12, 150, 26, nil));
  Group1 := New(PGroupBox, Init(@Self, id_Group1, 'Group Box',
    158, 102, 176, 108));
  Rad1 := New(PRadioButton, Init(@Self, id_Rad1, 'Radio Button 1',
    174, 128, 138, 24, Group1));
  Rad2 := New(PRadioButton, Init(@Self, id_Rad2, 'Radio Button 2',
    174, 162, 138, 24, Group1));
end;

procedure TestWindow.HandlePush1Msg(var Msg: TMessage);
begin
  if Check1^.GetCheck = bf_Unchecked then
  MessageBox(HWindow, 'Unchecked', 'The check box is:', MB_OK)
  else MessageBox(HWindow, 'Checked', 'The check box is:', MB_OK);
end;

procedure TestWindow.HandleCheck1Msg(var Msg: TMessage);
begin
  MessageBox(HWindow, 'Toggled', 'The check box has been:', MB_OK)
end;

procedure TestWindow.HandleGroup1Msg(var Msg: TMessage);
var
  TextBuff: array[0..20] of Char;
begin
  if Rad1^.GetCheck <> bf_Unchecked
  then GetWindowText(Rad1^.HWindow, TextBuff, SizeOf(TextBuff))
  else GetWindowText(Rad2^.HWindow, TextBuff, SizeOf(TextBuff));
  MessageBox(HWindow, TextBuff, 'You have selected:', MB_OK);
end;

{ -----------TestApplication Methods------------ }
procedure TestApplication.InitMainWindow;
begin
  MainWindow := New(PTestWindow, Init(nil, 'Button Tester'));
end;
 
var
  TestApp : TestApplication;

begin
  TestApp.Init('ButtonTest');
  TestApp.Run;
  TestApp.Done;
end.
