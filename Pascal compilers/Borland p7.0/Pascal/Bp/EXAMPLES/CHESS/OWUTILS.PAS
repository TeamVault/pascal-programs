{************************************************}
{                                                }
{   ObjectWindows Chess Demo                     }
{   Utility objects and procedures               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit OWUtils;

interface

uses WinProcs, WinTypes, Objects, OWindows;

type
  PXtendedApp = ^TXtendedApp;
  TXtendedApp = object (TApplication)
    INIFileName: PChar;
    ProfileWriteEnabled: Boolean;
    constructor Init(AppName: PChar);
    destructor Done; virtual;
    procedure InitINIFileName; virtual;
    procedure EnableAppProfileWrite(Enable: Boolean);
    function  GetAppProfileString(Section, Key, Default,
                     Result: PChar; Size: Word): Integer;
    procedure WriteAppProfileString(Section, Key, S: PChar);
    function  GetAppProfileLongint(Section, Key: PChar;
                     Default: Longint): Longint;
    procedure WriteAppProfileLongint(Section, Key: PChar; Data: Longint);
    function  GetAppProfileRGB(Section, Key: PChar;
                     Default: TColorRef): TColorRef;
    procedure WriteAppProfileRGB(Section, Key: PChar; Data: TColorRef);
    function  GetAppProfileBoolean(Section, Key: PChar;
                                   Default: Boolean): Boolean;
    procedure WriteAppProfileBoolean(Section, Key: PChar; Data: Boolean);
  end;

{ Context returns a composite string id if the MsgCode is non zero,
  otherwise returns zero.  This is handy for mapping multiple error
  code sets with overlapping codes into a non-overlapping set of context
  string ids, as long as they all use zero to indicate "A-Ok, no msg
  needed". The non-overlapped set of context numbers is what you need
  for string resources.  Build your string table entries using a
  context base constant + the error/msg code for each msg string,
  changing the base constant for each group of codes that conflict.  }
function  Context(Ctx, MsgCode: Integer): Integer;

{ StrResMessageBox will accept string ids (typecast to PChars) as well
  as true string pointers.  If the high word of the pointer is zero,
  the low word is used as the string id in a call to LoadString, otherwise
  the pointer is used as-is. The normal MessageBox function is called
  after any string fixups.

  This function makes it convenient to use string id constants and
  string resources instead of string constants in your program.}
function  StrResMessageBox(Parent: HWnd; Txt, Caption: PChar;
  Flags: Word): Integer;

{ StrNewAny:  If Source is a regular string pointer, StrNew is called.
  If Source is a string id, LoadString is called and the result is passed
  to StrNew.  Either way, you get back a pointer which needs to be
  StrDisposed with you're through with it. }
function  StrNewAny(Source: PChar): PChar;

{ StrNewRes:  Load a string resource and StrNew it. }
function  StrNewRes(Source: Word): PChar;

{ StrLoadRes:  Load a string resource into the provided buffer. }
function  StrLoadRes(var Dest: array of Char; Source: Word): PChar;

var
  XApp : PXtendedApp;

implementation

uses Strings;

var
  OldMessageBox : TMessageBox;

constructor TXtendedApp.Init(AppName: PChar);
begin
  InitINIFileName;
  XApp := @Self;
  ProfileWriteEnabled := True;
  inherited Init(AppName);
end;

destructor TXtendedApp.Done;
begin
  inherited Done;
  if INIFileName <> nil then
    StrDispose(INIFileName);
end;

procedure TXtendedApp.InitINIFileName;
var
  Buf: array [0..80] of Char;
  B, E: PChar;
begin
  GetModuleFileName(HInstance, Buf, SizeOf(Buf));
  B := StrRScan(Buf, '\');
  if B = nil then
    B := Buf
  else
    Inc(B);
  E := StrScan(B, '.');
  if E = nil then
    StrCat(B,'.INI')
  else
    StrCopy(E, '.INI');
  INIFileName := StrNew(B);
end;

procedure TXtendedApp.EnableAppProfileWrite(Enable: Boolean);
begin
  ProfileWriteEnabled := Enable;
end;

function TXtendedApp.GetAppProfileString(Section, Key, Default,
  Result: PChar; Size: Word): Integer;
begin
  GetAppProfileString := GetPrivateProfileString(Section, Key, Default,
    Result, Size, INIFileName);
end;

procedure TXtendedApp.WriteAppProfileString(Section, Key, S: PChar);
begin
  if ProfileWriteEnabled then
    WritePrivateProfileString(Section, Key, S, INIFileName);
end;

function  TXtendedApp.GetAppProfileLongint(Section, Key: PChar;
  Default: Longint): Longint;
var
  S: array [0..20] of Char;
  Temp : Longint;
  Code : Integer;
begin
  GetAppProfileLongint := Default;
  GetAppProfileString(Section, Key, '', S, SizeOf(S));
  if S[0] = #0 then  Exit;
  Val(S, Temp, Code);
  if Code <> 0 then  Exit;
  GetAppProfileLongint := Temp;
end;

procedure TXtendedApp.WriteAppProfileLongint(Section, Key: PChar;
  Data: Longint);
var
  Temp: String[15];
begin
  Temp := '';
  Str(Data, Temp);
  Temp := Temp + #0;
  WriteAppProfileString(Section, Key, @Temp[1]);
end;

function TXtendedApp.GetAppProfileRGB(Section, Key: PChar;
  Default: Longint): Longint;
var
  S: array[0..15] of Char;
  P,Q: PChar;
  Code: Integer;
  R,G,B: Byte;
begin
  GetAppProfileRGB := Default;
  S[0] := #0;
  GetAppProfileString(Section, Key, '', S, Sizeof(S)-1);
  if S[0] = #0 then Exit;
  P := StrScan(S, ',');
  if P = nil then Exit;
  P[0] := #0;
  Val(S, R, Code);

  Q := P + 1;
  P := StrScan(Q, ',');
  if P = nil then Exit;
  P[0] := #0;
  Val(Q, G, Code);

  Q := P + 1;
  Val(Q, B, Code);

  GetAppProfileRGB := RGB(R,G,B);
end;

procedure TXtendedApp.WriteAppProfileRGB(Section, Key: PChar;
  Data: TColorRef);
var
  Temp: String[5];
  S: array [0..15] of Char;
begin
  Str(GetRValue(Data), Temp);
  StrCat(StrPCopy(S, Temp), ',');
  Str(GetGValue(Data), Temp);
  Temp := Temp + #0;
  StrCat(StrCat(S, @Temp[1]), ',');
  Str(GetBValue(Data), Temp);
  Temp := Temp + #0;
  StrCat(S, @Temp[1]);
  WriteAppProfileString(Section, Key, S);
end;

function  TXtendedApp.GetAppProfileBoolean(Section, Key: PChar;
  Default: Boolean): Boolean;
var
  S: array [0..5] of Char;
begin
  if Default then
    S[0] := 'Y'
  else
    S[0] := 'N';
  S[1] := #0;
  GetAppProfileString(Section, Key, S, S, SizeOf(S));
  GetAppProfileBoolean := S[0] in ['Y','1'];
end;

procedure TXtendedApp.WriteAppProfileBoolean(Section, Key: PChar;
  Data: Boolean);
begin
  if Data then
    WriteAppProfileString(Section, Key, 'Y')
  else
    WriteAppProfileString(Section, Key, 'N');
end;

function Context(Ctx, MsgCode: Integer): Integer;
begin
  Context := 0;
  if MsgCode <> 0 then
    Context := Ctx + MsgCode;
end;

function StrNewAny(Source: PChar): PChar;
begin
  StrNewAny := nil;
  if Source <> nil then
    if PtrRec(Source).Seg = 0 then
      StrNewAny := StrNewRes(PtrRec(Source).Ofs)
    else
      StrNewAny := StrNew(Source);
end;

function StrNewRes(Source: Word): PChar;
var
  Temp : array [0..255] of Char;
begin
  StrNewRes := StrNew(StrLoadRes(Temp, Source));
end;

function StrLoadRes(var Dest: array of Char; Source: Word): PChar;
begin
  Dest[0] := #0;
  LoadString(HInstance, Source, @Dest, High(Dest));
  StrLoadRes := @Dest;
end;

function  StrResMessageBox(Parent: HWnd;
                           Txt, Caption: PChar;
                           Flags: Word): Integer;
begin
  Txt := StrNewAny(Txt);
  Caption := StrNewAny(Caption);
  StrResMessageBox := OldMessageBox(Parent, Txt, Caption, Flags);
  StrDispose(Txt);
  StrDispose(Caption);
end;


begin
  @OldMessageBox := @MessageBox;
  @MessageBox := @StrResMessageBox;
end.