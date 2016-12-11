{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program Menu;

{$R MENU}

uses WinProcs, WinTypes, OWindows, ODialogs, Strings;

const

{ Command IDs }

  cm_Modify  = 100;
  cm_About   = 101;
  cm_Static  = 200;
  cm_Dynamic = 300;

{ Modify dialog item IDs }

  id_InputBox = 100;
  id_Checked  = 101;
  id_Grayed   = 102;
  id_Add      = 103;
  id_Delete   = 104;

type

{ Modify dialog object }

  PModifyDialog = ^TModifyDialog;
  TModifyDialog = object(TDialog)
    procedure AddItem(var Msg: TMessage);
      virtual id_First + id_Add;
    procedure DeleteItem(var Msg: TMessage);
      virtual id_First + id_Delete;
  end;

{ Menu name string }

  TMenuName = array[0..31] of Char;

{ Main window object }

  PMenuWindow = ^TMenuWindow;
  TMenuWindow = object(TWindow)
    MenuCount: Word;
    MenuName: TMenuName;
    constructor Init;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure DefCommandProc(var Msg: TMessage); virtual;
    procedure CMModify(var Msg: TMessage);
      virtual cm_First + cm_Modify;
    procedure CMAbout(var Msg: TMessage);
      virtual cm_First + cm_About;
  end;

{ Application object }

  TMenuApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

{ Handle the Add button by appending a new item to the Dynamic menu. }

procedure TModifyDialog.AddItem(var Msg: TMessage);
var
  Style: Word;
  Name: TMenuName;
begin
  GetWindowText(GetDlgItem(HWindow, id_InputBox), Name, SizeOf(Name));
  if Name[0] <> #0 then
  begin
    if SendMessage(GetDlgItem(HWindow, id_Checked),
      bm_GetCheck, 0, 0) = 0 then
      Style := mf_Unchecked
    else
      Style := mf_Checked;
    if SendMessage(GetDlgItem(HWindow, id_Grayed),
      bm_GetCheck, 0, 0) = 0 then
      Style := Style or mf_Enabled
    else
      Style := Style or mf_Grayed;
    with PMenuWindow(Parent)^ do
    begin
      AppendMenu(GetSubMenu(GetMenu(HWindow), 2),
        Style or mf_String, cm_Dynamic + MenuCount, @Name);
      Inc(MenuCount);
    end;
  end;
  EndDlg(id_Cancel);
end;

{ Handle the Delete button.  Loop through all menu items on the
  Dynamic menu until a matching item is found, and then delete that
  item.  If no match is found, bring up an error box. }

procedure TModifyDialog.DeleteItem(var Msg: TMessage);
var
  I: Integer;
  DynamicMenu: HMenu;
  Name, S: TMenuName;
begin
  GetWindowText(GetDlgItem(HWindow, id_InputBox), Name, SizeOf(Name));
  DynamicMenu := GetSubMenu(GetMenu(Parent^.HWindow), 2);
  for I := 0 to GetMenuItemCount(DynamicMenu) - 1 do
  begin
    GetMenuString(DynamicMenu, I, S, SizeOf(S), mf_ByPosition);
    if StrIComp(Name, S) = 0 then
    begin
      DeleteMenu(DynamicMenu, I, mf_ByPosition);
      EndDlg(id_Cancel);
      Exit;
    end;
  end;
  MessageBox(HWindow, 'Menu item not found', 'Error', mb_Ok);
end;

{ Constructor for main window object. }

constructor TMenuWindow.Init;
begin
  TWindow.Init(nil, 'Menu Demo');
  Attr.Menu := LoadMenu(HInstance, 'Menu');
  MenuCount := 1;
  MenuName[0] := #0;
end;

{ Bring up the About box. }

procedure TMenuWindow.CMAbout(var Msg: TMessage);
begin
  Application^.ExecDialog(New(PDialog, Init(@Self, 'About')));
end;

{ Bring up the Modify dialog. }

procedure TMenuWindow.CMModify(var Msg: TMessage);
begin
  Application^.ExecDialog(New(PModifyDialog, Init(@Self, 'Modify')));
end;

{ Paint window by displaying the name of the last menu selection. }

procedure TMenuWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
begin
  TextOut(PaintDC, 10, 10, MenuName, StrLen(MenuName));
end;

{ All unrecognized commands are sent to DefCommandProc.  Get the name
  of the menu selection that generated the command, and invalidate
  the window's client area so the new menu name gets displayed. }

procedure TMenuWindow.DefCommandProc(var Msg: TMessage);
begin
  GetMenuString(GetMenu(HWindow), Msg.WParam, MenuName,
    SizeOf(MenuName), mf_ByCommand);
  InvalidateRect(HWindow, nil, True);
  TWindow.DefCommandProc(Msg);
end;

{ Create the application's main window. }

procedure TMenuApp.InitMainWindow;
begin
  MainWindow := New(PMenuWindow, Init);
end;

var
  MenuApp: TMenuApp;

begin
  MenuApp.Init('Menu');
  MenuApp.Run;
  MenuApp.Done;
end.
