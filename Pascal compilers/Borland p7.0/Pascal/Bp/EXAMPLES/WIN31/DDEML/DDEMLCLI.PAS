{***************************************************}
{                                                   }
{   Windows 3.1 DDEML Demonstration Program         }
{   Copyright (c) 1992 by Borland International     }
{                                                   }
{***************************************************}

program DDEMLClient;

{ This is a sample application demonstrating the use of the DDEML APIs in
  a client application.  It uses the DataEntry server application that
  is part of this demo in order to maintain a display of the entered data
  as a bar graph.

  You must run the server application first (in DDEMLSRV.PAS), and then
  run this client.  If the server is not running, this application will
  fail trying to connect.

  The interface to the server is defined by the list of names (Service,
  Topic, and Items) in the separate unit called DataEntry (DATAENTR.TPU).
  The server makes the Items available in cf_Text format; they are con-
  verted and stored locally as integers.
}

uses Strings, WinTypes, WinProcs, OWindows, ODialogs, Win31, DDEML,
  ShellAPI, BWCC, DataEntry;

{$R DDEMLCLI}

const

{ Resource IDs }

  id_Menu  = 100;
  id_About = 100;
  id_Icon  = 100;

  id_PokeEdit = 201;    { Edit Control in Poke Data dialog }

{ Menu command IDs }

  cm_Request   = 200;
  cm_Poke      = 201;
  cm_Advise    = 202;
  cm_HelpAbout = 300;

type

{ Application main window }

  PDDEClientWindow = ^TDDEClientWindow;
  TDDEClientWindow = object(TWindow)
    Inst: Longint;
    CallBackPtr: ^TCallback;
    ServiceHSz : HSz;
    TopicHSz   : HSz;
    ItemHSz    : array [1..NumValues] of HSz;
    ConvHdl    : HConv;

    DataSample : TDataSample;

    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    destructor  Done; virtual;

    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
    function  GetClassName: PChar; virtual;
    procedure SetupWindow; virtual;

    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;

    procedure CMRequest(var Msg: TMessage);
      virtual cm_First + cm_Request;
    procedure CMPoke(var Msg: TMessage);
      virtual cm_First + cm_Poke;
    procedure CMAdvise(var Msg: TMessage);
      virtual cm_First + cm_Advise;
    procedure CMHelpAbout(var Msg: TMessage);
      virtual cm_First + cm_HelpAbout;

    procedure Request(HConversation: HConv); virtual;
  end;

{ Application object }

  TDDEClientApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

{ Initialized globals }

const
  DemoTitle : PChar = 'DDEML Demo, Client Application';

{ Global variables }

var
  App: TDDEClientApp;


{ Local Function: CallBack Procedure for DDEML }

function CallbackProc(CallType, Fmt: Word; Conv: HConv; hsz1, hsz2: HSZ;
  Data: HDDEData; Data1, Data2: Longint): HDDEData; export;
var
  ThisWindow: PDDEClientWindow;
begin
  CallbackProc := 0;    { See if proved otherwise }

  ThisWindow := PDDEClientWindow(App.MainWindow);

  case CallType of
    xtyp_Register:
      begin
        { Nothing ... Just return 0 }
      end;
    xtyp_Unregister:
      begin
        { Nothing ... Just return 0 }
      end;
    xtyp_xAct_Complete:
      begin
        { Nothing ... Just return 0 }
      end;
    xtyp_Request, Xtyp_AdvData:
      begin
        ThisWindow^.Request(Conv);
        CallbackProc := dde_FAck;
      end;
    xtyp_Disconnect:
      begin
	MessageBox(ThisWindow^.HWindow, 'Disconnected!',
	  Application^.Name, mb_IconStop);
        PostQuitMessage(0);
      end;
  end;
end;


{ TDDEClientWindow Methods }

{ Constructs an instance of the DDE Client Window.  Constructs the 
  window using the inherited constructor, then initializes the instance
  data.
}
constructor TDDEClientWindow.Init(AParent: PWindowsObject; ATitle: PChar);
var
  I : Integer;
begin
  TWindow.Init(AParent, ATitle);

  Inst       := 0;      { Must be zero for first call to DdeInitialize } 
  CallBackPtr:= nil;    { MakeProcInstance is called in SetupWindow    }
  ConvHdl    := 0;
  ServiceHSz := 0;
  TopicHSz   := 0;
  for I := 1 to NumValues do
  begin
    ItemHSz[I]    := 0;
    DataSample[I] := 0;
  end;
end;

{ Destroys an instance of the Client window.  Frees the DDE string
  handles, and frees the callback proc instance if they exist.  Also 
  calls DdeUninitialize to terminate the conversation.  Then calls on
  the ancestral destructor to finish the job.
}
destructor TDDEClientWindow.Done;
var
  I : Integer;
