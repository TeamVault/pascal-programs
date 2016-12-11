{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program VDlgApp;

{$R VDLGAPP.RES}

uses OWindows, ODialogs, WinTypes, WinProcs, Strings;

const

  cm_Input     = 201;
  id_NameField = 101;
  id_SSNField  = 105;
  id_NumField  = 107;

  NameLen = 25;
  SSNLen  = 11;

type

{ Application object }

  TEmpDataApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

{ Name input field }

  PNameEdit = ^TNameEdit;
  TNameEdit = object(TEdit)
    function CanClose: Boolean; virtual;
  end;

{ Social security number string }

  TSSNStr = array[0..SSNLen] of Char;

{ Social security number input field }

  PSSNEdit = ^TSSNEdit;
  TSSNEdit = object(TEdit)
    constructor Init(AParent: PWindowsObject; AnId: Integer;
      ATitle: PChar; X, Y, W, H: Integer);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word);
    function CanClose: Boolean; virtual;
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

{ Data transfer record for employee data dialog }

  PDataRec = ^TDataRec;
  TDataRec = record
    Name: array [0..NameLen] of Char;
    SSN: TSSNStr;
    Number: Longint;
  end;

{ Application main window }

  PDataWindow = ^TDataWindow;
  TDataWindow = object(TWindow)
    DataRec: TDataRec;
    constructor Init(AParent: PWindowsObject; TheTitle: PChar);
    procedure Input(var Msg: TMessage); virtual cm_First + cm_Input;
  end;

{ TNameEdit }

function TNameEdit.CanClose: Boolean;
const
  CharSet = ['a'..'z','A'..'Z',' ','.'];
var
  I, Len: Integer;
  Text: array[0..255] of Char;
  Valid: Boolean;
begin
  GetText(Text, SizeOf(Text));
  I := 0;
  Len := StrLen(Text);
  Valid := True;
  while Valid and (I < Len) do
  begin
    Valid := Text[I] in CharSet;
    Inc(I);
  end;
  if not Valid then
  begin
    MessageBox(HWindow, 'Invalid character in name', 'Data error',
      mb_Ok or mb_IconExclamation);
    SetSelection(0, MaxInt);
    SetFocus(HWindow);
  end;
  CanClose := Valid;
end;

{ TSSNEdit }

constructor TSSNEdit.Init(AParent: PWindowsObject; AnId: Integer;
  ATitle: PChar; X, Y, W, H: Integer);
begin
  TEdit.Init(AParent, AnId, ATitle, X, Y, W, H, SSNLen + 1, False);
end;

constructor TSSNEdit.InitResource(AParent: PWindowsObject;
  ResourceID: Word);
begin
  TEdit.InitResource(AParent, ResourceID, SSNLen + 1);
end;

function TSSNEdit.CanClose: Boolean;
const
  NumSet = ['0'..'9'];
var
  Valid: Boolean;
  I, Len: Integer;
  SSN: TSSNStr;
begin
  GetText(SSN, SizeOf(SSN));
  Len := StrLen(SSN);
  Valid := (Len = SSNLen) and (SSN[3] = '-') and (SSN[6] = '-');
  I := 0;
  while Valid and (I < Len) do
  begin
    Valid := (I = 3) or (I = 6) or (SSN[I] in NumSet);
    Inc(I);
  end;
  if not Valid then
  begin
    MessageBox(HWindow, 'SSN must be entered as 999-99-9999', 'Data error',
      mb_Ok or mb_IconExclamation);
    SetSelection(0, MaxInt);
    SetFocus(HWindow);
  end;
  CanClose :=  Valid;
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
        Val(Text, Longint(DataPtr^), ValCode);
      end;
    tf_SetData:
      begin
        Str(Longint(DataPtr^), Text);
        SetText(Text);
      end;
  end;
  Transfer := SizeOf(Longint);
end;

{ TDataWindow }

constructor TDataWindow.Init(AParent: PWindowsObject; TheTitle: PChar);
begin
  TWindow.Init(AParent, TheTitle);
  Attr.Menu := LoadMenu(HInstance, 'Commands');
  FillChar(DataRec, SizeOf(DataRec), 0);
end;

procedure TDataWindow.Input(var Msg: TMessage);
var
  Dialog: PDialog;
  P: PWindowsObject;
  Params: array[0..2] of Longint;
  Result: array [0..255] of Char;
begin
  Dialog := New(PDialog, Init(@Self, 'DataDialog'));
  Dialog^.TransferBuffer := @DataRec;
  P := New(PNameEdit, InitResource(Dialog, id_NameField, NameLen + 1));
  P := New(PSSNEdit, InitResource(Dialog, id_SSNField));
  P := New(PNumEdit, InitResource(Dialog, id_NumField, 5, 0, 99999));
  if Application^.ExecDialog(Dialog) = id_OK then
  begin
    Params[0] := Longint(@DataRec.Name);
    Params[1] := Longint(@DataRec.SSN);
    Params[2] := DataRec.Number;
    WVSPrintF(Result,
      'Name:'#9'%s'#13#10'SSN:'#9'%s'#13#10'ID:'#9'%ld', Params);
    MessageBox(HWindow, Result, 'Employee Data Entered', 0);
  end;
end;

{ TEmpDataApp }

procedure TEmpDataApp.InitMainWindow;
begin
  MainWindow := New(PDataWindow, Init(nil, 'Employee Data'));
end;

var
  EmpDataApp: TEmpDataApp;

begin
  EmpDataApp.Init('EmpDataApp');
  EmpDataApp.Run;
  EmpDataApp.Done;
end.
