unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Express, OpenGL;

type TMyColor = Record
       R, G, B : glUByte;
     end;
type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    GroupBox2: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    functionEdit: TEdit;
    Label2: TLabel;
    ComboBox1: TComboBox;
    Label6: TLabel;
    ColorDialog1: TColorDialog;
    Panel3: TPanel;
    GroupBox3: TGroupBox;
    CheckBox1: TCheckBox;
    Shape1: TShape;
    Button3: TButton;
    Button2: TButton;
    Shape2: TShape;
    Button4: TButton;
    Button5: TButton;
    CheckBox2: TCheckBox;
    Button1: TButton;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label1: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    minX: TEdit;
    maxX: TEdit;
    minY: TEdit;
    maxY: TEdit;
    incX: TEdit;
    incY: TEdit;
    CheckBox3: TCheckBox;
    ShowAxis: TCheckBox;
    GroupBox4: TGroupBox;
    ComboBox2: TComboBox;
    Button6: TButton;
    Button7: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button5Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure ShowAxisClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
    rc : HGLRC;    // Rendering Context
    dc  : HDC;     // Device Context

    GraphColor : TMyColor;
    YRot, XRot : glFloat;
    Depth      : glFloat;
    Xcoord, Ycoord, Zcoord : Integer;
    MouseButton : Integer;

    xMin, xMax, yMin, yMax, zMin, zMax, xInc, yInc : glFloat;
    fx2D : Array of glFloat;
    fx3D : Array of Array of glFloat;
    procedure InitGL;
    procedure glDraw;
    procedure getGraphData(newFunction : String);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses about;

{$R *.DFM}

procedure TForm1.Button2Click(Sender: TObject);
begin
  Close;
end;


