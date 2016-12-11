{***************************************************}
{                                                   }
{   Windows 3.1 OLE Server Demonstration Program    }
{   Server Object Unit                              }
{   Copyright (c) 1992 by Borland International     }
{                                                   }
{***************************************************}

{ This unit defines the Server and Document objects, which
  represent the Ole Server and Ole Document, respectively.
  The Server interfaces with the Client application at the
  highest level, managing the creation and manipulation of
  Documents.

  Interaction between the Client and these objects is carried
  out through a series of callback functions, which are also
  defined here.

  NOTE that we only have one document per server. if yours
  was an MDI app, then you would have a list of documents.

  Note: To compile the OLE Server demo, set Compile|Primary File to OLESERVR.PAS
}

unit Server;

interface

uses WinTypes, CommDlg, Ole, Objects, OWindows, OleTypes, OleObj;

type

{ The following record types represent the Server and Document
  objects within the OLE library.  They are based on the
  standard structures defined in Ole.pas, and each adds one
  field to provide access back to the TPW object which represents
  it.
}
  POleServerObj = ^TOleServerObj;

  PAppServer = ^TAppServer;
  TAppServer = record
    OleServer: TOleServer;
    Owner    : POleServerObj;
  end;

  POleDocument  = ^TOleDocument;

  PAppServerDoc = ^TAppServerDoc;
  TAppServerDoc = record
    OleServerDoc: TOleServerDoc;
    Owner       : POleDocument;
  end;

{ TOleServerObj }

{ This object represents the OLE Server, wrapping useful
  behaviors around the basic TOleServer structure that is
  used within OLE to represent a Server.  This structure
  is represented by the AppServer data field, which is of
  the TAppServer type defined in oleservr.pas, and which
  includes an additional field to point back to Self so
  that our callback functions can reference this object.
}
  TOleServerObj = object(TObject)
    AppServer : TAppServer;
    ServerHdl : LHServer;       { Registration handle returned
                                  by server library}
    Document  : POleDocument;  
    IsReleased: Boolean;        { True if Release method has been called}

    constructor Init(App: PApplication; Embedded: Boolean);
    constructor InitFromFile(App: PApplication; Path: PChar);

    function Initialize(App: PApplication): Boolean;

    function RegisterWithDatabase: Boolean; virtual;
    function WantsToRegister: Boolean; virtual;
  end;


{ TOleDocument }

{ This object represents the OLE ServerDoc, wrapping useful
  behaviors around the basic TOleServerDoc structure that is
  used within OLE to represent a document.  This structure
  is represented by the AppServerDoc data field, which is of
  the TAppServerDoc type defined in oleservr.pas, and which
  includes an additional field which points back to Self so
  that our callback functions can reference this object.
}
  TOleDocument = object(TObject)
    AppServerDoc: TAppServerDoc;
    ServerDoc   : LHServerDoc;     { Registration handle returned by
                                     server library }
    DocType     : TDocType;
    Name        : PChar;
    OleObject   : POleObjectObj;
    IsDirty     : Boolean;
    IsReleased  : Boolean;  { True if Release method has been called }

    constructor Init(Server: POleServerObj; Doc: LHServerDoc;
      Path: PChar; Dirty: Boolean);

    procedure Setup(Path: PChar; MaxPathLen: Integer;
      var FNStruct: TOpenFileName); virtual;
    function  LoadFromFile(Path: PChar): Boolean; virtual;
    procedure SaveDoc; virtual;
    procedure SaveAs; virtual;
    procedure Reset(Path: PChar); virtual;         
    procedure SetDocumentName(NewName: PChar;
      ChangeCaption: Boolean); virtual;
    function  PromptForOpenFileName(Path: PChar): Boolean; virtual;
  end;

function TOleServerObj_InitVTbl(Inst: THandle): Boolean;
function TOleDocument_InitVTbl(Inst: THandle): Boolean;


implementation

uses Strings, WinProcs, ServrWin, OleApp, ShellAPI;

{ Global variables }

var
  OleServerVTbl   : TOleServerVTbl;
  OleServerDocVTbl: TOleServerDocVTbl;

  Filter          : array [0..100] of Char;   { Used in Setup }
  SimpleName      : array [0..13]  of Char;

const
  UnnamedDoc: PChar = '(Untitled)';




{ Server Callback Functions }

