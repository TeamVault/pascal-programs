{***************************************************}
{                                                   }
{   Windows 3.1 OLE Server Demonstration Program    }
{   OLE Object Unit                                 }
{   Copyright (c) 1992 by Borland International     }
{                                                   }
{***************************************************}

{ This unit implements the actual OLE Object.  The Object rep-
  resents the lowest level of interaction between the Client and
  Server: the Object is the actual information the Client is after.

  For this demo, the only supported object is a simple blue graphic
  that can be one of three shapes: a circle, a square, or a
  rectangle.

  Although we have embedded the native data in the ole object, you might
  not want to do this.  Rather than integrate OLE with your app you
  should treat OLE as a protocol that sits on top of your app and allows
  other applications access to your server's data.  Instead of embedding
  the data in the OLE object have the OLE object contain a pointer to the
  native data.

  Note: To compile the OLE Server demo, set Compile|Primary File
  to OLESERVR.PAS

}

unit OleObj;

interface

uses WinTypes, Objects, Ole, OleTypes;

type

{ Type which defines the types of actions that the server can perform on
  an object.
}
  TVerb = (VerbEdit, VerbPlay);

{ The following record types represent the Object within
  the OLE library.  It is based on the standard structure
  defined in Ole.pas, and adds one field to provide access
  back to the TPW object which represents it.
}
  POleObjectObj = ^TOleObjectObj;

  PAppObject = ^TAppObject;
  TAppObject = record
    OleObject: TOleObject;
    Owner    : POleObjectObj;
  end;

{ TOleObjectObj }

{ This object represents the OLE Object, wrapping useful
  behaviors around the basic TOleObject structure that is
  used within OLE to represent an object.  This structure
  is represented by the AppObject data field, which is of
  the TAppObject type defined in oleservr.pas, and which
  includes an additional field which points back to Self
  so that our callback functions can reference this object.
}
  TOleObjectObj = object(TObject)
    AppObject : TAppObject;
    Native    : TNative;
    IsReleased: Boolean;  { True if Release method has been called }
    Clients   : array[0..MaxLinks] of POleClient;  { nil terminated list of client(s) }
                                                   { we are linked to                 }
    constructor Init;
    constructor Load(var S: TStream);

    procedure AddClientLink(OleClient: POleClient); virtual;
    procedure Draw(ADC: HDC); virtual;
    function  GetType: TNativeType; virtual;
    procedure ObjectChanged; virtual;
    procedure SetType(NewType: TNativeType); virtual;
    procedure Store(var S: TStream); virtual;

    { Routines to build the various clipboard formats that are required for
      an OLE server.  Your routine might provide routines for additional 
      formats such as TEXT, RTF, and DIB.
    }
    function GetNativeData:      THandle; virtual;       
    function GetLinkData:        THandle; virtual;        
    function GetBitmapData:      HBitmap; virtual;
    function GetMetafilePicture: THandle; virtual;
  end;

{ TOleObjectObj stream registration record }

const
  ROleObjectObj: TStreamRec = (
    ObjType: 888;
    VmtLink: Ofs(TypeOf(TOleObjectObj)^);
    Load   : @TOleObjectObj.Load;
    Store  : @TOleObjectObj.Store
  );

function TOleObjectObj_InitVTBL(Inst: THandle): Boolean;

implementation

uses WinProcs, Strings, OWindows, Server, OleApp, ServrWin;

{ Global variables }

var
  OleObjectVtbl: TOleObjectVtbl;


{ Object Callback Procedures }

{ NOTE:
  The first parameter to each callback is a pointer to the TOleObject
  structure that defines this object.  In each case, we know that it
  will really be a pointer to a TAppObject record, which includes a
  pointer to the Pascal object which owns the TOleObject record.  We
  can therefore use a typecast to access that object, and thus find our
  way back to Self.
}

