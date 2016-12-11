{***************************************************}
{                                                   }
{   Windows 3.1 OLE Server Demonstration Program    }
{   Application Unit                                }
{   Copyright (c) 1992 by Borland International     }
{                                                   }
{***************************************************}

unit OLEApp;

{ This unit contains the definition of the OLE Server
  Application Object.

  Note that this application object is defined in its own
  unit because other objects in the program need to reference
  their owning application.

  Note: To compile the OLE Server demo, set Compile|Primary File to OLESERVR.PAS
}

interface

uses Ole, OWindows, Server;

type

{ Application Object }

  POLEApp  = ^TOLEApp;
  TOLEApp  = object(TApplication)
    Server       : POleServerObj;
    cfNative     : TOleClipFormat;
    cfOwnerLink  : TOleClipFormat;
    cfObjectLink : TOleClipFormat;

    procedure InitInstance; virtual;
    procedure CreateServer; virtual;
    procedure Wait(var WaitFlag: Boolean); virtual;
    function  RegisterClipboardFormats: Boolean; virtual;
    Procedure Error(ErrorCode: Integer); virtual;
  end;

implementation

uses WinTypes, WinProcs, OleTypes, Strings,
     ServrWin, OleObj, Objects;


{ TOleApp Methods }

{ Processes the command line and check for option /Embedding or -Embedding,
  then create the OLE server. There are four scenarios we are concerned with:

    1. Case One: oleservr.exe
      - Embedding = False; create an untitled document

    2. Case two: oleservr.exe filename
      - Embedding = False; create a new document from the file

    3. Case three: oleservr.exe -Embedding
      - Embedding = True; do NOT create or register a document.
                          do NOT show a window until client requests it

    4. Case four: oleservr.exe -Embedding filename
      - Embedding = True; load file, register it (this is the linking case)
                          do NOT show a window until client requests it
}
procedure TOleApp.CreateServer;
var
  Strng    : PChar;
  Embedded : Boolean;
  Path     : PChar;
  ServerObj: POleServerObj;
begin
  Strng    := CmdLine;
  Embedded := False;
  Path     := nil;

  { Skip any whitespace
  }
  if Strng <> nil then
  begin
    while (Strng^ = ' ') and (Strng^ <> #0) do
      inc(Strng);

  { Check for a '-' or '/'.  If found, check for the "Embedding"
    option.  Then, skip past the option to the file name.
  }
    if (Strng^ = '-') or (Strng^ = '/') then
    begin
      Embedded := (StrIComp(@Strng[1], Embedding) <> 0);
      while (Strng^ <> ' ') and (Strng^ <> #0) do
        inc(Strng);
    end;

  { Skip any whitespace before looking for the file name
  }
    while (Strng^ = ' ') and (Strng^ <> #0) do
      inc(Strng);

    if Strng^ <> #0 then
      Path := Strng;
  end
  else
  begin
    Embedded := False;
    Path     := nil;
  end;

  { If we are embedded, then we won't display the window until requested
    to by the library.
  }
  if Embedded then
    CmdShow := sw_Hide;

  { Create the server object.  Recall that the object will attach itself
    to this application, much as a child window attaches to a parent, so
    we don't need to hold the results of these New's.
  }
  if Path <> nil then
    New(ServerObj, InitFromFile(@Self, Path))
  else
    New(ServerObj, Init(@Self, Embedded));
end;

{ Registers the clipboard formats.  If you are a mini-server (embedding 
  only) you will need to register clipboard formats for "Native" and 
  "OwnerLink".  If you are a full server (linking and embedding) you will
  also need to register clipboard format "ObjectLink"
}
function TOleApp.RegisterClipboardFormats: Boolean;
begin
  cfNative    := RegisterClipboardFormat('Native');
  cfOwnerLink := RegisterClipboardFormat('OwnerLink');
  cfObjectLink:= RegisterClipboardFormat('ObjectLink');

  RegisterClipboardFormats :=    (cfNative     <> 0)
                             and (cfOwnerLink  <> 0)
                             and (cfObjectLink <> 0);
end;

{ Initializes this instance of the OLE application, by doing the following:
    - Create the main window
    - Create OLE VTbl thunks
    - Create clipboard formats
    - Parse the command line
    - Create/register OLE server

  NOTE: We let Windows free all thunks when the application terminates,
        and don't do it ourselves
}
procedure TOleApp.InitInstance;
begin
  MainWindow := New(PServerWindow, Init(nil, DemoTitle));
  MainWindow := MakeWindow(MainWindow);

  RegisterType(ROleObjectObj);

  if (not TOleServerObj_InitVTbl(HInstance) or
      not TOleDocument_InitVTbl(HInstance) or
      not TOleObjectObj_InitVTbl(HInstance)
     )
  then
    Status := olInitVTblError
  else 
    if not RegisterClipboardFormats then
      Status := olRegClipError
    else
      CreateServer;

  { We do this *after* calling CreateServer, because if we are embedded
    then we don't want to display the main window until requested to by
    the server library, and it is CreateServer who determines that and sets
    'CmdShow' accordingly
  }
  if MainWindow <> nil then
    MainWindow^.Show(CmdShow)
  else
    Status := em_InvalidMainWindow;
end;

{ Redefines the Error method to trap error messages generated by OLE app,
  display an error message box and terminate the application.
}
procedure TOleApp.Error(ErrorCode: Integer);
var
  Strng : PChar;
begin
  Strng := nil;
  if (ErrorCode = olRegClipError) then
    Strng := 'Fatal Error: Cannot register ''Native'', ''OwnerLink'', and ' +
      '''ObjectLink'' clipboard formats'
  else 
    if (ErrorCode = olInitVTBLError) then
      Strng := 'Fatal Error: Cannot create thunks for ''OleServer'', ' +
        '''OleServerDoc'', and ''OleObject'' VTbls';
 
  if Strng <> nil then
  begin
    MessageBox(0, Strng, DemoTitle, mb_OK or mb_IconStop);
    PostAppMessage(GetCurrentTask, wm_Quit, 0, 0);
  end
  else
    TApplication.Error(ErrorCode);
end;

{ Dispatches messages until the given flag is set to True.  One use of this
  function is to wait until a Release method is called after a function has
  returned Ole_Wait_for_Release.

  PARAMETER: "WaitFlag" is a reference to a flag that will be set to True
             when we can return.
}
procedure TOleApp.Wait(var WaitFlag: Boolean);
var
  Msg         :  TMsg;
  MoreMessages:  Bool;
begin
  MoreMessages := False;
  while not WaitFlag do
  begin
    OleUnblockServer(Server^.ServerHdl, MoreMessages);

    if not MoreMessages then 
    begin
      { If there are no more messages in the OLE queue, go to system queue
      }
      if (GetMessage(Msg, 0, 0, 0)) then
      begin
        TranslateMessage(Msg);
        DispatchMessage (Msg);
      end;
    end;
  end;
end;

end.
