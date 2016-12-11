{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program SBarTest;

uses WinTypes, WinProcs, Strings, OWindows, ODialogs;
         
const
  id_ThermScroll = 100;
  id_Stat1 = 101;

type

  TestApplication = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

  PTestWindow = ^TestWindow;

  TestWindow = object(TWindow)
    ThermScroll : PScrollBar;
    Stat1 : PStatic;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    procedure SetupWindow; virtual;
    procedure HandleThermScrollMsg(var Msg: TMessage);
      virtual id_First + id_ThermScroll;
  end;

{ Set attributes and construct child controls }
constructor TestWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  inherited Init(AParent, ATitle);
  with Attr do
  begin
    X := 20;
    Y := 20;
    W := 380;
    H := 250;
  end;
  ThermScroll := New(PScrollBar,
    Init(@Self, id_ThermScroll, 20, 170, 340, 0, True));
  Stat1 := New(PStatic,
    Init(@Self, id_Stat1, ' 32 degrees', 135, 40, 160, 17, 0));
end;

{ Create scrollbar and static controls; set range of scrollbar }
procedure TestWindow.SetupWindow;
begin
  inherited SetupWindow;
  ThermScroll^.SetRange(32, 120);
end;

{ Handle notification messages from therm scrollbar }
procedure TestWindow.HandleThermScrollMsg(var Msg: TMessage);
var
  cString: array[0..11] of Char;
begin
  Str(ThermScroll^.GetPosition:3, cString);
  StrCat(cString, ' degrees');
  Stat1^.SetText(cString);
end;

procedure TestApplication.InitMainWindow;
begin
  MainWindow := New(PTestWindow, Init(nil, 'Thermostat'));
end;
 
var
  TestApp : TestApplication;

begin
  TestApp.Init('SBarApp');
  TestApp.Run;
  TestApp.Done;
end.
