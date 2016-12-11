{***************************************************}
{                                                   }
{   Windows 3.1 TrueType Font Demonstration Program }
{   Copyright (c) 1992 by Borland International     }
{                                                   }
{***************************************************}

{$N+}

program TrueTypeDemo;

{ This program demonstrates some of the flexibility of the
  TrueType font system for Windows 3.1 by generating a complex
  display of rotated text.  The Font Selection dialog from the
  Common Dialogs DLL is also demonstrated.
}

{$R TTDEMO}

uses WinTypes, WinProcs, Win31, OWindows, ODialogs, Strings, CommDlg, BWCC;

const

{ Application error message }

  em_WrongWinVersion = -10;

{ Resource IDs }

  id_Menu  = 100;
  id_About = 100;
  id_Icon  = 1;

{ Menu command IDs }

  cm_Shadows        = 201;
  cm_Fonts          = 203;
  cm_HelpAbout      = 300;

type

{ Application main window }

  PFontWindow = ^TFontWindow;
  TFontWindow = object(TWindow)

    MainFontRec,
    LogoFontRec,
    BorlandFontRec    : TLogFont;

    FanColor          : array [0..9] of TColorRef;
    ShadowAll         : Boolean;
    Rendering         : Boolean;

    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    function  GetClassName: PChar; virtual;
    procedure GetWindowClass( var WC: TWndClass); virtual;

    procedure Paint(DC: HDC; var PS: TPaintStruct); virtual;

    procedure CMHelpAbout(var Msg: TMessage);
      virtual cm_First + cm_HelpAbout;
    procedure CMShadows(var Msg: TMessage);
      virtual cm_First + cm_Shadows;
    procedure CMFonts(var Msg: TMessage);
      virtual cm_First + cm_Fonts;
    procedure WMGetMinMaxInfo(var Msg: TMessage);
      virtual wm_First + wm_GetMinMaxInfo;
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;
  end;

{ Application object }

  TFontApp = object(TApplication)
    procedure Error(ErrorCode: Integer); virtual;
    procedure InitApplication; virtual;
    procedure InitMainWindow; virtual;
  end;

{ Initialized globals }

const
  DemoTitle: PChar = 'TrueType Demo';

{ TFontWindow Methods }

{ Constructs an instance of the TFontWindow.  Sets up the window's menu,
  then initializes the Logical Font structures for the three fonts to
  be used in the demo.
}
constructor TFontWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  TWindow.Init(AParent, ATitle);
  Attr.Menu := LoadMenu(HInstance, PChar(id_Menu));

{ Initialize the logical font record for the 'fan' text.  Default
  is TimesNewRoman.
}
  with MainFontRec do
  begin
    lfHeight        := 26;
    lfWidth         := 10;
    lfEscapement    := 0;
    lfOrientation   := 0;
    lfWeight        := fw_Bold;
    lfItalic        := 0;
    lfUnderline     := 0;
    lfStrikeOut     := 0;
    lfCharSet       := ANSI_CharSet;
    lfOutPrecision  := Out_Default_Precis;
    lfClipPrecision := Clip_Default_Precis;
    lfQuality       := Proof_Quality;
    lfPitchAndFamily:= Variable_Pitch or FF_Roman;
    StrCopy(lfFaceName,'Times New Roman');
  end;

  LogoFontRec := MainFontRec;

  BorlandFontRec:= MainFontRec;
  with BorlandFontRec do
  begin
    lfHeight:= 60;
    lfWidth := 0;           {Choose best width for this height }
    lfWeight:= 900;
    StrCopy(lfFaceName, 'Arial');
  end;

{ Initialize an array of colors used to color the fan text }
  FanColor[0] := RGB(255,0,0);
  FanColor[1] := RGB(128,0,0);
  FanColor[2] := RGB(255,128,0);
  FanColor[3] := RGB(80,80,0);
  FanColor[4] := RGB(80,255,0);
  FanColor[5] := RGB(0,128,0);
  FanColor[6] := RGB(0,128,255);
  FanColor[7] := RGB(0,0,255);
  FanColor[8] := RGB(128,128,128);
  FanColor[9] := RGB(255,0,0);

  ShadowAll := False;
  Rendering := False;
