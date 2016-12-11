{************************************************}
{                                                }
{   Demo Program                                 }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program WMenu;

{$R WMenu}

uses WinProcs, WinTypes;

type
  TList = array[1..99] of String[17];

const
  ListCount: Word = 0;

var
  UserMenu: hMenu;
  List: TList;
  MenuName: string[17];
  Window: hWnd;

function AboutProc(Dlg: hWnd; iMessage, wParam: Word; lParam: LongInt): Bool; Export;
begin
  AboutProc := false;
  case iMessage of
    WM_Create: AboutProc:=true;
    WM_Command:
      if (wParam = IDOK) or (wParam = IDCancel) then
      begin
	AboutProc := True;
	EndDialog(Dlg, 0);
      end;
  end;
end;

function CreateProc(Dlg: hWnd; iMessage, wParam: Word; lParam: LongInt): WordBool; export;
var
  Style: Word;
  Name: string[17];
  Found: Boolean;
  I: Integer;
  R: TRect;
begin
  CreateProc:=False;
  case iMessage of
    WM_InitDialog:
      CreateProc := True;
    WM_Command:
      case wParam of
	IDCancel:
          begin
	    EndDialog(Dlg, 0);
	    CreateProc := True;
	  end;
	104:
          begin
	    Name[0] := Char(GetWindowText(GetDlgItem(Dlg, 103), @Name[1], 16));
	    Found := False;
	    for I := 1 to ListCount do
	      if Name = List[I] then
	      begin
		Found := True;
		DeleteMenu(UserMenu, I+300, MF_ByCommand);
	      end;
	      if MenuName = Name then
	      begin
		MenuName := '';
		GetClientRect(Window, R);
		InvalidateRect(Window, @R, True);
	      end;
	      if Not found then
		MessageBox(Dlg, 'Item Not Found', 'Error', MB_OK)
	      else
		EndDialog(Dlg, 0);
	  end;
	IDOK:
          begin
	    if SendMessage(GetDlgItem(Dlg, 101), BM_GetCheck, 0,0) = 0 then
	      Style := MF_UnChecked
	    else
	      Style := MF_Checked;
	    if SendMessage(GetDlgItem(Dlg, 102), BM_GetCheck, 0,0) = 0 then
	      Style := Style or MF_Enabled
	    else
	      Style := Style or MF_Grayed;
	    Name[0]:=Char(GetWindowText(GetDlgItem(Dlg, 103), @Name[1], 16));
	    Inc(ListCount);
	    if ListCount > 99 then
	    begin
	      MessageBox(Dlg, 'Too many menus', 'Error', MB_OK);
	      Exit;
	    end;
	    List[ListCount] := Name;
	    AppendMenu(UserMenu, Style or MF_String, ListCount+300, @Name[1]);
	    EndDialog(Dlg, 0);
	    CreateProc := True;
	  end;
      end;
  end;
end;

function WindowProc(Wnd: hWnd; iMessage, wParam:Word; lParam: LongInt): LongInt; export;
var
  ProcInst: Pointer;
  DC: hDC;
  PaintStruct: TPaintStruct;
  R: TRect;
begin
  case iMessage of
    WM_Command:
      case WParam of
        100:
          begin
	    ProcInst := MakeProcInstance(@CreateProc, hInstance);
	    DialogBox(hInstance, 'CreateDlg', Wnd, ProcInst);
	    FreeProcInstance(ProcInst);
	  end;
        106:
          begin
	    ProcInst := MakeProcInstance(@AboutProc, hInstance);
	    DialogBox(hInstance, 'About', Wnd, ProcInst);
	    FreeProcInstance(ProcInst);
	  end;
        301..399:
          begin
	    MenuName := List[wParam-300];
	    GetClientRect(Window, R);
	    InvalidateRect(Window, @R, true);
	  end;
        else
	  WindowProc:=DefWindowProc(Wnd, iMessage, wParam, lParam);
      end;
      WM_Paint:
        begin
	  DC := BeginPaint(Wnd, PaintStruct);
	  TextOut(DC, 0, 0, @MenuName[1], Length(MenuName));
	  EndPaint(Wnd, PaintStruct);
	end;
      WM_Destroy:
        PostQuitMessage(0);
    else
      WindowProc := DefWindowProc(Wnd, iMessage, wParam, lParam);
  end;
end;

procedure WinMain;
var
  WndClas: TWndClass;
  Msg: TMsg;
begin
  if hPrevInst = 0 then
  begin
    WndClas.Style := 0;
    WndClas.lpfnWndProc:= @WindowProc;
    WndClas.cbClsExtra := 0;
    WndClas.cbWndExtra := 0;
    WndClas.hInstance := HInstance;
    WndClas.hIcon := 0;
    WndClas.hCursor := LoadCursor(0, IDC_Arrow);
    WndClas.hbrBackground := GetStockObject(White_Brush);
    WndClas.lpszMenuName := 'Menu';
    WndClas.lpszClassName := 'GenWindow';
    if not RegisterClass(WndClas) then
      Halt;
  end;
  Window := CreateWindow('GenWindow', 'Menu Example', WS_OverLappedWindow,
    CW_UseDefault, 0, CW_UseDefault, 0, 0, 0, hInstance, nil);
  UpDateWindow(Window);
  UserMenu:=CreatePopUpMenu;
  InsertMenu(GetMenu(Window), 106, MF_ByCommand or MF_PopUp, UserMenu, 'User Define Menu');
  ShowWindow(Window,Sw_ShowNormal);
  while GetMessage(Msg, 0, 0, 0) do
  begin
    TranslateMessage(msg);
    DispatchMessage(msg);
  end;
end;

begin
  WinMain;
end.
