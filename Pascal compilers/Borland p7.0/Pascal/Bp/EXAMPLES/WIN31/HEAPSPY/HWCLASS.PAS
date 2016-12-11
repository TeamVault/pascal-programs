{$A-,B-,E-,F-,G+,I-,K-,N-,O-,P-,Q-,R-,S-,T+,V-,W-,X+}

{**********************************************}
{                                              }
{   HeapSpy - HWClass module                   }
{   Copyright (c) 1992  Borland International  }
{                                              }
{**********************************************}

unit HWClass;

{$C MOVEABLE DEMANDLOAD DISCARDABLE}

interface

uses Wintypes, WinProcs, Objects, ODialogs, OWindows, BWCC, Strings,
  WinDOS, Toolhelp, HWGlobal;

type
  PClassWin = ^TClassWin;
  TClassWin = object(TListWin)
    DetWin : PWindow;
    destructor Done; virtual;
    procedure SetupWindow;  virtual;
    procedure BuildList; virtual;
    function GetItemString(P : Pointer) : PChar; virtual;
    procedure DeleteItem(P : Pointer); virtual;
    function HandleSelect(LeftClick : Boolean) : Boolean; virtual;
  end;

implementation

type
  PClassDlg = ^TClassDlg;
  TClassDlg = object(TBWCCDlg)
    CE: PClassEntry;
    constructor Init(AParent: PWindowsObject; AClassEntry: PClassEntry);
    procedure SetupWindow; virtual;
    procedure SetDlgInt(ID: Word; V: Word);
    procedure SetDlgPtr(ID: Word; V: Pointer);
    procedure SetDlgText(ID: Word; V: PChar);
  end;

constructor TClassDlg.Init;
begin
  inherited Init(AParent,'ClassInfo',0);
  CE := AClassEntry;
end;

procedure TClassDlg.SetDlgInt;
var
  S: array[0..7] of char;
begin
  HexW(S, V);
  SendDlgItemMsg(ID, wm_SetText, 0, LongInt(@S));
end;

procedure TClassDlg.SetDlgPtr;
var
  S: array[0..12] of char;
begin
  HexPtr(s,V);
  SendDlgItemMsg(ID, wm_SetText, 0, LongInt(@S));
end;

procedure TClassDlg.SetDlgText;
begin
  SendDlgItemMsg(ID, wm_SetText, 0, LongInt(V));
end;


procedure TClassDlg.SetupWindow;
var
  WndClass: TWndClass;
  I: integer;
const
  CS_Lits: array[0..15] of PChar = (
   'VRedraw', 'HRedraw', 'KeyCvtWindow', 'DblClks', '0010', 'OwnDC',
   'ClassDC', 'ParentDC', 'NoKeyCVT', 'NoClose', '0400', 'SaveBits',
   'ByteAlignClient', 'ByteAlignWindow', 'GlobalClass', 'UseDefault');
begin
  inherited SetupWindow;
  with CE^ do
    GetClassInfo(hInst,szClassName,WndClass);
  SetDlgText(ci_ClassName,CE^.szClassName);
  with WndClass do
  begin
    SetDlgInt(ci_Style,style);
    SetDlgInt(ci_hCursor,hCursor);
    SetDlgInt(ci_HIcon,hIcon);
    SetDlgPtr(ci_lpfnWndProc,lpfnWndProc);
    SetDlgInt(ci_cbClsExtra,cbClsExtra);
    SetDlgInt(ci_cbWndExtra,cbWndExtra);
    SetDlgInt(ci_hInstance,hInstance);
    SetDlgInt(ci_hbrBackground,hbrBackground);
    for i := 0 to 15 do
    begin
      if Odd(Style) then
        SendDlgItemMsg(ci_StyleList,LB_ADDSTRING,0,LongInt(CS_Lits[i]));
      Style := Style shr 1;
    end;
  end;
end;

destructor TClassWin.Done;
begin
  inherited Done;
end;

procedure TClassWin.BuildList;
var
  CE: TClassEntry;
  CEP: PClassEntry;
  Temp: array[0..127] of char;
  ModName: array[0..fsFileName] of char;
begin
 CE.dwSize := sizeof(TClassEntry);
 ClassFirst(@CE);
 repeat
   New(CEP);
   Move(CE,CEP^,Sizeof(TClassEntry));
   List^.InsertString(PChar(CEP),0);
 until not ClassNext(@CE);
end;

procedure TClassWin.SetupWindow;
begin
  inherited SetupWindow;
end;

procedure TClassWin.DeleteItem;
begin
  FreeMem(p,sizeof(TClassEntry));
end;

function TClassWin.GetItemString(p: Pointer): PChar;
var
  CEP: PClassEntry absolute p;
  Temp: array[0..(12+Max_CLASSNAME)] of char;
  ModName: array[0..fsFileName] of char;
  WndClass: TWndClass;
  GlobalClass: Boolean;
begin
  with CEP^ do
  begin
    if GetClassInfo(hInst,szClassName,WndClass) then
    begin
      Temp[0] := #0;
      GlobalClass :=(WndClass.Style and CS_GLOBALCLASS) <> 0;
      if GlobalClass then
        StrCopy(Temp,'[');
      StrCat(Temp,GetModuleName(hInst,ModName));
      if GlobalClass then
        StrCat(Temp,'] ')
      else
        StrCat(Temp,'.');
        StrCat(Temp,szClassName);
    end
    else
      StrCopy(Temp,'>>> Deleted Class <<<');
  end;
  GetItemString := StrNew(Temp);
end;

function TClassWin.HandleSelect(LeftClick: Boolean): Boolean;
var
  CEP: PClassEntry;
begin
  HandleSelect := true;
  CEP := PClassEntry(SendMessage(List^.hWindow,LB_GETITEMDATA,List^.GetSelIndex,0));
  with CEP^ do
    if not IsValidSelector(hInst) then
    begin
      BWCCMessageBox(hWindow,'Class no longer exists','Class Info',MB_OK);
      List^.DeleteString(List^.GetSelIndex);
      Exit;
    end;
  Application^.ExecDialog(New(PClassDlg,Init(@Self,CEP)));
end;

end.