{------------------------------------------------------------------}
{  Function to draw the actual scene                               }
{------------------------------------------------------------------}
procedure TForm1.glDraw();
var X, Y : Integer;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);    // Clear The Screen And The Depth Buffer
  glLoadIdentity();                                       // Reset The View

  glTranslatef(0.0, 0.0, Depth);

  glRotatef(xRot, 1, 0, 0);
  glRotatef(-yRot, 0, 0, 1);

  // Draw the X, Y, Z axis
  if ShowAxis.Checked then
  begin
    glColor3ub(GraphColor.B, GraphColor.G, GraphColor.R);
    glBegin(GL_LINES);
      glVertex(2*xMin, (zMax+zMin)/2, (yMax+yMin)/2);
      glVertex(2*xMax, (zMax+zMin)/2, (yMax+yMin)/2);
      glVertex((xMax+xMin)/2, 2*zMin, (yMax+yMin)/2);
      glVertex((xMax+xMin)/2, 2*zMax, (yMax+yMin)/2);
      glVertex((xMax+xMin)/2, (zMax+zMin)/2, 2*yMin);
      glVertex((xMax+xMin)/2, (zMax+zMin)/2, 2*yMax);
    glEnd();
  end;

  glColor3ubv(@GraphColor);

  if radiobutton1.checked then
  begin
    glBegin(GL_QUADS);
      for X :=0 to High(fx2D)-1 do
      begin
        if not(Checkbox3.checked) then
          glColor3f(GraphColor.R*(zMax+fx2D[X])/zMax/256, GraphColor.G*(zMax+fx2D[X])/zMax/256, GraphColor.B*(zMax+fx2D[X])/zMax/256);
        glVertex3f(xMin+X*xInc, fx2D[X], 0.5);

        if Checkbox1.Checked then
          glColor3f(GraphColor.R*(zMax+fx2D[X+1])/zMax/256, GraphColor.G*(zMax+fx2D[X+1])/zMax/256, GraphColor.B*(zMax+fx2D[X+1])/zMax/256);
        glVertex3f(xMin+(X+1)*xInc, fx2D[X+1], 0.5);
        glVertex3f(xMin+(X+1)*xInc, fx2D[X+1], -0.5);

        if Checkbox1.Checked then
          glColor3f(GraphColor.R*(zMax+fx2D[X])/zMax/256, GraphColor.G*(zMax+fx2D[X])/zMax/256, GraphColor.B*(zMax+fx2D[X])/zMax/256);
        glVertex3f(xMin+X*xInc, fx2D[X], -0.5);
      end;
    glEnd();
  end
  else
  begin
    glBegin(GL_QUADS);
      for X :=0 to High(fx3D)-1 do
      begin
        for Y :=0 to High(fx3D[X])-1 do
        begin
          if not(Checkbox3.checked) then
            glColor3f(GraphColor.R*(zMax+fx3D[X, Y])/zMax/256, GraphColor.G*(zMax+fx3D[X, Y])/zMax/256, GraphColor.B*(zMax+fx3D[X, Y])/zMax/256);
          glVertex3f(xMin+X*xInc, fx3D[X, Y], yMin+Y*yInc);

          if Checkbox1.Checked then
            glColor3f(GraphColor.R*(zMax+fx3D[X+1, Y])/zMax/256, GraphColor.G*(zMax+fx3D[X+1, Y])/zMax/256, GraphColor.B*(zMax+fx3D[X+1, Y])/zMax/256);
          glVertex3f(xMin+(X+1)*xInc, fx3D[X+1, Y], yMin+Y*yInc);

          if Checkbox1.Checked then
            glColor3f(GraphColor.R*(zMax+fx3D[X+1, Y+1])/zMax/256, GraphColor.G*(zMax+fx3D[X+1, Y+1])/zMax/256, GraphColor.B*(zMax+fx3D[X+1, Y+1])/zMax/256);
          glVertex3f(xMin+(X+1)*xInc, fx3D[X+1, Y+1], yMin+(Y+1)*yInc);

          if Checkbox1.Checked then
            glColor3f(GraphColor.R*(zMax+fx3D[X, Y+1])/zMax/256, GraphColor.G*(zMax+fx3D[X, Y+1])/zMax/256, GraphColor.B*(zMax+fx3D[X, Y+1])/zMax/256);
          glVertex3f(xMin+X*xInc, fx3D[X, Y+1], yMin+(Y+1)*yInc);
        end;
      end;
    glEnd();
  end;

  SwapBuffers(DC);                  // Display the scene
end;


{------------------------------------------------------------------}
{  Initialise the OpengGL variables                                }
{------------------------------------------------------------------}
procedure TForm1.InitGL;
begin
  glClearColor(1.0, 1.0, 1.0, 1.0); 	   // White Background
  glShadeModel(GL_SMOOTH);                 // Enables Smooth Color Shading
  glClearDepth(1.0);                       // Depth Buffer Setup
  glEnable(GL_DEPTH_TEST);                 // Enable Depth Buffer
  glDepthFunc(GL_LESS);		           // The Type Of Depth Test To Do

  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);   //Realy Nice perspective calculations
end;


{------------------------------------------------------------------}
{  Form Create. Init openGL and local variables                    }
{------------------------------------------------------------------}
procedure TForm1.FormCreate(Sender: TObject);
var pfd : TPIXELFORMATDESCRIPTOR;
    pf  : Integer;
begin
  // OpenGL initialisieren
  DecimalSeparator:='.';
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

  ComboBox2.ItemIndex :=0;
  Depth :=-3;
  GraphColor.R :=0;
  GraphColor.G :=$60;
  GraphColor.B :=$BF;
  setlength(fx2D, 0);
  setlength(fx3D, 0);
  InitGL;
end;


