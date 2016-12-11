{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program SysInfo;

{$R SysInfo.res}

uses WinProcs, WinTypes, Strings, WinDos, OWindows, ODialogs;

type
  TSysInfoApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

type
  SysInfoRecord = record
    InstanceNumber: Array[0..30] of Char;
    WindowsVersion: Array[0..30] of Char;
    OperationMode: Array[0..30] of Char;
    CPUType: Array[0..30] of Char;
    CoProcessor: Array[0..30] of Char;
    Global: Array[0..30] of Char;
    VersionDos: Array[0..30] of Char;
  end;

  PSysInfoWindow = ^TSysInfoWindow;
  TSysInfoWindow = object(TDlgWindow)
    TransferRecord: SysInfoRecord;
    constructor Init(aParent: PWindowsObject; aTitle: PChar);
    procedure GetSysInformation;
    procedure InitChildren;
  end;

const
  EnhancedID =  0;
  StandardID =  1;
  RealID     =  2;
  CPU8086ID  =  3;
  CPU80186ID =  4;
  CPU80286ID =  5;
  CPU80386ID =  6;
  CPU80486ID =  7;
  YesID      =  8;
  NoID       =  9;
  UnknownID  = 10;

constructor TSysInfoWindow.Init(aParent: PWindowsObject; aTitle: PChar);
begin
  TDlgWindow.Init(aParent, aTitle);
  InitChildren;
  GetSysInformation;
end;

procedure TSysInfoWindow.InitChildren;
var
  s: PStatic;
begin
  new(s, InitResource(@Self, 200, SizeOf(TransferRecord.InstanceNumber)));
  new(s, InitResource(@Self, 201, SizeOf(TransferRecord.WindowsVersion)));
  new(s, InitResource(@Self, 202, SizeOf(TransferRecord.OperationMode)));
  new(s, InitResource(@Self, 203, SizeOf(TransferRecord.CPUType)));
  new(s, InitResource(@Self, 204, SizeOf(TransferRecord.CoProcessor)));
  new(s, InitResource(@Self, 205, SizeOf(TransferRecord.Global)));
  new(s, InitResource(@Self, 206, SizeOf(TransferRecord.VersionDos)));
end;

procedure TSysInfoWindow.GetSysInformation;
var
  SysFlags: word;
  Str: array[0..40] of char;
  Ver: Longint;
  ArgList: array[0..1] of word;
  Available: Longint;
begin
  SysFlags := GetWinFlags;

  ArgList[0] := GetModuleUsage(HInstance);
  wvSprintf(TransferRecord.InstanceNumber, '%d', ArgList);

  Ver := GetVersion;
  ArgList[0] := Lo(LoWord(Ver));
  ArgList[1] := Hi(LoWord(Ver));
  wvSprintf(TransferRecord.WindowsVersion, '%d.%d', ArgList);
  if WordBool(SysFlags and WF_ENHANCED) then
    LoadString(HInstance, EnhancedID, Str, Sizeof(Str))
  else if WordBool(SysFlags and WF_STANDARD) then
    LoadString(HInstance, StandardID, Str, Sizeof(Str))
  else if WordBool(SysFlags and WF_PMODE) then
    LoadString(HInstance, RealID, Str, Sizeof(Str))
  else LoadString(HInstance, UnknownID, Str, Sizeof(Str));

  StrCopy(TransferRecord.OperationMode, Str);

  if WordBool(SysFlags and WF_CPU086) then
    LoadString(HInstance, CPU8086ID, Str, Sizeof(Str))
  else if WordBool(SysFlags and WF_CPU186) then
    LoadString(HInstance, CPU80186ID, Str, Sizeof(Str))
  else if WordBool(SysFlags and WF_CPU286) then
    LoadString(HInstance, CPU80286ID, Str, Sizeof(Str))
  else if WordBool(SysFlags and WF_CPU386) then
    LoadString(HInstance, CPU80386ID, Str, Sizeof(Str))
  else if WordBool(SysFlags and WF_CPU486) then
    LoadString(HInstance, CPU80486ID, Str, Sizeof(Str))
  else LoadString(HInstance, UnknownID, Str, Sizeof(Str));

  StrCopy(TransferRecord.CPUType, Str);

  if WordBool(SysFlags and WF_80x87) then
    LoadString(HInstance, YesID, Str, Sizeof(Str))
  else
    LoadString(HInstance, NoID, Str, Sizeof(Str));

  StrCopy(TransferRecord.Coprocessor, Str);

  Available := GetFreeSpace(0) div 1024;
  ArgList[0] := LoWord(Available);
  ArgList[1] := HiWord(Available);
  wvsprintf(TransferRecord.Global, '%luK', ArgList);

  Ver := DosVersion;
  ArgList[0] := Lo(Ver);
  ArgList[1] := Hi(Ver);
  wvsprintf(TransferRecord.VersionDos, '%d.%d', ArgList);
  TransferBuffer := @TransferRecord;
end;

procedure TSysInfoApp.InitMainWindow;
begin
  MainWindow := new(PSysInfoWindow,Init(nil,MakeIntResource(100)));
end;

var
  SysInfoApp: TSysInfoApp;
begin
  SysInfoApp.Init('SysInfo');
  SysInfoApp.Run;
  SysInfoApp.Done;
end.
