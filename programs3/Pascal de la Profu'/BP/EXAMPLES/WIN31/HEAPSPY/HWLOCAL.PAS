{$A-,B-,E-,F-,G+,I-,K-,N-,O-,P-,Q-,R-,S-,T+,V-,W-,X+}

{**********************************************}
{                                              }
{   HeapSpy - HWLocal Module                   }
{   Copyright (c) 1992  Borland International  }
{                                              }
{**********************************************}

unit HWLocal;

{$C MOVEABLE DEMANDLOAD DISCARDABLE}

interface

uses Wintypes, WinProcs, Objects, ODialogs, OWindows, BWCC, Strings,
  Toolhelp, HWGlobal, HWHexDmp, HWBitmap;

type
  PLocalWin = ^TLocalWin;
  TLocalWin = object(TSortListWin)
    HHeap: THandle;
    constructor Init(AParent: PWindowsObject; AhHeap: Word; AModule: PChar);
    procedure BuildList; virtual;
    function HandleSelect(LeftClick: Boolean): Boolean; virtual;
    function GetItemString(p: Pointer): PChar; virtual;
    procedure DeleteItem(p: Pointer); virtual;
    function Less(p1, p2: Pointer): integer; virtual;
  end;

implementation

function DoTypeLit(Dest: Pchar; wHeapType, wType: Word;
  Item: Pointer): PChar;
var
  Temp: array[0..6] of Char;
begin
  if wType = lt_Normal then
    StrCopy(Dest,'Normal')
  else if wType = lt_Free then
    StrCopy(Dest,'Free')
  else
    case wHeapType of
      Normal_Heap:
        begin
          Str(wType,Temp);
          StrCat(StrCopy(Dest,'Block Type '),Temp);
        end;
      User_Heap:
          StrCopy(Dest,LocalUserLit[wType]);
      GDI_Heap:
          StrCopy(Dest,LocalGDILit[wType]);
    else
      StrCopy(Dest,'>> Unknown Heap Type <<');
    end;
  DoTypeLit := Dest;
end;


constructor TLocalWin.Init;
var
  ATitle: array[0..30] of Char;
begin
  HHeap := AhHeap;
  WVSPrintF(ATitle,'%s Local Heap',AModule);
  inherited Init(AParent, ATitle, True);
end;

procedure TLocalWin.BuildList;
var
  Local: TLocalEntry;
  LP: PLocalEntry;
begin
  Local.dwSize := sizeof(TLocalEntry);
  LocalFirst(@Local,HHeap);
  repeat
    with Local do
    begin
      New(LP);
      Move(Local,LP^,Sizeof(TLocalEntry));
      List^.AddString(PChar(LP));
    end;
  until not LocalNext(@Local);
end;

function TLocalWin.GetItemString(p: Pointer): PChar;
var
  GL: PLocalEntry absolute p;
  ListString: array[0..127] of Char;
  Temp: array[0..80] of Char;
  NumStr: array[0..20] of Char;
  HexTemp: array[0..4] of Char;
begin
  with GL^ do
  begin
    HexW(ListString,wAddress);
    StrCat(ListString,' H:');
    StrCat(ListString,HexW(HexTemp,hHandle));
    if wcLock = 0 then
      StrCat(ListString,'         ')
    else
      StrCat(ListString,'  Locked ');
    case wFlags of
      1: StrCat(ListString,'Fixed    ');
      4: StrCat(ListString,'Moveable ');
    else
      StrCat(ListString,'         ');
    end;
    DoTypeLit(Temp,wHeapType,wType,Ptr(HHeap,wAddress));
    Str(wSize:7,NumStr);
    StrCat(ListString,NumStr);
    StrCat(ListString,'  ');
    StrCat(ListString,Temp);
    GetItemString := StrNew(ListString);
  end;
end;

procedure TLocalWin.DeleteItem;
begin
  FreeMem(p, Sizeof(TLocalEntry));
end;

function TLocalWin.Less(p1,p2: Pointer): Integer;
var
  LE1: PLocalEntry absolute p1;
  LE2: PLocalEntry absolute p2;
  Key1,Key2: longint;
begin
  case SortOpt of
    cm_sbAddress:
      begin
        Key1 := LE1^.wAddress;
        Key2 := LE2^.wAddress;
      end;
    cm_sbHandle:
      begin
        Key1 := LE1^.hHandle;
        Key2 := LE2^.hHandle;
      end;
    cm_sbSize:
      begin
        Key1 := (Longint(LE1^.wSize) shl 16) or LE1^.wAddress;
        Key2 := (Longint(LE2^.wSize) shl 16) or LE2^.wAddress;
      end;
    cm_sbType:
      begin
        Key1 := (Longint(LE1^.wType) shl 16) or LE1^.wAddress;
        Key2 := (Longint(LE2^.wType) shl 16) or LE2^.wAddress;
      end;
    cm_sbModule:
      begin
        Key1 := LE1^.waddress;
        Key2 := LE2^.waddress;
      end;
  end;
  Less := Compare32(Key1,Key2);
end;

function TLocalWin.HandleSelect(LeftClick: Boolean): Boolean;
var
  GP: PLocalEntry;
begin
  HandleSelect := True;
  GP := PLocalEntry(SendMEssage(List^.hWindow, lb_GetItemData,
    List^.GetSelIndex, 0));
  with Application^,GP^ do
    MakeWindow(New(PHexDmpWin,Init(MainWindow, HHeap, wAddress, wSize)));
end;

end.
