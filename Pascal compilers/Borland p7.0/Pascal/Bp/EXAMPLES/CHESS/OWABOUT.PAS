{************************************************}
{                                                }
{   ObjectWindows Chess Demo                     }
{   About box unit                               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit OWAbout;

interface

uses Winprocs, Wintypes, OWindows, ODialogs;

{$R OWAbout.res}

  { This about box currently only supports BWCC style dialogs. }
const
  idShade = 100;
  idBump  = 101;
  idHotKey = 103;

type
  PCreditWindow = ^TCreditWindow;
  TCreditWindow = object(TWindow)
    Bitmap: HBitmap;
    BitSize: TBitmap;
    ScrollUnit: Integer;
    ScrollRate: Integer;
    ScrollPos: Integer;
    FontHeight: Integer;
    constructor Init(AParent: PWindowsObject; ABitmapName: PChar);
    destructor Done; virtual;
    function  GetClassName: PChar; virtual;
    procedure GetWindowClass(var WC: TWndClass); virtual;
    procedure SetupWindow; virtual;         { First place HWindow is valid }
    procedure WMDestroy(var Msg: TMessage); { Last place HWindow is valid  }
      virtual wm_First + wm_Destroy;
    procedure Paint(DC: HDC; var PS: TPaintStruct); virtual;
    procedure ShowCredits; virtual;
    procedure WriteLine(DC: HDC; Y: Word; const S: array of Char); virtual;
    procedure WMTimer(var Msg: TMessage);
      virtual wm_First + wm_Timer;
  end;

  PAboutBox = ^TAboutBox;
  TAboutBox = object(TDialog)
    Title: PChar;
    CreditWindow: PCreditWindow;
    constructor Init(AParent: PWindowsObject;
                     ATitle, ABitmapName: PChar);
    destructor Done; virtual;
    procedure SetupWindow; virtual;
    function  GetResName: PChar; virtual;
    procedure InitCreditWindow(ABitmapName: PChar); virtual;
    procedure ShowCredits(var Msg: TMessage);
      virtual id_First + idHotKey;
  end;

implementation

uses Strings;

constructor TCreditWindow.Init(AParent: PWindowsObject;
                               ABitmapName: PChar);
var
  DC: HDC;
  OldFont: HFont;
  TM: TTextMetric;
begin
  inherited Init(AParent, nil);
  Attr.Style := ws_Child or ws_Visible;
  Bitmap := LoadBitmap(HInstance, ABitmapName);
  if Bitmap = 0 then
  begin
    Status := em_InvalidWindow;
    Exit;
  end;
  GetObject(Bitmap, SizeOf(BitSize), @BitSize);
  ScrollPos := 0;
  DC := GetDC(0);
  ScrollUnit := 2;
  ScrollRate := 80;
  OldFont := SelectObject(DC, GetStockObject(ANSI_VAR_FONT));
  GetTextMetrics(DC, TM);
  FontHeight := TM.tmHeight + TM.tmExternalLeading + 5;
  SelectObject(DC, Oldfont);
  ReleaseDC(0, DC);
end;

destructor TCreditWindow.Done;
begin
  inherited Done;
  DeleteObject(Bitmap);
end;

function TCreditWindow.GetClassName: PChar;
begin
  GetClassName := 'OWLAboutCredits';
end;

procedure TCreditWindow.GetWindowClass(var WC: TWndClass);
begin
  inherited GetWindowClass(WC);
  WC.Style := cs_ByteAlignWindow;
  WC.hbrBackground := GetStockObject(Black_Brush);
end;

procedure TCreditWindow.SetupWindow;
begin
  inherited SetupWindow;
  SetWindowPos(HWindow, 0, 0, 0, BitSize.bmWidth, BitSize.bmHeight,
               swp_NoMove or swp_NoZOrder or swp_NoActivate or swp_NoRedraw);
end;

procedure TCreditWindow.WMDestroy(var Msg: TMessage);
begin
  if ScrollPos <> 0 then { We're scrolling and need to kill the timer }
  begin
    KillTimer(HWindow, 1);
    ScrollPos := 0;
  end;
  inherited WMDestroy(Msg);
end;

const
  CreditText: array[1..8] of PChar = (
    '',
    'OWLChess''s Chess engine,',
    'contained in CHESS.DLL, is',
    'a modernized version of the',
    'Chess program supplied in',
    'Borland''s GameWorks Toolbox.',
    '',
    '');

procedure TCreditWindow.Paint(DC: HDC; var PS: TPaintStruct);
var
  R: TRect;
  FirstLine, LastLine: Integer;
  S: array [0..50] of Char;
  CryptMark: Longint;
  Y: Integer;

  procedure DrawBitmap(Y: Integer);
  var
    MemDC: HDC;
    OldBits: HBitmap;
  begin
    MemDC:= CreateCompatibleDC(DC);
    OldBits := SelectObject(MemDC, Bitmap);
    BitBlt(DC, 0, Y, Attr.W, Attr.H, MemDC, 0, 0, srcCopy);
    SelectObject(MemDC, OldBits);
    DeleteDC(MemDC);
  end;

begin
  SaveDC(DC);
  SetViewportOrg(DC, 0, -ScrollPos);
  OffsetRect(PS.rcPaint, 0, ScrollPos);
  with R do
  begin
    Left := 0;
    Top := 0;
    Right := Attr.W;
    Bottom := Attr.H;
  end;
  if Bool(IntersectRect(R, PS.rcPaint, R)) then
  begin
    DrawBitmap(0);
    with PS.rcPaint do
    begin
      if (R.Top < Top) and (R.Bottom > Top) then Top := R.Bottom;
      if (R.Top < Bottom) and (R.Bottom > Bottom) then Bottom := R.Top;
      if Top > Bottom then Top := Bottom;
    end;
  end;
  if ScrollPos > 0 then    { we're scrolling }
  begin
    FirstLine := (PS.rcPaint.Top - Attr.H) div FontHeight;
    if FirstLine < 0 then FirstLine := 0;
    if FirstLine < High(CreditText) then
    begin                             { we have text to draw }
      SetTextAlign(DC, TA_Center);
      SetBkColor(DC, 0);
      SetTextColor(DC, RGB($ff,$ff,$ff));
      LastLine := (PS.rcPaint.Bottom - Attr.H) div FontHeight;
      for Y := FirstLine to LastLine do
        if Y < High(CreditText) then
          WriteLine(DC, Y*FontHeight + Attr.H, CreditText[Y + 1]^);
    end;
                            { Paint second image of bitmap at bottom }
    if PS.rcPaint.Bottom > (Attr.H+FontHeight*High(CreditText)) then
      DrawBitmap(Attr.H + FontHeight * High(CreditText));
  end;
  RestoreDC(DC, -1);
end;

procedure TCreditWindow.ShowCredits;
begin
  SetTimer(HWindow, 1, ScrollRate, nil);
end;

procedure TCreditWindow.WriteLine(DC: HDC; Y: Word; const S: array of Char);
begin
  TextOut(DC, Attr.W div 2, Y, @S, StrLen(@S));
end;

procedure TCreditWindow.WMTimer(var Msg: TMessage);
begin
  Inc(ScrollPos, ScrollUnit);
  { Check to see if it's time to stop scrolling }
  if ScrollPos > Attr.H + FontHeight * High(CreditText) then
  begin
    ScrollPos := 0;
    KillTimer(HWindow, 1);
    InvalidateRect(HWindow, nil, False);
  end
  else
    ScrollWindow(HWindow, 0, -ScrollUnit, nil, nil);
  UpdateWindow(HWindow);
end;

constructor TAboutBox.Init(AParent: PWindowsObject;
                           ATitle, ABitmapName: PChar);
begin
  inherited Init(AParent, GetResName);
  Title := StrNew(ATitle);
  InitCreditWindow(ABitmapName);
end;

destructor TAboutBox.Done;
begin
  inherited Done;
  if Title <> nil then
    StrDispose(Title);
end;

procedure TAboutBox.SetupWindow;
var
  RDialog,R,RBitWnd,RShade,RBump,ROk: TRect;
  X8, Y8: Integer;
  DC: HDC;
begin
  inherited SetupWindow;
  SetWindowText(HWindow, Title);
  DC := GetDC(HWindow);
  X8 := GetDeviceCaps(DC,LogPixelsX) div 8;   { 1/8 inch }
  Y8 := GetDeviceCaps(DC,LogPixelsY) div 8;
  ReleaseDC(HWindow, DC);
  GetClientRect(GetDlgItem(HWindow, idShade), RShade);
  GetClientRect(GetDlgItem(HWindow, idBump), RBump);
  GetClientRect(GetDlgItem(HWindow, idOK), ROk);
  GetClientRect(CreditWindow^.HWindow, RBitWnd);
  RShade.Top := Y8;
  RShade.Left := X8;
  if RShade.Right < RBitWnd.Right + 2*X8 then
    RShade.Right := RBitWnd.Right + 2*X8;
  if RShade.Bottom < RBitWnd.Bottom + 2*Y8 then
    RShade.Bottom := RBitWnd.Bottom + 2*Y8;

  with  RDialog do
  begin
    GetWindowRect(HWindow, RDialog);
    GetClientRect(HWindow, R);
    Right := Right - Left - R.Right;
    Bottom := Bottom - Top - R.Bottom;
    Right := Right + X8 + RShade.Right + X8;   { 1/8 inch margins }
    Bottom := Bottom + Y8 + RShade.Bottom
                     + Y8 + RBump.Bottom
                     + Y8 + ROk.Bottom + Y8;
    if Parent <> nil then
    begin
      GetWindowRect(Parent^.HWindow, R);
        { Center dialog in parent's window }
      Left := R.Left + (R.Right - R.Left) div 2 - Right div 2;
      Top := R.Top + (R.Bottom - R.Top) div 2 - Bottom div 2;
    end;
    SetWindowPos(HWindow, 0, Left, Top, Right, Bottom,
                 swp_NoActivate or swp_NoZOrder);
  end;
  with RShade do
  begin
    SetWindowPos(GetDlgItem(HWindow, idShade), 0, Left, Top,
                 Right, Bottom, swp_NoActivate or swp_NoZOrder);
    SetWindowPos(CreditWindow^.HWindow, 0,  Left + X8, Top + Y8, 0, 0,
                 swp_NoActivate or swp_NoSize or swp_NoZOrder);
  end;
  with RBump do
  begin
    Left := -1;
    Right := RDialog.Right + 2;
    Top := RShade.Top + RShade.Bottom + Y8 ;
    SetWindowPos(GetDlgItem(HWindow, idBump), 0, Left, Top, Right, Bottom,
                 swp_NoActivate or swp_NoZOrder);
  end;
  GetClientRect(HWindow, R);
  with ROk do
    SetWindowPos(GetDlgItem(HWindow, idOk), 0,
                 R.Right div 2 - Right div 2,
                 RBump.Top + RBump.Bottom + Y8, 0, 0,
                 swp_NoActivate or swp_NoZOrder or swp_NoSize);
end;

function TAboutBox.GetResName: PChar;
begin
  GetResName := 'dlgAbout';
end;

procedure TAboutBox.InitCreditWindow(ABitmapName: PChar);
begin
  CreditWindow := New(PCreditWindow, Init(@Self, ABitmapName));
end;

procedure TAboutBox.ShowCredits(var Msg: TMessage);
begin
  CreditWindow^.ShowCredits;
end;

end.