unit ActiveGLProject_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : $Revision:   1.88.1.0.1.0  $
// File generated on 23/03/2002 11:02:59 from Type Library described below.

// ************************************************************************ //
// Type Lib: D:\Delphi\Delphi 5\OpenGL\ActiveX\ActiveGLProject.tlb (1)
// IID\LCID: {E676D026-707A-4910-82D2-F31D15837017}\0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT\System32\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, OleCtrls, StdVCL;

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  ActiveGLProjectMajorVersion = 1;
  ActiveGLProjectMinorVersion = 0;

  LIBID_ActiveGLProject: TGUID = '{E676D026-707A-4910-82D2-F31D15837017}';

  IID_IActiveGL: TGUID = '{495D0CCA-818C-4884-9989-191F0AF18658}';
  DIID_IActiveGLEvents: TGUID = '{EB1985CC-3524-430E-9899-DBE5C0651372}';
  CLASS_ActiveGL: TGUID = '{2AF973E9-21D2-4BCE-AB51-9DE67165A7C4}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum TxActiveFormBorderStyle
type
  TxActiveFormBorderStyle = TOleEnum;
const
  afbNone = $00000000;
  afbSingle = $00000001;
  afbSunken = $00000002;
  afbRaised = $00000003;

// Constants for enum TxPrintScale
type
  TxPrintScale = TOleEnum;
const
  poNone = $00000000;
  poProportional = $00000001;
  poPrintToFit = $00000002;

// Constants for enum TxMouseButton
type
  TxMouseButton = TOleEnum;
const
  mbLeft = $00000000;
  mbRight = $00000001;
  mbMiddle = $00000002;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IActiveGL = interface;
  IActiveGLDisp = dispinterface;
  IActiveGLEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  ActiveGL = IActiveGL;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PPUserType1 = ^IFontDisp; {*}


// *********************************************************************//
// Interface: IActiveGL
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {495D0CCA-818C-4884-9989-191F0AF18658}
// *********************************************************************//
  IActiveGL = interface(IDispatch)
    ['{495D0CCA-818C-4884-9989-191F0AF18658}']
    function  Get_Active: WordBool; safecall;
    function  Get_Cursor: Smallint; safecall;
    procedure Set_Cursor(Value: Smallint); safecall;
    property Active: WordBool read Get_Active;
    property Cursor: Smallint read Get_Cursor write Set_Cursor;
  end;

// *********************************************************************//
// DispIntf:  IActiveGLDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {495D0CCA-818C-4884-9989-191F0AF18658}
// *********************************************************************//
  IActiveGLDisp = dispinterface
    ['{495D0CCA-818C-4884-9989-191F0AF18658}']
    property Active: WordBool readonly dispid 9;
    property Cursor: Smallint dispid 14;
  end;

// *********************************************************************//
// DispIntf:  IActiveGLEvents
// Flags:     (0)
// GUID:      {EB1985CC-3524-430E-9899-DBE5C0651372}
// *********************************************************************//
  IActiveGLEvents = dispinterface
    ['{EB1985CC-3524-430E-9899-DBE5C0651372}']
    procedure OnActivate; dispid 1;
    procedure OnClick; dispid 2;
    procedure OnCreate; dispid 3;
    procedure OnDblClick; dispid 5;
    procedure OnKeyPress(var Key: Smallint); dispid 11;
    procedure OnPaint; dispid 16;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TActiveGL
// Help String      : ActiveGL Control
// Default Interface: IActiveGL
// Def. Intf. DISP? : No
// Event   Interface: IActiveGLEvents
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TActiveGLOnKeyPress = procedure(Sender: TObject; var Key: Smallint) of object;

  TActiveGL = class(TOleControl)
  private
    FOnActivate: TNotifyEvent;
    FOnClick: TNotifyEvent;
    FOnCreate: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FOnKeyPress: TActiveGLOnKeyPress;
    FOnPaint: TNotifyEvent;
    FIntf: IActiveGL;
    function  GetControlInterface: IActiveGL;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    property  ControlInterface: IActiveGL read GetControlInterface;
    property  DefaultInterface: IActiveGL read GetControlInterface;
    property Active: WordBool index 9 read GetWordBoolProp;
  published
    property Cursor: Smallint index 14 read GetSmallintProp write SetSmallintProp stored False;
    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnCreate: TNotifyEvent read FOnCreate write FOnCreate;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnKeyPress: TActiveGLOnKeyPress read FOnKeyPress write FOnKeyPress;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
  end;

procedure Register;

implementation

uses ComObj;

procedure TActiveGL.InitControlData;
const
  CEventDispIDs: array [0..5] of DWORD = (
    $00000001, $00000002, $00000003, $00000005, $0000000B, $00000010);
  CControlData: TControlData2 = (
    ClassID: '{2AF973E9-21D2-4BCE-AB51-9DE67165A7C4}';
    EventIID: '{EB1985CC-3524-430E-9899-DBE5C0651372}';
    EventCount: 6;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$80040154*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnActivate) - Cardinal(Self);
end;

procedure TActiveGL.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IActiveGL;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TActiveGL.GetControlInterface: IActiveGL;
begin
  CreateControl;
  Result := FIntf;
end;

procedure Register;
begin
  RegisterComponents('ActiveX',[TActiveGL]);
end;

end.