{ The first parameter to each callback is a pointer to the TOleServer
  structure that defines this document.  In each case, we know that it
  will really be a pointer to a TAppServer record, which includes a
  pointer to the Pascal object which owns the TOleServer record.  We
  can therefore use a typecast to access that object, and thus find our
  way back to Self.
}

{ Handles the Open callback. The user has activated a linked object in an
  OLE client by calling OleActivate.  Similar to CreateFromTemplate in that
  we need to create a document, initialize it with the contents of file 
  'DocName', and save the file name for later use.

  WHAT TO DO:
    - Create a TOleDocument of class 'ClassName' (since we only have one
      class we can ignore the class name)
    - Initialize the document with the contents of file 'DocName'
    - Associate handle 'Doc' with the document
    - Store the pointer to the TOleDocument in 'ServerDoc'
    - Save file name 'DocName'
    - Return ole_Ok if successful, ole_Error_Open otherwise
}
function Open(Server: POleServer; Doc: LHServerDoc; DocName: PChar;
              var ServerDoc: POleServerDoc): TOleStatus; export;
var
  SelfPtr: POleServerObj;
  NewDoc : POleDocument;
begin
  SelfPtr := PAppServer(Server)^.Owner;

  NewDoc := New(POleDocument, Init(SelfPtr, Doc, DocName, False));
  if NewDoc = nil then
    Open := ole_Error_Edit
  else 
  begin
    ServerDoc := @NewDoc^.AppServerDoc;
    Open      := ole_Ok;
  end;
end;

{ Handles the Create callback.  Called by the server library when a client
  application has created a new embedded object by calling OleCreate.

  WHAT TO DO:
    - Create an *untitled* TOleDocument of class 'ClassName' (since we
      only have one class we can ignore the class name) and mark it as dirty
    - Associate handle 'Doc' with the document
    - Store the pointer to the TOleDocument in 'ServerDoc'
    - Return ole_Ok if successful, ole_Error_New otherwise

  If your app is an MDI application then you would also allocate a window
  here, but since this app isn't the window is already created.

  'DocName' is the name of the document as it appears in the client
  class. DON'T use this to change the title bar, use what you get when
  the document is sent the message 'SetHostNames'.

  NOTE: Since we only have one document we could have created it during
        initialization
}
function Create(Server: POleServer; Doc: LHServerDoc;
                Class, DocName: PChar;
                var ServerDoc: POleServerDoc): TOleStatus; export;
var
  SelfPtr: POleServerObj;
  NewDoc : POleDocument;
begin
  SelfPtr:= PAppServer(Server)^.Owner;

  NewDoc := New(POleDocument, Init(SelfPtr, Doc, nil, True));
  if NewDoc = nil then
    Create := ole_Error_New
  else 
  begin
    ServerDoc := @NewDoc^.AppServerDoc;
    PServerWindow(Application^.MainWindow)^.BeginEmbedding;
    Create := ole_Ok;
  end;
end;

{ Handles the CreateFromTemplate callback.  Called by the server library 
  when a client application has created a new linked object specifying a 
  template by calling OleCreateFromTemplate. What this really means is that
  we need to create a document and initialize it with the contents of a file.
  'DocName' is the name of the document as it appears in the client class.
  DON'T use this to change the title bar, use what you get when the document
  is sent message 'SetHostNames'

  WHAT TO DO:
    - Create a TOleDocument of class 'ClassName' (since we only have one
      class we can ignore the class name)
    - Initialize the document with the contents of file 'TemplateName'
    - Associate handle 'Doc' with the document
    - Store the pointer to the TOleDocument in 'ServerDoc'
    - Return ole_Ok if successful, ole_Error_Template otherwise

    If your app is an MDI application then you would also allocate a window
    here, but since this app isn't the window is already created.

    NOTE: since we only have one document we could have created it during
          initialization
}
function CreateFromTemplate(Server: POleServer; Doc: LHServerDoc;
  Class, DocName, TemplateName: PChar;
  var ServerDoc: POleServerDoc): TOleStatus; export;
var
  SelfPtr: POleServerObj;
  NewDoc : POleDocument;
begin
  SelfPtr:= PAppServer(Server)^.Owner;

  NewDoc := New(POleDocument, Init(SelfPtr, Doc, TemplateName, False));
  if NewDoc = nil then
    CreateFromTemplate := ole_Error_New
  else 
  begin
    ServerDoc := @NewDoc^.AppServerDoc;
    PServerWindow(Application^.MainWindow)^.BeginEmbedding;
    CreateFromTemplate := ole_Ok;
  end
end;

