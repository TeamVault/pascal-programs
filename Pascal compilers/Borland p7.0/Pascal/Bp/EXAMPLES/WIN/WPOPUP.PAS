{************************************************}
{                                                }
{   Demo Program                                 }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program WPopUp;

{ This is a small example of creating child and pop up windows without  }
{ using the ObjectWindows library.                                      }

{$R WPopUp}

uses WinTypes, WinProcs, Strings;

var
  Parent, PopUp, PopUpNo, Child: hWnd;

function Window1(Wnd: hWnd; iMessage, wParam: Word; lParam: LongInt): LongInt; export;
var
  PaintStruct: TPaintStruct;
  DC: hDC;
  S: String;
  R: TRect;
begin
  case iMessage of
    WM_Paint:
      begin
	DC:=BeginPaint(Wnd, PaintStruct);
	S:='';
	if Wnd = PopUp then
	  S := 'PopUp windows can be moved outside the Parent Window. '+
	  'A PopUp with a Parent will always stay on top even when the '+
	  'focus is put on the underlying Parent Window.  Try this '+
	  'by clicking on the Parent Window.  When Minimized, PopUp '+
	  'icons reside on the desktop.'
	else if Wnd = PopUpNo then
	  S := 'PopUp windows can be moved outside the Parent Window. '+
	  'A PopUp with no Parent allows the focused Parent window to be '+
	  'brought to the front (Try this by clicking on the Parent '+
	  'Window).  When Minimized, PopUp icons reside on the desktop.'
	else if Wnd = Child then
	  S := 'Child Window always lives within the Parent Window.  It cannot '+
	  'be moved outside the Parent Window.  When Minimized, the icon '+
	  'also resides within the Parent Window.';
	if Length(S) <> 0 then
	begin
	  GetClientRect(Wnd, R);
	  DrawText(DC, @S[1], Length(S), R, DT_WordBreak);
	end;
	EndPaint(Wnd, PaintStruct);
      end;
      WM_Destroy:
        begin
          if Wnd = PopUp then
	    EnableMenuItem(GetMenu(Parent), 101, MF_Enabled)
          else if Wnd = PopUpNo then
            EnableMenuItem(GetMenu(Parent), 102, MF_Enabled)
          else if Wnd = Child then
	    EnableMenuItem(GetMenu(Parent), 103, MF_Enabled);
        end;
    else
      Window1 := DefWindowProc(Wnd, iMessage, wParam, lParam);
  end;
end;

procedure Register(P: Pointer; Name: PChar; Menu: PChar);
var
  WndClas: TWndClass;
begin
  if hPrevInst <> 0 then Exit;
  WndClas.Style := CS_HReDraw or CS_VReDraw;
  WndClas.lpfnWndProc:= P;
  WndClas.cbClsExtra := 0;
  WndClas.cbWndExtra := 0;
  WndClas.hInstance := HInstance;
  WndClas.hIcon := LoadIcon(0, Idi_Application);
  WndClas.hCursor := LoadCursor(0, Idc_Arrow);
  WndClas.hbrBackground := GetStockObject(White_Brush);
  WndClas.lpszMenuName := Menu;
  WndClas.lpszClassName := Name;
  if not RegisterClass(WndClas) then
  begin
    MessageBox(GetFocus, 'Can not Register Class', 'Error ', MB_OK);
    Halt;
  end;
end;

function Create(Name: PChar; Style: Longint; X1,Y1,X2,Y2: Integer; Parent: Word): Word;
var
  Wnd: Word;
begin
  Wnd := CreateWindow(Name, Name, Style, X1, Y1, X2, Y2, Parent, 0, hInstance, nil);
  ShowWindow(Wnd, SW_ShowNormal);
  UpDateWindow(Wnd);
  Create := Wnd;
end;

procedure Loop;
var
  Msg: TMsg;
begin
  while GetMessage(Msg, 0, 0, 0) do
  begin
    TranslateMessage(msg);
    DispatchMessage(msg);
  end;
end;

procedure InvalidateWindow(Wnd: hWnd);
var
  R: TRect;
begin
  GetClientRect(Wnd, R);
  InvalidateRect(Wnd, @R, false);
end;

function AboutProc(Dlg: hWnd; iMessage, wParam: Word; lParam: LongInt): Bool; Export;
begin
  AboutProc:=false;
  case iMessage of
    WM_Create: AboutProc := True;
    WM_Command:
      if (wParam = IDOK) or (wParam = IDCancel) then
      begin
	AboutProc := True;
	EndDialog(Dlg, 0);
      end;
  end;
end;

function WindowSetup(Wnd: hWnd; iMessage, wParam:Word; lParam: LongInt): LongInt; export;
var
  ProcInst: Pointer;
begin
  case iMessage of
    WM_Command:
      case wParam of
        101:
          begin
	    PopUp := Create('PopUp With Parent', WS_PopUp or WS_OverLappedWindow, 40, 60, 300, 150, Parent);
	    InvalidateWindow(PopUp);
	    EnableMenuItem(GetMenu(Wnd), 101, MF_Grayed);
	  end;
	102:
          begin
	    PopUpNo := Create('PopUp No Parent', WS_PopUp or WS_OverLappedWindow, 60, 80, 300, 150, 0);
	    InvalidateWindow(PopUpNo);
	    EnableMenuItem(GetMenu(Wnd), 102, MF_Grayed);
	  end;
	103:
          begin
	    Child := Create('Child Window', WS_Child or WS_OverLappedWindow, 20, 0, 300, 100, Parent);
	    InvalidateWindow(Child);
	    EnableMenuItem(GetMenu(Wnd), 103, MF_Grayed);
	  end;
	104:
          begin
	    ProcInst := MakeProcInstance(@AboutProc, hInstance);
	    DialogBox(hInstance, 'About', Wnd, ProcInst);
	    FreeProcInstance(ProcInst);
	  end;
	else
	  WindowSetUp:=DefWindowProc(Wnd, iMessage, wParam, lParam);
      end;
    WM_Destroy:
      PostQuitMessage(0);
  else
    WindowSetUp := DefWindowProc(Wnd, iMessage, wParam, lParam);
  end;
end;

begin
  Register(@WindowSetUp, 'Parent Window', 'Menu');
  Parent:=Create('Parent Window', WS_OverLappedWindow, 0, 0, 400, 200, 0);
  Register(@Window1, 'Child Window', '');
  Register(@Window1, 'PopUp No Parent', '');
  Register(@Window1, 'PopUp With Parent', '');
  Loop;
end.
