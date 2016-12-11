{$A-,B-,E-,F-,G+,I-,K-,N-,O-,P-,Q-,R-,S-,T+,V-,W-,X+}

{**********************************************}
{                                              }
{   HeapSpy - HWHeap Module                    }
{   Copyright (c) 1992  Borland International  }
{                                              }
{**********************************************}

unit HWHeap;

{$C MOVEABLE DEMANDLOAD DISCARDABLE}

interface

uses Wintypes, WinProcs, Objects, ODialogs, OWindows, BWCC, Strings,
  Toolhelp, HWGlobal, HWHexDmp, HWBitmap, HWLocal, HWTPWh;

type
  PHeapWin = ^THeapWin;
  THeapWin = object(TSortListWin)
    ModuleName: PChar;
    Module: THandle;
    SelectType: (ModuleHeap, All, FreeHeap);
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    destructor Done; virtual;
    procedure BuildList; virtual;
    function HandleSelect(LeftClick: Boolean): Boolean; virtual;
    function GetItemString(p: pointer): PChar; virtual;
    procedure DeleteItem(p: pointer); virtual;
    function Less(p1,p2: pointer): integer; virtual;
    procedure CMFormDump(var Msg: TMessage);
      virtual cm_First + cm_FormDump;
    procedure CMHexDump(var Msg: TMessage);
      virtual cm_First + cm_HexDump;
    procedure CMLocalWalk(var Msg: TMessage);
      virtual cm_First + cm_LocalWalk;
  end;

implementation

function DoTypeLit(Dest: PChar; wType,wData,hOwner: Word): PChar;
var
   Temp: array[0..4] of Char;
begin
  case wType of
    gt_Resource:
      begin
        StrCopy(Dest,'Resource_');
        StrCat(Dest,GlobalResLit[wData]);
      end;
    else
      StrCopy(Dest, GlobalTypeLit[wType]);
      StrCat(Dest, '[');
      if wType <> gt_CODE then
        StrCat(Dest, HexW(Temp, hOwner))
      else
        StrCat(Dest, HexW(Temp, wData));
      StrCat(Dest, ']');
   end;
 DoTypeLit := Dest;
end;

procedure ChangeTypes(var G: TGlobalEntry);
var
  SB: pTPWSubBlock;
begin
  if G.wType = gt_unknown then
  begin
    SB := PtrFromHandle(G.hBlock);
    if SB <> nil then
      with SB^ do
        if (Signature = $5054) and ((reserved1 or reserved2) = 0) and
          (FreeList < G.dwBlockSize) and (MemFree <= G.dwBlockSize) then
            G.wType := gt_TPWHeap;
  end;
end;




destructor THeapWin.Done;
begin
  StrDispose(ModuleName);
  Inherited Done;
end;

constructor THeapWin.Init;
var Modl: TModuleEntry;
begin
 ModuleName := StrNew(ATitle);
 if StrLComp(ModuleName,'All',3) = 0 then
    SelectType := All
 else
 if StrLComp(ModuleName,'Free',4) = 0 then
    SelectType := FreeHeap
 else
    begin
    SelectType := ModuleHeap;
    Modl.dwSize := Sizeof(TModuleEntry);
    Modl.szModule[0] := #0;
    Module := ModuleFindName(@Modl,ModuleName);
    if Module = 0 then fail;
    end;
 Inherited Init(AParent, ATitle,true);
end;

procedure THeapWin.BuildList;
var
  Globl: TGlobalEntry;
  GP: PGlobalEntry;
begin
  SetCursor(WaitCursor);
  Globl.dwSize := sizeof(TGlobalEntry);
  GlobalFirst(@Globl,GLOBAL_ALL);
  repeat
    ChangeTypes(Globl);
    With Globl do
     if ((SelectType = ModuleHeap) and
        ((hOwner = Module) or IsTaskOf(hOwner,Module))) or
        ((SelectType = FreeHeap) and (hOwner = 0)) or
        (SelectType = All) then
     begin
       New(GP);
       Move(Globl,GP^,Sizeof(TGlobalEntry));
       List^.AddString(PChar(GP));
     end;
   until not GlobalNext(@Globl,GLOBAL_ALL);
   SetCursor(ArrowCursor);
end;

function THeapWin.Less(p1,p2: pointer): integer;
var
  GL1: PGlobalEntry absolute p1;
  GL2: PGlobalEntry absolute p2;
  Key1, Key2: LongInt;