{ Handles the Edit callback.  Called by the server library when a client
  application has activated an embedded object for editing.  This is exactly
  like 'Create' except that the document will receive a 'GetData' message to
  create the object, and the object will receive a 'SetData' message to 
  initialize itself

  'DocName' is the name of the document as it appears in the client class.
  DON'T use this to change the title bar, use what you get when the document
  is sent message 'SetHostNames'

  WHAT TO DO:
    - Create a TOleDocument of class 'ClassName' (since we only have one
      class we can ignore the class name)
    - Associate handle 'Doc' with the document
    - Store the pointer to the TOleDocument in 'ServerDoc'
    - Return ole_Ok if successful, ole_Error_Edit otherwise
} 
function Edit(Server: POleServer; Doc: LHServerDoc; Class, DocName: PChar;
  var ServerDoc: POleServerDoc): TOleStatus; export;
var
  SelfPtr: POleServerObj;
  NewDoc : POleDocument;
begin
  SelfPtr:= PAppServer(Server)^.Owner;
  NewDoc := New(POleDocument, Init(SelfPtr, Doc, nil, False));
  if NewDoc = nil then
    Edit := ole_Error_Edit
  else 
  begin
    ServerDoc := @NewDoc^.AppServerDoc;
    PServerWindow(Application^.MainWindow)^.BeginEmbedding;
    Edit := ole_Ok;
  end;
end;

{ Handles the Exit callback.  We have been instructed by the library to 
  exit immediately because of a fatal error.

  WHAT TO DO:
    - Hide the window to prevent user interaction
    - Call OleRevokeServer and ignore a return of ole_Wait_For_Release
    - Terminate the application immediately
    - Return ole_Ok if successful, ole_Error_Generic otherwise
}
function Exit(Server: POleServer): TOleStatus; export;
var
  SelfPtr: POleServerObj;
begin
  SelfPtr := PAppServer(Server)^.Owner;

  Application^.MainWindow^.Show(sw_Hide);

  OleRevokeServer(SelfPtr^.ServerHdl);

  PostAppMessage(GetCurrentTask, wm_Quit, 0, 0);
  Exit := ole_Ok;
end;

{ Handles the Release callback.  This routine gets called by the server
  library after the server has called OleRevokeServer and when the DDE 
  conversation with the client has been successfully closed.  This tells
  us that there are no connections to the server, its documents, or their
  objects and that we are free to terminate.

  WHAT TO DO:
    - Set a flag to indicate that 'Release' has been called
    - If the application is hidden and we *haven't* called OleRevokeServer
      then we *must* terminate by posting a wm_Close message
    - Free any resources allocated including documents, but *not* the
      TOleServer structure
    - Return ole_Ok if successful, Ole_Error_Generic otherwise

  NOTE: this routine is tricky because it is invoked under different
  circumstances:
    - User brought up the server and then closes it, which causes us
      to call OleRevokeServer which means the server will eventually
      receive a 'Release' message

    - The server was started to perform an invisible update for a client
      (i.e. the server has always been hidden). In this case the server will
      receive a 'Release' message and we must tell ourselves to close
      because there is no user interaction.
}
function Release(Server: POleServer): TOleStatus; export;
var
  SelfPtr: POleServerObj;
begin
  SelfPtr := PAppServer(Server)^.Owner;

  { If we haven't been sent a 'Release' message yet and our main window is
    hidden then we post a quit message.  NOTE: Call PostMessage and not 
    PostQuitMessage because PostQuitMessage might bypass your application's
    necessary cleanup procedures.
  }
  if (not SelfPtr^.IsReleased) and
      (not IsWindowVisible(Application^.MainWindow^.HWindow)) then
    PostMessage(Application^.MainWindow^.HWindow, wm_Close, 0, 0);

  SelfPtr^.IsReleased := True;

  Release := ole_Ok;
end;

{ Handles the Execute callback. If your app supports DDE execution
  commands then you would handle this event. Since we don't we return
  ole_Error_Command.
}
function Execute(Server: POleServer; Commands: THandle): TOleStatus; export;
begin
  Execute := ole_Error_Command;
end;


{ TOleServerObj Methods }

{ Constructs an untitled instance of the OLE server document.
}
constructor TOleServerObj.Init(App: PApplication; Embedded: Boolean);
begin
  if Initialize(App) and (not Embedded) then
    Document := New(POleDocument, Init(@Self, 0, nil, False));
end;

