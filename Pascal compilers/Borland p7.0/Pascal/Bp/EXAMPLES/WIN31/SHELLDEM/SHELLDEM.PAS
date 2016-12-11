{***************************************************}
{                                                   }
{   Windows 3.1 ShellAPI / Drag-and-Drop            }
{   Demonstration Program                           }
{   Copyright (c) 1992 by Borland International     }
{                                                   }
{***************************************************}

program ShellDemo;

{
 This demo program implements a simple program-manager type application
 using Drag & Drop and the SHELL API calls.

 Open this program on the Windows 3.1 desktop, and then drag files from the
 File Manager onto this application's window.  The dropped-in files will 
 appear as Icons in the window's client area, and double-clicking on those
 Icons will execute the corresponding program.
}

uses Strings, WinTypes, WinProcs, OWindows, ODialogs, Win31, ShellAPI, BWCC;

{$R SHELLDEM}

const

{ Resource IDs }

  id_Menu  = 100;
  id_About = 100;
  id_Instr = 101;   { Instructions }
  id_Icon  = 100;

{ Menu command IDs }

  cm_HelpAbout = 300;
  cm_HelpInstr = 301;

type

{ Filename string }

  TFilename = array[0..255] of Char;

{ Application main window }

  PDropTargetWin = ^TDropTargetWin;
  TDropTargetWin = object(TWindow)
    destructor Done; virtual;

    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
    function  GetClassName: PChar; virtual;
    procedure SetupWindow; virtual;

    procedure WMDropFiles(var Msg: TMessage);
      virtual wm_First + wm_DropFiles;

    procedure CMHelpAbout(var Msg: TMessage);
      virtual cm_First + cm_HelpAbout;
    procedure CMHelpInstructions(var Msg: TMessage);
      virtual cm_First + cm_HelpInstr;

{ Override this function in descendant classes to change behavior: }

    procedure DropAFile(FileName: PChar; DropX, DropY: Integer); virtual;
  end;

{ Icon Window }

  PIconWindow = ^TIconWindow;
  TIconWindow = object(TWindow)
    AppIcon   : HIcon;
    HasOwnIcon: Boolean;  { True if icon found, False if default used }
    Path      : PChar;
    X, Y      : Integer;

    constructor Init(AParent: PWindowsObject; ATitle: PChar; DropX, DropY: Integer);
    destructor  Done; virtual;

    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
    function  GetClassName: PChar; virtual;

    procedure WMQueryDragIcon(var Msg: TMessage);
      virtual wm_First + wm_QueryDragIcon;
    procedure WMQueryOpen(var Msg: TMessage);
      virtual wm_First + wm_QueryOpen;
    procedure WMSysCommand(var Msg: TMessage);
      virtual wm_First + wm_SysCommand;
  end;

{ Application object }

  TShellApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

{ Initialized globals }

const
  DemoTitle: PChar = 'Shell Demo Program';

{ Global variables }

var
  App: TShellApp;


{ TIconWindow Methods }

{ Constructs an instance of an IconWindow.  These are child windows to the
  main ShellAPI window which represent dropped files.  IconWindows always
  represent themselves as Iconic.  The Icon to be used is extracted from
  the application (as represented by its Title); if none can be found, the
  idi_Question icon is used.  The IconWindow positions itself at the given
  location.
}
constructor TIconWindow.Init(AParent: PWindowsObject; ATitle: PChar; DropX, DropY: Integer);
var
  FileName: PChar;
  Temp    : TFilename;
  ExeHdl  : THandle;
