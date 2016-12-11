{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program InitResTest;

uses WinTypes, WinProcs, OWindows, ODialogs;

const
  id_LB1 = 101;

type
  TestApplication = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

  PTestWindow = ^TestWindow;

  TestWindow = object(TWindow)
    LB1: PListBox;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    procedure SetupWindow; virtual;
    procedure HandleListBoxMsg(var Msg: TMessage);
      virtual id_First + id_LB1;
  end;

{ --------TestWindow methods------------------ }
constructor TestWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  inherited Init(AParent, ATitle);
  LB1 := new(PListBox, Init(@Self, id_LB1, 20, 20, 340, 100));
end;

procedure TestWindow.SetupWindow;
begin
  inherited SetupWindow;
  LB1^.AddString('Item 1');
  LB1^.AddString('Item 2');
  LB1^.AddString('Item 3');
  LB1^.InsertString('Item 1.5', 1);
  LB1^.AddString('Item 4');
  LB1^.AddString('Item 5');
  LB1^.AddString('Item 6');
end;

procedure TestWindow.HandleListBoxMsg(var Msg: TMessage);
var
  Idx: Integer;
  ItemText: array[0..10] of Char;
begin
  if Msg.LParamHi = lbn_SelChange then
  begin
    Idx := LB1^.GetSelIndex;
    if LB1^.GetStringLen(Idx) < 11 then
    begin
      LB1^.GetSelString(ItemText, 10);
      MessageBox(HWindow, ItemText, 'You selected:', mb_OK);
    end;
  end
  else DefWndProc(Msg);
end;

{ -----------TestApplication Methods------------ }
procedure TestApplication.InitMainWindow;
begin
  MainWindow := New(PTestWindow, Init(nil, 'List Box Tester'));
end;

var
  TestApp : TestApplication;

begin
  TestApp.Init('LBoxTest');
  TestApp.Run;
  TestApp.Done;
end.