{ Constructs an instance of the Server Object, creating an OLE document
  and initializing it from file 'Path'.
}
constructor TOleServerObj.InitFromFile(App: PApplication; Path: PChar);
begin
  if Initialize(App) then
    Document := New(POleDocument, Init(@Self, 0, Path, False));
end;

{ Completes the construction of Self, attaching Self to the given
  application.  Returns True if successful, False if not.
}
function TOleServerObj.Initialize(App: PApplication): Boolean;
var
  Status: TOleStatus;
begin
  AppServer.OleServer.lpvtbl:= @OleServerVTbl;
  AppServer.Owner           := @Self;

  IsReleased := False;

  { Attach Self to the containing application.
  }
  POleApp(App)^.Server := @Self;

  { Since we can't handle multiple documents (MDI), request that we use
    multiple instances to support multiple objects
  }
  Status := OleRegisterServer(ClassKey, @AppServer, ServerHdl, HInstance,
    ole_Server_Multi);

  Initialize := True;
  if Status = ole_Error_Class then
  begin
    if RegisterWithDatabase then
      OleRegisterServer(ClassKey, @AppServer, ServerHdl, HInstance,
        ole_Server_Multi)
    else
      Initialize := False;
  end;
end;

{ Displays an action message prompting the user to see if they want to
  register Application^.Name with the system registration database.
  Returns True if user says YES and False is users says NO.  If user
  says NO we terminate the app.
}
function TOleServerObj.WantsToRegister: Boolean;
var
  Buf: array [0..255] of Char;
begin
  StrCopy(Buf, Application^.Name);
  StrCat(Buf, ' is not registered as an OLE server in the ' +
    'system registration');
  StrCat(Buf, ' database. Do you want to register it?');

  if MessageBox(0, Buf, Application^.Name, mb_YesNo or
      mb_IconQuestion) = idYes then
    WantsToRegister := True
  else 
  begin
    PostAppMessage(GetCurrentTask, wm_Quit, 0, 0);

    { We also need to make sure that the main window doesn't get displayed.
      We have a couple of choices: set 'CmdShow' to sw_Hide or set 'Status'
      to non-zero.  Since the user electing not to register isn't really an
      error, let's set 'CmdShow'.
    }
    CmdShow := sw_Hide;
    WantsToRegister := False;
  end;
end;

{ Registers us as an OLE server with the system registration database.
  This would typically be done during *installation* of the app and not
  when the app runs.

  NOTE: We first prompt the user to see if they want us to register. if so
        we register and if not we terminate the app.
}
function TOleServerObj.RegisterWithDatabase: Boolean;
var
  Buf  : array [0..127] of Char;
  Path : array [0..255] of Char;
begin
  if not WantsToRegister then
    RegisterWithDatabase := False
  else 
  begin
    StrCopy(Buf, '.');
    StrCat(Buf, FileExt);
    RegSetValue(hkey_Classes_Root, Buf, Reg_Sz, ClassKey, StrLen(ClassKey));
    RegSetValue(hkey_Classes_Root, ClassKey, Reg_Sz, ClassValue,
      StrLen(ClassValue));

    { Register verb actions EDIT and PLAY with EDIT being the primary verb.
    }
    StrCopy(Buf, ClassKey);
    StrCat(Buf, '\protocol\StdFileEditing\verb\0');
    RegSetValue(hkey_Classes_Root, Buf, Reg_Sz, 'Edit', 4);
  
    StrCopy(Buf, ClassKey);
    StrCat(Buf, '\protocol\StdFileEditing\verb\1');
    RegSetValue(hkey_Classes_Root, Buf, Reg_Sz, 'Play', 4);

    { Register a full pathname to the executable with the database.
    }
    GetModuleFileName(HInstance, Path, SizeOf(Path));
    StrCopy(Buf, ClassKey);
    StrCat(Buf, '\protocol\StdFileEditing\server');
    RegSetValue(hkey_Classes_Root, Buf, Reg_Sz, Path, StrLen(Path));
  
    { Inform the user that we have registered as an OLE server by displaying
      an information message.
    }
    StrCopy(Buf, Application^.Name);
    StrCat(Buf, ' successfully registered as an OLE server with the system '+
      'registration database.');
  
    MessageBox(0, Buf, Application^.Name, mb_Ok or mb_IconInformation);
    RegisterWithDatabase := True;
  end
end;