begin
 Case SortOpt of
   cm_sbAddress: begin Key1 := Gl1^.dwAddress;   Key2 := GL2^.dwAddress;   end;
   cm_sbHandle: begin Key1 := GL1^.hBlock;      Key2 := GL2^.hBlock;      end;
   cm_sbSize  : begin Key1 := GL1^.dwBlockSize; Key2 := GL2^.dwBlockSize; end;
   cm_sbType  : begin Key1 := (LongInt(GL1^.wType) shl 16) or GL1^.wdata;
                       Key2 := (LongInt(GL2^.wType) shl 16) or GL2^.wdata; end;
   cm_sbModule: begin Key1 := GL1^.hOwner;      Key2 := GL2^.hOwner;      end;
 end;
 Less := Compare32(Key1,Key2);
end;

function THeapWin.GetItemString(p: pointer): PChar;
var
  GL: PGlobalEntry absolute p;
  ListString: array[0..127] of Char;
  Temp: array[0..80] of Char;
  NumStr: array[0..20] of Char;
  HexTemp: array[0..4] of Char;
  ModuleN: array[0..10] of Char;
  FlagsStr: array[0..5] of Char;
begin
  with GL^ do
  begin
    StrCopy(FlagsStr,'     ');
    if wcLock=1 then FlagsStr[0] := 'L';
    if wcPageLock = 1 then FlagsStr[2] := 'P';
    if wHeapPresent then FlagsStr[4] := 'H';
    HexL(ListString,LongInt(dwAddress));
    StrCat(ListString,' ');
    StrCat(ListString,HexW(HexTemp,hBlock));
    StrCat(ListString,'  ');
    StrCat(ListString,FlagsStr);
    DoTypeLit(Temp,wType,wData,hOwner);
    Str(dwBlockSize:10,NumStr);
    StrCat(ListString,NumStr);
    StrCat(ListString,'  ');
    if SelectType = All then
    begin
      GetModuleName(hOwner,ModuleN);
      StrPad(ModuleN,9);
      StrCat(ListString,ModuleN);
    end;
    StrCat(ListString,Temp);
    GetItemString := StrNew(ListString);
  end;
end;

procedure THeapWin.DeleteItem;
begin
  Freemem(p,Sizeof(TGlobalEntry));
end;

function THeapWin.HandleSelect(LeftClick: Boolean): Boolean;
var
  GP: PGlobalEntry;
  Msg: TMessage;
begin
  HandleSelect := true;
  GP := PGlobalEntry(SendMEssage(List^.hWindow,LB_GETITEMDATA,List^.GetSelIndex,0));
  With Application^,GP^ do
  if (hBlock <> 0) then
    begin
    if (not LeftClick) then
       begin
       if wHeapPresent or (wType = gt_TPWHeap) then
          CMLocalWalk(Msg)
       else if (wType = gt_Resource) and (wData=GD_BitMap) then
          CMFormDump(Msg)
       else
          CMHexDump(Msg);
       end
    else
       CMHexDump(Msg);
    end;
end;

procedure THeapWin.CMLocalWalk;
var
  i: integer;
  GP: PGlobalEntry;
  MN: array[0..10] of Char;
begin
  i := List^.GetSelIndex;
  if i < 0 then exit;
  GP := PGlobalEntry(SendMEssage(List^.hWindow,LB_GETITEMDATA,i,0));
  With Application^,GP^ do
     if wHeapPresent or (wType = gt_TPWHEap) then
        begin
        GetModuleName(hOwner,MN);
        if wType = gt_TPWHeap then
           MakeWindow(New(pTPWHeap,Init(MainWindow,hBlock,MN)))
        else
           MakeWindow(New(PLocalWin,Init(MainWindow,hBlock,MN)));
        end
     else
        BWCCMessageBox(hWindow,'No local heap present',nil,MB_ICONSTOP or MB_OK);
end;

procedure THeapWin.CMHexDump;
var
  i: integer;
  GP: PGlobalEntry;
  MN: array[0..10] of Char;
begin
  i := List^.GetSelIndex;
  if i < 0 then exit;
  GP := PGlobalEntry(SendMEssage(List^.hWindow,LB_GETITEMDATA,i,0));
  With Application^,GP^ do
     if (hBlock <> 0) then
        if MakeWindow(New(PHexDmpWin,Init(MainWindow,hBlock,0,dwBlockSize))) = nil then
           BWCCMessageBox(hWindow,'Unable to lock block',nil,MB_ICONSTOP or MB_OK);
end;

procedure THeapWin.CMFormDump;
var
  i: integer;
  GP: PGlobalEntry;
  MN: array[0..10] of Char;
begin
  i := List^.GetSelIndex;
  if i < 0 then exit;
  GP := PGlobalEntry(SendMEssage(List^.hWindow,LB_GETITEMDATA,i,0));
  With Application^,GP^ do
     if (wType = gt_Resource) and (wData=GD_BitMap) then
        MakeWindow(New(PBitmapWin,Init(MainWindow,@Self,hBlock)))
     else
        BWCCMessageBox(hWindow,'Can''t format this block type',nil,MB_ICONSTOP or MB_OK);
end;

end.
