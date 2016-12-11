{***************************************************}
{                                                   }
{   Windows 3.1 OLE Server Demonstration Program    }
{   Server Window Unit                              }
{   Copyright (c) 1992 by Borland International     }
{                                                   }
{***************************************************}

{ This unit implements the main window for the OLE Server
  demo application.  This is the window which manages the
  display and modification of the supported OLE objects.

  Note: To compile the OLE Server demo, set Compile|Primary File
  to OLESERVR.PAS
}

unit ServrWin;

interface

uses WinTypes, WinProcs, OWindows, OleTypes;

type

{ Type used to communicate the result of File I/O dialogs.
}
  TFileIoStatus = (fiCancel, fiExecute);

{ Application Main Window }

  PServerWindow = ^TServerWindow;
  TServerWindow = object(TWindow)
    constructor Init(AParent: PWindowsObject; ATitle: PChar);

    function  CanClose: Boolean; virtual;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure DefCommandProc(var Msg: TMessage); virtual;

    procedure BeginEmbedding; virtual;
    procedure EndEmbedding; virtual;
    function  SaveChangesPrompt: TFileIoStatus; virtual;
    procedure ShapeChange(NewType: TNativeType); virtual;
    procedure UpdateFileMenu(DocName: PChar); virtual;

    procedure CMFileNew(var Msg: TMessage);
      virtual cm_First + cm_FileNew;
    procedure CMFileOpen(var Msg: TMessage);
      virtual cm_First + cm_FileOpen;
    procedure CMFileSave(var Msg: TMessage);
      virtual cm_First + cm_FileSave;
    procedure CMFileSaveAs(var Msg: TMessage);
      virtual cm_First + cm_FileSaveAs;
    procedure CMFileUpdate(var Msg: TMessage);
      virtual cm_First + cm_FileUpdate;
    procedure CMEditCopy(var Msg: TMessage);
      virtual cm_First + cm_EditCopy;
    procedure CMHelpAbout(var Msg: TMessage); 
      virtual cm_First + cm_HelpAbout;
  end;

implementation

uses Ole, Strings, ODialogs, OleApp, Server, OleObj;

{ Initialized globals }

const
  CmToNativeType: array[cm_ShapeEllipse..cm_ShapeTriangle] of TNativeType
                    = (ObjEllipse, ObjRect, ObjTriangle);

  NativeTypeToCm: array[TNativeType] of Word
                    = (cm_ShapeEllipse, cm_ShapeRectangle, cm_ShapeTriangle);


{ TServerWindow Methods }

constructor TServerWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  TWindow.Init(AParent, ATitle);
  Attr.Menu := LoadMenu(HInstance, PChar(id_Menu));
  Attr.X    := 100;
  Attr.Y    := 100;
  Attr.W    := 250;
  Attr.H    := 250;
end;

{ Prompts the user to save changes in the document and return,
  and whether the pending operation (new/open/exit) should be
  executed or canceled.  The user has requested File/New,
  File/Open, or File/Exit.
}
function TServerWindow.SaveChangesPrompt: TFileIoStatus;
var
  App     : POleApp;
  Doc     : POleDocument;
  Outcome : Integer;
  Buf     : array [0..127] of Char;
begin
  App := POLEApp(Application);
  Doc := App^.Server^.Document;
  Outcome := IdYes;

  if Doc^.IsDirty then
  begin
    if Doc^.DocType = DoctypeEmbedded then
    begin
      StrCopy(Buf, 'Embedded object ');
      StrCat (Buf, Doc^.Name);
      StrCat (Buf, ' has changed. Do you want to update?');
    end
    else
    begin
      StrCopy(Buf, 'Do you want to save changes to ');
      StrCat (Buf, Doc^.Name);
      StrCat (Buf, '?');
    end;

    Outcome := MessageBox(HWindow, Buf, App^.Name, mb_IconQuestion or
      mb_YesNoCancel);

    if Outcome = IdYes then
      if Doc^.DocType = DoctypeEmbedded then
        OleSavedServerDoc(Doc^.ServerDoc)
      else
        Doc^.SaveDoc;
  end;

  if Outcome <> IdCancel then
  begin
    { If the server library is in the process of closing down
      connections to the document, wait until it is finished
      (flag "IsReleased" becomes True) before we re-use the
      document space.
    }
    if OleRevokeServerDoc(Doc^.ServerDoc) = ole_Wait_For_Release then
      App^.Wait(Doc^.IsReleased);

    Doc^.ServerDoc := 0;

    if Doc^.DocType = DoctypeEmbedded then
      EndEmbedding;
  end;
 
  if Outcome = IdCancel then
    SaveChangesPrompt := fiCancel
  else
    SaveChangesPrompt := fiExecute;
