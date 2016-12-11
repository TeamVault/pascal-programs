{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program CBoxTest;

uses WinTypes, WinProcs, OWindows, ODialogs;
        
const
  id_LB1 = 101;
  id_CB1 = 102;
  id_CB2 = 103;
  id_CB3 = 104;
  id_BN1 = 105;
  id_BN2 = 106;
  id_ST1 = 107;
  id_ST2 = 108;
  id_ST3 = 109;
  id_ST4 = 110;

type
  TestApplication = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

  PTestWindow = ^TestWindow;
  TestWindow = object(TWindow)
    LB1: PListBox;
    CB1, CB2, CB3: PComboBox;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    procedure SetupWindow; virtual;
    procedure IDBN1(var Msg: TMessage); virtual id_First + id_BN1;
    procedure IDBN2(var Msg: TMessage); virtual id_First + id_BN2;
  end;

{--------------------------------------------------}
{ TestWindow's method implementations:             }
{--------------------------------------------------} 

constructor TestWindow.Init(AParent: PWindowsObject; ATitle: PChar);
var
  ABtn : PButton;
  AStat : PStatic;
begin
  inherited Init(AParent, ATitle);
  LB1 := New(PListBox, Init(@Self, id_LB1, 20, 30, 150, 100));
  CB1 := New(PComboBox, Init(@Self, id_CB1, 190, 30, 150, 100, cbs_Simple, 0));
  CB1^.Attr.Style := CB1^.Attr.Style and not ws_VScroll;
  CB2 := New(PComboBox, Init(@Self, id_CB2, 20, 160, 150, 100, cbs_DropDown, 0));
  CB3 := New(PComboBox, Init(@Self, id_CB3, 190, 160, 150, 100, cbs_DropDownList, 0));
  ABtn := New(PButton, Init(@Self, id_BN1, 'Show', 190, 270, 65, 20, False));
  ABtn := New(PButton, Init(@Self, id_BN2, 'Hide', 275, 270, 65, 20, False));
  AStat := New(PStatic, Init(@Self, id_ST1, 'List Box', 20, 8, 150, 20, 0));
  AStat := New(PStatic, Init(@Self, id_ST2, 'Simple Combo', 190, 8, 150, 20, 0));
  AStat := New(PStatic, Init(@Self, id_ST3, 'Drop Down Combo', 20, 138, 150, 20, 0));
  AStat := New(PStatic, Init(@Self, id_ST4, 'Drop Down List Combo', 190, 138, 150, 20, 0));
end;

procedure TestWindow.SetupWindow;
begin
  inherited SetupWindow;
  LB1^.AddString('a');
  LB1^.AddString('b');
  LB1^.AddString('c');
  LB1^.AddString('d');
  LB1^.AddString('e');
  LB1^.AddString('f');
  
  CB1^.AddString('a');
  CB1^.AddString('b');
  CB1^.AddString('c');
  CB1^.AddString('d');
  CB1^.AddString('e');
  CB1^.AddString('f');

  CB2^.AddString('a');
  CB2^.AddString('b');
  CB2^.AddString('c');
  CB2^.AddString('d');
  CB2^.AddString('e');
  CB2^.AddString('f');

  CB3^.AddString('a');
  CB3^.AddString('b');
  CB3^.AddString('c');
  CB3^.AddString('d');
  CB3^.AddString('e');
  CB3^.AddString('f');
end;

procedure TestWindow.IDBN1(var Msg: TMessage);
begin
  { Respond to the 'Show' button being pressed. }
  CB3^.ShowList;
end;

procedure TestWindow.IDBN2(var Msg: TMessage);
begin
  { Respond to the 'Hide' button being pressed. }
  CB3^.HideList;
end;

{--------------------------------------------------}
{ TestApplication's method implementations:        }
{--------------------------------------------------} 

procedure TestApplication.InitMainWindow;
begin
  MainWindow := New(PTestWindow, Init(nil, 'Combo Box Tester'));
end;

{--------------------------------------------------}
{ Main program:                                    }
{--------------------------------------------------} 

var
  TestApp : TestApplication;
begin
  TestApp.Init('CBoxTest');
  TestApp.Run;
  TestApp.Done;
end.
