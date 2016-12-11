{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program FConvert;

{ This program converts text files between ANSI and OEM
  character sets. The original text file is renamed to
  a .BAK file and the converted file replaces the original.
  DOS text files use the OEM character set; Windows text
  files generally use the ANSI character set. Converting
  data back and forth will only have an effect if the text
  file contains international characters (ASCII values
  above 128) like the umlaut, etc. Not all OEM characters
  are present in the ANSI character set, and vice versa.
  Therefore, converting between these character sets
  may result in a loss of data. }

uses WinTypes, WinProcs, WinDos, OWindows, ODialogs, OMemory, Strings;

{$I-,S-}
{$R FCONVERT}

const

{ Resource IDs }

  id_Dialog = 100;

{ Convert dialog item IDs }

  id_FileName  = 100;
  id_FilePath  = 101;
  id_FileList  = 102;
  id_DirList   = 103;
  id_OemToAnsi = 104;
  id_AnsiToOem = 105;
  id_Convert   = 106;

{ File specifier maximum length }

  fsFileSpec = fsFileName + fsExtension;

{ Conversion buffer size }

  BufSize = 32768;

type

{ TConvertDialog is the main window of the application. It allows
  the user to select a file and convert it from the Oem to the Ansi
  character set and vice versa. }

  PConvertDialog = ^TConvertDialog;
  TConvertDialog = object(TDlgWindow)
    FileName: array[0..fsPathName] of Char;
    Extension: array[0..fsExtension] of Char;
    FileSpec: array[0..fsFileSpec] of Char;
    constructor Init;
    procedure SetupWindow; virtual;
    function GetClassName: PChar; virtual;
    function GetFileName: Boolean;
    procedure SelectFileName;
    procedure UpdateFileName;
    function UpdateListBoxes: Boolean;
    function  ConvertFile(OemToAnsi: Boolean) : Boolean;
    procedure DoFileName(var Msg: TMessage);
      virtual id_First + id_FileName;
    procedure DoFileList(var Msg: TMessage);
      virtual id_First + id_FileList;
    procedure DoDirList(var Msg: TMessage);
      virtual id_First + id_DirList;
    procedure DoConvert(var Msg: TMessage);
      virtual id_First + id_Convert;
  end;

{ TConvertApp is the application object. It creates a main window of
  type TConvertDialog. }

  TConvertApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

{ Return a pointer to the file name part of a file path. }

function GetFileName(FilePath: PChar): PChar;
var
  P: PChar;
begin
  P := StrRScan(FilePath, '\');
  if P = nil then P := StrRScan(FilePath, ':');
  if P = nil then GetFileName := FilePath else GetFileName := P + 1;
end;

{ Return a pointer to the extension part of a file path. }

function GetExtension(FilePath: PChar): PChar;
var
  P: PChar;
begin
  P := StrScan(GetFileName(FilePath), '.');
  if P = nil then GetExtension := StrEnd(FilePath) else GetExtension := P;
end;

{ Return True if the specified file path contains wildcards. }

function HasWildCards(FilePath: PChar): Boolean;
begin
  HasWildCards := (StrScan(FilePath, '*') <> nil) or
    (StrScan(FilePath, '?') <> nil);
end;

{ Copy Source file name to Dest, changing the extension to Ext. }

function MakeFileName(Dest, Source, Ext: PChar): PChar;
begin
  MakeFileName := StrLCat(StrLCopy(Dest, Source,
    GetExtension(Source) - Source), Ext, fsPathName);
end;

{ Delete a file. }

procedure FileDelete(FileName: PChar);
var
  F: file;
begin
  Assign(F, FileName);
  Erase(F);
  InOutRes := 0;
end;

{ Rename a file. }

procedure FileRename(CurName, NewName: PChar);
var
  F: file;
begin
  Assign(F, CurName);
  Rename(F, NewName);
  InOutRes := 0;
end;

{ TConvertDialog }

{ Convert dialog constructor. }

constructor TConvertDialog.Init;
begin
  TDlgWindow.Init(nil, PChar(id_Dialog));
  StrCopy(FileName, '*.*');
  Extension[0] := #0;
end;

{ SetupWindow is called right after the Convert dialog is created.
  Limit the file name edit control to 79 characters, check the Oem to
  Ansi radio button, update the file and directory list boxes, and
  select the file name edit control. }

procedure TConvertDialog.SetupWindow;
begin
  SendDlgItemMessage(HWindow, id_FileName, em_LimitText, fsPathName, 0);
  CheckRadioButton(HWindow, id_OemToAnsi, id_AnsiToOem, id_OemToAnsi);
  UpdateListBoxes;
  SelectFileName;
end;

{ Return window class name. This name correspons to the class name
  specified for the Convert dialog in the resource file. }

function TConvertDialog.GetClassName: PChar;
begin
  GetClassName := 'ConvertDialog';
end;

{ Return True if the name in the file name edit control is not a
  directory and does not contain wildcards. Otherwise, update the
  file and directory list boxes as required. }

function TConvertDialog.GetFileName: Boolean;
var
  FileLen: Word;
begin
  GetFileName := False;
  GetDlgItemText(HWindow, id_FileName, FileName, fsPathName + 1);
  FileExpand(FileName, FileName);
  FileLen := StrLen(FileName);
  if (FileName[FileLen - 1] = '\') or HasWildCards(FileName) or
    (GetFocus = GetDlgItem(HWindow, id_DirList)) then
  begin
    if FileName[FileLen - 1] = '\' then
      StrLCat(FileName, FileSpec, fsPathName);
    if not UpdateListBoxes then
    begin
      MessageBeep(0);
      SelectFileName;
    end;
    Exit;
  end;
  StrLCat(StrLCat(FileName, '\', fsPathName), FileSpec, fsPathName);
  if UpdateListBoxes then Exit;
  FileName[FileLen] := #0;
  if GetExtension(FileName)[0] = #0 then
    StrLCat(FileName, Extension, fsPathName);
  AnsiLower(FileName);
  GetFileName := True;
end;

{ Select the file name edit control. }

procedure TConvertDialog.SelectFileName;
begin
  SendDlgItemMessage(HWindow, id_FileName, em_SetSel, 0, $7FFF0000);
  SetFocus(GetDlgItem(HWindow, id_FileName));
end;

{ Update the file name edit control. }

procedure TConvertDialog.UpdateFileName;
begin
  SetDlgItemText(HWindow, id_FileName, AnsiLower(FileName));
  SendDlgItemMessage(HWindow, id_FileName, em_SetSel, 0, $7FFF0000);
end;

{ Update the file and directory list boxes. }

function TConvertDialog.UpdateListBoxes: Boolean;
begin
  UpdateListBoxes := False;
  if DlgDirList(HWindow, FileName, id_FileList, id_FilePath, 0) <> 0 then
  begin
    DlgDirList(HWindow, '*.*', id_DirList, 0, $C010);
    StrLCopy(FileSpec, FileName, fsFileSpec);
    UpdateFileName;
    UpdateListBoxes := True;
  end;
end;

{ Convert file from Oem to Ansi or from Ansi to Oem. }

function TConvertDialog.ConvertFile(OemToAnsi: Boolean) : Boolean;
var
  N: Word;
  L: Longint;
  Buffer: Pointer;
  TempName, BakName: array[0..fsPathName] of Char;
  InputFile, OutputFile: file;

  function Error(Stop: Boolean; Message: PChar): Boolean;
  begin
    if Stop then
    begin
      if Buffer <> nil then FreeMem(Buffer, BufSize);
      if TFileRec(InputFile).Mode <> fmClosed then Close(InputFile);
      if TFileRec(OutputFile).Mode <> fmClosed then
      begin
        Close(OutputFile);
        Erase(OutputFile);
      end;
      InOutRes := 0;
      MessageBox(HWindow, Message, 'Error', mb_IconStop + mb_Ok);
    end;
    Error := Stop;
  end;

begin
  ConvertFile := False;
  MakeFileName(TempName, FileName, '.$$$');
  Assign(InputFile, FileName);
  Assign(OutputFile, TempName);
  Buffer := MemAlloc(BufSize);
  if Error(Buffer = nil, 'Not enough memory for copy buffer.') then Exit;
  Reset(InputFile, 1);
  if Error(IOResult <> 0, 'Cannot open input file.') then Exit;
  Rewrite(OutputFile, 1);
  if Error(IOResult <> 0, 'Cannot create output file.') then Exit;
  L := FileSize(InputFile);
  while L > 0 do
  begin
    if L > BufSize then N := BufSize else N := L;
    BlockRead(InputFile, Buffer^, N);
    if Error(IOResult <> 0, 'Error reading input file.') then Exit;
    if OemToAnsi then
      OemToAnsiBuff(Buffer, Buffer, N) else
      AnsiToOemBuff(Buffer, Buffer, N);
    BlockWrite(OutputFile, Buffer^, N);
    if Error(IOResult <> 0, 'Error writing output file.') then Exit;
    Dec(L, N);
  end;
  FreeMem(Buffer, BufSize);
  Close(InputFile);
  Close(OutputFile);
  MakeFileName(BakName, FileName, '.bak');
  FileDelete(BakName);
  FileRename(FileName, BakName);
  FileRename(TempName, FileName);
  ConvertFile := True;
end;

{ File name edit control response method. }

procedure TConvertDialog.DoFileName(var Msg: TMessage);
begin
  if Msg.LParamHi = en_Change then
    EnableWindow(GetDlgItem(HWindow, id_Convert),
      SendMessage(Msg.LParamLo, wm_GetTextLength, 0, 0) <> 0);
end;

{ File list box response method. }

procedure TConvertDialog.DoFileList(var Msg: TMessage);
begin
  case Msg.LParamHi of
    lbn_SelChange, lbn_DblClk:
      begin
        DlgDirSelect(HWindow, FileName, id_FileList);
        UpdateFileName;
        if Msg.LParamHi = lbn_DblClk then DoConvert(Msg);
      end;
    lbn_KillFocus:
      SendMessage(Msg.LParamLo, lb_SetCurSel, Word(-1), 0);
  end;
end;

{ Directory list box response method. }

procedure TConvertDialog.DoDirList(var Msg: TMessage);
begin
  case Msg.LParamHi of
    lbn_SelChange, lbn_DblClk:
      begin
        DlgDirSelect(HWindow, FileName, id_DirList);
        StrCat(FileName, FileSpec);
        if Msg.LParamHi = lbn_DblClk then
          UpdateListBoxes else
          UpdateFileName;
      end;
    lbn_KillFocus:
      SendMessage(Msg.LParamLo, lb_SetCurSel, Word(-1), 0);
  end;
end;

{ Convert button response method. }

procedure TConvertDialog.DoConvert(var Msg: TMessage);
var
  OemToAnsi: Boolean;
  P: array[0..1] of PChar;
  S: array[0..127] of Char;
  InputFile : File;
begin
  if not GetFileName then Exit;
  P[0] := FileName;
  Assign( InputFile, FileName );
  Reset(InputFile, 1);
  if IOResult <> 0 then
  begin
    InOutRes := 0;
    MessageBox(HWindow, 'Cannot open input file.', 'Error', mb_IconStop + mb_Ok);
    Exit;
  end;
  OemToAnsi := IsDlgButtonChecked(HWindow, id_OemToAnsi) <> 0;
  if OemToAnsi then P[1] := 'Oem to Ansi' else P[1] := 'Ansi to Oem';
  WVSPrintF(S, 'Convert %s from %s character set?  ' +
    'Warning: this mapping may be irreversible!', P);
  if MessageBox(HWindow, S, 'Convert',
    mb_IconStop + mb_YesNo + mb_DefButton2) <> id_Yes then Exit;
  if ( ConvertFile(OemToAnsi) = False ) then Exit;
  WVSPrintF(S, 'Done with conversion of %s (a .BAK file was created).', P);
  MessageBox(HWindow, S, 'Success', mb_IconInformation + mb_Ok);
  UpdateListBoxes;
  SelectFileName;
end;

{ TConvertApp }

{ Create a Convert dialog as the application's main window. }

procedure TConvertApp.InitMainWindow;
begin
  MainWindow := New(PConvertDialog, Init);
end;

var
  ConvertApp: TConvertApp;

begin
  ConvertApp.Init('ConvertApp');
  ConvertApp.Run;
  ConvertApp.Done;
end.