end;

{ Responds to repaint requests by completely redrawing the
  fanned-text demo display.
}
procedure TFontWindow.Paint(DC: HDC; var PS: TPaintStruct);
const
  ArcText     = 'TrueType';
  FanText     = 'Turbo Pascal for Windows';
  BorlandText = 'Borland';
  WaitText    = 'Windows is rendering fonts...';
  Radius      = 100;   { Controls circle about which text is fanned }

  Deg2Rad : Extended = PI / 18;    { Used for angle calculations }
type
  TTextExtent = record
    W, H: Word;
  end;
var
  FontRec   : TLogFont;
  FontMetric: TOutlineTextMetric;
  FontHeight: Integer;
  d         : Word;
  x, y, j, k: Integer;
  Theta     : Real;
  P         : PChar;
  CRect     : TRect;
  BaseWidth,
  DesiredExtent,
  FanTextLen: Word;
  TextExt   : TTextExtent;
begin
  P := ArcText;
  FanTextLen := StrLen(FanText);

  SaveDC(DC);

  if Rendering then
    { Display a message that Windows is rendering fonts, please wait... }
    SetWindowText(HWindow, WaitText);

{ Create the "TT" logo, in black-on-gray, at the upper left-hand
  corner of the window.
}
  FontRec := LogoFontRec;
  SetBkMode(DC, Transparent);
  SetTextColor(DC, RGB(128, 128, 128));
  FontRec.lfHeight:= FontRec.lfHeight * 2;
  FontRec.lfWidth := Trunc(FontRec.lfWidth * 2.1);
  SelectObject(DC, CreateFontIndirect(FontRec));
  TextOut(DC, 18, 5, 'T', 1);
  SetTextColor(DC, RGB(0, 0, 0));
  TextOut(DC, 32, 13, 'T', 1);

{ Next, get the TextMetrics for the font to be used as the fan
  text.  This will be used to control the fanning, and to size
  the window.
}
  GetClientRect(HWindow, CRect);
  FontRec := MainFontRec;
  DeleteObject(SelectObject(DC, CreateFontIndirect(FontRec)));
  GetOutlineTextMetrics(DC, SizeOf(FontMetric), @FontMetric);
  FontHeight := FontMetric.otmTextMetrics.tmHeight;
  SetViewportOrg(DC, FontHeight+2, 0);
  Dec(CRect.Right, FontHeight+2);
  BaseWidth := LoWord(GetTextExtent(DC, FanText, FanTextLen));

{ Always draw the inner circle around which the text will be
  fanned (draw two circles for nice effect).  If Alignment
  Marks are on, then draw the outer circle as well.  Use a Null
  brush to avoid writing over text.
}
  SelectObject(DC, GetStockObject(Null_Brush));
  Ellipse(DC, -(Radius-5),  -(Radius-5),  (Radius-5),  Radius-5);
  Ellipse(DC, -(Radius-10), -(Radius-10), (Radius-10), Radius-10);

  SetTextColor(DC, FanColor[0]);
  for d:= 27 to 36 do
  begin
    x := Round(Radius * cos( d * Deg2Rad));
    y := Round(Radius * sin(-d * Deg2Rad)); { -d because y axis is inverted }

    Theta := -d * Deg2Rad;
    if X <> 0 then
      Theta := ArcTan((CRect.Right / CRect.Bottom) * (Y / X));

    j := Round(CRect.Right  * cos(Theta));
    k := Round(CRect.Bottom * sin(Theta));

