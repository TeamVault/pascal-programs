{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program prntest;

uses WinDos, Strings, WinTypes, WinProcs, Objects, OWindows, OStdDlgs, OPrinter, BWCC;

{$R PRNTEST.RES}

{$I PRNTEST.INC}

type
  PPCharCollection = ^TPCharCollection;
  TPCharCollection = object(TCollection)
    procedure FreeItem(Item: Pointer); virtual;
  end;

  PTextWindow = ^TTextWindow;
  TTextWindow = object(TWindow)
    FileName: array[0..fsPathName] of Char;
    FileLines: PPCharCollection;
    Printer: PPrinter;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    destructor Done; virtual;
    procedure CMFileOpen(var Msg: TMessage); virtual cm_First + cm_FileOpen;
    procedure CMFilePrint(var Msg: TMessage); virtual cm_First + cm_FilePrint;
    procedure LoadFile;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
  end;

  TTextApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

  PTextPrint = ^TTextPrint;
  TTextPrint = object(TPrintout)
    TextHeight, LinesPerPage, FirstOnPage, LastOnPage: Integer;
    TheLines: PCollection;
    constructor Init(ATitle: PChar; TheText: PPCharCollection);
    function GetDialogInfo(var Pages: Integer): Boolean; virtual;
    function HasNextPage(Page: Word): Boolean; virtual;
    procedure SetPrintParams(ADC: HDC; ASize: TPoint); virtual;
    procedure PrintPage(Page: Word; var Rect: TRect; Flags: Word); virtual;
  end;


procedure TPCharCollection.FreeItem(Item: Pointer);
begin
  StrDispose(PChar(Item));
end;

constructor TTextWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  inherited Init(AParent, ATitle);
  Attr.Menu := LoadMenu(HInstance, 'MAINMENU');
  Attr.Style := Attr.Style or ws_VScroll or ws_HScroll;
  StrCopy(FileName, '*.*');
  FileLines := New(PPCharCollection, Init(10, 10));
  Scroller := New(PScroller, Init(@Self, 10, 17, 80, 10));
  Printer := New(PPrinter, Init);
end;

destructor TTextWindow.Done;
begin
  if Assigned(FileLines) then Dispose(FileLines, Done);
  inherited Done;
end;

procedure TTextWindow.CMFileOpen(var Msg: TMessage);
begin
  if Application^.ExecDialog(New(PFileDialog, Init(@Self,
    PChar(sd_FileOpen), FileName))) = id_OK then
    LoadFile;
end;

procedure TTextWindow.CMFilePrint(var Msg: TMessage);
var
  Printout: PPrintout;
begin
  Printout := New(PTextPrint, Init(FileName, FileLines));
  Printer^.Print(@Self, Printout);
  Dispose(Printout, Done);
end;

procedure TTextWindow.LoadFile;
var
  TextLine: array[0..255] of Char;
  TextFile: Text;
begin
  if Assigned(FileLines) then Dispose(FileLines, Done);
  FileLines := New(PPCharCollection, Init(100, 10));
  Assign(TextFile, FileName);
  Reset(TextFile);
  while not eof(TextFile) do
  begin
    Readln(TextFile, TextLine);
    FileLines^.Insert(StrNew(TextLine));
  end;
  Close(TextFile);
  Scroller^.SetRange(10, FileLines^.Count);
  InvalidateRect(HWindow, nil, True);
end;

procedure TTextWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  Line: Integer;
  TextMetrics: TTextMetric;
  TheText: PChar;

  function TextVisible(ALine: Integer): Boolean;
  begin
    with Scroller^ do
      TextVisible := IsVisibleRect(0, (ALine div YUnit) + YPos, 1, Attr.W div YUnit);
  end;

begin
  GetTextMetrics(PaintDC, TextMetrics);
  Scroller^.SetUnits(TextMetrics.tmAveCharWidth, TextMetrics.tmHeight);
  Line := 0;
  while (Line < FileLines^.Count) and TextVisible(Line) do
  begin
    TheText := PChar(FileLines^.At(Line));
    if TheText <> nil then
      TextOut(PaintDC, 0, Line * Scroller^.YUnit, TheText, StrLen(TheText));
    Inc(Line);
  end;
end;

procedure TTextApp.InitMainWindow;
begin
  MainWindow := New(PTextWindow, Init(nil, 'Text Viewer'));
end;

constructor TTextPrint.Init(ATitle: PChar; TheText: PPCharCollection);
begin
  inherited Init(ATitle);
  TheLines := TheText;
  FirstOnPage := 0;
  LastOnPage := 0;
end;

function TTextPrint.GetDialogInfo(var Pages: Integer): Boolean;
begin
  Pages := TheLines^.Count div LinesPerPage + 1;
  GetDialogInfo := True;
end;

function TTextPrint.HasNextPage(Page: Word): Boolean;
begin
  HasNextPage := LastOnPage < TheLines^.Count - 1;
end;

procedure TTextPrint.SetPrintParams(ADC: HDC; ASize: TPoint);
var
  TextMetrics: TTextMetric;
begin
  inherited SetPrintParams(ADC, ASize);
  GetTextMetrics(DC, TextMetrics);
  TextHeight := TextMetrics.tmHeight;
  LinesPerPage := Size.Y div TextHeight;
end;

procedure TTextPrint.PrintPage(Page: Word; var Rect: TRect; Flags: Word);
var
  Line: Integer;
  TheText: PChar;
begin
  FirstOnPage := (Page - 1) * LinesPerPage;
  LastOnPage := (Page * LinesPerPage) - 1;
  if LastOnPage >= TheLines^.Count then LastOnPage := TheLines^.Count - 1;
  for Line := FirstOnPage to LastOnPage do
  begin
    TheText := TheLines^.At(Line);
    if TheText <> nil then
      TextOut(DC, 0, (Line - FirstOnPage) * TextHeight, TheText, StrLen(TheText));
  end;
end;

var
  TextApp: TTextApp;

begin
  TextApp.Init('TextPrn');
  TextApp.Run;
  TextApp.Done;
end.
