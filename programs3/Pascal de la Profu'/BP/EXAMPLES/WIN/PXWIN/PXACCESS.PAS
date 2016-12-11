{************************************************}
{                                                }
{   Paradox Engine demo access unit              }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ Note: This demo requires version 3.0 of the Paradox Engine. }

unit PXAccess;

interface

{$N+}

uses Objects, PXEngWin;

type
  PFieldArray = ^TFieldArray;
  TFieldArray = array[1..256] of PChar;

type
  PPXTable = ^TPXTable;
  TPXTable = object(TObject)
    Status: Integer;
    constructor Init(TableName: PChar);
    destructor Done; virtual;
    procedure ClearError;
    function FieldName(Field: Integer): PChar;
    function FieldType(Field: Integer): PChar;
    function FieldWidth(Field: Integer): Integer;
    function GetField(Rec, Fld: Integer): PChar;
    function NumRecords: LongInt;
    function NumFields: Integer;
    procedure PXError(Error: Integer); virtual;
  private
    CurRecord: Integer;
    TblHandle: TableHandle;
    RecHandle: RecordHandle;
    NumFlds: Integer;
    NumRecs: LongInt;
    FieldNames: PFieldArray;
    FieldTypes: PFieldArray;
    Cache: Pointer;
    function CheckError(Code: Integer): Boolean;
  end;

implementation

uses WinTypes, WinProcs, Strings, PXMsg;

type
  PCache = ^TCache;
  TCache = object(TCollection)
    constructor Init(CacheSize: Integer);
    procedure Add(Index: LongInt; P: PChar);
    function Get(Index: LongInt): PChar;
    procedure FreeItem(P: Pointer); virtual;
  end;

type
  PCacheElement = ^TCacheElement;
  TCacheElement = record
    Index: LongInt;
    Item: PChar;
  end;

constructor TCache.Init(CacheSize: Integer);
begin
  TCollection.Init(CacheSize, 0);
end;

procedure TCache.Add(Index: LongInt; P: PChar);
var
  CE: PCacheElement;
begin
  New(CE);
  CE^.Index := Index;
  CE^.Item := P;
  if Count = Limit then AtFree(Count - 1);
  AtInsert(0, CE);
end;

function TCache.Get(Index: LongInt): PChar;
var
  P: PCacheElement;

  function ItemWithIndex(P: PCacheElement): Boolean; far;
  begin
    ItemWithIndex := P^.Index = Index;
  end;

begin
  Get := nil;
  P := FirstThat(@ItemWithIndex);
  if P <> nil then Get := P^.Item;
end;

procedure TCache.FreeItem(P: Pointer);
begin
  StrDispose(PCacheElement(P)^.Item);
  Dispose(P);
end;

{ TPXTable }

constructor TPXTable.Init(TableName: PChar);
var
  Temp: array[0..25] of Char;
  I: Integer;
begin
  FieldTypes := nil;
  FieldNames := nil;
  Status := 0;
  CurRecord := -1;
  if CheckError(PXTblOpen(TableName, TblHandle, 0, True)) and
     CheckError(PXRecBufOpen(TblHandle, RecHandle)) and
     CheckError(PXRecBufOpen(tblHandle, recHandle)) and
     CheckError(PXRecNFlds(tblHandle, NumFlds)) and
     CheckError(PXTblNRecs(tblHandle, NumRecs)) then
  begin
    GetMem(FieldTypes, NumFields * SizeOf(PChar));
    GetMem(FieldNames, NumFields * SizeOf(PChar));
    for I := 1 to NumFields do
    begin
      CheckError(PXFldName(TblHandle, I, SizeOf(Temp), Temp));
      FieldNames^[I] := StrNew(Temp);
      CheckError(PXFldType(TblHandle, I, SizeOf(Temp), Temp));
      FieldTypes^[I] := StrNew(Temp);
    end;
    Cache := New(PCache, Init(300));
  end;
end;

destructor TPXTable.Done;
var
  I: Integer;
