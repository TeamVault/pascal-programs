{***************************************************}
{                                                   }
{   Windows 3.1 OLE Server Demonstration Program    }
{   Types and Constants Unit                        }
{   Copyright (c) 1992 by Borland International     }
{                                                   }
{***************************************************}

unit OleTypes;

{ This unit contains the definition of types and constants
  that are used by more than one unit of the OLE Server
  Demonstration program.

  Note: To compile the OLE Server demo, set Compile|Primary File to OLESERVR.PAS
}

interface

const

{ Resource IDs }

  id_Menu  = 100;
  id_About = 100;
  id_Icon  = 100;

{ Menu command IDs }

  cm_FileNew        = 100;    { File Menu }
  cm_FileOpen       = 101;
  cm_FileSave       = 102;
  cm_FileSaveAs     = 103;
  cm_FileUpdate     = 104;
  cm_EditCopy       = 200;    { Edit Menu }
  cm_ShapeEllipse   = 300;
  cm_ShapeRectangle = 301;
  cm_ShapeTriangle  = 302;
  cm_HelpAbout      = 400;    { Help Menu }

{ Miscellaneous Constants }

  MaxLinks          = 10;     { Max # of Client Links }

  ObjX              = 75;     { Defines position and size }
  ObjY              = 50;     { of the shape object.      }
  ObjWidth          = 100;
  ObjHeight         = 100;

{ Error codes }

  olRegClipError  = 182;      { Used within this app to signal errors }
  olInitVTBLError = 183;      { Handled in TOleApp.Error.             }                                  

type

  TFilename = array [0..255] of Char;

{ Version Type.  Server applications should store version numbers in their
  Native data formats.  This way a client application may embed data from
  one version of a server and later request a newer version to edit that 
  data.
}
  TVersion = Integer;

{ Type which defines the different Native data type formats.
}
  TNativeType = (ObjEllipse, ObjRect, ObjTriangle);

{ Record type which combines the Native type with its version.
}
  PNative = ^TNative;
  TNative = record
    NativeType : TNativeType;
    Version    : TVersion;
  end;

{ Type which defines the different states of an Ole document.
}
  TDocType = (DoctypeNew,        {Document is untitled}
              DoctypeFromFile,   {Document exists in a file and may be
                                  linked}
              DoctypeEmbedded);  {Document is an embedded document}

{ Initialized Globals }

const

 DemoTitle  : PChar = 'OLE Server Demo';
 ClassKey   : PChar = 'OLEServerDemoTPW';
 ClassValue : PChar = 'OLE Demo Object';
 ExeName    : PChar = 'oleservr';
 FileExt    : PChar = 'oos';
 Embedding  : PChar = 'Embedding';

implementation

end.