{---------------------------------------------}
{--- Resize scene when window resizes      ---}
{---------------------------------------------}
procedure TForm1.FormResize(Sender: TObject);
begin
  glViewport(0, 0, Panel1.Width, Panel1.Height);    // Set the viewport for the OpenGL window
  glMatrixMode(GL_PROJECTION);        // Change Matrix Mode to Projection
  glLoadIdentity();                   // Reset View
  gluPerspective(45.0, Panel1.Width/Panel1.Height, 0.1, 500.0);  // Do the perspective calculations. Last value = max clipping depth

  glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
  glDraw();                           // Draw the scene
end;


{---------------------------------------------}
{--- Release OpenGL when window closes     ---}
{---------------------------------------------}
procedure TForm1.FormDestroy(Sender: TObject);
begin
  wglMakeCurrent(0,0);
  wglDeleteContext(rc);
end;


{-----------------------------------------------------------------------}
{---  following functions control the scene rotation                 ---}
{-----------------------------------------------------------------------}
procedure TForm1.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if MouseButton = 1 then
  begin
    xRot := xRot + (Y - Ycoord)/2;  // moving up and down = rot around X-axis
    yRot := yRot + (X - Xcoord)/2;
    Xcoord := X;
    Ycoord := Y;
    glDraw;
  end;
  if MouseButton = 2 then
  begin
    Depth :=Depth - (Y-ZCoord)/3;
    Zcoord := Y;
    glDraw;
  end;
end;

procedure TForm1.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft  then
  begin
    MouseButton :=1;
    Xcoord := X;
    Ycoord := Y;
  end;
  if Button = mbRight then
  begin
    MouseButton :=2;
    Zcoord := Y;
  end;
end;                                                     

procedure TForm1.Panel1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseButton :=0;
end;


{---------------------------------------------}
{--- Changes the graph color               ---}
{---------------------------------------------}
procedure TForm1.Button3Click(Sender: TObject);
begin
  ColorDialog1.Color :=Shape1.Brush.Color;
  if ColorDialog1.Execute then
  begin
    Shape1.Brush.Color :=ColorDialog1.Color;
    GraphColor.R :=Shape1.Brush.Color AND $000000FF;
    GraphColor.G :=(Shape1.Brush.Color AND $0000FF00) DIV 256;
    GraphColor.B :=(Shape1.Brush.Color AND $00FF0000) DIV 65536;
    glDraw();
  end;
end;


{---------------------------------------------}
{--- Changes the background color          ---}
{---------------------------------------------}
procedure TForm1.Button4Click(Sender: TObject);
begin
  ColorDialog1.Color :=Shape2.Brush.Color;
  if ColorDialog1.Execute then
  begin
    Shape2.Brush.Color :=ColorDialog1.Color;
    glClearColor((Shape2.Brush.Color AND $000000FF) / 255,
                 ((Shape2.Brush.Color AND $0000FF00) DIV 256) / 255,
                 ((Shape2.Brush.Color AND $00FF0000) DIV 65536) / 255, 1);
    glDraw();
  end;
end;


{---------------------------------------------}
{--- Changes to 2D graphs                  ---}
{---------------------------------------------}
procedure TForm1.RadioButton1Click(Sender: TObject);
begin
  if RadioButton1.Checked then
  begin
    Label2.Caption :='y =';
//    functionEdit.Text :='sin(pi*x)';
    minY.Visible :=FALSE;
    maxY.Visible :=FALSE;
    incY.Visible :=FALSE;
    Label1.Visible :=FALSE;
    Label5.Visible :=FALSE;
    Label8.Visible :=FALSE;
  end;
end;


{---------------------------------------------}
{--- Changes to 3D graphs                  ---}
{---------------------------------------------}
procedure TForm1.RadioButton2Click(Sender: TObject);
begin
  if RadioButton2.Checked then
  begin
    Label2.Caption :='z =';
//    functionEdit.Text :='cos(2*pi*x)/4 + cos(2*pi*y)/4';
    minY.Visible :=TRUE;
    maxY.Visible :=TRUE;
    incY.Visible :=TRUE;
    Label1.Visible :=TRUE;
    Label5.Visible :=TRUE;
    Label8.Visible :=TRUE;
  end;