{ Handles the QueryProtocol callback.  The server library is trying to
  determine which protocols we support.  'Protocol' will either be 
  'StdFileEditing' or 'StdExecute'.  If we don't support the protocol 
  then we should return nil.  Since we don't support 'StdFileExecute'
  we return nil in that case.
}    
function QueryProtocol(Self: POleObject; Protocol: PChar): Pointer; export;
begin
  if StrIComp(Protocol, 'StdFileEditing') = 0 then
    QueryProtocol := Self
  else
    QueryProtocol := nil;
end;

{ Handles the Release callback.  This gets called when the library wants
  to inform us that we have no more clients connected to the object.  It
  is initiated after the client calls OleDelete or the server calls
  OleRevokeServer, OleRevokeServerDoc, or OleRevokeObject.

  This is the last time that the receiving object will be called, so all
  resources for the object can be free'd, but we MUST not delete the object
  itself.

  WHAT TO DO:
    - Free resources associated with the object
    - Set a flag to indicate 'Release' has been called
    - Nil out any POleClient handles saved in the object
    - Return ole_Ok if successful, Ole_Error_Generic otherwise

  NOTE: This is not called Release since it appears at the same scope as
  the Release callback for the Server.
}
function ReleaseObj(Self: POleObject): TOleStatus; export;
var
  SelfPtr: POleObjectObj;
begin
  SelfPtr := PAppObject(Self)^.Owner;

  SelfPtr^.Clients[0] := nil;
  SelfPtr^.IsReleased := True;
  ReleaseObj := ole_Ok;
end;

{ Handles the Show callback.  This gets called when we should make the 
  object visible by making the server window visible and possibly scroling
  the object into view.  If the object is selectable, select it as well.
  'TakeFocus' indicates whether the server should set focus to itself.

  WHAT TO DO:
    - Show the window(s) if not visible
    - Scroll 'OleObject' into view and select it if possible
    - If 'TakeFocus' is True, call SetFocus with the main window handle
    - Return ole_Ok if successful, Ole_Error_Generic otherwise
}
function Show(Self: POleObject; TakeFocus: Bool): TOleStatus; export;
begin
  { In our case all we need to do is request that the window is showing
  }
  Application^.MainWindow^.Show(sw_ShowNormal);

  if TakeFocus then
    SetFocus(Application^.MainWindow^.HWindow);

  Show := ole_Ok;
end;

{ Handles the DoVerb callback.  The client application has called
  OleActivate on an embedded object and requests an action on the object.
  The action is specified by the verb identifier 'Verb'.  This server
  only understands EDIT and PLAY:  all we do for PLAY is beep, and for
  EDIT we bring up the server and let the user edit the specified object.

  PARAMETERS:
    - 'Verb' is the index to the verb to execute
    - 'Show' indicates if the server should show the object or 
      remain in its current state
    - 'Focus' indicates if the server should take the focus

  WHAT TO DO:
    - For PLAY verb, a server doesn't usually show its window or affect the
      focus
    - For EDIT verb, show the server's window and object if 'Show' and
      take the focus if 'Focus'
    - Return ole_Ok if successful, Ole_Error_DoVerb otherwise
}
function DoVerb(Self: POleObject; Verb: Word; Show, Focus: Bool): TOleStatus; export;
begin
  case TVerb(Verb) of
    VerbEdit:
      { The easiest way to show the server's window is to send the
        object a 'Show' message.  Note how we access the Object's
        callback list directly.
      }
      if Show then
        DoVerb := Self^.lpvtbl^.Show(Self, Focus)
      else
        DoVerb := ole_Ok;

    VerbPlay:
      begin
        MessageBeep(0);
        MessageBeep(0);

        DoVerb := ole_Ok;
      end;
  else
    DoVerb := Ole_Error_DoVerb;
  end;
end;

{ Handles the GetData callback.  We are requested to supply data for
  the object in a specific format, such as Native or cf_MetaFilePict.
  In general, you should handle the same data formats that you put on
  the clipboard when the object was embedded/linked.  These should be
  the same formats that are returned by EnumFormats callback.

  Requests for GetData occur any time that the client needs to display
  an object, or when the data must be written to a client file.
}
function GetData(Self: POleObject; Format: TOleClipFormat;
  var Handle: THandle): TOleStatus; export;