{ Creates the instance thunks for the OleServer callback tables.
}
function TOleServerObj_InitVTbl(Inst: THandle): Boolean;
begin
  @OleServerVTbl.Open    := MakeProcInstance(@Open,    Inst);
  @OleServerVTbl.Create  := MakeProcInstance(@Create,  Inst);
  @OleServerVTbl.CreateFromTemplate
                         := MakeProcInstance(@CreateFromTemplate, Inst);
  @OleServerVTbl.Edit    := MakeProcInstance(@Edit,    Inst);
  @OleServerVTbl.Exit    := MakeProcInstance(@Exit,    Inst);
  @OleServerVTbl.Release := MakeProcInstance(@Release, Inst);
  @OleServerVTbl.Execute := MakeProcInstance(@Execute, Inst);

  TOleServerObj_InitVTbl := (@OleServerVTbl.Open <> nil) and
                            (@OleServerVTbl.Create <> nil) and
                            (@OleServerVTbl.CreateFromTemplate <> nil) and
                            (@OleServerVTbl.Edit <> nil) and
                            (@OleServerVTbl.Exit <> nil) and
                            (@OleServerVTbl.Release <> nil) and
                            (@OleServerVTbl.Execute <> nil);
end;


{ Document Callback Functions }

{ The first parameter to each callback is a pointer to the TOleServerDoc
  structure that defines this document.  In each case, we know that it
  will really be a pointer to a TAppServerDoc record, which includes a
  pointer to the Pascal object which owns the TOleServerDoc record.  We
  can therefore use a typecast to access that object, and thus find our
  way back to Self.
}

{ Handles the Save callback.  This method is only used when the server is
  editing a linked object: the client application is closing and the user
  has requested saving the client document which contains a linked object.

  WHAT TO DO:
    - Save the document to the filename which was passed in when the document
      was opened for linking
    - Return Ole_Ok if successful, ole_Error_Generic otherwise
}
function Save(Doc: POleServerDoc): TOleStatus; export;
var
  SelfPtr: POleDocument;
begin
  SelfPtr := PAppServerDoc(Doc)^.Owner;

  if SelfPtr^.DocType <> DoctypeFromFile then
    Save := Ole_Error_Generic
  else
  begin
    SelfPtr^.SaveDoc;
    Save := Ole_Ok;
  end;
end;

{ Handles the Close callback.  We have been requested to close the document
  because the client that contains a link (embedding or linking) to that 
  document has shut down.  This is always called *before* the document's
  'Release' callback is called.

  WHAT TO DO:
    - Call OleRevokeServerDoc and *don't* free any resources until
      'Release' is called
    - Return the value of OleRevokeServerDoc
}
function Close(Doc: POleServerDoc): TOleStatus; export;
var
  SelfPtr: POleDocument;
begin
  SelfPtr:= PAppServerDoc(Doc)^.Owner;

  Close := OleRevokeServerDoc(SelfPtr^.ServerDoc);
end;

{ Responds to the SetHostNames callback.  The server library is calling
  to provide the server with the name of the client's document and the
  name of the object in the client application.  These names should be
  used to make the necessary window title bar and menu changes.

  This is only called for embedded objects because linked objects display
  their filename in the title bar.

   WHAT IT DOES:
    - Change the title bar and File menu
    - Store the object and client names for later use
    - Return Ole_Ok is successful, Ole_Error_Generic otherwise

   PARAMETERS:
    - 'Client' is the name of the client application document
    - 'Doc' is the name of the object in the client application
}
function SetHostNames(Doc: POleServerDoc; Client,
  DocName: PChar): TOleStatus; export;
var
  SelfPtr: POleDocument;
  Title  : array [0..63] of Char;
begin
  SelfPtr := PAppServerDoc(Doc)^.Owner;
  PServerWindow(Application^.MainWindow)^.UpdateFileMenu(DocName);

  { Store the document name, but don't update the title bar; we will do that
    below
  }
  SelfPtr^.SetDocumentName(DocName, True);

  { Set the caption to be <App Name> - <Object Name> in <Client App Document>
  }
  StrCopy(Title, Application^.Name);
  StrCat (Title, ' - ');
  StrCat (Title, DocName);
  StrCat (Title, ' in ');
  StrCat (Title, Client);
  PWindow(Application^.MainWindow)^.SetCaption(Title);

  SetHostNames := Ole_Ok;
end;

{ Handles the DocSetDimensions callback. The client is informing us how
  big the object should be. 'Rect' is in mm_HiMetric units (all OLE
  libraries express the size of every object in mm_HiMetric).  This
  function is not supported.
}
function SetDocDimensions(Doc: POleServerDoc;
  var Bounds: TRect): TOleStatus; export;