{ Calculate how long the displayed string should be.
}
    DesiredExtent:= Round(Sqrt(Sqr(x*1.0 - j) + Sqr(y*1.0 - k))) - 5;
    FontRec := MainFontRec;
    FontRec.lfEscapement:= d * 100;
    FontRec.lfWidth     := Trunc(FontMetric.otmTextMetrics.tmAveCharWidth *
      (DesiredExtent / BaseWidth));
    DeleteObject(SelectObject(DC, CreateFontIndirect(FontRec)));
    Longint(TextExt) := GetTextExtent(DC, FanText, FanTextLen);

{ Shave off some character width until the string fits
}
    while (TextExt.W > DesiredExtent) and (FontRec.lfWidth <> 0) do
    begin
      Dec(FontRec.lfWidth);
      DeleteObject(SelectObject(DC, CreateFontIndirect(FontRec)));
      Longint(TextExt) := GetTextExtent(DC, FanText, FanTextLen);
    end;

{ Expand the string if necessary to make it fit the desired extent.
}
    if TextExt.W < DesiredExtent then
      SetTextJustification(DC, DesiredExtent - TextExt.W, 3);

{ If shadowing is enabled, draw an underlying copy of the string
  in black.  Then, draw the text in the actual color.
}
    if ShadowAll then
    begin
      SetTextColor(DC, RGB(0, 0, 0));
      TextOut(DC, x+2, y+1, FanText, FanTextLen);
    end;
    SetTextColor(DC, FanColor[d - 27]);
    TextOut(DC, x, y, FanText, FanTextLen);
    SetTextJustification(DC, 0, 0);  {Clear justifier's internal error
                                      accumulator}

    if P[0] <> #0 then
    begin
      FontRec := LogoFontRec;
      FontRec.lfEscapement:= (d + 10) * 100;
      FontRec.lfWidth     := 0;
      DeleteObject(SelectObject(DC, CreateFontIndirect(FontRec)));
      SetTextColor(DC, 0);
      x := Round((Radius - FontHeight - 5) * cos( d * Deg2Rad));
      y := Round((Radius - FontHeight - 5) * sin(-d * Deg2Rad));
      TextOut(DC, x, y, P, 1);
      inc(P);
    end;
  end;      {for d:= 27 to 36}

{ Render the Borland logo in the bottom-right corner.
}
  DeleteObject(SelectObject(DC, CreateFontIndirect(BorlandFontRec)));
  Longint(TextExt) := GetTextExtent(DC, BorlandText, StrLen(BorlandText));
  SetTextColor(DC, RGB(0, 0, 0));
  TextOut(DC, CRect.Right - TextExt.W, CRect.Bottom - TextExt.H,
              BorlandText, StrLen(BorlandText));
  SetTextColor(DC, RGB(255, 0, 0));
  TextOut(DC, CRect.Right - TextExt.W - 5, CRect.Bottom - TextExt.H,
              BorlandText, StrLen(BorlandText));

{ Restore the window caption to the proper title string, then clear the
  rendering flag.  The flag will be set again when the window is resized.
}
  if Rendering then
  begin
    SetWindowText(HWindow, Attr.Title);
    Rendering := False;
  end;

  DeleteObject(SelectObject(DC, GetStockObject(System_Font)));
  RestoreDC(DC, -1);
end;

{ Posts the About box dialog from the Help Menu.
}
procedure TFontWindow.CMHelpAbout(var Msg: TMessage);
begin
  Application^.ExecDialog(New(PDialog, Init(@Self, PChar(id_About))));
end;

{ Toggles the state of the text shadow display.  Repaints
  the window to show the new state.
}
procedure TFontWindow.CMShadows(var Msg: TMessage);
begin
  ShadowAll := not ShadowAll;  { Set data field for repaint }
  if ShadowAll then
    CheckMenuItem(Attr.Menu, cm_Shadows, mf_ByCommand or mf_Checked)
  else
    CheckMenuItem(Attr.Menu, cm_Shadows, mf_ByCommand or mf_UnChecked);

