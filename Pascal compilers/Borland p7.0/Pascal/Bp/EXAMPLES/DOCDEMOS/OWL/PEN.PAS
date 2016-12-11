{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Pen;

{$R PEN.RES}

interface

uses WinTypes, Objects, OWindows, ODialogs;

type
  TPenData = record
    XWidth: array[0..6] of Char;
    ColorArray: array[0..7] of Word;
    StyleArray: array[0..5] of Word;
  end;

  PPenDialog = ^TPenDialog;
  TPenDialog = object(TDialog)
    constructor Init(AParent: PWindowsObject; AName: PChar);
  end;

  PPen = ^TPen;
  TPen = object(TObject)
    Width, Style: Integer;
    Color: Longint;
    constructor Init(AStyle, AWidth:Integer; AColor: Longint);
    constructor InitLike(APen: PPen);
    destructor Done; virtual;
    constructor Load(var S: TStream);
    procedure ChangePen;
    procedure Delete;
    procedure Select(ADC: HDC);
    procedure SetAttributes(AStyle, AWidth: Integer; AColor: Longint);
    procedure Store(var S: TStream);
  private
    PenHandle, OldPen: HPen;
    TheDC: HDC;
    PenData: TPenData;
  end;

const
  RPen: TStreamRec = (
    ObjType: 202;
    VmtLink: Ofs(TypeOf(TPen)^);
    Load: @TPen.Load;
    Store: @TPen.Store);

implementation

uses Strings, WinProcs;

const
  ColorAttr: array[0..7] of Longint =
    (0, $FF0000, $FF00, $FFFF00, $0000FF, $FF00FF, $00FFFF, $FFFFFF);

function GetColorAttr(ARec: TPenData): Longint;
var
  i: Integer;
begin
  for i := 0 to 7 do
    if ARec.ColorArray[i] = bf_Checked then GetColorAttr := ColorAttr[i];
end;

procedure SetColorAttr(var ARec: TPenData; AColor: Longint);
var
  i: Integer;
begin
  for i := 0 to 7 do
    if ColorAttr[i] = AColor then
      ARec.ColorArray[i] := bf_Checked
    else ARec.ColorArray[i] := bf_Unchecked;
end;

function GetStyle(ARec: TPenData): Longint;
var
  i: Integer;
begin
  for i := 0 to 5 do
    if ARec.StyleArray[i] = bf_Checked then GetStyle := i;
end;

procedure SetStyle(var ARec: TPenData; AStyle: Integer);
var
  i: Integer;
begin
  for i := 0 to 5 do
    if i = AStyle then ARec.StyleArray[i] := bf_Checked
  else ARec.StyleArray[i] := bf_Unchecked;
end;

{--------------------------------------------------}
{ TPenDialog's method implementations:             }
{--------------------------------------------------}

constructor TPenDialog.Init(AParent: PWindowsObject; AName: PChar);
var
  AControl: PControl;
  i: Integer;
begin
  inherited Init(AParent, AName);
  AControl := New(PEdit, InitResource(@Self, 1099, 7));
  for i := 0 to 7 do
    AControl := New(PRadioButton, InitResource(@Self, 1100 + i));
  for i := 0 to 5 do
    AControl := New(PRadioButton, InitResource(@Self, 1200 + i));
end;


{--------------------------------------------------}
{ TPen's method implementations:                   }
{--------------------------------------------------}

constructor TPen.Init(AStyle, AWidth: Integer; AColor: Longint);
begin
  inherited Init;
  PenHandle := 0;
  SetAttributes(AStyle, AWidth, AColor);
  FillChar(PenData, SizeOf(PenData), #0);
end;

constructor TPen.InitLike(APen: PPen);
begin
  inherited Init;
  PenHandle := 0;
  SetAttributes(APen^.Style, APen^.Width, APen^.Color);
  FillChar(PenData, SizeOf(PenData), #0);
end;

destructor TPen.Done;
begin
  Delete;
  inherited Done;
end;

constructor TPen.Load(var S: TStream);
begin
  S.Read(Style, SizeOf(Style));
  S.Read(Width, SizeOf(Width));
  S.Read(Color, SizeOf(Color));
  PenHandle := 0;
  FillChar(PenData, SizeOf(PenData), 0);
end;

procedure TPen.ChangePen;
var
  PenDlg: PPenDialog;
  TempWidth, ErrorPos: Integer;
  PenDlgName: PChar;
begin
  if BWCCClassNames then PenDlgName := StrNew('PenDlgB')
  else PenDlgName := StrNew('PenDlg');
  SetColorAttr(PenData, Color);
  SetStyle(PenData, Style);
  wvsprintf(PenData.XWidth, '%d', Width);
  PenDlg := New(PPenDialog, Init(Application^.MainWindow, PenDlgName));
  PenDlg^.TransferBuffer := @PenData;
  if Application^.ExecDialog(PenDlg) <> idCancel then
  begin
    Val(PenData.XWidth, TempWidth, ErrorPos);
    if ErrorPos = 0 then
      SetAttributes(GetStyle(PenData), TempWidth, GetColorAttr(PenData));
  end;
  StrDispose(PenDlgName);
end;

procedure TPen.Delete;
begin
  if PenHandle <> 0 then
  begin
    SelectObject(TheDC, OldPen);
    DeleteObject(PenHandle);
  end;
  PenHandle := 0;
end;

procedure TPen.Select(ADC: HDC);
begin
  if PenHandle <> 0 then Delete;
  TheDC := ADC;
  PenHandle := CreatePen(Style, Width, Color);
  OldPen := SelectObject(TheDC, PenHandle);
end;

procedure TPen.SetAttributes(AStyle, AWidth: Integer; AColor: Longint);
begin
  Style := AStyle;
  Width := AWidth;
  Color := AColor;
end;

procedure TPen.Store(var S: TStream);
begin
  S.Write(Style, SizeOf(Style));
  S.Write(Width, SizeOf(Width));
  S.Write(Color, SizeOf(Color));
end;

begin
  RegisterType(RPen);
end.