end;

{ Prompts the user for changes and initiate application shutdown by
  calling OleRevokeServer.  OleRevokeServer automatically revokes any
  documents which revokes any objects.
}
function TServerWindow.CanClose: Boolean;
var
  App   : POLEApp;
  Server: POleServerObj;
begin
  App   := POleApp(Application);
  Server:= App^.Server;

  if SaveChangesPrompt = fiExecute then
  begin
    { If the server library is in the process of closing down
      connections to the server, wait until it is finished (flag
      "IsReleased" becomes True) before we terminate
    }
   if OleRevokeServer(Server^.ServerHdl) = ole_Wait_for_Release then
      App^.Wait(Server^.IsReleased);
    CanClose := True;
  end
  else
    CanClose := False;
end;

{ Rather than have a message response function for each menu item on the
  "Shape" menu we catch the commands here instead.  Other commands are 
  passed to our inherited method.
}
procedure TServerWindow.DefCommandProc(var Msg: TMessage);
begin
  if (Msg.WParam >= cm_ShapeEllipse) and
      (Msg.WParam <= cm_ShapeTriangle) then
    ShapeChange(CmToNativeType[Msg.WParam])
  else
    TWindow.DefCommandProc(Msg);
end;

{ Responds to selection of the File/New menu item.
}
procedure TServerWindow.CMFileNew(var Msg: TMessage);
begin
  if SaveChangesPrompt = fiExecute then
    POleApp(Application)^.Server^.Document^.Reset(nil);
end;

{ Responds to selection of the File/Open menu item.
}
procedure TServerWindow.CMFileOpen(var Msg: TMessage);
var
  Path: TFilename;
  Doc : POleDocument;
begin
  Doc := POleApp(Application)^.Server^.Document;
  if SaveChangesPrompt = fiExecute then
  begin
    if Doc^.PromptForOpenFileName(Path) then
      Doc^.Reset(Path)
    else
      Doc^.Reset(nil);
  end;
end;

{ Responds to selection of the File/Save menu item.
  NOTE: This is only for stand-alone mode, when we're not
  linked.
}
procedure TServerWindow.CMFileSave(var Msg: TMessage);
begin
  POleApp(Application)^.Server^.Document^.SaveDoc;
end;

{ Responds to selection of the File/SaveAs menu item.
}
procedure TServerWindow.CMFileSaveAs(var Msg: TMessage);
begin
  POleApp(Application)^.Server^.Document^.SaveAs;
end;

{ Responds to selection of the File/Update menu item.
  NOTE: This is only for embedding mode.
}
procedure TServerWindow.CMFileUpdate(var Msg: TMessage);
var
  Doc: POleDocument;
begin
  Doc := POleApp(Application)^.Server^.Document;

  { Notify the server library that the embedded document
    has changed
  }
  OleSavedServerDoc(Doc^.ServerDoc);
  Doc^.IsDirty := False;
end;

{ Copies the object to the clipoard.  NOTE: since this app only has one
  object we don't support "Cut" and "Delete", but your app might want to.
}
procedure TServerWindow.CMEditCopy(var Msg: TMessage);
var
  App      : POleApp;
  ObjectPtr: POleObjectObj;
  Handle   : THandle;
begin
  App      := POLEApp(Application);
  ObjectPtr:= App^.Server^.Document^.OleObject;

  if OpenClipboard(HWindow) then
  begin
    EmptyClipboard;

    { Server applications are responsible for placing the data formats
      on the clipboard in most important order first.  Here is the standard
      ordering:
        1. Application-specific data
        2. Native
        3. OwnerLink
        4. cf_MetafilePict
        5. cf_Bitmap
        6. ObjectLink
        7. Any other data
    
     add Native first...
    }
    Handle := ObjectPtr^.GetNativeData;
    if Handle <> 0 then
      SetClipboardData(App^.cfNative, Handle);

    { In order for the object to be embedded we must also identify the
      owner of the object using "OwnerLink" data
    }
    Handle := ObjectPtr^.GetLinkData;
    if Handle <> 0 then
      SetClipboardData(App^.cfOwnerLink, Handle);

    { Now offer at least one presentation format.  If the server doesn't
      have an object handler DLL then it must provide a metafile.
    }
    Handle := ObjectPtr^.GetMetafilePicture;
    if Handle <> 0 then
      SetClipboardData(cf_MetafilePict, Handle);

    { Now offer bitmap format.
    }
    Handle := ObjectPtr^.GetBitmapData;
    if Handle <> 0 then
      SetClipboardData(cf_Bitmap, Handle);

    { If the document type is a file then we can offer 'ObjectLink'.
    }
    if (App^.Server^.Document^.DocType = DoctypeFromFile) then
    begin
      Handle := ObjectPtr^.GetLinkData;
      if Handle <> 0 then
        SetClipboardData(App^.cfObjectLink, Handle);
    end;

    CloseClipboard;
  end;