begin
  SetDocDimensions := Ole_Ok;
end;

{ Handles the GetObject callback. The server library calls this method
  whenever a client application creates an object using a function like
  OleCreate.  If 'ObjName' is nil, that means we are being called for an
  embedded object after the server was sent 'Create', 'Edit', or
  'CreateFromTemplate' and the server library requests the entire document.

  If 'ObjName' isn't nil then the server has already received a 'Open'
  message to activate the linked object

  WHAT TO DO:
    - Allocate a TOleObject if 'Item' is nil, or look up 'Item'
      in the list of objects if it isn't nil
    - Store the pointer to the TOleObject in 'OleObject' for return
    - Store 'Client' so we can send notifications to the client
      (used for linked objects)
    - Return ole_Ok if successful, ole_Error_Name if 'Item' isn't
      recognized, or ole_Error_Memory if the object could not be
      allocated

  NOTE:
    - We only have one object and it is created when the document is
      created. Therefore, we don't actually create anything here.
    - 'Client' resides in the server library and is used on behalf of
      a client application
}
function GetObject(Doc: POleServerDoc; Item: PChar;
  var OleObject: POleObject; Client: POleClient): TOleStatus; export;
var
  SelfPtr: POleDocument;
begin
  SelfPtr := PAppServerDoc(Doc)^.Owner;

  { In either case (whether 'ObjName' is nil or not) we just return
    the object associated with the document.  NOTE that we return a
    pointer to its AppObject field, not to the object itself.
  }
  OleObject := POleObject(@SelfPtr^.OleObject^.AppObject);

  { If 'Item' isn't nil then we associate 'Client' with it.
  
    NOTE: We only have one object. if you have multiple objects then you
          would have to search your objects to find the one that matched
          'Item'
  }
  if Item <> nil then
    SelfPtr^.OleObject^.AddClientLink(Client);

  GetObject := Ole_Ok;
end;

{ Handles the Release callback.  The server library calls this routine when
  all conversations to the object have been closed.  At this point the server
  has called either OleRevokeServerDoc or OleRevokeServer.

  There will be no more calls to the document's methods.  It is thus okay to
  free the document's objects, but *not* the TOleDocument yet.

  WHAT TO DO:
    - Free the document's objects and resources (e.g. atoms) but *not* the
      document itself
    - Set a flag to indicate that 'Release' has been called
    - Return Ole_Ok if successful, Ole_Error_Generic otherwise

  NOTE:
    - Since we only have one document and one object within the
      document we don't delete the object here.  However, you
      might want to.
    - This procedure is not called 'Release' because it appears in the
      same scope as the Release callback for the TOleServerObj.
}
function ReleaseDoc(Doc: POleServerDoc): TOleStatus; export;
var
  SelfPtr: POleDocument;
begin
  SelfPtr := PAppServerDoc(Doc)^.Owner;

  SelfPtr^.IsReleased := True;
  ReleaseDoc := Ole_Ok;
end;

{ Handles the SetColorScheme callback.  Not supported.
}
function SetColorSchemeDoc(Doc: POleServerDoc; var Palette: TLogPalette): TOleStatus; export;
begin
  SetColorSchemeDoc := Ole_Error_Generic;
end;

{ Handles the Execute callback.  If your app supports DDE execution commands
  then you would handle this event.  Since we don't, we return
  Ole_Error_Command.
}
function ExecuteDoc(Doc: POleServerDoc;
  Commands: THandle): TOleStatus; export;
begin
  ExecuteDoc := ole_Error_Command;
end;


{ TOleDocument Methods }

{ Constructs an instance of the OLE Document. If 'Path' is nil then we
  create an untitled document and default object.  The type is 'DoctypeNew'
  if 'ServerDoc' is nil and 'DoctypeEmbedded' if 'ServerDoc' is non-nil.
  If 'Path' is non-nil we create a document of type 'DoctypeFromFile'
  and initialize it from file 'Path'
    
  If 'ServerDoc' is nil then we call OleRegisterServerDoc, otherwise we
  just use 'ServerDoc' as our registration handle.
}
constructor TOleDocument.Init(Server: POleServerObj; Doc: LHServerDoc; 
                              Path: PChar; Dirty: Boolean);
