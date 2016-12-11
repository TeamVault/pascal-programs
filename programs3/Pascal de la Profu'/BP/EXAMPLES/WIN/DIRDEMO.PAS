{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

{ This programs demonstrates how to use the WinCrt unit. See the
  Programmer's Guide for more details. For information on writing more
  advanced Windows applications, read about the ObjectWindows
  application framework in the Windows Programming Guide.
}

program DirDemo;

{$S-}

uses WinTypes, WinProcs, WinCrt, WinDos, Strings;

const
  MaxDirSize = 512;
  MonthStr: array[1..12, 0..3] of Char = (
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

type
  PDirEntry = ^TDirEntry;
  TDirEntry = record
    Attr: Byte;
    Time: Longint;
    Size: Longint;
    Name: array[0..12] of Char;
  end;
  TDirList = array[0..MaxDirSize - 1] of PDirEntry;

var
  Count: Integer;
  Path: array[0..fsPathName] of Char;
  DirList: TDirList;

function NumStr(N: Integer): PChar;
const
  NumText: array[0..2] of Char = '00';
begin
  NumText[0] := Chr(N div 10 + Ord('0'));
  NumText[1] := Chr(N mod 10 + Ord('0'));
  NumStr := NumText;
end;

procedure QuickSort(L, R: Integer);
var
  I, J: Integer;
  X, Y: PDirEntry;
begin
  I := L;
  J := R;
  X := DirList[(L + R) div 2];
  repeat
    while StrComp(DirList[I]^.Name, X^.Name) < 0 do Inc(I);
    while StrComp(DirList[J]^.Name, X^.Name) > 0 do Dec(J);
    if I <= J then
    begin
      Y := DirList[I];
      DirList[I] := DirList[J];
      DirList[J] := Y;
      Inc(I);
      Dec(J);
    end;
  until I > J;
  if L < J then QuickSort(L, J);
  if I < R then QuickSort(I, R);
end;

procedure GetPath;
var
  Attr: Word;
  Dir: array[0..fsDirectory] of Char;
  Name: array[0..fsFileName] of Char;
  Ext: array[0..fsExtension] of Char;
  F: File;
begin
  Write('Show directory of? ');
  ReadLn(Path);
  FileExpand(Path, Path);
  if Path[StrLen(Path) - 1] <> '\' then
  begin
    Assign(F, Path);
    GetFAttr(F, Attr);
    if (DosError = 0) and (Attr and faDirectory <> 0) then
      StrLCat(Path, '\', fsPathName);
  end;
  FileSplit(Path, Dir, Name, Ext);
  if Name[0] = #0 then StrCopy(Name, '*');
  if Ext[0] = #0 then StrCopy(Ext, '.*');
  StrECopy(StrECopy(StrECopy(Path, Dir), Name), Ext);
end;

procedure FindFiles;
var
  N: Word;
  SearchRec: TSearchRec;
begin
  Count := 0;
  FindFirst(Path, faReadOnly + faDirectory + faArchive, SearchRec);
  while (DosError = 0) and (Count < MaxDirSize) do
  begin
    N := StrLen(SearchRec.Name) + 10;
    GetMem(DirList[Count], N);
    Move(SearchRec.Attr, DirList[Count]^, N);
    Inc(Count);
    FindNext(SearchRec);
  end;
end;

procedure SortFiles;
begin
  if Count <> 0 then QuickSort(0, Count - 1);
end;

procedure PrintFiles;
var
  I: Integer;
  Total: Longint;
  P: PChar;
  T: TDateTime;
  N: array[0..fsFileName] of Char;
  E: array[0..fsExtension] of Char;
begin
  WriteLn('Directory of ', Path);
  if Count = 0 then
  begin
    WriteLn('No matching files');
    Exit;
  end;
  Total := 0;
  for I := 0 to Count - 1 do
    with DirList[I]^ do
    begin
      P := StrPos(Name, '.');
      if (P = nil) or (P = Name) then
      begin
        StrCopy(N, Name);
        StrCopy(E, '');
      end else
      begin
        StrLCopy(N, Name, P - Name);
        StrCopy(E, P + 1);
      end;
      Write(N, ' ': 9 - StrLen(N), E, ' ': 4 - StrLen(E));
      if Attr and faDirectory <> 0 then
        Write('<DIR>   ')
      else
        Write(Size: 8);
      UnpackTime(Time, T);
      WriteLn(T.Day: 4, '-',
        MonthStr[T.Month], '-',
        NumStr(T.Year mod 100),
        T.Hour: 4, ':',
        NumStr(T.Min));
      Inc(Total, Size);
    end;
  WriteLn(Count, ' files, ', Total, ' bytes, ',
    DiskFree(Ord(Path[0]) - 64), ' bytes free');
  WriteLn;
end;

begin
  ScreenSize.X := 64;
  ScreenSize.Y := 256;
  while True do
  begin
    GetPath;
    FindFiles;
    SortFiles;
    PrintFiles;
  end;
end.