end;


{---------------------------------------------}
{--- Refresh the scene if necesary         ---}
{---------------------------------------------}
procedure TForm1.Button5Click(Sender: TObject);
begin
  glDraw();    // Draw the scene
end;


{-------------------------------------------------}
{--- Builds an array of vertices from function ---}
{-------------------------------------------------}
procedure TForm1.getGraphData(newFunction : String);
var xStep, yStep : Integer;
    X, Y : Integer;
    Result : glFloat;
    Expression : TExpress;
begin
  xMin :=StrToFloat(minX.Text);
  xMax :=StrToFloat(maxX.Text);
  xInc :=StrToFloat(IncX.Text);
  yMin :=StrToFloat(minY.Text);
  yMax :=StrToFloat(maxY.Text);
  yInc :=StrToFloat(IncY.Text);
  zMin := 999999999;
  zMax :=-999999999;

  if (yMax - yMin) > (xMax - xMin) then
    Depth :=-2*(yMax - yMin)-1
  else
    Depth :=-2*(xMax - xMin)-1;

  Expression := TExpress.create(self);
  //----------------------------------------
  Expression.Expression := newFunction;
  //----------------------------------------
  try
    if RadioButton1.Checked then
    begin
      xStep :=Abs(Round((xMax - xMin)/xInc));
      SetLength(fx2D, xStep+1);
      try
        for X :=0 to xStep do
        begin
          //Expression.Expression := newFunction;
          Result :=Expression.theFunction(xMin+X*xInc, 0, 0);

          fx2D[X] :=Result;
          if Result < zMin then zMin :=Result;
          if Result > zMax then zMax :=Result;
        end;
      except
        on E:Exception do
        messageDlg(E.Message,mtError,[mbOk],0);
      end;
    end
    else
    begin
      xStep :=Abs(Round((xMax - xMin)/xInc));
      yStep :=Abs(Round((yMax - yMin)/yInc));
      SetLength(fx3D, xStep+1, yStep+1);
      try
        for X :=0 to xStep do
        begin
          for Y :=0 to yStep do
          begin
            //Expression.Expression := newFunction;
            Result :=Expression.theFunction(xMin+X*xInc, yMin+Y*yInc, 0);
            fx3D[X, Y] :=Result;
            if Result < zMin then zMin :=Result;
            if Result > zMax then zMax :=Result;
          end
        end;
      except
        on E:Exception do
        messageDlg(E.Message,mtError,[mbOk],0);
      end;
    end
  finally
    Expression.Free;
  end;
end;


{-----------------------------------------------------}
{--- Check for valid function and create vertices  ---}
{-----------------------------------------------------}
procedure TForm1.Button1Click(Sender: TObject);
var newFunction : String;
    Expression  : TExpress;
begin
  newFunction :=functionEdit.Text;
  newFunction :=lowercase(newFunction);

  try
    screen.cursor :=crHourglass;
    Expression := TExpress.create(self);
    Expression.Expression :=newFunction;
    if not(Expression.Error) then
    begin
      getGraphData(newFunction);
      glDraw();    // Draw the scene
    end
    else
      MessageDlg('Invalid function', mtError, [mbOK], 0)
  finally
    screen.cursor :=crDefault;
    Expression.Free;
  end;
end;


{-----------------------------------------------------}
{--- Toggle between solid and wireframe mode       ---}
{-----------------------------------------------------}
procedure TForm1.CheckBox2Click(Sender: TObject);
begin
  if CheckBox2.Checked then
    glPolygonmode(GL_FRONT_AND_BACK, GL_LINE)
  else
    glPolygonmode(GL_FRONT_AND_BACK, GL_FILL);
  glDraw();
end;