end;

{ Activates the Help dialog.
}
procedure TServerWindow.CMHelpAbout(var Msg: TMessage);
begin
  Application^.ExecDialog(New(PDialog, Init(@Self, PChar(id_About))));
end;

{ Responds to selection of a menu item from the "Shape" menu.  Checks the
  new menu item, unchecks the previous menu item, changes the selected 
  object's type, repaints the damaged area, and checks the menu items to
  see if they should be enabled/disabled.
}
procedure TServerWindow.ShapeChange(NewType: TNativeType);
var
  DocPtr   : POleDocument;
  ObjectPtr: POleObjectObj;
  OldType  : TNativeType;
  Rect     : TRect;
  MyMenu   : HMenu;
begin
  MyMenu := GetMenu(HWindow);

  DocPtr   := POleApp(Application)^.Server^.Document;
  ObjectPtr:= DocPtr^.OleObject;
  OldType  := ObjectPtr^.GetType;

  if NewType <> OldType then
  begin
    { Change the object's type which marks the document as 'dirty' and
      notifies each linked object of the change.  Then invalidate
      the window to redraw the object, and update the menu to reflect
      the changes.
    }
    ObjectPtr^.SetType(NewType);

    InvalidateRect(HWindow, nil, True);
    CheckMenuItem(MyMenu, NativeTypeToCm[OldType], mf_Unchecked);
    CheckMenuItem(MyMenu, NativeTypeToCm[NewType], mf_Checked);
  end;
end;

{ Changes the File/Save As... menu item to File/Save Copy As...
  when an embedded document is being edited.
}
procedure TServerWindow.BeginEmbedding;
var
  MyMenu : HMenu;
begin
  MyMenu := GetMenu(HWindow);
  ModifyMenu(MyMenu, cm_FileSaveAs, mf_ByCommand or mf_String, cm_FileSaveAs, 'Save Copy &As...');
end;

{ Changes File/Save Copy As..., File/Exit & Return, and
  File/Update menu entries to reflect the end of embedded editing.
}
procedure TServerWindow.EndEmbedding;
var
  MyMenu : HMenu;
begin
  MyMenu := GetMenu(HWindow);
  ModifyMenu(MyMenu, cm_FileSaveAs, mf_ByCommand or mf_String,
    cm_FileSaveAs, 'Save &As...');
  ModifyMenu(MyMenu, cm_Exit,       mf_ByCommand or mf_String,
    cm_Exit,       'E&xit');
  ModifyMenu(MyMenu, cm_FileUpdate, mf_ByCommand or mf_String,
    cm_FileSave,   '&Save');
end;

{ Changes the  File/Save to File/Update <Client Document> and
  File/Exit to File/Exit & Return to <Client Document> in response
  to a SetHostNames callback from the Client.
}
procedure TServerWindow.UpdateFileMenu(DocName: PChar);
var
  MyMenu : HMenu;
  Buf    : array [0..127] of Char;
begin
  MyMenu := GetMenu(HWindow);

  StrCopy(Buf, '&Update ');
  StrCat(Buf, DocName);
  ModifyMenu(MyMenu, cm_FileSave, mf_ByCommand or mf_String,
    cm_FileUpdate, Buf);

  StrCopy(Buf, '&Exit and Return to ');
  StrCat(Buf, DocName);
  ModifyMenu(MyMenu, cm_Exit, mf_ByCommand or mf_String, cm_Exit, Buf);
end;

{ Draws the object in Self's client area, by requesting the OLE Server
  to perform the paint with our DC.
}
procedure TServerWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
begin
  SetViewportOrg(PaintDC, ObjX, ObjY);
  POleApp(Application)^.Server^.Document^.OleObject^.Draw(PaintDC);
end;

end.

