{************************************************}
{                                                }
{   Resource Workshop Demo                       }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit RWPWnd;

{$R-}

interface

uses RWPDlgs, WinProcs, WinTypes, Objects, OWindows, ODialogs, OMemory,
  Strings, OStdDlgs, RWPDemoC, WinDOS;

const
  OpenEditWindows: Word = 0;
  OpenWindows: Word = 0;

type
  PBaseMDIChildWindow = ^TBaseMDIChildWindow;
  TBaseMDIChildWindow = object(TWindow)
    TheMenu: HMenu;
    constructor Init(aParent: PWindowsObject; ATitle: PChar);
    destructor Done; virtual;
    function GetPopupMenu: HMenu; virtual;
    function GetPopupTitle: PChar; virtual;
    procedure SetEditPopup(Style: Word);
    procedure SetWindowPopup(Style: Word);
    procedure SetupWindow; virtual;
    procedure WMMDIActivate(var Msg: TMessage); virtual wm_MDIActivate;
    procedure WMRButtonDown(var Msg: TMessage); virtual wm_RButtonUp;
  end;

  { TDocument }
  PDocument = ^TDocument;
  TDocument = object(TBaseMDIChildWindow)
    Changed: Boolean;
    FileName: PChar;
    IsNewFile: Boolean;

    constructor Init(AParent: PWindowsObject; AFileName: PChar);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    function CanClear: Boolean; virtual;
    function CanClose: Boolean; virtual;
    procedure ClearModify;
    procedure ClearWindow; virtual;
    procedure CMFileSave(var Msg: TMessage); virtual cm_First + cm_Save;
    procedure CMFileSaveAs(var Msg: TMessage); virtual cm_First + cm_SaveAs;
    function GetTitlePrefix: PChar; virtual;
    function IsModified: Boolean; virtual;
    procedure Read; virtual;
    function Save: Boolean; virtual;
    function SaveAs: Boolean; virtual;
    procedure SetFileName(AFileName: PChar);
    procedure SetupWindow; virtual;
    procedure Store(var S: TStream);
    procedure Write; virtual;
  end;

  { TEditWindow  }
  PEditWindow = ^TEditWindow;
  TEditWindow = object(TDocument)
    Editor: PEdit;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure ClearModify; virtual;
    procedure ClearWindow; virtual;
    function  GetTitlePrefix: PChar; virtual;
    function IsModified: Boolean; virtual;
    procedure Read; virtual;
    procedure Store(var S: TStream);
    procedure WMSize(var Msg: TMessage); virtual wm_First + wm_Size;
    procedure WMSetFocus(var Msg: TMessage); virtual wm_First + wm_SetFocus;
    procedure Write; virtual;
  end;


type
  PGraphObject = ^TGraphObject;
  TGraphObject = object(TObject)
    X1, Y1, X2, Y2: Integer;
    TheColor: TColorRef;
    ThePen: THandle;
    OldPen: THandle;
    constructor Init(R: TRect; AColor: TColorRef);
    constructor Load(var S: TStream);
    procedure Assign(R: TRect);
    procedure Draw(HandleDC: HDC); virtual;
    procedure DrawRect(HandleDC: HDC; R: TRect);
    procedure EndDraw(HandleDC: HDC);
    procedure Store(var S: TStream);
  end;

  PRectangle = ^TRectangle;
  TRectangle = object(TGraphObject)
    procedure Draw(HandleDC: HDC); virtual;
  end;

  PCircle = ^TCircle;
  TCircle = object(TGraphObject)
    procedure Draw(HandleDC: HDC); virtual;
  end;

const
  ShapeCircle = 1;
  ShapeRectangle = 2;