begin
  if ServiceHSz <> 0 then
    DdeFreeStringHandle(Inst, ServiceHSz);
  if TopicHSz <> 0 then
    DdeFreeStringHandle(Inst, TopicHSz);
  for I := 1 to NumValues do
    if ItemHSz[I] <> 0 then
      DdeFreeStringHandle(Inst, ItemHSz[I]);

  if Inst <> 0 then
    DdeUninitialize(Inst);   { Ignore the return value }

  if CallBackPtr <> nil then
    FreeProcInstance(CallBackPtr);

  TWindow.Done;
end;

{ Redefines GetWindowClass to give this application its own Icon, and 
  its own menu.
}
procedure TDDEClientWindow.GetWindowClass(var AWndClass: TWndClass);
begin
  TWindow.GetWindowClass(AWndClass);
  AWndClass.hIcon := LoadIcon(AWndClass.hInstance, PChar(id_Icon));
  AWndClass.lpszMenuName := PChar(id_Menu);
end;

{ Returns the class name of this window.  This is necessary since we
  redefine the inherited GetWindowClass method, above.
}
function TDDEClientWindow.GetClassName: PChar;
begin
  GetClassName := 'TDDEClientWindow';
end;

{ Completes the initialization of the DDE Server Window.  Performs those 
  actions which require a valid window.  Initializes the use of the DDEML.
}
procedure TDDEClientWindow.SetupWindow;
var
  I     : Integer;
  InitOK: Boolean;
begin
  CallBackPtr := MakeProcInstance(@CallBackProc, HInstance);

{ Initialize the DDE and setup the callback function. If server is not
  present, call will fail.
}
  if CallBackPtr <> nil then
  begin
    if DdeInitialize(Inst, TCallback(CallBackPtr), AppCmd_ClientOnly,
      0) = dmlErr_No_Error then
    begin
      ServiceHSz:= DdeCreateStringHandle(Inst, DataEntryName, cp_WinAnsi);
      TopicHSz  := DdeCreateStringHandle(Inst, DataTopicName, cp_WinAnsi);
      InitOK := True;
      for I := 1 to NumValues do
      begin
	ItemHSz[I]:= DdeCreateStringHandle(Inst, DataItemNames[I],
	  cp_WinAnsi);
        InitOK := InitOK and (ItemHSz[I] <> 0); 
      end;

      if (ServiceHSz <> 0) and (TopicHSz <> 0) and InitOK then
      begin
        ConvHdl := DdeConnect(Inst, ServiceHSz, TopicHSz, nil);
        if ConvHdl = 0 then
        begin
	  MessageBox(HWindow, 'Can''t start conversation!',
	    Application^.Name, mb_IconStop);
          PostQuitMessage(0);
        end
      end
      else
      begin  
	MessageBox(HWindow, 'Can''t create strings!', Application^.Name,
	  mb_IconStop);
        PostQuitMessage(0);
      end
    end
    else
    begin
      MessageBox(HWindow, 'Can''t initialize!', Application^.Name,
        mb_IconStop);
      PostQuitMessage(0);
    end;
  end;
end;

{ Repaints the window on request.  Plots a graph of the current sales
  volume.
}
procedure TDDEClientWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
const
  LMarg = 30;    { Left Margin of graph }
var
  Wd, Mid: Integer;
  Step   : Integer;
  I      : Integer;
  Norm   : Integer;
  CRect  : TRect;
  ARect  : TRect;
  ALabel : array [0..10] of Char;
  TextMet: TTextMetric;
begin
{ First, find the maximum value, and compute a normalization
  factor based on it.
}
  Norm := 0;
  for I := 1 to NumValues do
  begin
    if abs(DataSample[I]) > Norm then
      Norm := abs(DataSample[I]);
  end;
  if Norm = 0 then Norm := 1;   { Just in case we have all zeros }

{ Next, paint and label the axes.
}
  GetTextMetrics(PaintDC, TextMet);
  GetClientRect(HWindow, CRect);
  Mid := CRect.Bottom div 2;
  MoveTo(PaintDC, 0, Mid);
  LineTo(PaintDC, CRect.Right, Mid);
  MoveTo(PaintDC, LMarg,      0);
  LineTo(PaintDC, LMarg, CRect.Bottom);
  Str(Norm, ALabel);
  TextOut(PaintDC, 0,0, ALabel, StrLen(ALabel));
  TextOut(PaintDC, 0, Mid-(TextMet.tmHeight div 2), '0', 1);
  Str(-Norm, ALabel);
  TextOut(PaintDC, 0,CRect.Bottom-TextMet.tmHeight, ALabel, StrLen(ALabel));

