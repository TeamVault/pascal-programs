library ActiveGLProject;

uses
  ComServ,
  ActiveGLProject_TLB in 'ActiveGLProject_TLB.pas',
  ActiveGLImpl1 in 'ActiveGLImpl1.pas' {ActiveGL: TActiveForm} {ActiveGL: CoClass};

{$E ocx}

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.