type
  PGraphWindow = ^TGraphWindow;
  TGraphWindow = object(TDocument)
    ButtonDown: Boolean;
    CurrentShape: PGraphObject;
    HandleDC: HDC;
    MenuShape: Integer;
    MenuColor: TColorRef;
    OldROP: Word;
    Rect: TRect;
    TheShapes: PCollection;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    destructor Done; virtual;
    procedure Clear; virtual;
    procedure CMBlue(var Msg: TMessage); virtual cm_First + cm_Blue;
    procedure CMCircle(var Msg: TMessage); virtual cm_First + cm_Circle;
    procedure CMClear(var Msg: TMessage); virtual cm_First + cm_ClearShape;
    procedure CMGreen(var Msg: TMessage); virtual cm_First + cm_Green;
    procedure CMRectangle(var Msg: TMessage); virtual cm_First + cm_Rectangle;
    procedure CMRed(var Msg: TMessage); virtual cm_First + cm_Red;
    function GetPopupMenu: HMenu; virtual;
    function GetPopupTitle: PChar; virtual;
    function GetTitlePrefix: PChar; virtual;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure Read; virtual;
    procedure WMLButtonDown(var Msg: TMessage); virtual wm_First + wm_LButtonDown;
    procedure WMLButtonUp(var Msg: TMessage); virtual wm_First + wm_LButtonUp;
    procedure WMMouseMove(var Msg: TMessage); virtual wm_First + wm_MouseMove;
    procedure Write; virtual;
  end;

type
  PPointCollection = ^TPointCollection;
  TPointCollection = object(TCollection)
    destructor Done; virtual;
    function GetItem(var S: TStream): Pointer; virtual;
    procedure PutItem(var S: TStream; Item: Pointer); virtual;
  end;

type
  PLine = ^TLine;
  TLine = object(TObject)
    X,Y: Integer;
    LineColor: TColorRef;
    PointCollection: PPointCollection;
    LineThickness: Byte;
    constructor Init(AColor: TColorRef; AThickness: Byte);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Store(var S: TStream);
  end;

type
  PScribbleWindow = ^TScribbleWindow;
  TScribbleWindow = object(TDocument)
    ButtonDown: Boolean;
    CurrentLine: PLine;
    HandleDC: HDC;
    LineCollection: PCollection;
    MenuColor: TColorRef;
    MenuThickness: Byte;
    OldPen: THandle;

    constructor Init(aParent: PWindowsObject; ATitle: PChar);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Clear; virtual;
    procedure CMBlue(var Msg: TMessage); virtual cm_First + cm_Blue;
    procedure CMClear(var Msg: TMessage); virtual cm_First + cm_ClearShape;
    procedure CMGreen(var Msg: TMessage); virtual cm_First + cm_Green;
    procedure CMNormal(var Msg: TMessage); virtual cm_First + cm_Normal;
    procedure CMRed(var Msg: TMessage); virtual cm_First + cm_Red;
    procedure CMThick(var Msg: TMessage); virtual cm_First + cm_Thick;
    procedure CMThin(var Msg: TMessage); virtual cm_First + cm_Thin;
    function GetPopupMenu: HMenu; virtual;
    function GetPopupTitle: PChar; virtual;
    function GetTitlePrefix: PChar; virtual;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure Read; virtual;
    procedure Store(var S: TStream); virtual;
    procedure WMLButtonDown(var Msg: TMessage); virtual wm_First + wm_LButtonDown;
    procedure WMLButtonUp(var Msg: TMessage); virtual wm_First + wm_LButtonUp;
    procedure WMMouseMove(var Msg: TMessage); virtual wm_First + wm_MouseMove;
    procedure Write; virtual;
  end;

implementation

function Min(a, b: Word): Word;
begin
  if a < b then Min := a
  else Min := b;
end;

function Max(a, b: Word): Word;
begin
  if a > b then Max := a
  else Max := b;
end;

{---------------- TBaseMDIChildWindow implementation ------------------}

constructor TBaseMDIChildWindow.Init(aParent: PWindowsObject; ATitle: PChar);
begin
  TWindow.Init(aParent, ATitle);
  TheMenu := 0;
end;

procedure TBaseMDIChildWindow.SetupWindow;
begin
  TWindow.SetupWindow;
  if (OpenWindows = 0) then
    SetWindowPopup(mf_Enabled);
  Inc(OpenWindows);
end;

destructor TBaseMDIChildWindow.Done;
begin
  TWindow.Done;
  Dec(OpenWindows);
  if OpenWindows = 0 then
    SetWindowPopup(mf_Disabled or mf_Grayed);
end;


function TBaseMDIChildWindow.GetPopupMenu: HMenu;
begin
  GetPopupMenu := 0;
end;

function TBaseMDIChildWindow.GetPopupTitle: PChar;
begin
  GetPopupTitle := nil;
end;

procedure TBaseMDIChildWindow.SetEditPopup(Style: Word);
var
  AMenu: HMenu;