begin
  Name      := nil;
  IsReleased:= False;
  IsDirty   := Dirty;

  AppServerDoc.OleServerDoc.lpvtbl:= @OleServerDocVTbl;
  AppServerDoc.Owner              := @Self;

  { Attach this document to the owning server.
  }
  POleServerObj(Server)^.Document := @Self;

  { Since we only have one object we can create it now.
  }
  OleObject := New(POleObjectObj, Init);

  if Path <> nil then
    LoadFromFile(Path)
  else
  begin
    SetDocumentName(UnnamedDoc, True);

    if Doc <> 0 then
      DocType := DoctypeEmbedded
    else
      DocType := DoctypeNew;
  end;

  if Doc <> 0 then
    ServerDoc := Doc  { Use registration handle we were given }
  else
    OleRegisterServerDoc(Server^.ServerHdl, Name, @AppServerDoc, ServerDoc);
end;

{ Changes the instance variable 'Name' and changes the window caption to
  those given.
}
procedure TOleDocument.SetDocumentName(NewName: PChar;
  ChangeCaption: Boolean);
var
  Title: array[0..63] of Char;
begin
  StrDispose(Name);
  Name := StrNew(NewName);

  if ChangeCaption then
  begin
    StrCopy(Title, Application^.Name);
    StrCat (Title, ' - ');
    StrCat (Title, NewName);
    PWindow(Application^.MainWindow)^.SetCaption(Title);
  end;
end;

{ Loads from the given file name.  Returns True if successful and False
  otherwise.  If successful sets DocType to 'DoctypeFromFile' and sets
  'Name' to 'Path'.
}
function TOleDocument.LoadFromFile(Path: PChar): Boolean;
var
  Msg     : array [0..255] of Char;
  Key     : array [0..40]  of Char;
  InStream: TBufStream;
begin
  InStream.Init(Path, stOpen, 1000);
  if InStream.Status = stInitError then
  begin
    StrCopy(Msg, 'Cannot open file ');
    StrCat(Msg, Path);
    MessageBeep(0);
    MessageBox(Application^.MainWindow^.HWindow, Msg,
               Application^.Name, mb_OK or mb_IconExclamation);
    LoadFromFile := False;
  end
  else
  begin
    { Read in the signature.  Read the number of characters we
      would expect, then see if we got them.  If not, then abandon
      the attempt.  Note that the Read will not get in a NUL; we
      put that on manually.  Also note that we read StrLen(ClassKey)+1
      characters to consume the extra blank written out.
    }
    InStream.Read(Key, StrLen(ClassKey)+1);
    Key[StrLen(ClassKey)] := #0;
    if StrComp(Key, ClassKey) <> 0 then
    begin
      StrCopy(Msg, 'File ');
      StrCat(Msg, Path);
      StrCat(Msg, ' is not an "');
      StrCat(Msg, Application^.Name);
      StrCat(Msg, '" file!');
      MessageBeep(0);
      MessageBox(Application^.MainWindow^.HWindow, Msg, Application^.Name,
                 mb_OK or mb_IconExclamation);
      LoadFromFile := False;
    end
    else
    begin
      OleObject:= POleObjectObj(InStream.Get);
      DocType  := DoctypeFromFile;
      SetDocumentName(Path, True);
      LoadFromFile := True;
    end;
  end;
  InStream.Done;
end;

{ Resets the document so that we can re-use the document object.  If your
  app doesn't then you would delete the old object and create a new one.
  Sets 'IsDirty' flag to False and 'IsReleased' to False. If 'ServerDoc'
  is nil then calls OleRegisterServerDoc.
}
procedure TOleDocument.Reset(Path: PChar);
begin
  IsDirty    := False;
  IsReleased := False;

  if Path <> nil then
    if not LoadFromFile(Path) then 
    begin
      PServerWindow(Application^.MainWindow)^.ShapeChange(ObjEllipse);

      OleObject^.Native.NativeType := ObjEllipse;
      OleObject^.Native.Version    := 1;

      DocType := DoctypeNew;
      SetDocumentName(UnnamedDoc, True);
    end;

  if ServerDoc = 0 then
    OleRegisterServerDoc(POleApp(Application)^.Server^.ServerHdl, Name,
      @AppServerDoc, ServerDoc);
end;

{ Sets up a TOpenFileName structure for use with the File Open Common
  Dialog.  The caller passes in a structure which is filled in as
  required, and a pointer to the array to receive the full path name.
  Uses the Filter and SimpleName variables defined above, which are
  global to allow this to be used from several places.
}
procedure TOleDocument.Setup(Path: PChar; MaxPathLen: Integer;
  var FNStruct: TOpenFileName);
