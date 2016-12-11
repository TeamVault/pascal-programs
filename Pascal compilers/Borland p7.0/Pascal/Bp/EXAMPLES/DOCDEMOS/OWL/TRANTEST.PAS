{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program TranApp;

{$R TRANTEST.RES }

uses WinTypes, WinProcs, Strings, OWindows, ODialogs;

const
  cm_MenuTest      = 399;
  id_AddressStatic = 101;
  id_MrButton      = 102;
  id_MsButton      = 103;
  id_DrButton      = 104;
  id_NameEdit      = 106;
  id_Address1Edit  = 107;
  id_Address2Edit  = 108;
  id_CityStateEdit = 109;
  id_CountryEdit   = 110;

type
  TransferAddressRecord = record
    AddressStatic: array[0..40] of Char;
    MrTitle: Bool;
    MsTitle: Bool;
    DrTitle: Bool;
    NameEdit: array[0..40] of Char;
    Address1Edit: array[0..40] of Char;
    Address2Edit: array[0..40] of Char;
    CityStateEdit: array[0..40] of Char;
    CountryEdit: array[0..40] of Char;
  end;

  { TransferApplication type declaration. }
  TransferApplication = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

  { TransferWindow type declaration. }
  PTransferWindow = ^TransferWindow;
  TransferWindow = object(TWindow)
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    procedure Test(var Msg: TMessage); virtual cm_First + cm_MenuTest;
  end;

var
  MyApp: TransferApplication;

{ Constructor; init each child control. }
constructor TransferWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  inherited Init(AParent, ATitle);
  Attr.Menu := LoadMenu(HInstance, MakeIntResource(cm_MenuTest));
end;

{ Init the main window of a TransferApplication - an TransferWindow. }
procedure TransferApplication.InitMainWindow;
begin
  MainWindow := New(PTransferWindow, Init(nil, 'Test Dialog Transfer'));
end;

procedure TransferWindow.Test(var Msg: TMessage);
const
  AddressRecord: TransferAddressRecord = (
    AddressStatic: 'First Mailing Label';
    MrTitle: True;
    MsTitle: False;
    DrTitle: False);
  NewLine = #13#10;
var
  D: PDialog;
  S1: PStatic;
  R1: PRadioButton;
  E1: PEdit;
  ReturnValue: Integer;
  ALabel: array[0..255] of Char;
begin
  D := New(PDialog, Init(@Self, MakeIntResource(100)));
  New(S1, InitResource(D, id_AddressStatic, SizeOf(AddressRecord.AddressStatic)));
  New(R1, InitResource(D, id_MrButton));
  New(R1, InitResource(D, id_MsButton));
  New(R1, InitResource(D, id_DrButton));
  New(E1, InitResource(D, id_NameEdit, SizeOf(AddressRecord.NameEdit)));
  New(E1, InitResource(D, id_Address1Edit, SizeOf(AddressRecord.Address1Edit)));
  New(E1, InitResource(D, id_Address2Edit, SizeOf(AddressRecord.Address2Edit)));
  New(E1, InitResource(D, id_CityStateEdit, SizeOf(AddressRecord.CityStateEdit)));
  New(E1, InitResource(D, id_CountryEdit, SizeOf(AddressRecord.CountryEdit)));
  D^.TransferBuffer := @AddressRecord;
  ReturnValue := Application^.ExecDialog(D);
  if ReturnValue = idCancel then
    MessageBox(HWindow, 'Cancelled', 'AddressDialog', 0)
  else
  begin
    StrCopy(ALabel, 'Mailing Label Entered:');
    StrLCat(ALabel, NewLine, SizeOf(ALabel));
    StrLCat(ALabel, NewLine, SizeOf(ALabel));
    StrLCat(ALabel, AddressRecord.NameEdit, SizeOf(ALabel));
    StrLCat(ALabel, NewLine, SizeOf(ALabel));
    StrLCat(ALabel, AddressRecord.Address1Edit, SizeOf(ALabel));
    StrLCat(ALabel, NewLine, SizeOf(ALabel));
    if StrComp(AddressRecord.Address2Edit, '') <> 0 then
    begin
      StrLCat(ALabel, AddressRecord.Address2Edit, SizeOf(ALabel));
      StrLCat(ALabel, NewLine, SizeOf(ALabel));
    end;
    StrLCat(ALabel, AddressRecord.CityStateEdit, SizeOf(ALabel));
    StrLCat(ALabel, NewLine, SizeOf(ALabel));
    StrLCat(ALabel, AddressRecord.CountryEdit, SizeOf(ALabel));
    MessageBox(HWindow, ALabel, 'Test Dialog Transfer', mb_Ok);
    StrCopy(AddressRecord.AddressStatic, 'Subsequent Mailing Labels');
  end;
end;

begin
  MyApp.Init('TranApp');
  MyApp.Run;
  MyApp.Done;
end.
