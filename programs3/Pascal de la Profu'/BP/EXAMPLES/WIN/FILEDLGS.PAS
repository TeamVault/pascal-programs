{************************************************}
{                                                }
{   Demo unit                                    }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

unit FileDlgs;

{$S-}
{$R FILEDLGS}

interface

uses WinTypes, WinProcs, WinDos, Strings;

{ DoFileDialog executes a file dialog. Window specifies the
  parent window of the dialog (typically the application's main
  window). FilePath must point to a zero-based character array
  of fsPathName characters. On entry, DoFileDialog changes to
  the drive and directory (if any) specified by FilePath, and
  the name and extension parts specified by FilePath are used
  as the default file specifier. On exit, if the user pressed
  OK, the resulting fully expanded file path is stored in
  FilePath. DialogName specifies the resource name of the
  dialog. Caption specifies an optional new dialog box title.
  If Caption is nil, the dialog's title is not changed. The
  returned value is True if the user pressed OK, or False if
  the user pressed Cancel. }

function DoFileDialog(Window: HWnd;
  FilePath, DialogName, Caption: PChar): Boolean;

{ DoFileOpen calls DoFileDialog with a DialogName of 'FileOpen'
  and a Caption of nil. The 'FileOpen' dialog is contained in
  the FILEDLGS.RES resource file. }

function DoFileOpen(Window: HWnd; FilePath: PChar): Boolean;

{ DoFileOpen calls DoFileDialog with a DialogName of 'FileSave'
  and a Caption of nil. The 'FileSave' dialog is contained in
  the FILEDLGS.RES resource file. }

function DoFileSave(Window: HWnd; FilePath: PChar): Boolean;

implementation

const
  id_FName = 100;
  id_FPath = 101;
  id_FList = 102;
  id_DList = 103;

const
  fsFileSpec = fsFileName + fsExtension;

type
  TDWord = record
    Lo, Hi: Word;
  end;

var
  GCaption: PChar;
  GFilePath: PChar;
  GPathName: array[0..fsPathName] of Char;
  GExtension: array[0..fsExtension] of Char;
  GFileSpec: array[0..fsFileSpec] of Char;

function GetFileName(FilePath: PChar): PChar;
var
  P: PChar;