var
  App    : POleApp;
  Stat   : TOleStatus;
  SelfPtr: POleObjectObj;
begin
  SelfPtr:= PAppObject(Self)^.Owner;
  App    := POleApp(Application);

  Stat := ole_Ok;
  if Format = App^.cfNative then
    Handle := SelfPtr^.GetNativeData
  else
    if Format = App^.cfOwnerLink then
      Handle := SelfPtr^.GetLinkData
    else
      if Format = cf_Bitmap then
        Handle := SelfPtr^.GetBitmapData
      else
        if Format = cf_MetaFilePict then
          Handle := SelfPtr^.GetMetafilePicture
        else
          Stat := Ole_Error_Format;

  if  Stat = ole_Ok then
    if Handle = 0 then
      Stat := Ole_Error_Memory;

  GetData := Stat;
end;

{ Handles the SetData callback.  This gets called to provide the server 
  with the data for an object that is embedded in a client.  This routine
  gets called after the server has received an 'Edit' message.  This is
  always called before 'DoVerb' and 'Show'.

  WHAT TO DO:
    - If the data format isn't supported, return Ole_Error_Format
    - Lock down the memory to get a pointer to the data, returning
      Ole_Error_Memory if GlobalLock returns NULL
    - Copy the data to the object indicated by 'Self'
    - Unlock the memory and call GlobalFree on the handle (you are
      responsible for the memory!)
    - Return ole_Ok
}
function SetData(Self: POleObject; Format: TOleClipFormat;
  Data: THandle): TOleStatus; export;
var
  App    : POleApp;
  SelfPtr: POleObjectObj;
  DataPtr: PNative;
  NewType: TNativeType;