begin
  if Application^.MainWindow^.HWindow <> 0 then
  begin
    AMenu := GetMenu(Application^.MainWindow^.HWindow);
    if AMenu <> 0 then
    begin
      EnableMenuItem(AMenu, cm_EditUndo, mf_ByCommand or Style);
      EnableMenuItem(AMenu, cm_EditCut, mf_ByCommand or Style);
      EnableMenuItem(AMenu, cm_EditCopy, mf_ByCommand or Style);
      EnableMenuItem(AMenu, cm_EditPaste, mf_ByCommand or Style);
      EnableMenuItem(AMenu, cm_EditClear, mf_ByCommand or Style);
      EnableMenuItem(AMenu, cm_EditDelete, mf_ByCommand or Style);
   end;
  end;
end;

procedure TBaseMDIChildWindow.SetWindowPopup(Style: Word);
var
  AMenu: HMenu;
begin
  if Application^.MainWindow^.HWindow <> 0 then
  begin
    AMenu := GetMenu(Application^.MainWindow^.HWindow);
    if AMenu <> 0 then
    begin
      EnableMenuItem(AMenu, cm_CloseChildren, mf_ByCommand or Style);
      EnableMenuItem(AMenu, cm_TileChildren, mf_ByCommand or Style);
      EnableMenuItem(AMenu, cm_CascadeChildren, mf_ByCommand or Style);
      EnableMenuItem(AMenu, cm_ArrangeIcons, mf_ByCommand or Style);
      EnableMenuItem(AMenu, cm_Save, mf_ByCommand or Style);
      EnableMenuItem(AMenu, cm_SaveAs, mf_ByCommand or Style);
      EnableMenuItem(AMenu, cm_Print, mf_ByCommand or Style);
    end;
  end;  
end;


procedure TBaseMDIChildWindow.WMMDIActivate(var Msg: TMessage);
begin
  DefWndProc(Msg);
  if Typeof(Self) = TypeOf(TEditWindow) then
    SetEditPopup(mf_Enabled)
  else
    SetEditPopup(mf_Grayed);
end;

procedure TBaseMDIChildWindow.WMRButtonDown(var Msg: TMessage);
var
  AMenu: HMenu;
  AName: PChar;
begin
  AMenu := CreatePopupMenu;
  AName := GetPopupTitle;

  if AName <> nil then
  begin
    AppendMenu(AMenu, mf_Popup, GetPopupMenu, AName);
    ClientToScreen(HWindow, MakePoint(Msg.LParam));
    TrackPopupMenu(AMenu, 0, Msg.LParamLo, Msg.LParamHi, 0, HWindow, nil);
    DestroyMenu(AMenu);
  end;
end;

{------------------------- TDocument Implementation ---------------------}
constructor TDocument.Init(AParent: PWindowsObject; AFileName: PChar);
begin
  TBaseMDIChildWindow.Init(AParent, AFileName);
  IsNewFile := True;
  Changed := False;
  if AFileName = nil then
    FileName := nil
  else
    FileName := StrNew(AFileName);
end;

constructor TDocument.Load(var S: TStream);
begin
  TBaseMDIChildWindow.Load(S);
  FileName := S.StrRead;
  IsNewFile := FileName = nil;
end;

destructor TDocument.Done;
begin
  StrDispose(FileName);
  TBaseMDIChildWindow.Done;
end;

function TDocument.CanClear: Boolean;
var
  S: array[0..fsPathName+27] of Char;
  P: PChar;
  Rslt: Integer;
begin
  CanClear := True;
  if IsModified then
  begin
    if FileName = nil then StrCopy(S, 'Untitled file has changed. Save?')
    else
    begin
      P := FileName;
      WVSPrintF(S, 'File "%s" has changed.  Save?', P);
    end;
    Rslt := MessageBox(HWindow, S, 'File Changed',
               mb_YesNoCancel or mb_IconQuestion);
    if Rslt = id_Yes then CanClear := Save
    else CanClear := Rslt <> id_Cancel;
  end;
end;

function TDocument.CanClose: Boolean;
begin
  CanClose := CanClear;
end;

procedure TDocument.ClearWindow;
begin
end;

procedure TDocument.ClearModify;
begin
end;

procedure TDocument.CMFileSave(var Msg: TMessage);
begin
  Save;
end;

procedure TDocument.CMFileSaveAs(var Msg: TMessage);
begin
  SaveAs;
end;

function TDocument.GetTitlePrefix: PChar;
begin
  GetTitlePrefix := nil;