{ Now draw the bars based on that Normalized value.  Compute the width
  of the bars so that all will fit in the window, and compute an inter-
  bar space that is approximately 20% of the width of a bar.
}
  SelectObject(PaintDC, CreateSolidBrush(RGB(255, 0, 0)));
  SetBkMode(PaintDC, Transparent);

  Wd  := (CRect.Right - LMarg) div NumValues;
  Step:= Wd div 5;
  Wd  := Wd - Step;
  ARect.Left := LMarg + (Step div 2);
  for I := 1 to NumValues do
  begin
    with ARect do
    begin
      Right := Left + Wd;
      Top   := Mid;
      Bottom:= Top - Round((Top-5) * (DataSample[I] / Norm));
      Rectangle(PaintDC, Left, Top, Right, Bottom);
      Bottom:= Top + 20;
      DrawText(PaintDC, DataItemNames[I], -1, ARect, dt_Center);
      Left := Left + Wd + Step;
    end;
  end;
  DeleteObject(SelectObject(PaintDC, GetStockObject(White_Brush)));
end;

{ Generate a DDE Request in response to the DDE | Request menu selection.
}
procedure TDDEClientWindow.CMRequest(var Msg: TMessage);
begin
  Request(ConvHdl);
end;

{ Generates a DDE Poke transaction in response to the DDE | Poke
  menu selection.  Requests a value from the user that will be
  poked into DataItem1 as an illustration of the Poke function.
}
procedure TDDEClientWindow.CMPoke(var Msg: TMessage);
var
  DataStr: TDataString;
  PokeDlg: PDialog;
  Ed     : PEdit;
begin
  PokeDlg := New(PDialog, Init(@Self, 'POKEDATA'));
  New(Ed, InitResource(PokeDlg, id_PokeEdit, SizeOf(DataStr)));
  StrCopy(DataStr, '0');
  PokeDlg^.TransferBuffer := @DataStr;

  if Application^.ExecDialog(PokeDlg) = IdOK then
  begin
    DdeClientTransaction(@DataStr, StrLen(DataStr) + 1, ConvHdl,
      ItemHSz[1], cf_Text, xtyp_Poke, 1000, nil);
    Request(ConvHdl);
  end;
end;

{ Toggles the state of the DDE Advise setting in response to the
  DDE | Advise menu selection.  When this is selected, all three
  Items are set for Advising.
}
procedure TDDEClientWindow.CMAdvise(var Msg: TMessage);
var
  TempMenu  : HMenu;
  TempResult: Longint;
  I         : Integer;
  NewState  : Word;
  TransType : Word;
begin
  TempMenu := GetMenu(HWindow);
  if GetMenuState(TempMenu, Msg.WParam, mf_ByCommand) = mf_Unchecked then
  begin
    NewState := mf_Checked;
    TransType:= (xtyp_AdvStart or xtypf_AckReq);
  end
  else
  begin
    NewState := mf_Unchecked;
    TransType:= xtyp_AdvStop;
  end;

  for I := 1 to NumValues do
    if DdeClientTransaction(nil, 0, ConvHdl, ItemHSz[I], cf_Text, TransType,
        1000, @TempResult) = 0 then
      MessageBox(HWindow, 'Cannot perform Advise Transaction',
          Application^.Name, mb_IconStop);

  CheckMenuItem(TempMenu, Msg.WParam, (mf_ByCommand or NewState));
  DrawMenuBar(HWindow);

  if TransType and xtyp_AdvStart <> 0 then Request(ConvHdl);
end;

{ Posts the about box dialog for the DDE Client.
}
procedure TDDEClientWindow.CMHelpAbout(var Msg: TMessage);
begin
  Application^.ExecDialog(New(PDialog, Init(@Self, PChar(id_About))));
end;

{ Posts a DDE request to obtain cf_Text data from the server.  Requests
  the data for all fields of the DataSample, and invalidates the window to
  cause the new data to be displayed.  Obtains the data from the Server
  synchronously, using DdeClientTransaction.
}
procedure TDDEClientWindow.Request(HConversation: HConv);
var
  hDdeTemp : HDDEData;
  DataStr  : TDataString;
  Err, I   : Integer;
begin
  if HConversation <> 0 then
  begin
    for I := 1 to NumValues do
    begin
      hDdeTemp := DdeClientTransaction(nil, 0, HConversation, ItemHSz[I],
        cf_Text, xtyp_Request, 0, nil);
      if hDdeTemp <> 0 then
      begin
        DdeGetData(hDdeTemp, @DataStr, SizeOf(DataStr), 0);
        Val(DataStr, DataSample[I], Err);
      end;
    end;
    InvalidateRect(HWindow, nil, True);
  end;
end;


{ TDDEClientApp Methods }

{ Constructs an instance of the DDE Client Window and installs it as the
  MainWindow of this application.
}
procedure TDDEClientApp.InitMainWindow;
begin
  MainWindow := New(PDDEClientWindow, Init(nil, Application^.Name));
end;


{ Main program }

begin
  App.Init(DemoTitle);
  App.Run;
  App.Done;
end.