begin
  PXRecBufClose(RecHandle);
  PXTblClose(TblHandle);
  if (FieldTypes <> nil) and (FieldNames <> nil) then
    for I := 1 to NumFields do
    begin
      StrDispose(FieldNames^[I]);
      StrDispose(FieldTypes^[I]);
    end;
  if FieldTypes <> nil then FreeMem(FieldTypes, NumFields * SizeOf(PChar));
  if FieldNames <> nil then FreeMem(FieldNames, NumFields * SizeOf(PChar));
  if Cache <> nil then Dispose(PCache(Cache), Done);
  TObject.Done;
end;

function TPXTable.CheckError(Code: Integer): Boolean;
begin
  if Status = 0 then
  begin
    if Code <> 0 then PXError(Code);
    Status := Code;
  end;
  CheckError := Status = 0;
end;

procedure TPXTable.ClearError;
begin
  Status := 0;
end;

function TPXTable.FieldName(Field: Integer): PChar;
begin
  FieldName := FieldNames^[Field];
end;

function TPXTable.FieldType(Field: Integer): PChar;
begin
  FieldType := FieldTypes^[Field];
end;

function TPXTable.FieldWidth(Field: Integer): Integer;
var
  Width, Code: Integer;
begin
  case FieldTypes^[Field][0] of
    'N',
    '$': FieldWidth := 14;
    'A':
      begin
	Val(PChar(@FieldTypes^[Field][1]), Width, Code);
	FieldWidth := Width
      end;
    'D': FieldWidth := 12;
    'S': FieldWidth := 8;
  else
    FieldWidth := 0;
  end;
end;

function TPXTable.GetField(Rec, Fld: Integer): PChar;
const
  TheData: array[0..255] of Char = '';
var
  Tmp: array[0..255] of Char;
  N: Double;
  I: Integer;
  L: LongInt;
  ArgList: array[0..2] of Integer;
  Index: LongInt;
  P: PChar;
begin
  TheData[0] := #0;
  GetField := TheData;
  if Status <> 0 then Exit;
  if (Rec < 1) or (Rec > NumRecords) then Exit;
  if (Fld < 1) or (Fld > NumFields) then Exit;
  Index := Rec * NumFields + Fld;
  P := PCache(Cache)^.Get(Index);
  if P = nil then
  begin
    if Rec <> CurRecord then
    begin
      CheckError(PXRecGoto(TblHandle, Rec));
      CheckError(PXRecGet(TblHandle, RecHandle));
      CurRecord := Rec;
    end;
    FillChar(TheData, SizeOf(TheData), ' ');
    Tmp[0] := #0;
    case FieldTypes^[Fld][0] of
      'A':
	CheckError(PXGetAlpha(RecHandle, Fld, SizeOf(Tmp), Tmp));
      'N':
	begin
	  CheckError(PXGetDoub(RecHandle, Fld, N));
	  if not IsBlankDouble(N) then
	    Str(N:12:4, Tmp);
	end;
      '$':
	begin
	  CheckError(PXGetDoub(RecHandle, Fld, N));
	  if not IsBlankDouble(N) then
	    Str(N:12:2, Tmp);
	end;
      'S':
	begin
	  CheckError(PXGetShort(RecHandle, Fld, I));
	  if not IsBlankShort(i) then
	    Str(I:6, Tmp)
	end;
      'D':
	begin
	  CheckError(PXGetDate(RecHandle, Fld, L));
	  if Not IsBlankDate(L) then
	  begin
	    CheckError(PXDateDecode(L, ArgList[0], ArgList[1], ArgList[2]));
	    wvSprintf(Tmp, '%2d/%2d/%4d', ArgList);
	  end;
	end;
    end;
    StrMove(TheData, Tmp, StrLen(Tmp));
    TheData[FieldWidth(Fld)] := #0;
    PCache(Cache)^.Add(Index, StrNew(TheData));
  end
  else
    GetField := P;
end;

function TPXTable.NumRecords: LongInt;
begin
  NumRecords := NumRecs;
end;

function TPXTable.NumFields: Integer;
begin
  NumFields := NumFlds;
end;

procedure TPXTable.PXError(Error: Integer);
begin
  MessageBox(GetFocus, PXErrMsg(Error), 'PXAccess', mb_OK)
end;

end.