end;

function TDocument.IsModified: Boolean;
begin
  IsModified := Changed;
end;

procedure TDocument.Read;
begin
  IsNewFile := False;
end;

function TDocument.Save: Boolean;
begin
  Save := True;
  if IsModified then
    if IsNewFile then Save := SaveAs
    else Write;
end;

function TDocument.SaveAs: Boolean;
var
  TmpName: array[0..fsPathName] of Char;
begin
  SaveAs := False;
  if FileName <> nil then StrCopy(TmpName, FileName)
  else TmpName[0] := #0;
  if Application^.ExecDialog(New(PFileDialog,
    Init(@Self, PChar(sd_FileSave), TmpName))) = id_Ok then
  begin
    SetFileName(TmpName);
    Write;
    SaveAs := True;
  end;
end;

procedure TDocument.SetFileName(AFileName: PChar);
var
  NewCaption: array[0..80] of Char;
begin
  if FileName <> AFileName then
  begin
    if FileName <> nil then
      StrDispose(FileName);
    FileName := StrNew(AFileName);
  end;

  StrCopy(NewCaption, GetTitlePrefix);
  if FileName = nil then
    StrLCat(NewCaption,'(Untitled)',SizeOf(NewCaption) - StrLen(NewCaption))
  else
    StrLCat(NewCaption, AFileName, SizeOf(NewCaption) - StrLen(NewCaption));
  SetWindowText(HWindow, NewCaption);
end;

procedure TDocument.SetupWindow;
begin
  TBaseMDIChildWindow.SetupWindow;
  SetFileName(FileName);
  if FileName <> nil then Read;
end;

procedure TDocument.Store(var S: TStream);
begin
  TBaseMDIChildWindow.Store(S);
  S.StrWrite(FileName);
end;

procedure TDocument.Write;
begin
  Changed := False;
end;

{------------------------- TEditWindow Implementation ---------------------}

constructor TEditWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  TDocument.Init(AParent, ATitle);
  Editor := New(PEdit, Init(@Self, 200, nil, 0, 0, 0, 0, 0, True));
  with Editor^.Attr do
    Style := Style or es_NoHideSel;
  Inc(OpenEditWindows);
end;

constructor TEditWindow.Load(var S: TStream);
begin
  TDocument.Load(S);
  GetChildPtr(S, Editor);
end;

destructor TEditWindow.Done;
begin
  TDocument.Done;
  Dec(OpenEditWindows);
  if OpenEditWindows = 0 then
    SetEditPopup(mf_Disabled or mf_Grayed);
end;

procedure TEditWindow.ClearModify;
begin
  Editor^.ClearModify;
end;

procedure TEditWindow.ClearWindow;
begin
  Editor^.Clear;
end;

function TEditWindow.GetTitlePrefix: PChar;
begin
  GetTitlePrefix := 'Text: ';
end;

function TEditWindow.IsModified: Boolean;
begin
  IsModified := Editor^.IsModified;
end;

procedure TEditWindow.Read;
const
  BufferSize = 1024;
var
  CharsToRead: LongInt;
  BlockSize: Integer;
  AStream: PDosStream;
  ABuffer: PChar;
begin
  TDocument.Read;
  AStream := New(PDosStream, Init(FileName, stOpen));
  ABuffer := MemAlloc(BufferSize + 1);
  CharsToRead := AStream^.GetSize;
  if ABuffer <> nil then
  begin
    Editor^.Clear;
    while CharsToRead > 0 do
    begin
      if CharsToRead > BufferSize then BlockSize := BufferSize
      else BlockSize := CharsToRead;
      AStream^.Read(ABuffer^, BlockSize);
      ABuffer[BlockSize] := Char(0);
      Editor^.Insert(ABuffer);
      CharsToRead := CharsToRead - BlockSize;
    end;
    IsNewFile := False;
    Editor^.ClearModify;
    Editor^.SetSelection(0, 0);
    FreeMem(ABuffer, BufferSize + 1);
  end;
  Dispose(AStream, Done);
end;

procedure TEditWindow.Store(var S: TStream);
begin
  TDocument.Store(S);
  PutChildPtr(S, Editor);
end;

procedure TEditWindow.WMSetFocus(var Msg: TMessage);
begin
  SetFocus(Editor^.HWindow);
end;