{-----------------------------------------------------}
{--- Toggle between gradient and flat shaded graph ---}
{-----------------------------------------------------}
procedure TForm1.CheckBox3Click(Sender: TObject);
begin
  if Checkbox3.Checked then
    CheckBox1.Checked :=FALSE;
  glDraw;
end;


{-----------------------------------------------------}
{--- Toggle between smooth and non-smooth gradient ---}
{-----------------------------------------------------}
procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.Checked then
    CheckBox3.Checked :=FALSE;
  glDraw;
end;


{-----------------------------------------------------}
{--- Toggle axis display on and off                ---}
{-----------------------------------------------------}
procedure TForm1.ShowAxisClick(Sender: TObject);
begin
  glDraw;
end;


{-----------------------------------------------------}
{--- Display the about window                      ---}
{-----------------------------------------------------}
procedure TForm1.Button7Click(Sender: TObject);
begin
  try
    form2 :=TForm2.Create(self);
    form2.ShowModal;
  finally
    form2.free;
  end;
end;


{-----------------------------------------------------}
{--- Draw some of the popular graphs               ---}
{-----------------------------------------------------}
procedure TForm1.Button6Click(Sender: TObject);
begin
      { Converted all numbers with FormatFloat for international support
        01-17-2002 - goran@goran-s.com }
  case combobox2.itemindex of
    0 : begin
          functionEdit.Text :='x^2 + y^2 - 1';
          minX.Text :=FormatFloat('0.00######', -1.000);
          maxX.Text :=FormatFloat('0.00######', 1.000);
          incX.Text :=FormatFloat('0.00######', 0.1);
          minY.Text :=FormatFloat('0.00######', -1.000);
          maxY.Text :=FormatFloat('0.00######', 1.000);
          incY.Text :=FormatFloat('0.00######', 0.1);
        end;
    1 : begin
          functionEdit.Text :='x^2 - y^2';
          minX.Text :=FormatFloat('0.00######', -1.000);
          maxX.Text :=FormatFloat('0.00######', 1.000);
          incX.Text :=FormatFloat('0.00######', 0.1);
          minY.Text :=FormatFloat('0.00######', -1.000);
          maxY.Text :=FormatFloat('0.00######', 1.000);
          incY.Text :=FormatFloat('0.00######', 0.1);
        end;
    2 : begin
          functionEdit.Text :='cos(pi*x)/2 + cos(pi*y)/2';
          minX.Text :=FormatFloat('0.00######', -3.000);
          maxX.Text :=FormatFloat('0.00######', 3.000);
          incX.Text :=FormatFloat('0.00######', 0.1);
          minY.Text :=FormatFloat('0.00######', -3.000);
          maxY.Text :=FormatFloat('0.00######', 3.000);
          incY.Text :=FormatFloat('0.00######', 0.1);
          Checkbox1.Checked :=FALSE;
        end;
    3 : begin
          functionEdit.Text :='cos(x + pi*sin(y))';
          minX.Text :=FormatFloat('0.00######', -6.000);
          maxX.Text :=FormatFloat('0.00######', 6.000);
          incX.Text :=FormatFloat('0.00######', 0.2);
          minY.Text :=FormatFloat('0.00######', -6.000);
          maxY.Text :=FormatFloat('0.00######', 6.000);
          incY.Text :=FormatFloat('0.00######', 0.2);
        end;
    4 : begin
          functionEdit.Text :='10*Sin(sqrt((x*x)+(y*y)))/(sqrt((x*x)+(y*y)))';
          minX.Text :=FormatFloat('0.00######', -20.000);
          maxX.Text :=FormatFloat('0.00######', 20.000);
          incX.Text :=FormatFloat('0.00######', 0.6);
          minY.Text :=FormatFloat('0.00######', -20.000);
          maxY.Text :=FormatFloat('0.00######', 20.000);           
          incY.Text :=FormatFloat('0.00######', 0.6);
        end;
  end;
  Button1Click(self);
end;

end.