begin
  P := StrRScan(FilePath, '\');
  if P = nil then P := StrRScan(FilePath, ':');
  if P = nil then GetFileName := FilePath else GetFileName := P + 1;
end;

function GetExtension(FilePath: PChar): PChar;
var
  P: PChar;
begin
  P := StrScan(GetFileName(FilePath), '.');
  if P = nil then GetExtension := StrEnd(FilePath) else GetExtension := P;
end;

function FileDialog(Dialog: HWnd; Message, WParam: Word;
  LParam: TDWord): Bool; export;
var
  PathLen: Word;

procedure UpdateFileName;
begin
  SetDlgItemText(Dialog, id_FName, StrLower(GPathName));
  SendDlgItemMessage(Dialog, id_FName, em_SetSel, 0, $7FFF0000);
end;

procedure SelectFileName;
begin
  SendDlgItemMessage(Dialog, id_FName, em_SetSel, 0, $7FFF0000);
  SetFocus(GetDlgItem(Dialog, id_FName));
end;

function UpdateListBoxes: Boolean;
var
  Result: Integer;
  Path: array[0..fsPathName] of Char;
begin
  UpdateListBoxes := False;
  if GetDlgItem(Dialog, id_FList) <> 0 then
  begin
    StrCopy(Path, GPathName);
    Result := DlgDirList(Dialog, Path, id_FList, id_FPath, 0);
    if Result <> 0 then DlgDirList(Dialog, '*.*', id_DList, 0, $C010);
  end else
  begin
    StrLCopy(Path, GPathName, GetFileName(GPathName) - GPathName);
    StrLCat(Path, '*.*', fsPathName);
    Result := DlgDirList(Dialog, Path, id_DList, id_FPath, $C010);
  end;
  if Result <> 0 then
  begin
    StrLCopy(GFileSpec, GetFileName(GPathName), fsFileSpec);
    StrCopy(GPathName, GFileSpec);
    UpdateFileName;
    UpdateListBoxes := True;
  end;
end;

begin
  FileDialog := True;
  case Message of
    wm_InitDialog:
      begin
        SendDlgItemMessage(Dialog, id_FName, em_LimitText, fsPathName, 0);
        if GCaption <> nil then SetWindowText(Dialog, GCaption);
        StrLCopy(GPathName, GFilePath, fsPathName);
        StrLCopy(GExtension, GetExtension(GPathName), fsExtension);
        if not UpdateListBoxes then
        begin
          StrCopy(GPathName, '*.*');
          UpdateListBoxes;
        end;
        SelectFileName;
        Exit;
      end;
    wm_Command:
      case WParam of
        id_FName:
          begin
            if LParam.Hi = en_Change then
              EnableWindow(GetDlgItem(Dialog, id_Ok),
                SendMessage(LParam.lo, wm_GetTextLength, 0, 0) <> 0);
            Exit;
          end;
        id_FList:
          if (LParam.Hi = lbn_SelChange) or (LParam.Hi = lbn_DblClk) then
          begin
            DlgDirSelect(Dialog, GPathName, id_FList);
            UpdateFileName;
            if LParam.Hi = lbn_DblClk then
              SendMessage(Dialog, wm_Command, id_Ok, 0);
            Exit;
          end;
        id_DList:
          if (LParam.Hi = lbn_SelChange) or (LParam.Hi = lbn_DblClk) then
          begin
            DlgDirSelect(Dialog, GPathName, id_DList);
            StrCat(GPathName, GFileSpec);
            if LParam.Hi = lbn_DblClk then
              UpdateListBoxes else
              UpdateFileName;
            Exit;
          end;
        id_Ok:
          begin
            GetDlgItemText(Dialog, id_FName, GPathName, fsPathName + 1);
            FileExpand(GPathName, GPathName);
            PathLen := StrLen(GPathName);
            if (GPathName[PathLen - 1] = '\') or
              (StrScan(GPathName, '*') <> nil) or
              (StrScan(GPathName, '?') <> nil) or
              (GetFocus = GetDlgItem(Dialog, id_DList)) then
            begin
              if GPathName[PathLen - 1] = '\' then
                StrLCat(GPathName, GFileSpec, fsPathName);
              if not UpdateListBoxes then
              begin
                MessageBeep(0);
                SelectFileName;
              end;
              Exit;
            end;
            StrLCat(StrLCat(GPathName, '\', fsPathName),
              GFileSpec, fsPathName);
            if UpdateListBoxes then Exit;
            GPathName[PathLen] := #0;
            if GetExtension(GPathName)[0] = #0 then
              StrLCat(GPathName, GExtension, fsPathName);
            StrLower(StrCopy(GFilePath, GPathName));
            EndDialog(Dialog, 1);
            Exit;
          end;
        id_Cancel:
          begin
            EndDialog(Dialog, 0);
            Exit;
          end;
      end;
  end;
  FileDialog := False;
end;

function DoFileDialog(Window: HWnd;
  FilePath, DialogName, Caption: PChar): Boolean;
var
  DialogProc: TFarProc;
begin
  GFilePath := FilePath;
  GCaption := Caption;
  DialogProc := MakeProcInstance(@FileDialog, HInstance);
  DoFileDialog := DialogBox(HInstance, DialogName, Window, DialogProc) = 1;
  FreeProcInstance(DialogProc);
end;

function DoFileOpen(Window: HWnd; FilePath: PChar): Boolean;
begin
  DoFileOpen := DoFileDialog(Window, FilePath, 'FileOpen', nil);
end;

function DoFileSave(Window: HWnd; FilePath: PChar): Boolean;
begin
  DoFileSave := DoFileDialog(Window, FilePath, 'FileSave', nil);
end;

end.
