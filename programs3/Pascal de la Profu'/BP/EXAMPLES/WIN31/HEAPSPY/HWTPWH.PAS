{$A-,B-,E-,F-,G+,I-,K-,N-,O-,P-,Q-,R-,S-,T+,V-,W-,X+}

{**********************************************}
{                                              }
{   HeapSpy - HWTPWh Module                    }
{   Copyright (c) 1992  Borland International  }
{                                              }
{**********************************************}

unit HWTPWh;

{$C MOVEABLE DEMANDLOAD DISCARDABLE}

interface

uses Wintypes, WinProcs, Objects, ODialogs, OWindows, BWCC,
  Strings, Toolhelp, HWGlobal, HWHexDmp, HWBitmap;

type
  PTPWHeap = ^TTPWHeap;
  TTPWHeap = object(TSortListWin)
    HHeap: THandle;
    constructor Init(AParent: PWindowsObject; AHHeap: Word; AModule: PChar);
    procedure BuildList; virtual;
    function HandleSelect(LeftClick: Boolean): Boolean; virtual;
    function GetItemString(p: Pointer): PChar; virtual;
    procedure DeleteItem(p: Pointer); virtual;
    function Less(p1, p2: Pointer): Integer; virtual;
  end;

implementation
type
  PTPWEntry = ^TTPWEntry;
  TTPWEntry = record
    dwSize: LongInt;
    HHeap  : Word;
    wOffset: Word;
    wSize  : Word;
    wType  : Word;
    wNext  : Word;
  end;

const
  TT_Control = 0;
  TT_InUse   = 1;
  TT_Free    = 2;

function DoTypeLit(Dest: PChar; wType: Word): PChar;
const
  TypeLit: array[0..2] of PChar = ('Control','In Use','Free');
begin
  StrCopy(Dest,TypeLit[wType]);
  DoTypeLit := Dest;
end;

function TPWFirst(var T: TTPWEntry;AHeap: THandle): Bool;
var
  Tmp: PTPWSubBlock;
begin
  TPWFirst := False;
  Tmp := PtrFromHandle(AHeap);
  if Tmp = nil then exit;
  with T do
  begin
    HHeap  := aHeap;
    wType := TT_Control;
    wOffset := 0;
    wNext   := SizeOf(Tmp^);
    wSize   := wNext;
  end;
  TPWFirst := True;
end;

function TPWNext(var T: TTPWEntry): Bool;
var
  Tmp: PTPWFreeEntry;
  ff: Word;
  BlockSize: LongInt;

function FindFirstFree(Fence: Word): Word;
var
  Ctl: PTPWSubBlock;
  FreeOfs: Word;
  BestBet: Word;
begin
  BestBet := BlockSize;
  Ctl := PTPWSubBlock(Tmp);
  FreeOfs := Ctl^.FreeList;
  while FreeOfs <> 0 do
  begin
    if FreeOfs >= Fence then
      if FreeOfs <= BestBet then BestBet := FreeOfs;
    Word(Tmp) := FreeOfs;
    FreeOfs := Tmp^.Next;
  end;
  Word(Tmp) := BestBet;
  FindFirstFree := BestBet;
end;

begin
  TPWNext := False;
  BlockSize := GlobalSize(T.HHeap);
  if T.wNext >= BlockSize then exit;
  Tmp := PtrFromHandle(T.HHeap);
  if Tmp = nil then exit;
  ff := FindFirstFree(T.wNext);
  if ff <> T.wNext then
     with T do
     begin
       wType := TT_InUse;
       wOffset := wNext;
       wSize := ff-wNext;
       wNext := ff;
     end
  else
    with T do
    begin
      wType := TT_Free;
      wOffset := ff;
      wSize := Tmp^.Size;
      wNext := ff+wSize;
    end;
 TPWNext := True;
end;

constructor TTPWHeap.Init;
var
  ATitle: array[0..30] of char;
begin
 HHeap := AHHeap;
 WVSPrintF(ATitle,'%s TPW Heap', AModule);
 Inherited Init(AParent,  ATitle, True);
end;

procedure TTPWHeap.BuildList;
var
  TPW: TTPWEntry;
  LP: PTPWEntry;
begin
  TPW.dwSize := sizeof(TTPWEntry);
  TPWFirst(TPW,HHeap);
  repeat
    with TPW do
    begin
      New(LP);
      Move(TPW,LP^,Sizeof(TTPWEntry));
      List^.AddString(PChar(LP));
    end;
   until not TPWNext(TPW);
end;

function TTPWHeap.GetItemString(p: Pointer): PChar;
var
  GL: PTPWEntry absolute p;
  ListString: array[0..127] of Char;
  Temp: array[0..80] of Char;
  NumStr: array[0..20] of Char;
begin
  with GL^ do
  begin
    HexW(ListString,wOffset);
    DoTypeLit(Temp,wType);
    Str(wSize:7,NumStr);
    StrCat(ListString,'  ');
    StrCat(ListString,NumStr);
    StrCat(ListString,'  ');
    StrCat(ListString,Temp);
    GetItemString := StrNew(ListString);
  end;
end;

procedure TTPWHeap.DeleteItem;
begin
  Freemem(p,Sizeof(TTPWEntry));
end;

function TTPWHeap.Less(p1,p2: Pointer): Integer;
var
 LE1: PTPWEntry absolute p1;
 LE2: PTPWEntry absolute p2;
 Key1,Key2: LongInt;
begin
  case SortOpt of
    cm_sbAddress:
      begin
        Key1 := LE1^.wOffset;
        Key2 := LE2^.wOffset;
      end;
    cm_sbHandle:
      begin
        Key1 := LE1^.wOffset;
        Key2 := LE2^.wOffset;
      end;
    cm_sbSize:
      begin
        Key1 := (LongInt(LE1^.wSize) shl 16) or LE1^.wOffset;
        Key2 := (LongInt(LE2^.wSize) shl 16) or LE2^.wOffset;
      end;
    cm_sbType:
      begin
        Key1 := (LongInt(LE1^.wType) shl 16) or LE1^.wOffset;
        Key2 := (LongInt(LE2^.wType) shl 16) or LE2^.wOffset;
      end;
    cm_sbModule:
      begin
        Key1 := LE1^.wOffset;
        Key2 := LE2^.wOffset;
      end;
  end;
  Less := Compare32(Key1, Key2);
end;


function TTPWHeap.HandleSelect(LeftClick: Boolean): Boolean;
var
  GP: PTPWEntry;
begin
  HandleSelect := True;
  GP := PTPWEntry(SendMEssage(List^.hWindow,LB_GETITEMDATA,List^.GetSelIndex,
    0));
  with Application^,GP^ do
    MakeWindow(New(PHexDmpWin,Init(MainWindow,HHeap,wOffset,wSize)));
end;

end.