procedure TEditWindow.WMSize(var Msg: TMessage);
begin
  TDocument.WMSize(Msg);
  SetWindowPos(Editor^.HWindow, 0, -1, -1, Msg.LParamLo+2, Msg.LParamHi+2,
    swp_NoZOrder);
end;

procedure TEditWindow.Write;
const
  BufferSize = 1024;
var
  CharsToWrite, CharsWritten: LongInt;
  BlockSize: Integer;
  AStream: PDosStream;
  ABuffer: pointer;
  NumLines: Integer;
begin
  TDocument.Write;
  NumLines := Editor^.GetNumLines;
  CharsToWrite := Editor^.GetLineIndex(NumLines-1) +
    Editor^.GetLineLength(NumLines-1);
  AStream := New(PDosStream, Init(FileName, stCreate));
  ABuffer := MemAlloc(BufferSize + 1);
  CharsWritten := 0;
  if ABuffer <> nil then
  begin
    while CharsWritten < CharsToWrite do
    begin
      if CharsToWrite - CharsWritten > BufferSize then
        BlockSize := BufferSize
      else BlockSize := CharsToWrite - CharsWritten;
      Editor^.GetSubText(ABuffer, CharsWritten, CharsWritten + BlockSize);
      AStream^.Write(ABuffer^, BlockSize);
      CharsWritten := CharsWritten + BlockSize;
    end;
    Editor^.ClearModify;
    FreeMem(ABuffer, BufferSize + 1);
  end;

  Dispose(AStream, Done);
end;

{------------------------- TGraphObject Implementation ---------------------}

constructor TGraphObject.Init(R: TRect; AColor: TColorRef);
begin
  TObject.Init;
  TheColor := AColor;
  Assign(R);
end;

constructor TGraphObject.Load(var S: TStream);
begin
  TObject.Init;
  S.Read(X1, SizeOf(X1));
  S.Read(X2, SizeOf(X2));
  S.Read(Y1, SizeOf(Y1));
  S.Read(Y2, SizeOf(Y2));
  S.Read(TheColor, SizeOf(TheColor));
end;

procedure TGraphObject.Assign(R: TRect);
begin
  with R do
  begin
    X1 := Left;
    X2 := Right;
    Y1 := Top;
    Y2 := Bottom;
  end;
end;

procedure TGraphObject.Draw(HandleDC: HDC);
begin
  ThePen := CreatePen(ps_Solid, 1, TheColor);
  OldPen := SelectObject(HandleDC, ThePen);
end;

procedure TGraphObject.DrawRect(HandleDC: HDC; R: TRect);
begin
  with R do
    SetRect(R, Min(Right, Left), Min(Bottom, Top),
      Max(Right, Left), Max(Top, Bottom));
  Assign(R);
  Draw(HandleDC);
end;

procedure TGraphObject.EndDraw(HandleDC: HDC);
begin
  DeleteObject(SelectObject(HandleDC, OldPen));
end;


procedure TGraphObject.Store(var S: TStream);
begin
  S.Write(X1, SizeOf(X1));
  S.Write(X2, SizeOf(X2));
  S.Write(Y1, SizeOf(Y1));
  S.Write(Y2, SizeOf(Y2));
  S.Write(TheColor, SizeOf(TheColor));
end;

{------------------ TRectangle, TCircle Implementations ---------------}

procedure TRectangle.Draw(HandleDC: HDC);
begin
  TGraphObject.Draw(HandleDC);
  Rectangle(HandleDC, X1, Y1, X2, Y2);
  EndDraw(HandleDC);
end;

procedure TCircle.Draw(HandleDC: HDC);
begin
  TGraphObject.Draw(HandleDC);
  Ellipse(HandleDC, X1, Y1, X2, Y2);
  EndDraw(HandleDC);
end;

{------------------------ TGraphWindow Implementation ------------------}

constructor TGraphWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  TDocument.Init(AParent, ATitle);
  ButtonDown := False;
  MenuShape := ShapeRectangle;
  MenuColor := RGB(255, 0, 0);
  New(TheShapes, Init(5, 5));
end;

destructor TGraphWindow.Done;
begin
  TDocument.Done;
  Dispose(TheShapes, Done);
end;

procedure TGraphWindow.Clear;
begin
  TheShapes^.FreeAll;
  InvalidateRect(HWindow, nil, True);
  UpdateWindow(HWindow);
end;