{ If the new state is to not show shadows, then clear the window
  before repainting.  Otherwise, don't clear so that alignment
  marks seem to appear without the text redrawing (it will actually
  be redrawing over itself).
}
  InvalidateRect(HWindow, nil, not ShadowAll);
end;

{ Posts the ChooseFont dialog from CommDlg.tpu to allow the
  user to select a new font.
}
procedure TFontWindow.CMFonts(var Msg: TMessage);
var
  ChooseRec: TChooseFont;
  FontRec  : TLogFont;
begin
  FontRec := MainFontRec;
  FillChar(ChooseRec, Sizeof(ChooseRec), #0);
  with ChooseRec do
  begin
    lStructSize:= SizeOf(TChooseFont);
    HWndOwner  := HWindow;
    Flags      := cf_AnsiOnly or cf_TTOnly or cf_ScreenFonts
                  or cf_EnableTemplate or cf_InitToLogFontStruct;
    nFontType  := Screen_FontType;
    lpLogFont  := @FontRec;
    lpTemplateName := 'FontDlg';
    ChooseRec.hInstance := System.hInstance;
  end;
{ Post the dialog and check the result.  If OK clicked, then
  only get the font name - we don't care what size the user
  selected, since the demo uses canned sizes.  Invalidate the
  window to redraw with the new font.
}
  if ChooseFont(ChooseRec) then
  begin
    StrCopy(MainFontRec.lfFaceName, FontRec.lfFaceName);
    MainFontRec.lfWeight := FontRec.lfWeight;
    MainFontRec.lfItalic := FontRec.lfItalic;
    Rendering := True;
    InvalidateRect(HWindow, nil, True);
  end;
end;

{ Provides Windows with a minimum size for the application window,
  so that the fonts don't get too small.
}
procedure TFontWindow.WMGetMinMaxInfo(var Msg: TMessage);
type
  TPointArray = array [0..4] of TPoint;
  PPointArray = ^TPointArray;
begin
  PPointArray(Msg.LParam)^[3].X := 300;
  PPointArray(Msg.LParam)^[3].Y := 300;
end;

{ Changes the window's class name so an icon can be associated with
  this window.
}
function TFontWindow.GetClassName: PChar;
begin
  GetClassName := 'OWLTrueTypeDemoWindow';
end;

{ Associates an icon with the window class.
}
procedure TFontWindow.GetWindowClass( var WC: TWndClass);
begin
  TWindow.GetWindowClass(WC);
  WC.hIcon := LoadIcon(hInstance, PChar(id_Icon));
end;

{ When the window is resized, the size of the fonts may need to change.
  This sets the Rendering flag so the Paint method can tell the user
  that delays in painting are due to Windows generating new fonts.
}
procedure TFontWindow.WMSize(var Msg: TMessage);
begin
  TWindow.WMSize(Msg);
  Rendering := True;
end;



procedure TFontApp.Error(ErrorCode: Integer);
begin
  if ErrorCode = em_WrongWinVersion then
  begin
    MessageBox(0, 'This program requires Windows 3.1 TrueType fonts.',
                  'Wrong Windows Version', mb_OK);
    Halt(Byte(ErrorCode));
  end
  else
    inherited Error(ErrorCode);
end;

type
  WinVersion = record
    WinMajor,
    WinMinor,
    DosMajor,
    DosMinor: Byte;
  end;

{ Verifies that the current operating environment is Win 3.1 or later }
procedure TFontApp.InitApplication;
var
  v: WinVersion;
begin
  Longint(V) := GetVersion;
  if not ((V.WinMajor >= 3) and (V.WinMinor >= 10)) then
    Status := em_WrongWinVersion;
end; 


{ Constructs the an instance of TFontWindow as the TFontApp's
  MainWindow object.
}
procedure TFontApp.InitMainWindow;
begin
  MainWindow := New(PFontWindow, Init(nil, Application^.Name));
end;


var
  App: TFontApp;


{ Main program }

begin
  App.Init(DemoTitle);
  App.Run;
  App.Done;
end.
