{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program EWndTest;

{$R EWNDTEST.RES}
 
uses WinTypes, WinProcs, Strings, OWindows, OStdWnds;
         
const
  cm_SendText = 399;
 
type
  TTestApplication = object(TApplication)
    procedure InitMainWindow; virtual;
  end;
 
  PTestWindow = ^TTestWindow;
  TTestWindow = object(TEditWindow)
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    procedure HandleSend(var Msg: TMessage);
      virtual cm_First + cm_SendText;
  end;
 
{ --------TTestWindow methods------------------ }
constructor TTestWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  inherited Init(AParent, ATitle);
  Attr.Menu := LoadMenu(HInstance, MakeIntResource(102));
end;

procedure TTestWindow.HandleSend(var Msg: TMessage);
var
  Lines: Integer;
  Text: array[0..20] of Char;
begin
  Lines := Editor^.GetNumLines;
  Str(Lines, Text);
  StrCat(Text, ' lines sent');
  MessageBox(HWindow, @Text, 'Message Sent', mb_Ok);
end;

{ -----------TTestApplication Methods------------ }
procedure TTestApplication.InitMainWindow;
begin
  MainWindow := New(PTestWindow, Init(nil, 'Edit Window Tester'));
  HAccTable := LoadAccelerators(HInstance, MakeIntResource(100));
end;
 
var
  TestApp : TTestApplication;
 
begin
  TestApp.Init('EWndTest');
  TestApp.Run;
  TestApp.Done;
end.