procedure TGraphWindow.CMBlue(var Msg: TMessage);
begin
  MenuColor := RGB(0, 0, 255);
end;

procedure TGraphWindow.CMCircle(var Msg: TMessage);
begin
  MenuShape := ShapeCircle;
end;

procedure TGraphWindow.CMClear(var Msg: TMessage);
begin
  Clear;
end;

procedure TGraphWindow.CMGreen(var Msg: TMessage);
begin
  MenuColor := RGB(0, 255, 0);
end;

procedure TGraphWindow.CMRectangle(var Msg: TMessage);
begin
  MenuShape := ShapeRectangle;
end;

procedure TGraphWindow.CMRed(var Msg: TMessage);
begin
  MenuColor := RGB(255, 0, 0);
end;

function TGraphWindow.GetPopupMenu: HMenu;
begin
  GetPopupMenu := LoadMenu(HInstance, MakeIntResource(1001));
end;

function TGraphWindow.GetPopupTitle: PChar;
begin
  GetPopupTitle:= 'Graph';
end;

function TGraphWindow.GetTitlePrefix: PChar;
begin
  GetTitlePrefix := 'Graph: ';
end;

procedure TGraphWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);

  procedure DoPaint(GraphObject: PGraphObject); far;
  begin
    GraphObject^.Draw(PaintDC);
  end;

begin
  TheShapes^.ForEach(@DoPaint);
end;

procedure TGraphWindow.Read;
var
  AStream: PDosStream;
  NewShapes: PCollection;
begin
  TDocument.Read;
  AStream := New(PDosStream, Init(FileName, stOpenRead));
  NewShapes := PCollection(AStream^.Get);
  if AStream^.Status <> 0 then
    Status := ste_InvalidGraphFileMsg
  else
  begin
    if TheShapes <> nil then
      Dispose(TheShapes, Done);
    TheShapes := NewShapes;
  end;
  Dispose(AStream, Done);
end;

procedure TGraphWindow.WMLButtonDown(var Msg: TMessage);
begin
  if not ButtonDown then
  begin
    ButtonDown := True;
    Changed := True;
    SetCapture(hWindow);
    HandleDC := GetDC(hWindow);
    OldROP := SetROP2(HandleDC, r2_NotXORPen);
    with Msg do
      SetRect(Rect, LParamLo, LParamHi, LParamLo, LParamHi);
    case MenuShape of
      ShapeRectangle:  CurrentShape := New(PRectangle, Init(Rect, MenuColor));
      ShapeCircle: CurrentShape := New(PCircle, Init(Rect, MenuColor));
    end;
  end;
end;

procedure TGraphWindow.WMLButtonUp(var Msg: TMessage);
begin
  if ButtonDown then
  begin
    ReleaseCapture;
    with Msg do
    begin
      SetRect(Rect, Min(LParamLo, Rect.Left), Min(LParamHi, Rect.Top),
        Max(LParamLo, Rect.Left), Max(LParamHi, Rect.Top));
      SetROP2(HandleDC, OldROP);
      CurrentShape^.Assign(Rect);
      CurrentShape^.Draw(HandleDC);
    end;
    ReleaseDC(HWindow,HandleDC);
    TheShapes^.Insert(CurrentShape);
    ButtonDown := False;
  end;
end;

procedure TGraphWindow.WMMouseMove(var Msg: TMessage);
begin
  if ButtonDown then
  with Msg do
  begin
    CurrentShape^.DrawRect(HandleDC, Rect);
    SetRect(Rect, Rect.Left, Rect.Top,
      LParamLo, LParamHi);
    CurrentShape^.DrawRect(HandleDC, Rect);
  end;
end;

procedure TGraphWindow.Write;
var
  AStream: PDosStream;
begin
  TDocument.Write;
  AStream := New(PDosStream, Init(FileName, stCreate));
  AStream^.Put(TheShapes);
  Dispose(AStream, Done);
end;

{----------------------- TPointCollection Implementation -----------------}

destructor TPointCollection.Done;

  procedure GoodBye(Point: PPoint); far;
  begin
    Dispose(Point);
  end;

begin
  ForEach(@GoodBye);
  DeleteAll;
  TCollection.Done;
end;

function TPointCollection.GetItem(var S: TStream): Pointer;
var
  P: PPoint;
begin
  New(P);
  with P^ do
  begin
    S.Read(X, SizeOf(X));
    S.Read(Y, SizeOf(Y));
  end;
  GetItem := P;
