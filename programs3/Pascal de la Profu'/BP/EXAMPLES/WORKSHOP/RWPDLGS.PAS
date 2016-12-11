{************************************************}
{                                                }
{   Resource Workshop Demo                       }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit RWPDlgs;

interface

uses WinProcs, WinTypes, Objects, OWindows, ODialogs, WinDOS, OStdDlgs,
  RWPDemoC, Strings;

const
  fsFileSpec        = fsPathName + fsExtension;
  ScribbleExtension = '.SCR';
  GraphExtension    = '.GRP';
  TextExtension     = '.TXT';

type
  PRWPDialog = ^TRWPDialog;
  TRWPDialog = object(TDialog)
    function DialogHelp(var Msg: TMessage): integer; virtual id_First + Id_Help;
  end;

type
  PDlgDirectories = ^TDlgDirectories;
  TDlgDirectories = object(TRWPDialog)
    procedure SetupWindow; virtual;
  end;

type
  PFileNew = ^TFileNew;
  TFileNew = object(TRWPDialog)
    FileType: ^Integer;
    constructor Init(AParent: PWindowsObject; var AType: Integer);
    function CanClose: Boolean; virtual;
    procedure SetupWindow; virtual;
  end;

type
  PFileOpen = ^TFileOpen;
  TFileOpen = object(TRWPDialog)
    Caption: PChar;
    FilePath: PChar;
    FileType: ^Integer;
    PathName: array[0..fsPathName] of Char;
    Extension: array[0..fsExtension] of Char;
    FileSpec: array[0..fsFileSpec] of Char;
    constructor Init(AParent: PWindowsObject; var AType: Integer;
      AFilePath: PChar);
    function CanClose: Boolean; virtual;
    function HasWildCards(AFilePath: PChar): Boolean;
    function GetExtension(AFilePath: PChar): PChar;
    function GetFileName(AFilePath: PChar): PChar;
    function GetFileFirst(AFilePath: PChar): PChar;
    procedure HandleBGrp(var Msg: TMessage); virtual id_First + id_Graph;
    procedure HandleBScr(var Msg: TMessage); virtual id_First + id_Scribble;
    procedure HandleBTxt(var Msg: TMessage); virtual id_First + id_Text;
    procedure HandleDList(var Msg: TMessage); virtual id_First + id_DList;
    procedure HandleFList(var Msg: TMessage); virtual id_First + id_FList;
    procedure HandleFName(var Msg: TMessage); virtual id_First + id_FName;
    procedure SetupWindow; virtual;
  private
    procedure SelectFileName;
    procedure UpdateButtons;
    procedure UpdateFileName;
    function UpdateListBoxes: Boolean;
  end;

implementation

function TRwpDialog.DialogHelp(var Msg: TMessage): integer;
begin
  MessageBox(HWindow,'Call WinHelp here','Help',mb_OK or mb_IconInformation);
end;

procedure TDlgDirectories.SetupWindow;
begin
  TRWPDialog.SetupWindow;
  { allow only 128 characters in each combo box }
  SendDlgItemMsg(id_TextDirectory, cb_LimitText, 128, 0);
  SendDlgItemMsg(id_GraphicDirectory, cb_LimitText, 128, 0);
  SendDlgItemMsg(id_ScribbleDirectory, cb_LimitText, 128, 0);
end;

constructor TFileNew.Init(AParent: PWindowsObject; var AType: Integer);
begin
  TRWPDialog.Init(AParent, MakeIntResource(dlg_FileNew));
  FileType := @AType;
end;

function TFileNew.CanClose: Boolean;
begin
  CanClose := True;
  if IsDlgButtonChecked(HWindow, id_Text) = 1 then
    FileType^ := FileWindow
  else
  if IsDlgButtonChecked(HWindow, id_Scribble) = 1 then
    FileType^ := ScribbleWindow
  else
  if IsDlgButtonChecked(HWindow, id_Graphics) = 1 then
    FileType^ := GraphWindow
  else
    CanClose := False;
end;

