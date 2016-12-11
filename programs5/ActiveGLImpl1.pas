unit ActiveGLImpl1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActiveX, AxCtrls, ActiveGLProject_TLB, StdVcl, ExtCtrls;

type
  TActiveGL = class(TActiveForm, IActiveGL)
    Panel1: TPanel;
    Timer1: TTimer;
    procedure ActiveFormCreate(Sender: TObject);
    procedure Panel1Resize(Sender: TObject);
    procedure ActiveFormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    rc : HGLRC;    // Rendering Context
    dc  : HDC;     // Device Context
    ElapsedTime, AppStart, LastTime : DWord;  // Timing variables
    
    FEvents: IActiveGLEvents;
    procedure ActivateEvent(Sender: TObject);
    procedure ClickEvent(Sender: TObject);
    procedure CreateEvent(Sender: TObject);
    procedure DblClickEvent(Sender: TObject);
    procedure KeyPressEvent(Sender: TObject; var Key: Char);
    procedure PaintEvent(Sender: TObject);

    procedure glDraw;
  protected
    { Protected declarations }
    procedure DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage); override;
    procedure EventSinkChanged(const EventSink: IUnknown); override;
    function Get_Active: WordBool; safecall;
    function Get_Cursor: Smallint; safecall;
    procedure Set_Cursor(Value: Smallint); safecall;
  public
    { Public declarations }
    procedure Initialize; override;
  end;

implementation

uses ComObj, ComServ, OpenGL;

{$R *.DFM}

{ TActiveGL }

procedure TActiveGL.DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage);
begin
  { Define property pages here.  Property pages are defined by calling
    DefinePropertyPage with the class id of the page.  For example,
      DefinePropertyPage(Class_ActiveGLPage); }
end;

procedure TActiveGL.EventSinkChanged(const EventSink: IUnknown);
begin
  FEvents := EventSink as IActiveGLEvents;
end;

procedure TActiveGL.Initialize;
begin
  inherited Initialize;
  OnActivate := ActivateEvent;
  OnClick := ClickEvent;
  OnCreate := CreateEvent;
  OnDblClick := DblClickEvent;
  OnKeyPress := KeyPressEvent;
  OnPaint := PaintEvent;
end;

function TActiveGL.Get_Active: WordBool;
begin
  Result := Active;
end;

function TActiveGL.Get_Cursor: Smallint;
begin
  Result := Smallint(Cursor);
end;


procedure TActiveGL.ActivateEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnActivate;
end;

procedure TActiveGL.ClickEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnClick;
end;

procedure TActiveGL.CreateEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnCreate;
end;

procedure TActiveGL.DblClickEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnDblClick;
end;

procedure TActiveGL.KeyPressEvent(Sender: TObject; var Key: Char);
var
  TempKey: Smallint;
begin
  TempKey := Smallint(Key);
  if FEvents <> nil then FEvents.OnKeyPress(TempKey);
  Key := Char(TempKey);
end;

procedure TActiveGL.PaintEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnPaint;
end;


procedure TActiveGL.Set_Cursor(Value: Smallint);
begin
  Cursor := TCursor(Value);
end;


{------------------------------------------------------------------}
{  Function to draw the actual scene                               }
{------------------------------------------------------------------}
procedure TActiveGL.glDraw;
const P180 = PI/180;
Var S: single;
    I: integer;
    R,G,B: single;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);    // Clear The Screen And The Depth Buffer
  glLoadIdentity();                                       // Reset The View

  glTranslatef(0, 0, -5);

  glRotatef(ElapsedTime/40, 1, 1, 1);

  glDisable(GL_TEXTURE_2D);
  glBegin(GL_TRIANGLE_STRIP);
    For I := 0 to 72 do
    begin
      S := 0.5+Sin(ElapsedTime/465)*0.2+Cos(ElapsedTime/657)*0.1;
      R := 0.5+Sin(Elapsedtime/100+I/1.6)*0.5;
      G := 0.5+Sin(Elapsedtime/200+720+I/1.6)*0.5;
      B := 0.5+Sin(Elapsedtime/100+720+I/1.6)*0.5;
      glColor3f(R,G,B);
      glVertex3f(Sin(P180*I*5)*S, Cos(P180*I*5)*S, Sin(P180*(I*10+Elapsedtime/500))*(0.5+sin(ElapsedTime/300)*0.3));
      glColor3f(B,G,R);
      glVertex3f(Sin(P180*I*5)*S*2, Cos(P180*I*5)*S*2, 1+Sin(P180*(I*(20)+ElapsedTime/500))*(0.5+sin(ElapsedTime/800)*0.4+cos(Elapsedtime/450)*0.4));
    end;
  glEnd;