end;

procedure TPointCollection.PutItem(var S: TStream; Item: Pointer);
begin
  with PPoint(Item)^ do
  begin
    S.Write(X, SizeOf(X));
    S.Write(Y, SizeOf(Y));
  end;
end;

{---------------- TLine Implementation -------------------}

constructor TLine.Init(AColor: TColorRef; AThickness: Byte);
begin
  TObject.Init;
  LineColor := AColor;
  LineThickness := AThickness;
  New(PointCollection, Init(100, 50));
end;

constructor TLine.Load(var S: TStream);
begin
  S.Read(X, SizeOf(X));
  S.Read(Y, SizeOf(Y));
  S.Read(LineColor, SizeOf(LineColor));
  S.Read(LineThickness, SizeOf(LineThickness));
  PointCollection := PPointCollection(S.Get);
end;

destructor TLine.Done;
begin
  TObject.Done;
  Dispose(PointCollection, Done);
end;

procedure TLine.Store(var S: TStream);
begin
  S.Write(X, SizeOf(X));
  S.Write(Y, SizeOf(Y));
  S.Write(LineColor, SizeOf(LineColor));
  S.Write(LineThickness, SizeOf(LineThickness));
  S.Put(PointCollection);
end;

{---------------------- TScribbleWindow Implementation ---------------}

constructor TScribbleWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  TDocument.Init(aParent, ATitle);
  ButtonDown := False;
  MenuColor := RGB(255, 0, 0);
  MenuThickness := 3;
  New(LineCollection, Init(5, 5));
end;

constructor TScribbleWindow.Load(var S: TStream);
begin
  TDocument.Load(S);
  LineCollection := PCollection(S.Get);
end;

destructor TScribbleWindow.Done;
begin
  TDocument.Done;
  Dispose(LineCollection, Done);
end;

procedure TScribbleWindow.Clear;
begin
  LineCollection^.FreeAll;
  InvalidateRect(HWindow, nil, True);
  UpdateWindow(HWindow);
end;

procedure TScribbleWindow.CMBlue(var Msg: TMessage);
begin
  MenuColor := RGB(0, 0, 255);
end;

procedure TScribbleWindow.CMClear(var Msg: TMessage);
begin
  Clear;
end;

procedure TScribbleWindow.CMGreen(var Msg: TMessage);
begin
  MenuColor := RGB(0, 255, 0);
end;

procedure TScribbleWindow.CMNormal(var Msg: TMessage);
begin
  MenuThickness := 3;
end;

procedure TScribbleWindow.CMRed(var Msg: TMessage);
begin
  MenuColor := RGB(255, 0, 0);
end;

procedure TScribbleWindow.CMThick(var Msg: TMessage);
begin
  MenuThickness := 5;
end;

procedure TScribbleWindow.CMThin(var Msg: TMessage);
begin
  MenuThickness := 1;
end;

function TScribbleWindow.GetPopupMenu: HMenu;
begin
  GetPopupMenu := LoadMenu(HInstance, MakeIntResource(1000));
end;

function TScribbleWindow.GetPopupTitle: PChar;
begin
  GetPopupTitle:= 'Scribble';
end;

function TScribbleWindow.GetTitlePrefix: PChar;
begin
  GetTitlePrefix := 'Scribble: ';
end;

procedure TScribbleWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);

  procedure DrawLine(Line: PLine); far;

    procedure DrawSegments(Segment: PPoint); far;
    begin
      LineTo(PaintDC, Segment^.X, Segment^.Y);
    end;

  begin
    with Line^ do
    begin
      OldPen := SelectObject(PaintDC, CreatePen(ps_Solid, LineThickness,
        LineColor));
      MoveTo(PaintDC, X, Y);
      PointCollection^.ForEach(@DrawSegments);
      DeleteObject(SelectObject(PaintDC, OldPen));
    end;
  end;

begin
  LineCollection^.ForEach(@DrawLine);
end;

procedure TScribbleWindow.Read;
var
  AStream: PDosStream;
  NewLines: PCollection;
begin
  TDocument.Read;
  AStream := New(PDosStream, Init(FileName, stOpenRead));
  NewLines := PCollection(AStream^.Get);
  if AStream^.Status <> 0 then
    Status := ste_InvalidScribbleFileMsg
  else
  begin
    if LineCollection <> nil then
      Dispose(LineCollection, Done);
    LineCollection := NewLines;
  end;
  Dispose(AStream, Done);
