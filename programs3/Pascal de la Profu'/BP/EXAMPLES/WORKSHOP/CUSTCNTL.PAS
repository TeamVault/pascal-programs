{*******************************************************}
{                                                       }
{       Turbo Pascal                                    }
{       Custom Control API Interface Unit               }
{                                                       }
{       Copyright (c) 1991 Borland International        }
{                                                       }
{*******************************************************}

unit CustCntl;

interface

uses WinTypes;

const
  ctlTypes = 12;
  ctlDescr = 22;
  ctlClass = 20;
  ctlTitle = 94;

{ CONTROL STYLE DATA STRUCTURE

  This data structure is used by the class style dialog function
  to set and/or reset various control attributes.}

type
  PCtlStyle = ^TCtlStyle;
  TCtlStyle = record
    wX:   Word;                             { x origin of control }
    wY:   Word;                             { y origin of control }
    wCx:  Word;                             { width of control }
    wCy:  Word;                             { height of control }
    wId:  Word;                             { control child id }
    dwStyle: LongInt;                       { control style }
    szClass: array[0..ctlClass-1] of Char;  { name of control class }
    szTitle: array[0..ctlTitle-1] of Char;  { control text }
  end;

{ CONTROL DATA STRUCTURE

  This data structure is returned by the control options function
  when inquiring about the capabilities of a particular control.
  Each control may contain various types (with predefined style
  bits) under one general class.


  The width and height fields provide the application with
  a suggested size. Use pixels or dialog units for the values
  in these fields. If you use pixels, turn on the most significant
  bit (MSB). If you use dialog units, turn off the MSB.}
 
  PCtlType = ^TCtlType;
  TCtlType = record
    wType:   Word;                          { type style }
    wWidth:  Word;                          { suggested width }
    wHeight: Word;                          { suggested height }
    dwStyle: LongInt;                       { default style }
    szDescr: array[0..ctlDescr-1] of Char;  { menu name }
  end;

  PCtlInfo = ^TCtlInfo;
  TCtlInfo = record
    wVersion:   Word;                           { control version }
    wCtlTypes:  Word;                           { control types }
    szClass:    array[0..ctlClass-1] of Char;   { control class name }
    szTitle:    array[0..ctlTitle-1] of Char;   { control title }
    szReserved: array[0..9] of Char;            { reserved for future use }
    ctType:     array[0..ctlTypes] of TCtlType; { control type list }
  end;

{ These two function variable types are used by dialog editor }

  TStrToId = function (Str: PChar): LongInt;
  TIdToStr = function (Id: Word; Str: PChar; StrLen: Word): Word;

{ Resource Workshop extensions follow here }

  TFnList  = function : THandle;
  TFnInfo  = function : THandle;
  TFnStyle = function(hWindow: HWnd; CntlStyle: THandle;
    StrToId: TStrToId; IdToStr: TIdToStr): Bool;
  TFnFlags = function(Style: LongInt; Buff: PChar; BuffLength: Word): Word;

{ Resource Workshop has extended the MS Dialog editor's custom control
  API in three main areas:

  1) More than 1 custom control can be placed in a single DLL.

  2) The "Info" data structure has been extended to allow custom controls
     to be added to the RW toolbox.

  3) The style data structure has been extended to allow custom controls
     access to the CTLDATA field. This field contains up to 255 bytes
     of binary data. A pointer to this data is passed to the control
     in the WM_CREATE message at runtime.
}

{ Two new fields have been added to the TCtlType data structure to
  make the TRWCtlType structure:

  hToolBit is a handle to a 24X24 bitmap which is added to the
  RW toolbox. If this field is 0, no button will be added for this style,
  and it will only be selectable via the Custom control dialog. This bitmap
  is "owned" by RW, and will be freed by RW when the dialog editor is
  unloaded.

  hDropCurs is a handle to a cursor which is used by RW when a user selects
  the control from the toolbox. If 0, a "cross" cursor will be used.
}

const
  ToolBitSize = 24;

type
  PRWCtlType = ^TRWCtlType;
  TRWCtlType = record
    wType:     Word;                          { type style }
    wWidth:    Word;                          { suggested width }
    wHeight:   Word;                          { suggested height }
    dwStyle:   LongInt;                       { default style }
    szDescr:   array[0..ctlDescr-1] of Char;  { menu name }
    hToolBit:  HBitmap;                       { toolbox bitmap }
    hDropCurs: HCursor;                       { drag and drop cursor }
  end;

{ This structure reflects the RWCTLTYPE data structure }

  PRWCtlInfo = ^TRWCtlInfo;
  TRWCtlInfo = record
    wVersion:   Word;                             { control version }
    wCtlTypes:  Word;                             { control types }
    szClass:    array[0..ctlClass-1] of Char;     { control class name }
    szTitle:    array[0..ctlTitle-1] of Char;     { control title }
    szReserved: array[0..9] of Char;              { reserved for future use }
    ctType:     array[0..ctlTypes] of TRWCtlType; { control type list }
  end;

{ Two new fields have been added to the CTLSTYLE data structure to make
  the RWCTLSTYLE data structure:

  CtlDataSize is the size of
  CtlData, which is an array of bytes passed to the control in the
  WM_CREATE message.
}

const
  ctlDataLength = 255;

type
  PRWCtlStyle = ^TRWCtlStyle;
  TRWCtlStyle = record
    wX:   Word;                                 { x origin of control }
    wY:   Word;                                 { y origin of control }
    wCx:  Word;                                 { width of control }
    wCy:  Word;                                 { height of control }
    wId:  Word;                                 { control child id }
    dwStyle: LongInt;                           { control style }
    szClass: array[0..ctlClass-1] of Char;      { name of control class }
    szTitle: array[0..ctlTitle-1] of Char;      { control text }
    CtlDataSize: Byte;                          { control data size }
    CtlData: array[0..ctlDataLength-1] of Char; { control data }
  end;

{ In order to use RW's extensions to the custom controls, a custom
  control DLL *must* implement the ListClasses function. This function
  returns a global memory handle to an initialized CTLCLASSLIST data
  structure. All function pointers *must* point to valid functions.
}

  PRWCtlClass = ^TRWCtlClass;
  TRWCtlClass = record
    fnInfo:  TFnInfo;                       { Info function }
    fnStyle: TFnStyle;                      { Style function }
    fnFlags: TFnFlags;                      { Flags function }
    szClass: array[0..ctlClass-1] of Char;  { Class name }
  end;

  PCtlClassList = ^TCtlClassList;
  TCtlClassList = record
    nClasses: Integer;                       { Number of classes in list }
    Classes: array[0..0] of TRWCtlClass;     { Class list }
  end;

{ The ListClasses function has the formal definition:

    function ListClasses(szAppName: PChar; wVersion: Word;
      fnLoad: TLoad; fnEdit: TEdit): THandle; export;

  where the parameters are

    szAppName         The class name for the applications main window

    wVersion          Major and minor version number of the application

    fnLoad            A procedure variable which, when called, acts like
                      a LoadResource on the current resource being edited.
                      This allows controls access to resource from the
                      resource file they are apart of (for example, access
                      to bitmaps).

    fnEdit            Causes a resource editor to be invoked for the given
                      resource.
}

  TLoad = function (szType, szId: PChar): THandle;
  TEdit = function (szType, szId: PChar): Bool;

implementation

end.