end;


{------------------------------------------------------------------}
{  Initialise OpenGL                                               }
{------------------------------------------------------------------}
procedure glInit();
begin
  glClearColor(0.0, 0.0, 0.0, 0.0); 	   // Black Background
  glShadeModel(GL_SMOOTH);                 // Enables Smooth Color Shading
  glClearDepth(1.0);                       // Depth Buffer Setup
  glEnable(GL_DEPTH_TEST);                 // Enable Depth Buffer
  glDepthFunc(GL_LESS);		           // The Type Of Depth Test To Do

  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);   //Realy Nice perspective calculations
end;


{------------------------------------------------------------------}
{  Create the form and initialist openGL                           }
{------------------------------------------------------------------}
procedure TActiveGL.ActiveFormCreate(Sender: TObject);
var pfd : TPIXELFORMATDESCRIPTOR;
    pf  : Integer;
begin
  // OpenGL initialisieren
  dc:=GetDC(Panel1.Handle);

  // PixelFormat
  pfd.nSize:=sizeof(pfd);
  pfd.nVersion:=1;
  pfd.dwFlags:=PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER or 0;
  pfd.iPixelType:=PFD_TYPE_RGBA;      // PFD_TYPE_RGBA or PFD_TYPEINDEX
  pfd.cColorBits:=32;

  pf :=ChoosePixelFormat(dc, @pfd);   // Returns format that most closely matches above pixel format
  SetPixelFormat(dc, pf, @pfd);

  rc :=wglCreateContext(dc);    // Rendering Context = window-glCreateContext
  wglMakeCurrent(dc,rc);        // Make the DC (Form1) the rendering Context

  // Initialist GL environment variables
  glInit;
  Panel1Resize(sender);    // sets up the perspective
  AppStart :=GetTickCount();
  Timer1.Enabled :=TRUE;
end;


{------------------------------------------------------------------}
{  If the panel resizes, reset the GL scene                        }
{------------------------------------------------------------------}
procedure TActiveGL.Panel1Resize(Sender: TObject);
begin
  glViewport(0, 0, Panel1.Width, Panel1.Height);    // Set the viewport for the OpenGL window
  glMatrixMode(GL_PROJECTION);        // Change Matrix Mode to Projection
  glLoadIdentity();                   // Reset View
  gluPerspective(45.0, Panel1.Width/Panel1.Height, 1.0, 500.0);  // Do the perspective calculations. Last value = max clipping depth

  glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
end;


{------------------------------------------------------------------}
{  Release rendering context when form gets detroyed               }
{------------------------------------------------------------------}
procedure TActiveGL.ActiveFormDestroy(Sender: TObject);
begin
  wglMakeCurrent(0,0);
  wglDeleteContext(rc);
end;


{------------------------------------------------------------------}
{  Application onIdle event                                        }
{------------------------------------------------------------------}
procedure TActiveGL.Timer1Timer(Sender: TObject);
begin
  LastTime :=ElapsedTime;
  ElapsedTime :=GetTickCount() - AppStart;      // Calculate Elapsed Time
  ElapsedTime :=(LastTime + ElapsedTime) DIV 2; // Average it out for smoother movement

  glDraw();                         // Draw the scene
  SwapBuffers(DC);                  // Display the scene
end;


initialization
  TActiveFormFactory.Create(
    ComServer,
    TActiveFormControl,
    TActiveGL,
    Class_ActiveGL,
    1,
    '',
    OLEMISC_SIMPLEFRAME or OLEMISC_ACTSLIKELABEL,
    tmApartment);
end.