end;

procedure TScribbleWindow.Store(var S: TStream);
begin
  TDocument.Store(S);
  S.Put(LineCollection);
end;

procedure TScribbleWindow.WMLButtonDown(var Msg: TMessage);
begin
  if not ButtonDown then
  begin
    ButtonDown := True;
    Changed := True;
    SetCapture(HWindow);
    HandleDC := GetDC(HWindow);
    OldPen := SelectObject(HandleDC, CreatePen(ps_Solid, MenuThickness,
      MenuColor));
    MoveTo(HandleDC, Msg.LParamLo, Msg.LParamHi);
    New(CurrentLine, Init(MenuColor, MenuThickness));
    CurrentLine^.X := Msg.LParamLo;
    CurrentLine^.Y := Msg.LParamHi;
  end;
end;

procedure TScribbleWindow.WMLButtonUp(var Msg: TMessage);
begin
  if ButtonDown then
  begin
    ReleaseCapture;
    DeleteObject(SelectObject(HandleDC, OldPen));
    ReleaseDC(HWindow,HandleDC);
    ButtonDown := False;
    LineCollection^.Insert(CurrentLine);
  end;
end;

procedure TScribbleWindow.WMMouseMove(var Msg: TMessage);
var
  APoint: PPoint;
begin
  if ButtonDown then
  begin
    LineTo(HandleDC, Msg.LParamLo, Msg.LParamHi);
    New(APoint);
    APoint^.X := Msg.LParamLo;
    APoint^.Y := Msg.LParamHi;
    CurrentLine^.PointCollection^.Insert(APoint);
  end;
end;

procedure TScribbleWindow.Write;
var
  AStream: PDosStream;
begin
  TDocument.Write;
  AStream := New(PDosStream, Init(FileName, stCreate));
  AStream^.Put(LineCollection);
  Dispose(AStream, Done);
end;

{------------------ Stream Registration Records -----------------------}
const
  REditWindow: TStreamRec = (
    ObjType: 80;
    VmtLink: Ofs(TypeOf(TEditWindow)^);
    Load:    @TEditWindow.Load;
    Store:   @TEditWindow.Store);

const
  RDocument: TStreamRec = (
    ObjType: 81;
    VmtLink: Ofs(TypeOf(TDocument)^);
    Load:    @TDocument.Load;
    Store:   @TDocument.Store);

const
  RScribbleWindow: TStreamRec = (
    ObjType: 82;
    VmtLink: Ofs(TypeOf(TScribbleWindow)^);
    Load:    @TScribbleWindow.Load;
    Store:   @TScribbleWindow.Store);

const
  RGraphWindow: TStreamRec = (
    ObjType: 83;
    VmtLink: Ofs(TypeOf(TGraphWindow)^);
    Load:    @TGraphWindow.Load;
    Store:   @TGraphWindow.Store);

const
  RPointCollection: TStreamRec = (
    ObjType: 84;
    VmtLink: Ofs(TypeOf(TPointCollection)^);
    Load:    @TPointCollection.Load;
    Store:   @TPointCollection.Store);

const
  RLine: TStreamRec = (
    ObjType: 85;
    VmtLink: Ofs(TypeOf(TLine)^);
    Load:    @TLine.Load;
    Store:   @TLine.Store);

const
  RGraphObject: TStreamRec = (
    ObjType: 86;
    VmtLink: Ofs(TypeOf(TGraphObject)^);
    Load:    @TGraphObject.Load;
    Store:   @TGraphObject.Store);

const
  RRectangle: TStreamRec = (
    ObjType: 87;
    VmtLink: Ofs(TypeOf(TRectangle)^);
    Load:    @TRectangle.Load;
    Store:   @TRectangle.Store);
const
  RCircle: TStreamRec = (
    ObjType: 88;
    VmtLink: Ofs(TypeOf(TCircle)^);
    Load:    @TCircle.Load;
    Store:   @TCircle.Store);

begin
  RegisterWObjects;
  RegisterType(REditWindow);
  RegisterType(RDocument);
  RegisterType(RScribbleWindow);
  RegisterType(RGraphWindow);
  RegisterType(RPointCollection);
  RegisterType(RLine);
  RegisterType(RGraphObject);
  RegisterType(RRectangle);
  RegisterType(RCircle);
end.