begin
  SelfPtr:= PAppObject(Self)^.Owner;
  App    := POleApp(Application);

  if Format <> App^.cfNative then
    SetData := Ole_Error_Format   { Data isn't in Native format }
  else
  begin
    DataPtr := PNative(GlobalLock(Data));

    if DataPtr = nil then
      SetData := Ole_Error_Memory
    else
    begin
      with SelfPtr^ do
      begin
        Native := DataPtr^;

        { Update the applications knowledge of the type }
        NewType := Native.NativeType;
        Native.NativeType := ObjEllipse; 
        PServerWindow(Application^.MainWindow)^.ShapeChange(NewType);
        Native.NativeType := NewType;
      end;

      GlobalUnlock(Data);
      GlobalFree(Data);    
      SetData := ole_Ok;
    end;
  end;
end;

{ Handles the SetTargetDevice callback.  Not supported; always returns
  Ole_Error_Generic.
}
function SetTargetDevice(Self: POleObject;
  TargetDevice: THandle): TOleStatus; export;
begin
  SetTargetDevice := Ole_Error_Generic;
end;

{ Handles the SetBounds callback.  Not supported; always returns
  Ole_Error_Generic. 
}
function SetBounds(Self: POleObject; var Bounds: TRect): TOleStatus; export;
begin
  SetBounds := Ole_Error_Generic;
end;

{ Handles the EnumFormats callback.  The client has requested that we 
  enumerate all clipboard formats that we support for the object 'Self'.
  The server library will make multiple calls until we return the format
  that the server library is looking for

  PARAMETERS:
    - 'Format' is the last format returned by this method. if it is 0 then
      this is the first call to the method for this series

  We terminate the query by returning NULL.

  NOTE: We *must* return the formats in the same order as the order that
        data is placed on the clipboard!
}
function EnumFormats(Self: POleObject;
  Format: TOleClipFormat): TOleClipFormat; export;
var
  App    : POleApp;
  SelfPtr: POleObjectObj;
begin
  App := POleApp(Application);

  { If 'Format' is 0 that indicates the client wants us to return the
    first format
  }
  if Format = 0 then
    EnumFormats := App^.cfNative
  else
    if Format = App^.cfNative then
      EnumFormats := App^.cfOwnerLink
    else
      if Format = App^.cfOwnerLink then
        EnumFormats := cf_MetaFilePict
      else
        if Format = cf_MetaFilePict then
          EnumFormats := cf_Bitmap
        else
          EnumFormats := 0;
end;

{ Handles the SetColorScheme callback.  Not supported, always returns 
  Ole_Error_Generic. 
}
function SetColorScheme(Self: POleObject;
  var Palette: TLogPalette): TOleStatus; export;
begin
  SetColorScheme := Ole_Error_Generic;
end;


{ TOleObjectObj Methods }

{ Constructs an instance of the TOleObjectObj.
}
constructor TOleObjectObj.Init;
begin
  AppObject.OleObject.lpvtbl := @OleObjectVTbl;
  AppObject.Owner            := @Self;

  Native.NativeType:= ObjEllipse;
  Native.Version   := 1;
  Clients[0]       := nil;
  IsReleased       := False;
end;

{ Constructs the Ole Object by loading it from the given stream.
}
constructor TOleObjectObj.Load(var S: TStream);
var
  NewType: TNativeType;
begin
  AppObject.OleObject.lpvtbl := @OleObjectVTbl;
  AppObject.Owner            := @Self;

  Native.NativeType:= ObjEllipse;
  Native.Version   := 1;
  Clients[0]       := nil;
  IsReleased       := False;

  S.Read(NewType, SizeOf(NewType));
  PServerWindow(Application^.MainWindow)^.ShapeChange(NewType);
  Native.NativeType := TNativeType(NewType);
  S.Read(Native.Version, SizeOf(Native.Version)); 
end;

{ Stores the Ole Object onto the given stream.
}
procedure TOleObjectObj.Store(var S: TStream);
begin
  S.Write(Native.NativeType, SizeOf(Native.NativeType));
  S.Write(Native.Version,    SizeOf(Native.Version)); 
end;

{ Gets the 'NativeType' field of the Native instance variable
  and returns it.
}
function TOleObjectObj.GetType: TNativeType;
begin
  GetType := Native.NativeType;
end;

{ Sets the 'NativeType' field of the Native instance variable and calls
  ObjectChanged to register the change.
}
procedure TOleObjectObj.SetType(NewType: TNativeType);
begin
  Native.NativeType := NewType;
  ObjectChanged;
end;

{ Responds to changes in a linked object by sending each of the clients
  we are linked to an Ole_Changed message.
}
procedure TOleObjectObj.ObjectChanged;
var
  I: Integer;
begin
  { Call the object through its callback function
  }
  I := 0;
  while Clients[I] <> nil do
  begin
    Clients[I]^.lpvtbl^.CallBack(Clients[I], Ole_Changed, @AppObject);
    inc(I);
  end;

  { Mark the document as changed
  }
  POleApp(Application)^.Server^.Document^.IsDirty := True;
end;

{ Adds a link to another client.
}
procedure TOleObjectObj.AddClientLink(OleClient: POleClient);
var
  I: Integer;
begin
  { We always append clients to the end of the list
  }
  I := 0;
  while (Clients[I] <> nil) and (I < MaxLinks-1) do
    inc(I);

  if (Clients[I] = nil) then
  begin
    Clients[I]  := OleClient;
    Clients[I+1]:= nil;  { Terminator }
  end;
end;

{ Draws the type specified by the 'NativeType' field of 'Native' using the
  device context that is passed in.
}
procedure TOleObjectObj.Draw(ADC: HDC);
const
  Pts: array [0..3] of TPoint = ((X:ObjWidth div 2; Y:0),
                                 (X:0;              Y:ObjHeight - 1),
                                 (X:ObjWidth - 1;   Y:ObjHeight - 1),
                                 (X:ObjWidth div 2; Y:0)
                                );
var
  OldBrush : HBrush;
  OldPen   : HPen;
begin
  OldBrush:= SelectObject(ADC, CreateSolidBrush(RGB(0, 0, 255)));
  OldPen  := SelectObject(ADC, GetStockObject(Null_Pen));

  case Native.NativeType of
    ObjEllipse:
      Ellipse(ADC, 0, 0, ObjWidth, ObjHeight);
    ObjRect:
      Rectangle(ADC, 0, 0, ObjWidth, ObjHeight);
    ObjTriangle:
      Polygon(ADC, Pts, 4);
  end;

  DeleteObject(SelectObject(ADC, OldBrush));
  SelectObject(ADC, OldPen);
end;

{ Returns a global memory handle that contains the native data for the
  receiver.  This handle can be used to set the Native clipboard data 
  format.
}
function TOleObjectObj.GetNativeData: THandle;
var
  DataHdl : THandle;
  DataPtr : PNative;
begin
  DataHdl := GlobalAlloc(gmem_DdeShare, SizeOf(Native));

  if DataHdl <> 0 then
  begin
    DataPtr := PNative(GlobalLock(DataHdl));
    DataPtr^:= Native;
    GlobalUnlock(DataHdl);
  end;
  GetNativeData := DataHdl;
end;

{ Returns a global memory handle suitable for pasting to the clipboard
  that contains three fields:

  - Class name
  - Document name (typically a fully qualified path name that identifies
    the file containing the document)
  - Item name (uniquely identifies the part of the document that is defined
    as an object)

  The class name and document name are null terminated, and the item name
  has two terminating null characters, e.g. CNAME#0DNAME#0INAME#0#0

  NOTE: Item names are assigned by the server. Since we have only 1 object
        per document, we always use the same name ('1'). most applications
        would use a different strategy, e.g. 'Object1', 'Object2', etc.

  Since 'ObjectLink' and 'OwnerLink' formats contain the same information
  the handle that is returned can be used for both clipboard formats
}
function TOleObjectObj.GetLinkData: THandle;
var
  DataHdl: THandle;
  DataPtr: PChar;
  Doc    : POleDocument;
  DocNameLen, ClassKeyLen, Len: Integer;
begin
  Doc := POleApp(Application)^.Server^.Document;

  DocNameLen := StrLen(Doc^.Name);
  ClassKeyLen:= StrLen(ClassKey);        
  Len        := ClassKeyLen + DocNameLen + StrLen('1') + 4;   { 4 nulls }

  DataHdl := GlobalAlloc(gmem_DdeShare, Len);

  if DataHdl <> 0 then
  begin
    DataPtr := GlobalLock(DataHdl);
  
    { Write class name, then the doc name, and then the item name (always
      '1').  Then, append the final NUL.
    }
    StrCopy(DataPtr, ClassKey);
    DataPtr := DataPtr + ClassKeyLen + 1;
    StrCopy(DataPtr, Doc^.Name);
    DataPtr := DataPtr + DocNameLen + 1;
    StrCopy(DataPtr, '1');
    DataPtr[2] := #0;
  
    GlobalUnlock(DataHdl);
  end;

  GetLinkData := DataHdl;
end;

{ Converts a width and height from device units to mm_HiMetric units,
  which are required by the OLE libraries
}
procedure SizeToHiMetric(var Width, Height: Integer);
const
  HiMetricPerInch : Longint = 2540;
var
  ADC: HDC;
  DpiX, DpiY: Integer;
begin
  ADC := GetDC(0);   { Gets a screen DC }

  DpiX := GetDeviceCaps(ADC, LogPixelsX);
  DpiY := GetDeviceCaps(ADC, LogPixelsY);

  Width := round(Width  * HiMetricPerInch / DpiX);
  Height:= round(Height * HiMetricPerInch / DpiY);

  ReleaseDC (0, ADC);
end;

{ Creates and returns a Metafile Pict which represents the current 
  object.
}
function TOleObjectObj.GetMetafilePicture: THandle;
var
  PictPtr: PMetaFilePict;
  PictHdl: THandle;          
  MFHdl  : THandle;
  ADC    : HDC;
  Width  : Integer;
  Height : Integer;
begin
  ADC   := CreateMetaFile(nil);
  Width := 100;
  Height:= 100;

  { Draw the object into the metafile
  }
  SetWindowOrg(ADC, 0, 0);
  SetWindowExt(ADC, Width, Height);
  Draw(ADC);

  { Get the handle to the metafile.
  }
  MFHdl := CloseMetaFile(ADC);

  { Allocate the metafile picture
  }
  PictHdl := GlobalAlloc(gmem_DDEShare, SizeOf(TMetaFilePict));

  if PictHdl <> 0 then
  begin
    SizeToHiMetric(Width, Height);
    PictPtr := PMetaFilePict(GlobalLock(PictHdl));
  
    PictPtr^.mm   := mm_Anisotropic;
    PictPtr^.hMF  := MFHdl;
    PictPtr^.xExt := Width;
    PictPtr^.yExt := Height;

    GlobalUnlock(PictHdl);
  end;

  GetMetafilePicture := PictHdl;
end;

{ Creates and returns an image of the Object as a Bitmap.
}
function TOleObjectObj.GetBitmapData: HBitmap;
var
  AWnd      : HWnd;
  ADC       : HDC;      
  AMemDC    : HDC;      
  ABitmap   : HBitmap; 
  OldBitmap : HBitmap; 
  Width     : Integer;
  Height    : Integer;
begin
  AWnd  := Application^.MainWindow^.HWindow;
  ADC   := GetDC(AWnd);
  AMemDC:= CreateCompatibleDC(ADC);

  ABitmap   := CreateCompatibleBitmap(ADC, 100, 100);
  OldBitmap := SelectObject(AMemDC, ABitmap);

  Width := 100;
  Height:= 100;

  ReleaseDC(AWnd, ADC);
  PatBlt(AMemDC, 0, 0, Width, Height, Whiteness);
  Draw(AMemDC);
  SelectObject(AMemDC, OldBitmap);
  DeleteDC(AMemDC);

  { Convert the width and height to mm_Himetric (all OLE libraries express
    the size of every object in mm_Himetric)
  }
  SizeToHiMetric(Width, Height);

  { SetBitmapDimension wants the width and height in .1 millimeter
    units, so we must divide by 10.
  }
  SetBitmapDimension(ABitmap, round(Width / 10), round(Height / 10));

  GetBitmapData := ABitmap;
end;

{ Initialize the VTbl for the Server.  Create thunks for OleObjectObj callback
  tables.
}
function TOleObjectObj_InitVTBL(Inst: THandle): Boolean;
begin
  @OleObjectVTbl.QueryProtocol   := MakeProcInstance(@QueryProtocol,   Inst);
  @OleObjectVTbl.Release         := MakeProcInstance(@ReleaseObj,      Inst);
  @OleObjectVTbl.Show            := MakeProcInstance(@Show,            Inst);
  @OleObjectVTbl.DoVerb          := MakeProcInstance(@DoVerb,          Inst);
  @OleObjectVTbl.GetData         := MakeProcInstance(@GetData,         Inst);
  @OleObjectVTbl.SetData         := MakeProcInstance(@SetData,         Inst);
  @OleObjectVTbl.SetTargetDevice := MakeProcInstance(@SetTargetDevice, Inst);
  @OleObjectVTbl.SetBounds       := MakeProcInstance(@SetBounds,       Inst);
  @OleObjectVTbl.EnumFormats     := MakeProcInstance(@EnumFormats,     Inst);
  @OleObjectVTbl.SetColorScheme  := MakeProcInstance(@SetColorScheme,  Inst);

  TOleObjectObj_InitVTbl := (@OleObjectVTbl.QueryProtocol <> nil) and
                            (@OleObjectVTbl.Release <> nil) and
                            (@OleObjectVTbl.Show <> nil) and
                            (@OleObjectVTbl.DoVerb <> nil) and
                            (@OleObjectVTbl.GetData <> nil) and
                            (@OleObjectVTbl.SetData <> nil) and
                            (@OleObjectVTbl.SetTargetDevice <> nil) and
                            (@OleObjectVTbl.SetBounds <> nil) and
                            (@OleObjectVTbl.EnumFormats <> nil) and
                            (@OleObjectVTbl.SetColorScheme <> nil);
end;

end.
