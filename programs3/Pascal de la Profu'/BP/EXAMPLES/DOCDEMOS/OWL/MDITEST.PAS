{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program MDITest;

{$R MDITEST.RES}

uses WinTypes, WinProcs, Strings, OWindows, ODialogs;

const
  cm_CountChildren = 102;
  id_CantClose = 201;

type
  TMDIApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

  PMyMDIChild = ^TMyMDIChild;
  TMyMDIChild = object(TWindow)
    Num: Integer;
    CanCloseCheckBox: PCheckBox;
    constructor Init(AParent: PWindowsObject; ChildNum: Integer);
    procedure SetupWindow; virtual;
    function CanClose: Boolean; virtual;
  end;

  PMyMDIWindow = ^TMyMDIWindow;
  TMyMDIWindow = object(TMDIWindow)
    procedure SetupWindow; virtual;
    function CreateChild: PWindowsObject; virtual;
    function GetChildCount: Integer;
    procedure CMCountChildren(var Msg: TMessage);
      virtual cm_First + cm_CountChildren;
  end;

{ TMyMDIChild's constructor instantiates a checkbox }
constructor TMyMDIChild.Init(AParent: PWindowsObject; ChildNum: Integer);
var
  TitleStr: array[0..12] of Char;
  ChildNumStr: array[0..5] of Char;
begin
  Str(ChildNum, ChildNumStr);
  StrCat(StrECopy(TitleStr, 'Child #'), ChildNumStr);
  inherited Init(AParent, TitleStr);
  Num := ChildNum;
  New(CanCloseCheckBox, Init(@Self, id_CantClose, 'Can Close', 10, 10,
    200, 20, nil));
end;

{ Check the checkbox by default }
procedure TMyMDIChild.SetupWindow;
begin
  inherited SetupWindow;
  CanCloseCheckBox^.Check;
end;

{ CanClose is dependent upon the state of the checkbox }
function TMyMDIChild.CanClose;
begin
  CanClose := CanCloseCheckBox^.GetCheck = bf_Checked;
end;

{ SetupWindow creates the first MDI child }
procedure TMyMDIWindow.SetupWindow;
var
  ARect: TRect;
  NewChild: PMyMDIChild;
begin
  inherited SetupWindow;
  CreateChild;
end;


{ Create a new MDI child }
function TMyMDIWindow.CreateChild: PWindowsObject;
var
  ChildNum: Integer;

  function NumberUsed(P: PMyMDIChild): Boolean; far;
  begin
    NumberUsed := ChildNum = P^.Num;
  end;

begin
  ChildNum := 1;
  while FirstThat(@NumberUsed) <> nil do Inc(ChildNum);
  CreateChild := Application^.MakeWindow(New(PMyMDIChild,
    Init(@Self, ChildNum)));
end;

{ Return a count of the MDI children }
function TMyMDIWindow.GetChildCount: Integer;
var
  Count: Integer;

  procedure CountChild(AChild: PWindowsObject); far;
  begin
    Inc(Count);
  end;

begin
  Count := 0;
  ForEach(@CountChild);
  GetChildCount := Count;
end;

{ Display a message box which shows the number of children }
procedure TMyMDIWindow.CMCountChildren(var Msg: TMessage);
var
  CountStr: array[0..5] of Char;
begin
  Str(GetChildCount, CountStr);
  MessageBox(HWindow, CountStr, 'Total Children', mb_Ok);
end;

{ Construct a main window object }
procedure TMDIApp.InitMainWindow;
begin
  MainWindow := New(PMyMDIWindow,
    Init('MDI Conformist', LoadMenu(HInstance, MakeIntResource(100))));
  HAccTable := LoadAccelerators(HInstance, MakeIntResource(100));
end;

var
  MDIApp: TMDIApp;

begin
  MDIApp.Init('MDITest');
  MDIApp.Run;
  MDIApp.Done;
end.
