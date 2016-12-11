{************************************************}
{                                                }
{   ObjectWindows Paint demo                     }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit PaintDlg;

{ This unit supplies the specialized dialogs for the paint program.
}

interface

uses ResDef, WinTypes, WinProcs, OWindows, ODialogs;

type

  PSizeBMInfo = ^TSizeBMInfo;
  TSizeBMInfo = record
    Width, Height: Integer;
    CurrentBMFlag: Integer;
  end;

  PSizeBMDialog = ^TSizeBMDialog;
  TSizeBMDialog = object(TDialog)
    constructor Init(AParent: PWindowsObject; AName: PChar; Buf: Pointer);
  end;

{ Numeric input field }

  PNumEdit = ^TNumEdit;
  TNumEdit = object(TEdit)
    MinValue, MaxValue: Longint;

    constructor Init(AParent: PWindowsObject; AnId: Integer;
      ATitle: PChar; X, Y, W, H: Integer; Digits: Word;
      AMinValue, AMaxValue: Longint);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word;
      Digits: Word; AMinValue, AMaxValue: Longint);
    function CanClose: Boolean; virtual;
    function Transfer(DataPtr: Pointer; TransferFlag: Word): Word; virtual;
  end;

{ Special Radio Buttons }
  
  PIDRadioButton = ^TIDRadioButton;
  TIDRadioButton = object(TRadioButton)
    MyID: Integer;

    constructor InitResource(AParent: PWindowsObject; ResourceID: Word);
    function Transfer(DataPtr: Pointer; TransferFlag:Word): Word; virtual;
  end;

implementation

{ TSizeBMDialog }
constructor TSizeBMDialog.Init(AParent: PWindowsObject; AName: PChar;
                               Buf: Pointer);
var
  P: PWindowsObject;
begin
  TDialog.Init(AParent, AName);

  TransferBuffer := Buf;

  P := New(PNumEdit, InitResource(@Self, id_WidthField, 5, -32768, 32767));
  P := New(PNumEdit, InitResource(@Self, id_HeightField, 5, -32768, 32767));

  P := New(PIDRadioButton, InitResource(@Self, id_StretchBM));
  P := New(PIDRadioButton, InitResource(@Self, id_PadBM));
  P := New(PGroupBox, InitResource(@Self, id_CurrentBMGroup));
end;

{ TNumEdit }

constructor TNumEdit.Init(AParent: PWindowsObject; AnId: Integer;
  ATitle: PChar; X, Y, W, H: Integer; Digits: Word;
  AMinValue, AMaxValue: Longint);
begin
  TEdit.Init(AParent, AnId, ATitle, X, Y, W, H, Digits + 1, False);
  MinValue := AMinValue;
  MaxValue := AMaxValue;
end;

constructor TNumEdit.InitResource(AParent: PWindowsObject;
  ResourceID: Word; Digits: Word; AMinValue, AMaxValue: Longint);
begin
  TEdit.InitResource(AParent, ResourceID, Digits + 1);
  MinValue := AMinValue;
  MaxValue := AMaxValue;
end;

function TNumEdit.CanClose: Boolean;
var
  Valid: Boolean;
  ValCode: Integer;
  Value: LongInt;
  Text: array[0..15] of Char;
  Msg: array[0..63] of Char;
begin
  GetText(Text, SizeOf(Text));
  Val(Text, Value, ValCode);
  Valid := (ValCode = 0) and
    (Value >= MinValue) and (Value <= MaxValue);
  if not Valid then
  begin
    WVSPrintF(Msg, 'Number must be between %ld and %ld', MinValue);
    MessageBox(HWindow, Msg, 'Data error', mb_Ok or mb_IconExclamation);
    SetSelection(0, MaxInt);
    SetFocus(HWindow);
  end;
  CanClose := Valid;
end;

function TNumEdit.Transfer(DataPtr: Pointer; TransferFlag: Word): Word;
var
  ValCode: Integer;
  Text: array[0..15] of Char;
begin
  case TransferFlag of
    tf_GetData:
      begin
        GetText(Text, SizeOf(Text));
        Val(Text, Integer(DataPtr^), ValCode);
      end;
    tf_SetData:
      begin
	Str(Integer(DataPtr^), Text);
        SetText(Text);
      end;
  end;
  Transfer := SizeOf(Integer);
end;

{ TIDRadioButton }
constructor TIDRadioButton.InitResource(AParent: PWindowsObject;
  ResourceID: Word);
begin
  TRadioButton.InitResource(AParent, ResourceID);
  MyID := ResourceID;
end;

function TIDRadioButton.Transfer(DataPtr: Pointer; TransferFlag:Word): Word;
begin
  Transfer := 0;
  case TransferFlag of
    tf_GetData:
      if GetCheck = bf_Checked then
      begin
	Integer(DataPtr^) := MyID;
	Transfer := SizeOf(Integer);
      end;
    tf_SetData:
       if (Integer(DataPtr^) = MyID) or (Integer(DataPtr^) = bf_Checked) then
       begin
	 Check;
	 Transfer := SizeOf(Integer);
       end;
  end;
end;

end.
