{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program EditTest;

{$R EDITTEST.RES}

uses WinTypes, WinProcs, OWindows, ODialogs;
         
const
  id_EC1 = 101;
  id_EC2 = 102;
  id_BN1 = 103;
  id_ST1 = 104;
  id_ST2 = 105;
 
type
  TestApplication = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

  PTestWindow = ^TestWindow;
  TestWindow = object(TWindow)
    EC1, EC2: PEdit;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    procedure HandleBN1Msg(var Msg: TMessage);
      virtual id_First + id_BN1;
  end;

{ --------TestWindow methods------------------ }
constructor TestWindow.Init(AParent: PWindowsObject; ATitle: PChar);
var
  AStat : PStatic;
  ABtn : PButton;
begin
  inherited Init(AParent, ATitle);
  Attr.Menu := LoadMenu(HInstance, MakeIntResource(100));
  EC1 := New(PEdit,
    Init(@Self, id_EC1, 'Default Text', 20, 50, 150, 30, 0, False));
  EC2 := New(PEdit, Init(@Self, id_EC2, '', 260, 50, 150, 30, 0, False));
  EC2^.Attr.Style := EC2^.Attr.Style or es_UpperCase;
  ABtn := New(PButton, Init(@Self, id_BN1, '-->', 190, 50, 50, 30, False));
  AStat := New(PStatic, Init(@Self, id_ST1, 'Original:', 20, 30, 150, 20, 0));
  AStat := New(PStatic, Init(@Self, id_ST2, 'Copy:', 260, 30, 150, 20, 0));
end;

procedure TestWindow.HandleBN1Msg(var Msg: TMessage);
var
  StartPos, EndPos: Integer;
  TheText: array[0..20] of Char;
begin
  EC1^.GetSelection(StartPos, EndPos);
  if StartPos = EndPos then
  EC1^.GetText(TheText, 20)
  else EC1^.GetSubText(TheText, StartPos, EndPos);
  EC2^.SetText(TheText);
end;

{ -----------TestApplication Methods------------ }
procedure TestApplication.InitMainWindow;
begin
  MainWindow := New(PTestWindow, Init(nil, 'Edit Control Tester'));
end;

var
  TestApp : TestApplication;

begin
  TestApp.Init('EditTest');
  TestApp.Run;
  TestApp.Done;
end.
