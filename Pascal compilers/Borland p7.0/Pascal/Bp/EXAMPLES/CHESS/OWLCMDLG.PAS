{************************************************}
{                                                }
{   ObjectWindows Chess Demo                     }
{   COMMDLG wrappers                             }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit OWLCmDlg;

interface

{$R OWLCMDLG.RES}

uses WinProcs, WinTypes, OWindows, ODialogs, CommDlg, WinDos, Strings;

type

   { TCDFileDlg builds an OWL object around a Windows 3.1 Common Dialog.
     By using the OWL object's Instance function pointer as the
     common dialog's hook procedure, the OWL object will get messages
     just as it would for a normal dialog (for the most part).

     Descendents of TCDFileDlg implement specific types of file dialogs:
     File Open, File Save, File Save As, and special purpose dialogs.}

   PCDFileDlg = ^TCDFileDlg;
   TCDFileDlg = object(TDialog)
     OFN : TOpenFileName;
     constructor Init(AParent: PWindowsObject; AFlags: Longint;
       AFileName: PChar; ANameLength: Word; AFilter: PChar);
     destructor Done;  virtual;
     function Create: Boolean; virtual;
     function Execute: Integer; virtual;
     function CDExecute: Bool; virtual;
     procedure OK(var Msg: TMessage);
       virtual id_First + id_OK;
     procedure Cancel(var Msg: TMessage);
       virtual id_First + id_Cancel;
   end;

   { TCDFileOpen implements a File Open common dialog.  If the main program
     is using BWCC, then this object makes the common dialog use a BWCC
     dialog template.  }

   PCDFileOpen = ^TCDFileOpen;
   TCDFileOpen = object(TCDFileDlg)
     constructor Init(AParent: PWindowsObject; AFlags: Longint;
       AFileName: PChar; ANameLength: Word; AFilter: PChar);
   end;

   PCDFileSaveAs = ^TCDFileSaveAs;
   TCDFileSaveAs = object(TCDFileOpen)
     constructor Init(AParent: PWindowsObject; AFlags: Longint;
       AFileName: PChar; ANameLength: Word; AFilter: PChar);
     function CDExecute: Bool; virtual;
   end;


implementation

const
  dlgCDFileOpen_BWCC   = MakeIntResource(32520);

constructor TCDFileDlg.Init(AParent: PWindowsObject; AFlags: Longint;
  AFileName: PChar; ANameLength: Word; AFilter: PChar);
var
  TempName: array[0..fsFileName] of Char;
  TempExt : array[0..fsExtension] of Char;

begin
   TDialog.Init(AParent,nil);
   FillChar(OFN,Sizeof(OFN),0);
   with OFN do
   begin
     lStructSize := SizeOf(OFN);
     hwndOwner := AParent^.hWindow;
     @lpfnHook := Instance;
     Flags     := AFlags or OFN_ENABLEHOOK;
     hInstance := System.hInstance;
     lpstrFilter := AFilter;
     lpstrFileTitle  := nil;
     nMaxFileTitle   := 0 ;
     GetMem(lpstrInitialDir,Succ(fsDirectory));
     lpstrFile := AFileName;
     nMaxFile  := ANameLength;
     FileExpand(lpstrFile,AFileName);
     FileSplit(lpstrFile,lpstrInitialDir,TempName,TempExt);
     StrCat(StrCopy(lpstrFile,TempName),TempExt);
   end;
end;


destructor TCDFileDlg.Done;
begin
  FreeMem(OFN.lpstrInitialDir,Succ(fsDirectory));
  TDialog.Done;
end;

function    TCDFileDlg.Create: Boolean;
begin
  Create := False;  { Cannot create a non-modal File Open dialog }
end;

{ Basically, This is the code from TDialog.Execute with the call to
  DialogBoxParam changed to CDExecute }
function    TCDFileDlg.Execute: Integer;
var
  CDError: Longint;
  OldKbHandler: PWindowsObject;
begin
  if Status = 0 then
  begin
    DisableAutoCreate;
    EnableKBHandler;
    IsModal := True;
    OldKbHandler := Application^.KBHandlerWnd;
    if CDExecute then
      Execute := id_ok
    else
    begin
      CDError := CommDlgExtendedError;
      if CDError = 0 then
        Execute := id_Cancel
      else
      begin
        Status := -CdError;
        Execute := Status;
      end;
    end;
    Application^.KBHandlerWnd := OldKbHandler;
    HWindow := 0;
  end
  else Execute := Status;
end;

function TCDFileDlg.CDExecute: Bool;
begin
  CDExecute := GetOpenFileName(OFN);
end;

{ COMMDLG requires that the hook function (ie: this method) does NOT
  call EndDlg() for it's modal dialogs.  Setting Msg.Result to 0 will
  allow COMMDLG to terminate the dialog.  A value of 1 will cause
  COMMDLG to ignore the OK button press. }
procedure   TCDFileDlg.OK(var Msg: TMessage);
begin
  if CanClose then
    Msg.Result := 0
  else
    Msg.Result := 1;
end;

procedure   TCDFileDlg.Cancel(var Msg: TMessage);
begin
  Msg.Result := 0
end;


{ TCDListBox resolves a BWCC <-> CommDlg display glitch by responding
  to WMEraseBkgnd messages to paint the invalidated rect using the
  window background system color.  Without this, partially filled
  CommDlg listboxes would be painted gray in the empty areas, leaving
  the listbox half-white and half-gray.  }

type
  PCDListBox = ^TCDListBox;
  TCDListBox = object(TListBox)
    Brush: HBrush;
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word);
    destructor Done; virtual;
    procedure WMEraseBkgnd(var Msg: TMessage);
      virtual wm_First + wm_EraseBkgnd;
  end;

constructor TCDListBox.InitResource(AParent: PWindowsObject;
                                    ResourceID: Word);
begin
  inherited InitResource(AParent, ResourceID);
  Brush := CreateSolidBrush(GetSysColor(COLOR_WINDOW));
end;

destructor TCDListBox.Done;
begin
  DeleteObject(Brush);
  TListbox.Done;
end;

procedure TCDListBox.WMEraseBkgnd(var Msg: TMessage);
var
  R: TRect;
begin                          
  GetClientRect(hWindow,R);
  FillRect(hDC(Msg.wParam),R,Brush);
  Msg.Result := 1;
end;


constructor TCDFileOpen.Init(AParent: PWindowsObject; AFlags: Longint;
  AFileName: PChar; ANameLength: Word; AFilter: PChar);
var
  Dummy: PWindowsObject;
begin
  inherited Init(AParent, AFlags, AFileName, ANameLength, AFilter);
  with OFN do
  begin
    lpstrTitle := 'File Open';
    if BWCCClassNames then
    begin
      Flags := Flags or OFN_EnableTemplate;
      lpTemplateName := dlgCDFileOpen_BWCC;
      Dummy := New(PCDListBox, InitResource(@Self, 1120));
      Dummy := New(PCDListBox, InitResource(@Self, 1121));
    end;
  end;
end;

constructor TCDFileSaveAs.Init(AParent: PWindowsObject; AFlags: Longint;
  AFileName: PChar; ANameLength: Word; AFilter: PChar);
begin
  inherited Init(AParent, AFlags, AFileName, ANameLength, AFilter);
  OFN.lpstrTitle := 'File Save As';
end;

function TCDFileSaveAs.CDExecute: Bool;
begin
  CDExecute := GetSaveFileName(OFN);
end;


end.