procedure TFileNew.SetupWindow;
begin
  TRWPDialog.SetupWindow;
  SetFocus(GetDlgItem(HWindow, id_Text));
  SendDlgItemMessage(HWindow, id_Text, bm_SetCheck, 1, 0);
end;

constructor TFileOpen.Init(AParent: PWindowsObject;
  var AType: Integer; AFilePath: PChar);
begin
  TRWPDialog.Init(AParent, MakeIntResource(dlg_Open));
  Caption := nil;
  FilePath := AFilePath;
  FileType := @AType;
end;

function TFileOpen.CanClose: Boolean;
var
  PathLen: Word;
begin
  CanClose := False;
  GetDlgItemText(HWindow, id_FName, PathName, fsPathName + 1);
  FileExpand(PathName, PathName);
  PathLen := StrLen(PathName);
  if (PathName[PathLen - 1] = '\') or HasWildCards(PathName) or
    (GetFocus = GetDlgItem(HWindow, id_DList)) then
  begin
    if PathName[PathLen - 1] = '\' then
      StrLCat(PathName, FileSpec, fsPathName);
    if not UpdateListBoxes then
    begin
      MessageBeep(0);
      SelectFileName;
    end;
    Exit;
  end;
  StrLCat(StrLCat(PathName, '\', fsPathName), FileSpec, fsPathName);
  if UpdateListBoxes then Exit;
  PathName[PathLen] := #0;
  if GetExtension(PathName)[0] = #0 then
    StrLCat(PathName, Extension, fsPathName);
  AnsiLower(StrCopy(FilePath, PathName));
  UpdateButtons;
  if IsDlgButtonChecked(HWindow, id_Text) = 1 then
    FileType^ := FileWindow
  else
  if IsDlgButtonChecked(HWindow, id_Scribble) = 1 then
    FileType^ := ScribbleWindow
  else
  if IsDlgButtonChecked(HWindow, id_Graph) = 1 then
    FileType^ := GraphWindow
  else
  begin
    CanClose := False;
    Exit;
  end;
  CanClose := True;
end;

function TFileOpen.HasWildCards(AFilePath: PChar): Boolean;
begin
  HasWildCards := (StrScan(AFilePath, '*') <> nil) or
    (StrScan(AFilePath, '?') <> nil);
end;

function TFileOpen.GetFileFirst(AFilePath: PChar): PChar;
var
  P, Q: PChar;
begin
  P := GetFileName(AFilePath);
  Q := StrScan(P, '.');
  if Q <> nil then Q[0] := #0;
  GetFileFirst := P;
end;

function TFileOpen.GetExtension(AFilePath: PChar): PChar;
var
  P: PChar;
begin
  P := StrScan(GetFileName(AFilePath), '.');
  if P = nil then GetExtension := StrEnd(FilePath)
  else GetExtension := P;
end;

function TFileOpen.GetFileName(AFilePath: PChar): PChar;
var
  P: PChar;
begin
  P := StrRScan(AFilePath, '\');
  if P = nil then P := StrRScan(AFilePath, ':');
  if P = nil then GetFileName := AFilePath else GetFileName := P + 1;
end;

procedure TFileOpen.SetupWindow;
begin
  TRWPDialog.SetupWindow;
  SendDlgItemMessage(HWindow, id_FName, em_LimitText, fsPathName, 0);
  if Caption <> nil then SetWindowText(HWindow, Caption);
  StrLCopy(PathName, FilePath, fsPathName);
  StrLCopy(Extension, GetExtension(PathName), fsExtension);
  if HasWildCards(Extension) then Extension[0] := #0;
  if not UpdateListBoxes then
  begin
    StrCopy(PathName, '*.*');
    UpdateListBoxes;
  end;
  SelectFileName;
end;

procedure TFileOpen.HandleFName(var Msg: TMessage);
begin
  if Msg.LParamHi = en_Change then
    EnableWindow(GetDlgItem(HWindow, id_Ok),
      SendMessage(Msg.LParamLo, wm_GetTextLength, 0, 0) <> 0);
end;

procedure TFileOpen.HandleFList(var Msg: TMessage);
begin
  case Msg.LParamHi of
    lbn_SelChange, lbn_DblClk:
      begin
	DlgDirSelect(HWindow, PathName, id_FList);
	UpdateFileName;
	if Msg.LParamHi = lbn_DblClk then Ok(Msg);
      end;
    lbn_KillFocus:
      SendMessage(Msg.LParamLo, lb_SetCurSel, Word(-1), 0);
  end;
end;

procedure TFileOpen.HandleDList(var Msg: TMessage);
begin
  case Msg.LParamHi of
    lbn_SelChange, lbn_DblClk:
      begin
	DlgDirSelect(HWindow, PathName, id_DList);
	StrCat(PathName, FileSpec);
	if Msg.LParamHi = lbn_DblClk then
	  UpdateListBoxes else
	  UpdateFileName;
      end;
    lbn_KillFocus:
      SendMessage(Msg.LParamLo, lb_SetCurSel, Word(-1), 0);
  end;
end;

procedure TFileOpen.HandleBScr(var Msg: TMessage);
begin
  StrCat(StrCopy(PathName,GetFileFirst(PathName)), ScribbleExtension);
  UpdateListBoxes;
end;

procedure TFileOpen.HandleBTxt(var Msg: TMessage);
begin
  if StrComp(GetExtension(PathName),'.') <> 0 then
  begin
    StrCat(StrCopy(PathName,GetFileFirst(PathName)), '.TXT');
    UpdateListBoxes;
  end;
end;

procedure TFileOpen.HandleBGrp(var Msg: TMessage);
begin
  StrCat(StrCopy(PathName, GetFileFirst(PathName)), GraphExtension);
  UpdateListBoxes;
end;

procedure TFileOpen.SelectFileName;
begin
  SendDlgItemMessage(HWindow, id_FName, em_SetSel, 0, $7FFF0000);
  SetFocus(GetDlgItem(HWindow, id_FName));
end;

procedure TFileOpen.UpdateFileName;
begin
  SetDlgItemText(HWindow, id_FName, AnsiLower(PathName));
  SendDlgItemMessage(HWindow, id_FName, em_SetSel, 0, $7FFF0000);
  UpdateButtons;
end;

procedure TFileOpen.UpdateButtons;
var
  P: PChar;
  WhichButton: Integer;
begin
  P := GetExtension(PathName);
  if P <> nil then
  begin
    if StrIComp(P, ScribbleExtension) = 0 then
      WhichButton := id_Scribble
    else
    if StrIComp(P, GraphExtension) =  0 then
      WhichButton := id_Graph
    else
      WhichButton := id_Text;
    SendDlgItemMessage(HWindow, id_Text, bm_SetCheck, 0, 0);
    SendDlgItemMessage(HWindow, id_Graph, bm_SetCheck, 0, 0);
    SendDlgItemMessage(HWindow, id_Scribble, bm_SetCheck, 0, 0);
    SendDlgItemMessage(HWindow, WhichButton, bm_SetCheck, 1, 0);
  end;
end;

function TFileOpen.UpdateListBoxes: Boolean;
var
  Result: Integer;
  Path: array[0..fsPathName] of Char;
begin
  UpdateListBoxes := False;
  if GetDlgItem(HWindow, id_FList) <> 0 then
  begin
    StrCopy(Path, PathName);
    Result := DlgDirList(HWindow, Path, id_FList, id_FPath, 0);
    if Result <> 0 then
      DlgDirList(HWindow, '*.*', id_DList, 0, $C010);
  end
  else
  begin
    StrLCopy(Path, PathName, GetFileName(PathName) - PathName);
    StrLCat(Path, '*.*', fsPathName);
    Result := DlgDirList(HWindow, Path, id_DList, id_FPath, $C010);
  end;
  if Result <> 0 then
  begin
    StrLCopy(FileSpec, GetFileName(PathName), fsFileSpec);
    StrCopy(PathName, FileSpec);
    UpdateFileName;
    UpdateListBoxes := True;
  end;
end;

end.