begin
{ Set up a filter buffer to look for '*.oos' files only.  Recall that filter
  buffer is a set of string pairs, with the last one terminated by a
  double-null.
}
  FillChar(Filter, SizeOf(Filter), #0);  { Set up for double null at end }
  StrCopy(Filter, 'OWL OLE Server');
  StrCopy(@Filter[StrLen(Filter)+1], '*.oos');

  StrCopy(Path, '*.');
  StrCat (Path, FileExt);

  FillChar(FNStruct, SizeOf(TOpenFileName), #0);

  with FNStruct do
  begin
    hInstance     := HInstance;
    hwndOwner     := Application^.MainWindow^.HWindow;
    lpstrDefExt   := FileExt;
    lpstrFile     := Path;
    lpstrFilter   := Filter;
    lpstrFileTitle:= SimpleName;
    Flags         := ofn_HideReadOnly or ofn_PathMustExist;
    lStructSize   := SizeOf(TOpenFileName);
    nFilterIndex  := 1;       {Use first Filter String in lpstrFilter}
    nMaxFile      := MaxPathLen;
  end;
end;

{ Activates the File/Open common dialog, and returns the result.
  Puts the obtained file name into the given Path parameter, which
  is assumed to point to a buffer big enough to contain a TFilename
  sized string.
}
function TOleDocument.PromptForOpenFileName(Path: PChar): Boolean;
var
  FNStruct: TOpenFileName;
begin
  Setup(Path, SizeOf(TFilename), FNStruct);
  PromptForOpenFileName := GetOpenFileName(FNStruct);
end;

{ Calls the common Windows dialog function to prompt the user for the
  filename to use.
}
procedure TOleDocument.SaveAs;
var
  Path    : TFilename;    { Result of GetSaveFileName }
  FNStruct: TOpenFileName;
begin
  Setup(Path, SizeOf(Path), FNStruct);

  if GetSaveFileName(FNStruct) then
  begin
    DocType := DoctypeFromFile;
    SetDocumentName(Path, True);  { We must do this BEFORE we call SaveDoc }
    SaveDoc;

    { Now inform the server library that we have renamed the document
    }
    OleRenameServerDoc(ServerDoc, Name);
  end;
end;

{ Saves the document to file 'Name' and marks the document as no
  longer 'dirty'.
}
procedure TOleDocument.SaveDoc;
var
  OutStream: TBufStream;
  Blank    : Char;
begin
  if DocType = DoctypeNew then
    SaveAs
  else
  begin
    OutStream.Init(Name, stCreate, 1000);
    OutStream.Write(ClassKey^, StrLen(ClassKey));
    Blank := ' ';
    OutStream.Write(Blank, 1);
    OutStream.Put(OleObject);
    IsDirty := False;
    OutStream.Done;
  end;
end;

{ Creates thunks for TOleServerDoc method callback tables
}
function TOleDocument_InitVTbl(Inst: THandle): Boolean;
begin
  @OleServerDocVTbl.Save            := MakeProcInstance(@Save,              Inst);
  @OleServerDocVTbl.Close           := MakeProcInstance(@Close,             Inst);
  @OleServerDocVTbl.SetHostNames    := MakeProcInstance(@SetHostNames,      Inst);
  @OleServerDocVTbl.SetDocDimensions:= MakeProcInstance(@SetDocDimensions,  Inst);
  @OleServerDocVTbl.GetObject       := MakeProcInstance(@GetObject,         Inst);
  @OleServerDocVTbl.Release         := MakeProcInstance(@ReleaseDoc,        Inst);
  @OleServerDocVTbl.SetColorScheme  := MakeProcInstance(@SetColorSchemeDoc, Inst);
  @OleServerDocVTbl.Execute         := MakeProcInstance(@ExecuteDoc,        Inst);

  TOleDocument_InitVTbl := (@OleServerDocVTbl.Save <> nil) and
                           (@OleServerDocVTbl.Close <> nil) and
                           (@OleServerDocVTbl.SetHostNames <> nil) and
                           (@OleServerDocVTbl.SetDocDimensions <> nil) and
                           (@OleServerDocVTbl.GetObject <> nil) and
                           (@OleServerDocVTbl.Release <> nil) and
                           (@OleServerDocVTbl.SetColorScheme <> nil) and
                           (@OleServerDocVTbl.Execute <> nil);
end;

end.