begin
{ Set the Path data field to the full pathname for later use in executing
  the program.  The passed-in title contains the complete path name of the
  file, which we just copy.  Then, strip off just the filename portion, and
  use that as the actual title for the icon, which is the Title field we
  pass into the ancestral constructor.
}
  Path    := StrNew(ATitle);
  FileName:= StrRScan(Path, '\');

  if (FileName <> nil) then
  begin
    if (FileName^ = '\') then
      inc(FileName);  { Skip past the '\' }
  end
  else
    FileName := ATitle;      { Just in case ... }

  inherited Init(AParent, FileName);
  Attr.Style := Attr.Style or (ws_Minimize or ws_Child);

{ Extract an Icon from the executable file.  If none is found, then just
  use idi_Question.
}
  ExeHdl := FindExecutable(Path, '.\', Temp);

  if ExeHdl <= 32 then
    AppIcon := 0
  else
    AppIcon := ExtractIcon(HInstance, Temp, 0);

  if AppIcon <= 1 then
  begin
    AppIcon   := LoadIcon(0, idi_Question);
    HasOwnIcon:= True;
  end
  else
    HasOwnIcon:= False;

{ Set the x/y position of drop (in Parent coordinates).  This is
  not used in this demo app, but is included to support variations
  through writing descendants.
}
  X := DropX;
  Y := DropY;
end;

{ Destroys an instance of the IconWindow.  Frees the AppIcon (unless the
  standard idi_Question was used), and disposes of the Path name string.
}
destructor TIconWindow.Done;
begin
  if HasOwnIcon then
    FreeResource(AppIcon);
  StrDispose(Path);
  inherited Done;
end;

{ Redefines GetWindowClass to give this application a NULL Icon.  This
  is necessary so that Windows gives this application a chance to paint
  its own icon when the window is Iconic.  When the hIcon field of AWndClass
  is NULL, this window will receive wm_QueryDragIcon messages.
}
procedure TIconWindow.GetWindowClass(var AWndClass: TWndClass);
begin
  inherited GetWindowClass(AWndClass);
  AWndClass.hIcon := 0;
end;

{ Returns the class name of this window.  This is necessary since we
  redefine the inherited GetWindowClass method, above.
}
function TIconWindow.GetClassName: PChar;
begin
  GetClassName := 'TIconWindow';
end;

{ Responds to double-clicks on the Icon by executing the associated program.
  Windows sends an iconified window a wm_QueryOpen message when
  double-clicked. Overriding here allows us to completely redefine that
  behavior. Uses the Path data field as the name of the program to execute.
}
procedure TIconWindow.WMQueryOpen(var Msg: TMessage);
begin
  ShellExecute(HWindow, nil, Path, '', '.\', sw_ShowNormal);

  Msg.Result := 0;  { Indicate that the message was handled }
end;

{ Returns the application's icon when the iconified window is dragged.  With
  AWndClass.hIcon set to NULL, Windows asks for this whenever the drag is 
  about to happen.
}
procedure TIconWindow.WMQueryDragIcon(var Msg: TMessage);
begin
  Msg.Result := AppIcon;
end;

{ Captures and filters out some variations on wm_SysCommand to prevent an
  annoying 'beep' on single clicks on the icon.
}
procedure TIconWindow.WMSysCommand(var Msg: TMessage);
begin
  case (Msg.WParam and $FFF0) of
    sc_MouseMenu: Msg.Result := 0;   { Indicate that the message was handled }
    sc_KeyMenu  : Msg.Result := 0;
  else
    DefWndProc(Msg);
  end;
end;

{ Responds to repaints of the window when requested.  With AWndClass.hIcon
  set to NULL, Windows will let the window paint itself even when iconic.
  NOTE that this is the 'new' way to draw you own icon, as opposed to 
  wm_PaintIcon in Win3.0.
}
procedure TIconWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
begin
  DefWindowProc(HWindow, wm_IconEraseBkgnd, PaintDC, 0);
  DrawIcon(PaintDC, 0, 0, AppIcon);
end;


{ TDropTargetWin Methods }

{ Destroys an instance of the Drop Target window.  Informs Windows that
  this application will no longer accept Drop-File requests, then invokes
  the ancestral destructor to complete the shutdown of the window.
}
destructor TDropTargetWin.Done;
begin
  DragAcceptFiles(HWindow, False);
  inherited Done;
end;

{ Redefines GetWindowClass to give this application its own Icon, and
  to identify the menu for this application.
}
procedure TDropTargetWin.GetWindowClass(var AWndClass: TWndClass);
begin
  inherited GetWindowClass(AWndClass);
  AWndClass.hIcon        := LoadIcon(AWndClass.hInstance, MakeIntResource(id_Icon));
  AWndClass.lpszMenuName := MakeIntResource(id_Menu);
  AWndClass.hBrBackground:= GetStockObject(LtGray_Brush);
end;

{ Returns the class name of this window.  This is necessary since we
  redefine the inherited GetWindowClass method, above.
}
function TDropTargetWin.GetClassName: PChar;
begin
  GetClassName := 'TDropTargetWin';
end;

{ Completes the initialization of the Icon window, by informing Windows
  that this window will accept Drop-File requests.  This is deferred to
  SetupWindow since it requires a valid window handle.  Note that
  Shell.dll will flip the ws_Ex_AcceptFiles style bit for this window.

  Also posts the Instructions dialog automatically upon startup.
}
procedure TDropTargetWin.SetupWindow;
begin
  inherited SetupWindow;
  DragAcceptFiles(HWindow, True);

  PostMessage(HWindow, wm_Command, cm_HelpInstr, 0);
end;

{ Responds to the dropping of a file onto this window.  Obtains the
  dropped in file name(s), then calls the DropAFile method for each 
  dropped file name.  The actual handling of the dropped file happens
  there; it is separated from this method for ease of redefinition by
  descendants.
}
procedure TDropTargetWin.WMDropFiles(var Msg: TMessage);
var
  DropPt     : TPoint;
  hDrop      : THandle;
  NumDropped : Integer;
  DroppedName: TFilename;
  I          : Integer;
begin
  hDrop := Msg.WParam;
  DragQueryPoint(hDrop, DropPt);

{ By passing in exactly these parameters, we get the number of files
  (and directories) being dropped.
}
  NumDropped := DragQueryFile(hDrop, Word(-1), nil, 0);

{ This time we pass in the 'real' parameters and SHELL.DLL will fill
  in the path to the file (or directory).  Do so for each dropped file.
}
  for I := 0 to NumDropped-1 do
  begin
    DragQueryFile(hDrop, I, DroppedName, SizeOf(DroppedName));
    DropAFile(DroppedName, DropPt.X, DropPt.Y);
  end;

  DragFinish(hDrop);
end;

{ Actually handles the dropping of a file at a given point, by creating the
  TIconWindow to represent that file.  Descendant classes can alter the be-
  havior of this application by simply redefining this method.
}
procedure TDropTargetWin.DropAFile(FileName: PChar; DropX, DropY: Integer);
begin
  Application^.MakeWindow(New(PIconWindow, Init(@Self, FileName, DropX, DropY)));
end;

{ Posts the About Box for the Shell API Demo.
}
procedure TDropTargetWin.CMHelpAbout(var Msg: TMessage);
begin
  Application^.ExecDialog(New(PDialog, Init(@Self, PChar(id_About))));
end;

{ Posts the Instructions Box for the Shell API Demo.
}
procedure TDropTargetWin.CMHelpInstructions(var Msg: TMessage);
begin
  Application^.ExecDialog(New(PDialog, Init(@Self, PChar(id_Instr))));
end;


{ TShellApp Methods }

procedure TShellApp.InitMainWindow;
begin
  MainWindow := New(PDropTargetWin, Init(nil, Application^.Name));
end;

{ Main program }

begin
  App.Init(DemoTitle);
  App.Run;
  App.Done;
end.
