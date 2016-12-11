//------------------------------------------------------------------------
//
// Author      : Maarten Kronberger
// Email       : Maartenk@tinderbox.co.za
// Website     : http://www.sulaco.co.za
//               http://www.tinderbox.co.za
// Date        : 6 October 2002
// Version     : 1.0
// Description : Bezier Curve Generator/Creator
//
// Special thanks to Digiben and the guys at www.gametutorials.com for the
// bezier curve source. :D
//------------------------------------------------------------------------

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, OpenGL,
  ExtCtrls, StdCtrls, ComCtrls, Menus,Math;

type
  TCoord = Record
    X, Y, Z : glFLoat;
  end;
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    txtPoint1X: TEdit;
    txtPoint1Y: TEdit;
    txtPoint1Z: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    txtPoint2Z: TEdit;
    txtPoint2Y: TEdit;
    txtPoint2X: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    txtPoint3Z: TEdit;
    txtPoint3Y: TEdit;
    txtPoint3X: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    txtPoint4Z: TEdit;
    txtPoint4Y: TEdit;
    txtPoint4X: TEdit;
    Button2: TButton;
    UpDown1: TUpDown;
    UpDown2: TUpDown;
    UpDown3: TUpDown;
    UpDown4: TUpDown;
    UpDown5: TUpDown;
    UpDown6: TUpDown;
    UpDown7: TUpDown;
    UpDown8: TUpDown;
    UpDown9: TUpDown;
    UpDown10: TUpDown;
    UpDown11: TUpDown;
    UpDown12: TUpDown;
    Button3: TButton;
    Button4: TButton;
    chkAllBeziers: TCheckBox;
    TTabControl1: TTabControl;
    Button5: TButton;
    Button6: TButton;
    chkRotate: TCheckBox;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Save1: TMenuItem;
    View1: TMenuItem;
    ShowStart1: TMenuItem;
    Rotate1: TMenuItem;
    ShowAllCurves1: TMenuItem;
    SaveControlPoints1: TMenuItem;
    Timer1: TTimer;
    Timer2: TTimer;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    OpenControlPointFile1: TMenuItem;
    New1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure Panel1Resize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown2Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown3Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown4Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown5Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown6Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown7Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown8Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown9Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown10Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown11Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown12Click(Sender: TObject; Button: TUDBtnType);
    procedure Button3Click(Sender: TObject);
    procedure GroupBox4Click(Sender: TObject);
    procedure GroupBox3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ShowStart1Click(Sender: TObject);
    procedure Rotate1Click(Sender: TObject);
    procedure ShowAllCurves1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer2Timer(Sender: TObject);
    procedure Button5MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button6MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button6MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button5MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SaveControlPoints1Click(Sender: TObject);
    procedure OpenControlPointFile1Click(Sender: TObject);
    procedure txtPoint1XEnter(Sender: TObject);
    procedure txtPoint1XExit(Sender: TObject);
    procedure txtPoint1YEnter(Sender: TObject);
    procedure txtPoint1YExit(Sender: TObject);
    procedure txtPoint1ZEnter(Sender: TObject);
    procedure txtPoint1ZExit(Sender: TObject);
    procedure txtPoint2XEnter(Sender: TObject);
    procedure txtPoint2XExit(Sender: TObject);
    procedure txtPoint2YEnter(Sender: TObject);
    procedure txtPoint2YExit(Sender: TObject);
    procedure txtPoint2ZEnter(Sender: TObject);
    procedure txtPoint2ZExit(Sender: TObject);
    procedure txtPoint3XEnter(Sender: TObject);
    procedure txtPoint3XExit(Sender: TObject);
    procedure txtPoint3YEnter(Sender: TObject);
    procedure txtPoint3YExit(Sender: TObject);
    procedure txtPoint3ZEnter(Sender: TObject);
    procedure txtPoint3ZExit(Sender: TObject);
    procedure txtPoint4XEnter(Sender: TObject);
    procedure txtPoint4XExit(Sender: TObject);
    procedure txtPoint4YEnter(Sender: TObject);
    procedure txtPoint4YExit(Sender: TObject);
    procedure txtPoint4ZEnter(Sender: TObject);
    procedure txtPoint4ZExit(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
    rc : HGLRC;    // Rendering Context
    dc  : HDC;     // Device Context
    ElapsedTime, AppStart, LastTime : DWord;  // Timing variables

    g_CurrentTime : GLfloat;  // This is the current position of the sphere along the curve (0 to 1)



    procedure glDraw;
    procedure Idle(Sender: TObject; var Done: Boolean);
    procedure glInit;
    procedure SetArrayLength;
    procedure UpdateTextValues;
    procedure SetTempValue(txtBox : TEdit);
    procedure SetCoordValue(txtBox : TEdit);
    procedure DoUpDown(txtBox : TEdit;Button: TUDBtnType);
    procedure UpdatePointValues();
  public
    { Public declarations }
  end;
const
  MAX_STEPS = 38.0;
  BALL_SPEED = 0.02;
var
  Form1: TForm1;
  g_CurrentTime : GLfloat;


  rotateY : GLfloat;

  g_arrvStartPoint : array of TCoord; // Starting point of the curve
  g_arrvControlPoint1 : array of TCoord; // First control point of the curve
  g_arrvControlPoint2 : array of TCoord; // Second control point of the curve
  g_arrvEndPoint : array of TCoord; // End point of the curve

  g_arrIndex : integer;

  zView : GLfloat;

  g_ControlPoint1Color : glFloat;
  g_ControlPoint2Color : glFloat;

  zViewModifier : glFloat;

  g_tempVar : glFloat;

implementation

{$R *.DFM}

Uses Unit2;


{------------------------------------------------------------------------}
{  This function renders a sphere to a given XYZ and with a given radius }
{------------------------------------------------------------------------}

procedure DrawSphere(x, y, z, radius : GLfloat);
var pSphere : GLUquadricObj;
begin
	// To use Quadrics, we need to create a new one first.  This is done below.
	// The GLUquadricObj type is defined with the GLU32 library and associated header file.

	pSphere := gluNewQuadric();			// Get a Quadric off the stack

	// Let's put on a matrix so what ever we do it doesn't effect the rest of
	// the objects we will display.

	glPushMatrix();										// Push on a new matrix

		glTranslatef(x, y, z);							// Move the sphere to the desired (x, y, z)

		// Draw the a sphere with a given radius and a width and height detail 
		// of 15 (15 by 15 is a good level of detail.  The lower the detail the 
		// more jagged the sphere becomes, where the high the detail the more round it is.
		gluSphere(pSphere, radius, 15, 15);				// Draw the sphere with a radius of 0.2

	glPopMatrix();										// Pop the current matrix

	// Since we are done rendering the Quadric, we can free the object.
	// gluDeleteQuadric() takes the object to be released. If you have a lot 
	// of Quadrics, you might not want to allocate and free them every frame.

	gluDeleteQuadric(pSphere);							// Free the quadric object
end;


{-----------------------------------------------------------------------------}
{	This function returns an XYZ point along the curve, depending on t (0 to 1) }
{-----------------------------------------------------------------------------}
function PointOnCurve(p1, p2, p3, p4: TCoord; t : GLfloat) : TCoord;
var var1, var2, var3 : glFloat;
    vPoint : TCoord;
begin
  vPoint.X := 0.0; vPoint.Y := 0.0; vPoint.Z := 0.0;

  {-----------------------------------------------------------------------------}
	{ Here is the juice of our tutorial.                                          }
  { Below is the equation for a 4 control point bezier curve:                   }
	{ B(t) = P1 * ( 1 - t )^3                                                     }
  {      + P2 * 3 * t * ( 1 - t )^2                                             }
  {      + P3 * 3 * t^2 * ( 1 - t )                                             }
  {      + P4 * t^3                                                             }
	{ Yes I agree, this isn't the most intuitive equation,                        }
  { but it is pretty straight forward.                                          }
	{ If you got up to Trig, you will notice that this is a polynomial.           }
  { That is what a curve is.                                                    }
	{ "t" is the time from 0 to 1.                                                }
  { You could also think of it as the distance along the curve,                 }
  { because that is really what it is.                                          }
  { P1 - P4 are the 4 control points.                                           }
	{ They each have an (x, y, z) associated with them.                           }
  { You notice that there is a lot of (1 - t) 's?                               }
  { Well, to clean up our code we will try to contain some of these             }
	{ repetitions into variables.                                                 }
  { This helps our repeated computations as well.                               }
  {-----------------------------------------------------------------------------}

	// Store the (1 - t) in a variable because it is used frequently
    var1 := 1 - t;

	// Store the (1 - t)^3 into a variable to cut down computation and create clean code
    var2 := var1 * var1 * var1;

	// Store the t^3 in a variable to cut down computation and create clean code
    var3 := t * t * t;

  {-----------------------------------------------------------------------------}
	{ Now that we have some computation cut down,                                 }
  { we just follow the equation above.                                          }
	{ If you multiply and simplify the equation,                                  }
  { you come up with what we have below.                                        }
	{ If you don't see how we came to here from the equation,                     }
  { multiply the equation out and it will become more clear.                    }
  { I don't intend to go into any more detail on the math of a bezier curve,    }
  { because there are far better places out there with graphical displays       }
  { and tons of examples.                                                       }
  { Look in our * Quick Notes * for an EXCELLENT web site that does just this.  }
  { It derives everything and has excellent visuals.                            }
  { It's the best I have seen so far.                                           }
  {-----------------------------------------------------------------------------}
  
    vPoint.x := var2*p1.x + 3*t*var1*var1*p2.x + 3*t*t*var1*p3.x + var3*p4.x;
    vPoint.y := var2*p1.y + 3*t*var1*var1*p2.y + 3*t*t*var1*p3.y + var3*p4.y;
    vPoint.z := var2*p1.z + 3*t*var1*var1*p2.z + 3*t*t*var1*p3.z + var3*p4.z;

	// Now we should have the point on the curve, so let's return it.
    result := vPoint;				
end;


{------------------------------------------------------------------}
{  Function to draw the actual scene                               }
{------------------------------------------------------------------}
procedure TForm1.glDraw();
var t : glFloat;
    vPoint : TCoord;
    I : integer;
begin


	glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);	// Clear The Screen And The Depth Buffer
	glLoadIdentity();									// Reset The matrix

  {-----------------------------------------------------------------------------}
	{ Below, we will draw a bezier curve with 4 control points                    }
	{ (including the start/end point).  We will use GL_LINES to draw the          }
	{ line segments of the curve.  Then, using Quadrics, we will draw a sphere    }
	{ on the curve.  You can use the LEFT and RIGHT arrow keys to move the        }
	{ sphere along the curve.  If you are not familiar with quadrics, you can     }
	{ view our quadric tutorial at www.GameTutorials.com.  I also include some    }
  { comments from the tutorial in here in case you just want the basics.        }
	{ Quadrics are used to create cylinders and spheres quickly and easily.       }
  {-----------------------------------------------------------------------------}

	// We set up our camera back a little bit to get the whole curve in view.

				// Position      View		Up Vector
	gluLookAt(0, 0.5, zView,   0, 0.5, 0,   0, 1, 0);	// Set up our camera position and view

	// Below we disable the lighting so you can clearly see the bezier curve.

	glDisable(GL_LIGHTING);								// Disable lighting for now



	vPoint.X := 0.0; vPoint.Y := 0.0; vPoint.Z := 0.0;				// Initialize a CVector3 to hold points.

	// Just so we can see the curve better, I rotate the curve and sphere

  if chkRotate.Checked then
  begin
  	glRotatef(rotateY, 0.0, 1.0, 0.0);				// Rotate the curve around the Y-Axis
   	//rotateY := rotateY + 0.1;									// Increase the current rotation
  end;

	// Here we tell OpenGL to render lines with a greater thickness (default is 1.0)

	glLineWidth(1.5);									// Increase the size of a line for visibility

  {-----------------------------------------------------------------------------}
	{ We haven't used GL_LINE_STRIP before so let me explain.                     }
  { Instead of passing in the first point of the line,                          }
  { then the next point of the line, then passing in that same point again      }
  { for the first point of the next line, etc... we can do a line strip.        }
  { That means we just pass in ONE point and it connects them for us.           }
  { If we just did GL_LINES it would render the curve is broken segments.       }
	{ Strips are very usefull, as well as fast.                                   }
  { You can do quad and triangle strips too.                                    }
  {-----------------------------------------------------------------------------}

  if chkAllBeziers.Checked then
  begin
    glColor3ub(0, 0, 255);								// Set the color to Blue

    for I := 0 to high(g_arrvStartPoint) do
    begin
      glBegin(GL_LINE_STRIP);								// Start drawing lines

      if I <> g_arrIndex then
      begin
        t := 0;

        while t <= (1 + (1.0 / MAX_STEPS)) do
    		begin
      		vPoint := PointOnCurve(g_arrvStartPoint[I], g_arrvControlPoint1[I], g_arrvControlPoint2[I], g_arrvEndPoint[I], t);
      		glVertex3f(vPoint.x, vPoint.y, vPoint.z);
          t := t + 1.0 / MAX_STEPS;
    		end;
      end;
  	  glEnd();
    end;
  end;
  
  glColor3ub(0, 255, 0);								// Set the color to Green
	glBegin(GL_LINE_STRIP);								// Start drawing lines

  {-----------------------------------------------------------------------------}
	{ Here we actually go through the curve and get the points                    }
	{ that make up the curve.  Since our PointOnCurve() function                  }
  { Take 4 points and a time value, we use a for loop starting                  }
	{ "t" at 0 (the starting point of the curve) and then increase                }
	{ "t" by constant value of time.  Because time is measured from               }
	{ 0 being the beginning of the curve, and 1 being the end, we divide          }
	{ 1 by the amount of steps we want to draw the curve. Basically the           }
	{ amount steps defines the detail of the curve.  If we just had 4             }
	{ steps, the curve would be created out of 4 lines.  The lowest the           }
	{ the amount of steps to make the curve is 3.  Otherwise it is just           }
	{ a straight line.  The more steps, the more rounded the curve is.            }
  {                                                                             }
	{ Go through the curve starting at 0, ending at 1 + another step.             }
	{ Since we are using line strips, we need to go past the end point by 1 step. }
  {-----------------------------------------------------------------------------}


    t := 0;

    while t <= (1 + (1.0 / MAX_STEPS)) do
		begin
  {-----------------------------------------------------------------------------}
  { Here we pass in our 4 points that make up the curve to PointOnCurve().      }
	{ We also pass in "t", which is the current time from 0 to 1.  If we pass     }
	{ in 0 for t, we should get the starting point of the curve, if we pass in    }
	{	1 for t, we should get the end point of the curve.                          }
  { So anything in between  0 and 1 will be another point along the curve       }
  { (IE, .5 would be a point halfway	along the curve).                         }
  {-----------------------------------------------------------------------------}
			// Get the current point on the curve, depending on the time.
			vPoint := PointOnCurve(g_arrvStartPoint[g_arrIndex], g_arrvControlPoint1[g_arrIndex], g_arrvControlPoint2[g_arrIndex], g_arrvEndPoint[g_arrIndex], t);

			// Draw the current point at distance "t" of the curve.
			glVertex3f(vPoint.x, vPoint.y, vPoint.z);

      t := t + 1.0 / MAX_STEPS;
		end;

	glEnd();

  {-----------------------------------------------------------------------------}
	{ Now that we drew the curve, we can turn lighting back on so the sphere      }
  { has some more realistic properties (shading).                               }
  {-----------------------------------------------------------------------------}

	glEnable(GL_LIGHTING);								// Turn lighting back on

  {-----------------------------------------------------------------------------}
	{ In order to move the sphere along the curve,                                }
  { we use the same function do draw the curve,                                 }
  { except that we pass in the current time from 0 to 1 that the sphere is at.  }
  { In the beginning the sphere's time is 0,                                    }
  { so it's at the beginning of the curve.                                      }
  { As we hit the RIGHT arrow key, g_CurrentTime will increase                  }
  { and will move the sphere along the curve                                    }
  { with a certain fixed speed (BALL_SPEED).                                    }
  { When g_CurrentTime gets to 1, we stop.                                      }
  { If the time gets below 0, we stop again.                                    }
  {-----------------------------------------------------------------------------}

  if ShowStart1.Checked then
  begin
  	// Get the current point on the curve, depending on the time.
  	vPoint := PointOnCurve(g_arrvStartPoint[g_arrIndex], g_arrvControlPoint1[g_arrIndex],
						  g_arrvControlPoint2[g_arrIndex], g_arrvEndPoint[g_arrIndex], g_CurrentTime);

  	glColor3ub(255, 0, 0);								// Set the color to red

  	// Draw the sphere at the current point along of the curve.  Give it a radius of 0.2f
  	DrawSphere(vPoint.x, vPoint.y, vPoint.z, 0.2);

  end;
	//glColor3ub(255, 255, 0);							// Set the color to yellow

	// Now, we should display the control points so you can better visualize what they do.
	// We represent them as small yellow spheres.

  glColor3f(0.0,g_ControlPoint1Color,g_ControlPoint2Color);

	// Draw the first control point as a small yellow sphere
	DrawSphere(g_arrvControlPoint1[g_arrIndex].x, g_arrvControlPoint1[g_arrIndex].y, g_arrvControlPoint1[g_arrIndex].z, 0.1);


  glColor3f(g_ControlPoint1Color,g_ControlPoint2Color,0.0);
	// Draw the second control point as a small yellow sphere
	DrawSphere(g_arrvControlPoint2[g_arrIndex].x, g_arrvControlPoint2[g_arrIndex].y, g_arrvControlPoint2[g_arrIndex].z, 0.1);

  glEnd();

  glDisable(GL_LIGHTING);
  glEnable(GL_BLEND);

  glColor4f(0.0,0.0,0.6,0.5);
  glBegin(GL_QUADS);
    glVertex3f(-6.0,0.0,-6.0);
    glVertex3f( 6.0,0.0,-6.0);
    glVertex3f( 6.0,0.0, 6.0);
    glVertex3f(-6.0,0.0, 6.0);
  glEnd;

  glDisable(GL_BLEND);



  glBegin(GL_LINES);
    glColor3f(1.0,1.0,0.0);
    glVertex3f(0.0,0.0,0.0);
    glVertex3f(1.0,0.0,0.0);
    glColor3f(0.0,1.0,1.0);
    glVertex3f(0.0,0.0,0.0);
    glVertex3f(0.0,1.0,0.0);
    glColor3f(1.0,0.0,1.0);
    glVertex3f(0.0,0.0,0.0);
    glVertex3f(0.0,0.0,1.0);
  glEnd;

end;


{------------------------------------------------------------------}
{  Initialise OpenGL                                               }
{------------------------------------------------------------------}
procedure TForm1.glInit();
begin
  glClearColor(0.0, 0.0, 0.0, 0.0); 	   // Black Background
  glShadeModel(GL_SMOOTH);                 // Enables Smooth Color Shading
  glClearDepth(1.0);                       // Depth Buffer Setup
  glEnable(GL_DEPTH_TEST);                 // Enable Depth Buffer
  glDepthFunc(GL_LESS);		           // The Type Of Depth Test To Do

  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);   //Realy Nice perspective calculations

  //////////// *** NEW *** ////////// *** NEW *** ///////////// *** NEW *** ////////////////////

	// Just to give the sphere more realism, we enable the default
	// lights for shading.  First we turn on a light, turn lighting on,
	// then enable coloring.  We need to enable color functions like glColor3f()
	// since lighting is on.  If we don't all objects will be white.

	glEnable(GL_LIGHT0);								// Turn on this light
	glEnable(GL_LIGHTING);								// Turn lighting on
	glEnable(GL_COLOR_MATERIAL);						// Since lighting is on, allow glColor*() functions

//////////// *** NEW *** ////////// *** NEW *** ///////////// *** NEW *** ////////////////////

  // soft edge, antialiasing when blending is enabled
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


  g_CurrentTime := 0.0;								// This is the current position of the sphere along the curve (0 to 1)

  New1Click(nil);

  zView := 10.0;

  g_ControlPoint1Color := 1.0;
  g_ControlPoint2Color := 1.0;

end;


{------------------------------------------------------------------}
{  Create the form and initialist openGL                           }
{------------------------------------------------------------------}
procedure TForm1.FormCreate(Sender: TObject);
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

  // when the app has spare time, render the GL scene
  Application.OnIdle := Idle;
end;


{------------------------------------------------------------------}
{  Release rendering context when form gets detroyed               }
{------------------------------------------------------------------}
procedure TForm1.FormDestroy(Sender: TObject);
begin
  wglMakeCurrent(0,0);
  wglDeleteContext(rc);
end;


{------------------------------------------------------------------}
{  Application onIdle event                                        }
{------------------------------------------------------------------}
procedure TForm1.Idle(Sender: TObject; var Done: Boolean);
begin
  Done := FALSE;

  LastTime :=ElapsedTime;
  ElapsedTime :=GetTickCount() - AppStart;      // Calculate Elapsed Time
  ElapsedTime :=(LastTime + ElapsedTime) DIV 2; // Average it out for smoother movement

  glDraw();                         // Draw the scene
  SwapBuffers(DC);                  // Display the scene
end;


{------------------------------------------------------------------}
{  If the panel resizes, reset the GL scene                        }
{------------------------------------------------------------------}
procedure TForm1.Panel1Resize(Sender: TObject);
begin
  glViewport(0, 0, Panel1.Width, Panel1.Height);    // Set the viewport for the OpenGL window
  glMatrixMode(GL_PROJECTION);        // Change Matrix Mode to Projection
  glLoadIdentity();                   // Reset View
  gluPerspective(45.0, Panel1.Width/Panel1.Height, 1.0, 500.0);  // Do the perspective calculations. Last value = max clipping depth

  glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
end;


{------------------------------------------------------------------}
{  Monitors all keypress events for the app                        }
{------------------------------------------------------------------}
procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = char(VK_LEFT) then 		// If we hit the LEFT arrow
  begin
      g_CurrentTime := g_CurrentTime - BALL_SPEED;			// Increase the position of the ball along the curve
			if g_CurrentTime < 0 then					// If we go below 0
      begin
        g_CurrentTime := 0;					// Set it back to 0
      end;
  end;

  if Key = char(VK_RIGHT) then 		// If we hit the Right arrow
  begin
      g_CurrentTime := g_CurrentTime + BALL_SPEED;			// Increase the position of the ball along the curve
			if g_CurrentTime > 1 then					// If we go below 0
      begin
        g_CurrentTime := 1;					// Set it back to 0
      end;
  end;

  if Key = #27 then
    Close;
end;

{------------------------------------------------------------------------}
{  Close the application                                                 }
{------------------------------------------------------------------------}
procedure TForm1.Button1Click(Sender: TObject);
begin
  Close;
end;


{------------------------------------------------------------------------}
{  Apply button                                                          }
{------------------------------------------------------------------------}
procedure TForm1.Button2Click(Sender: TObject);
begin

  UpdatePointValues();
  
end;


{------------------------------------------------------------------------}
{  Set the value of the target textBox higher or lower                   }
{------------------------------------------------------------------------}
procedure TForm1.DoUpDown(txtBox : TEdit;Button: TUDBtnType);
begin
  if Button = btPrev then
  begin
    txtBox.Text := FloatToStr(StrToFloat(txtBox.Text) - 0.01);
  end
  else
  begin
    txtBox.Text := FloatToStr(StrToFloat(txtBox.Text) + 0.01);
  end;
  UpdatePointValues();
end;

{------------------------------------------------------------------------}
{  Event Handlers for UpDowns                                            }
{------------------------------------------------------------------------}

procedure TForm1.UpDown1Click(Sender: TObject; Button: TUDBtnType);
begin

   DoUpDown(txtPoint1X,Button);

end;

procedure TForm1.UpDown2Click(Sender: TObject; Button: TUDBtnType);
begin

  DoUpDown(txtPoint1Y,Button);

end;

procedure TForm1.UpDown3Click(Sender: TObject; Button: TUDBtnType);
begin

  DoUpDown(txtPoint1Z,Button);

end;

procedure TForm1.UpDown4Click(Sender: TObject; Button: TUDBtnType);
begin
  DoUpDown(txtPoint2X,Button);

end;

procedure TForm1.UpDown5Click(Sender: TObject; Button: TUDBtnType);
begin

  DoUpDown(txtPoint2Y,Button);

end;

procedure TForm1.UpDown6Click(Sender: TObject; Button: TUDBtnType);
begin

  DoUpDown(txtPoint2Z,Button);

end;

procedure TForm1.UpDown7Click(Sender: TObject; Button: TUDBtnType);
begin

  DoUpDown(txtPoint3X,Button);

end;

procedure TForm1.UpDown8Click(Sender: TObject; Button: TUDBtnType);
begin

  DoUpDown(txtPoint3Y,Button);

end;

procedure TForm1.UpDown9Click(Sender: TObject; Button: TUDBtnType);
begin

  DoUpDown(txtPoint3Z,Button);

end;

procedure TForm1.UpDown10Click(Sender: TObject; Button: TUDBtnType);
begin

  DoUpDown(txtPoint4X,Button);

end;

procedure TForm1.UpDown11Click(Sender: TObject; Button: TUDBtnType);
begin

  DoUpDown(txtPoint3Y,Button);

end;

procedure TForm1.UpDown12Click(Sender: TObject; Button: TUDBtnType);
begin

  DoUpDown(txtPoint4Z,Button);

end;

{------------------------------------------------------------------------}
{  Goto or create next Bezier curve                                      }
{------------------------------------------------------------------------}

procedure TForm1.Button3Click(Sender: TObject);
begin

  g_arrIndex := g_arrIndex + 1;

  if g_arrIndex > high(g_arrvStartPoint) then // set size of temp point arrays
  begin

    if MessageDlg('You are about to add a new curve, Is this correct?',mtConfirmation,[mbOK ,mbCancel],0) = mrOk then
    begin
      SetArrayLength;

      //set the start point to the end of the last curve
      g_arrvStartPoint[g_arrIndex] := g_arrvEndPoint[g_arrIndex-1];

      //set the control points to the last used
      g_arrvControlPoint1[g_arrIndex].X := g_arrvStartPoint[g_arrIndex].X+2;
      g_arrvControlPoint1[g_arrIndex].Y := g_arrvStartPoint[g_arrIndex].Y;
      g_arrvControlPoint1[g_arrIndex].Z := g_arrvStartPoint[g_arrIndex].Z;

      g_arrvControlPoint2[g_arrIndex] := g_arrvControlPoint2[g_arrIndex-1];

      //set the end point to any point.
      g_arrvEndPoint[g_arrIndex].x := g_arrvStartPoint[g_arrIndex].X+2;
      g_arrvEndPoint[g_arrIndex].y := g_arrvStartPoint[g_arrIndex].Y;
      g_arrvEndPoint[g_arrIndex].z := g_arrvStartPoint[g_arrIndex].Z;
      // This is the end point of the curve
    end
    else
    begin
      g_arrIndex := 0;
    end;
  end;

  UpdateTextValues;

end;

{------------------------------------------------------------------------}
{  Increment Control point array sizes                                   }
{------------------------------------------------------------------------}
procedure TForm1.SetArrayLength();
begin
  setLength(g_arrvStartPoint,g_arrIndex+1);
  setLength(g_arrvControlPoint1,g_arrIndex+1);
  setLength(g_arrvControlPoint2,g_arrIndex+1);
  setLength(g_arrvEndPoint,g_arrIndex+1);
  
end;

{------------------------------------------------------------------------}
{  Update the text values from  the control point arrays                 }
{------------------------------------------------------------------------}
procedure TForm1.UpdateTextValues();
begin
 txtPoint1X.Text := FloatToStr(g_arrvStartPoint[g_arrIndex].X);
 txtPoint1Y.Text := FloatToStr(g_arrvStartPoint[g_arrIndex].Y);
 txtPoint1Z.Text := FloatToStr(g_arrvStartPoint[g_arrIndex].Z);

 txtPoint2X.Text := FloatToStr(g_arrvControlPoint1[g_arrIndex].X);
 txtPoint2Y.Text := FloatToStr(g_arrvControlPoint1[g_arrIndex].Y);
 txtPoint2Z.Text := FloatToStr(g_arrvControlPoint1[g_arrIndex].Z);

 txtPoint3X.Text := FloatToStr(g_arrvControlPoint2[g_arrIndex].X);
 txtPoint3Y.Text := FloatToStr(g_arrvControlPoint2[g_arrIndex].Y);
 txtPoint3Z.Text := FloatToStr(g_arrvControlPoint2[g_arrIndex].Z);

 txtPoint4X.Text := FloatToStr(g_arrvEndPoint[g_arrIndex].X);
 txtPoint4Y.Text := FloatToStr(g_arrvEndPoint[g_arrIndex].Y);
 txtPoint4Z.Text := FloatToStr(g_arrvEndPoint[g_arrIndex].Z);
end;


{------------------------------------------------------------------------}
{  Update the control point array values from  the text boxes            }
{------------------------------------------------------------------------}
procedure TForm1.UpdatePointValues();
begin
 g_arrvStartPoint[g_arrIndex].X := StrToFloat(txtPoint1X.Text);
 g_arrvStartPoint[g_arrIndex].Y := StrToFloat(txtPoint1Y.Text);
 g_arrvStartPoint[g_arrIndex].Z := StrToFloat(txtPoint1Z.Text);

 g_arrvControlPoint1[g_arrIndex].X := StrToFloat(txtPoint2X.Text);
 g_arrvControlPoint1[g_arrIndex].Y := StrToFloat(txtPoint2Y.Text);
 g_arrvControlPoint1[g_arrIndex].Z := StrToFloat(txtPoint2Z.Text);

 g_arrvControlPoint2[g_arrIndex].X := StrToFloat(txtPoint3X.Text);
 g_arrvControlPoint2[g_arrIndex].Y := StrToFloat(txtPoint3Y.Text);
 g_arrvControlPoint2[g_arrIndex].Z := StrToFloat(txtPoint3Z.Text);

 g_arrvEndPoint[g_arrIndex].X := StrToFloat(txtPoint4X.Text);
 g_arrvEndPoint[g_arrIndex].Y := StrToFloat(txtPoint4Y.Text);
 g_arrvEndPoint[g_arrIndex].Z := StrToFloat(txtPoint4Z.Text);
end;

{------------------------------------------------------------------------}
{  Highlight Control point 2                                             }
{------------------------------------------------------------------------}
procedure TForm1.GroupBox4Click(Sender: TObject);
begin
  g_ControlPoint1Color := 1.0;
  g_ControlPoint2Color := 0.0;
end;


{------------------------------------------------------------------------}
{  Highlight Control point 3                                             }
{------------------------------------------------------------------------}
procedure TForm1.GroupBox3Click(Sender: TObject);
begin
  g_ControlPoint1Color := 0.0;
  g_ControlPoint2Color := 1.0;
end;

{------------------------------------------------------------------------}
{  Move to the previous curve                                            }
{------------------------------------------------------------------------}
procedure TForm1.Button4Click(Sender: TObject);
begin
  if g_arrIndex > 0 then
  begin
    g_arrIndex := g_arrIndex - 1;
    UpdateTextValues;
  end
  else
  begin
    g_arrIndex := high(g_arrvStartPoint);
    UpdateTextValues;
  end;
end;


{------------------------------------------------------------------------}
{  Show/Hide start position                                              }
{------------------------------------------------------------------------}
procedure TForm1.ShowStart1Click(Sender: TObject);
begin
  ShowStart1.Checked := not ShowStart1.Checked
end;

{------------------------------------------------------------------------}
{  Enable/Disable the scene rotation                                     }
{------------------------------------------------------------------------}
procedure TForm1.Rotate1Click(Sender: TObject);
begin
  Rotate1.Checked := not Rotate1.Checked;
  chkRotate.Checked := Rotate1.Checked;
end;

{------------------------------------------------------------------------}
{  Show/Hide all curves                                                  }
{------------------------------------------------------------------------}
procedure TForm1.ShowAllCurves1Click(Sender: TObject);
begin
  ShowAllCurves1.Checked := not ShowAllCurves1.Checked;
  chkAllBeziers.Checked := ShowAllCurves1.Checked;
end;

{------------------------------------------------------------------------}
{  Save Array of Coords to file(*.pas)                                   }
{------------------------------------------------------------------------}
procedure TForm1.Save1Click(Sender: TObject);
var I : integer;
    t : GLfloat;
    vPoint : TCoord;
    f : TextFile;
begin

  SaveDialog1.Filter := 'Points Array File|*.PAS';
  if SaveDialog1.Execute then
  begin

    AssignFile(f,SaveDialog1.FileName);

    Rewrite(f);

    WriteLn(f,'unit Unit2;');
    WriteLn(f,'interface');

    WriteLn(f,'uses OpenGL;');

    WriteLn(f,'type');
    WriteLn(f,'TCoord = Record');
    WriteLn(f,'  X, Y, Z : glFLoat;');;
    WriteLn(f,'end;');
    WriteLn(f,'var');
    WriteLn(f,' vCurves : array of TCoord;');

    WriteLn(f,'implementation');

    WriteLn(f,'procedure addPoint(X,Y,Z : GLfloat);');
    WriteLn(f,'begin');
    WriteLn(f,'  setLength(vCurves,high(vCurves)+1);');
    WriteLn(f,'  vCurves[high(vCurves)].X := X;');
    WriteLn(f,'  vCurves[high(vCurves)].Y := Y;');
    WriteLn(f,'  vCurves[high(vCurves)].Z := Z;');
    WriteLn(f,'end;');

    WriteLn(f,'procedure initCurve();');
    WriteLn(f,'begin');

    for I := 0 to high(g_arrvStartPoint) do
    begin
      t := 0;
      while t <= (1 + (1.0 / MAX_STEPS)) do
      begin
        vPoint := PointOnCurve(g_arrvStartPoint[I], g_arrvControlPoint1[I], g_arrvControlPoint2[I], g_arrvEndPoint[I], t);
        WriteLn(f,' addPoint(' + FloatToStr(vPoint.X) + ',' + FloatToStr(vPoint.Y) + ',' + FloatToStr(vPoint.Z) + ');');
        t := t + 1.0 / MAX_STEPS;
      end;
    end;

    WriteLn(f,'end;');
    WriteLn(f,'end.');

    CloseFile(f);
  end;

end;

{------------------------------------------------------------------------}
{  Set Y rotation when mouseclick occurs on panel                        }
{------------------------------------------------------------------------}
procedure TForm1.Timer1Timer(Sender: TObject);
var mpos : TPoint;
begin
  GetCursorPos(mpos);
  if mpos.X > Panel1.Width div 2 then
  begin
    rotateY := rotateY + mpos.X/1000;
  end
  else
  begin
   rotateY := rotateY - (mpos.X+1000)/1000;
  end;
end;

{------------------------------------------------------------------------}
{  Enable Y rotation                                                     }
{------------------------------------------------------------------------}
procedure TForm1.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Timer1.Enabled := true;
end;

{------------------------------------------------------------------------}
{  Disable Y rotation                                                    }
{------------------------------------------------------------------------}
procedure TForm1.Panel1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Timer1.Enabled := false;
end;

{------------------------------------------------------------------------}
{  Zoom scene in or out depending on zViewModifier                       }
{------------------------------------------------------------------------}
procedure TForm1.Timer2Timer(Sender: TObject);
begin
   zView := zView + zViewModifier;
end;

{------------------------------------------------------------------------}
{  Enable Zoom out                                                    }
{------------------------------------------------------------------------}
procedure TForm1.Button5MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  zViewModifier := 0.1;
  timer2.Enabled := true;
end;

{------------------------------------------------------------------------}
{  Enable Zoom in                                                        }
{------------------------------------------------------------------------}
procedure TForm1.Button6MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  zViewModifier := -0.1;
  timer2.Enabled := true;
end;

{------------------------------------------------------------------------}
{  Disable Zoom in                                                       }
{------------------------------------------------------------------------}
procedure TForm1.Button6MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  timer2.Enabled := false;
end;

{------------------------------------------------------------------------}
{  Disable Zoom out                                                      }
{------------------------------------------------------------------------}
procedure TForm1.Button5MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  timer2.Enabled := false;
end;

{------------------------------------------------------------------------}
{  Save Control point to file(*.txt)                                     }
{------------------------------------------------------------------------}
procedure TForm1.SaveControlPoints1Click(Sender: TObject);
var f : TextFile;
    I : integer;
begin
  SaveDialog1.Filter := 'Control Points File|*.TXT';
  if SaveDialog1.Execute then
  begin
    AssignFile(f,SaveDialog1.FileName);
    Rewrite(f);
    for I := 0 to high(g_arrvStartPoint) do
    begin
      WriteLn(f,FloatToStr(g_arrvStartPoint[I].X) + ' ' + FloatToStr(g_arrvStartPoint[I].Y) + ' ' + FloatToStr(g_arrvStartPoint[I].Z));
      WriteLn(f,FloatToStr(g_arrvControlPoint1[I].X) + ' ' + FloatToStr(g_arrvControlPoint1[I].Y) + ' ' + FloatToStr(g_arrvControlPoint1[I].Z));
      WriteLn(f,FloatToStr(g_arrvControlPoint2[I].X) + ' ' + FloatToStr(g_arrvControlPoint2[I].Y) + ' ' + FloatToStr(g_arrvControlPoint2[I].Z));
      WriteLn(f,FloatToStr(g_arrvEndPoint[I].X) + ' ' + FloatToStr(g_arrvEndPoint[I].Y) + ' ' + FloatToStr(g_arrvEndPoint[I].Z));
    end;

    CloseFile(f);

  end;
end;

{------------------------------------------------------------------------}
{  Open Control point file(*.txt) and load                               }
{------------------------------------------------------------------------}
procedure TForm1.OpenControlPointFile1Click(Sender: TObject);
var x,y,z : GLfloat;
    f : TextFile;
    I : integer;
    arrvStartPoint,arrvControlPoint1,arrvControlPoint2,arrvEndPoint : array of TCoord;
begin
  if OpenDialog1.Execute then
  begin

    //save our current control points to temp vars incase we need to roll back 
    setLength(arrvStartPoint,high(g_arrvStartPoint)+1);
    setLength(arrvControlPoint1,high(g_arrvControlPoint1)+1);
    setLength(arrvControlPoint2,high(g_arrvControlPoint2)+1);
    setLength(arrvEndPoint,high(g_arrvEndPoint)+1);

    for I := 0 to high(g_arrvStartPoint) do
    begin
       arrvStartPoint[i] := g_arrvStartPoint[i];
       arrvControlPoint1[i] := g_arrvControlPoint1[i];
       arrvControlPoint2[i] := g_arrvControlPoint2[i];
       arrvEndPoint[i] := g_arrvEndPoint[i];
    end;

    //reset the control point arrays
    setLength(g_arrvStartPoint,0);
    setLength(g_arrvControlPoint1,0);
    setLength(g_arrvControlPoint2,0);
    setLength(g_arrvEndPoint,0);
    try
      try
        //load the control point file
        AssignFile(f,OpenDialog1.FileName);
        Reset(f);

        while not eof(f) do
        begin

          setLength(g_arrvStartPoint,high(g_arrvStartPoint)+2);
          setLength(g_arrvControlPoint1,high(g_arrvControlPoint1)+2);
          setLength(g_arrvControlPoint2,high(g_arrvControlPoint2)+2);
          setLength(g_arrvEndPoint,high(g_arrvEndPoint)+2);

          I := high(g_arrvStartPoint);

          Readln(f,x,y,z);
          g_arrvStartPoint[I].X := x;
          g_arrvStartPoint[I].Y := y;
          g_arrvStartPoint[I].Z := z;

          Readln(f,x,y,z);
          g_arrvControlPoint1[I].X := x;
          g_arrvControlPoint1[I].Y := y;
          g_arrvControlPoint1[I].Z := z;

          Readln(f,x,y,z);
          g_arrvControlPoint2[I].X := x;
          g_arrvControlPoint2[I].Y := y;
          g_arrvControlPoint2[I].Z := z;

          Readln(f,x,y,z);
          g_arrvEndPoint[I].X := x;
          g_arrvEndPoint[I].Y := y;
          g_arrvEndPoint[I].Z := z;
        end;
      except
        //if the control point file is malformed alert the user
        MessageDlg('This file is not a invalid control point file.',mtError,[mbOK],0);

        //rollback

        setLength(g_arrvStartPoint,high(arrvStartPoint)+1);
        setLength(g_arrvControlPoint1,high(arrvControlPoint1)+1);
        setLength(g_arrvControlPoint2,high(arrvControlPoint2)+1);
        setLength(g_arrvEndPoint,high(arrvEndPoint)+1);

        for I := 0 to high(arrvStartPoint) do
        begin
          g_arrvStartPoint[i] := arrvStartPoint[i];
          g_arrvControlPoint1[i] := arrvControlPoint1[i];
          g_arrvControlPoint2[i] := arrvControlPoint2[i];
          g_arrvEndPoint[i] := arrvEndPoint[i];
        end;

      end;
    finally
      //make sure the file gets closed
      CloseFile(f);
    end;

    g_arrIndex := 0;

    UpdateTextValues();

  end;
end;

{------------------------------------------------------------------------}
{  Set Temp value for validation                                         }
{------------------------------------------------------------------------}
procedure TForm1.SetTempValue(txtBox : TEdit);
begin
  g_tempVar := StrToFloat(txtBox.text);
end;

{------------------------------------------------------------------------}
{  Validate textBox value and rollback if neccecary                      }
{------------------------------------------------------------------------}
procedure TForm1.SetCoordValue(txtBox : TEdit);
var tempVar : glFloat;
begin
  try
    tempVar := StrToFloat(txtBox.Text);
  except
    txtBox.Text := FloatToStr(g_tempVar);
  end;
  UpdatePointValues();
end;

{------------------------------------------------------------------------}
{  TextBox event Handlers                                                }
{------------------------------------------------------------------------}
procedure TForm1.txtPoint1XEnter(Sender: TObject);
begin
  SetTempValue(TEdit(Sender));
end;

procedure TForm1.txtPoint1XExit(Sender: TObject);
begin
  SetCoordValue(TEdit(Sender));
end;

procedure TForm1.txtPoint1YEnter(Sender: TObject);
begin
   SetTempValue(TEdit(Sender));
end;

procedure TForm1.txtPoint1YExit(Sender: TObject);
begin
  SetCoordValue(TEdit(Sender));
end;

procedure TForm1.txtPoint1ZEnter(Sender: TObject);
begin
  SetTempValue(TEdit(Sender));
end;

procedure TForm1.txtPoint1ZExit(Sender: TObject);
begin
  SetCoordValue(TEdit(Sender));
end;

procedure TForm1.txtPoint2XEnter(Sender: TObject);
begin
  SetTempValue(TEdit(Sender));
end;

procedure TForm1.txtPoint2XExit(Sender: TObject);
begin
  SetCoordValue(TEdit(Sender));
end;

procedure TForm1.txtPoint2YEnter(Sender: TObject);
begin
  SetTempValue(TEdit(Sender));
end;

procedure TForm1.txtPoint2YExit(Sender: TObject);
begin
  SetCoordValue(TEdit(Sender));
end;

procedure TForm1.txtPoint2ZEnter(Sender: TObject);
begin
  SetTempValue(TEdit(Sender));
end;

procedure TForm1.txtPoint2ZExit(Sender: TObject);
begin
  SetCoordValue(TEdit(Sender));
end;

procedure TForm1.txtPoint3XEnter(Sender: TObject);
begin
  SetTempValue(TEdit(Sender));
end;

procedure TForm1.txtPoint3XExit(Sender: TObject);
begin
  SetCoordValue(TEdit(Sender));
end;

procedure TForm1.txtPoint3YEnter(Sender: TObject);
begin
  SetTempValue(TEdit(Sender));
end;

procedure TForm1.txtPoint3YExit(Sender: TObject);
begin
  SetCoordValue(TEdit(Sender));
end;

procedure TForm1.txtPoint3ZEnter(Sender: TObject);
begin
  SetTempValue(TEdit(Sender));
end;

procedure TForm1.txtPoint3ZExit(Sender: TObject);
begin
  SetCoordValue(TEdit(Sender));
end;

procedure TForm1.txtPoint4XEnter(Sender: TObject);
begin
  SetTempValue(TEdit(Sender));
end;

procedure TForm1.txtPoint4XExit(Sender: TObject);
begin
  SetCoordValue(TEdit(Sender));
end;

procedure TForm1.txtPoint4YEnter(Sender: TObject);
begin
  SetTempValue(TEdit(Sender));
end;

procedure TForm1.txtPoint4YExit(Sender: TObject);
begin
  SetCoordValue(TEdit(Sender));
end;

procedure TForm1.txtPoint4ZEnter(Sender: TObject);
begin
  SetTempValue(TEdit(Sender));
end;

procedure TForm1.txtPoint4ZExit(Sender: TObject);
begin
  SetCoordValue(TEdit(Sender));
end;


{------------------------------------------------------------------------}
{  Re-initialise Point Arrays and TextBoxes (New Curve)                  }
{------------------------------------------------------------------------}
procedure TForm1.New1Click(Sender: TObject);
begin
  g_arrIndex := 0;

  setLength(g_arrvStartPoint,g_arrIndex+1);
  setLength(g_arrvControlPoint1,g_arrIndex+1);
  setLength(g_arrvControlPoint2,g_arrIndex+1);
  setLength(g_arrvEndPoint,g_arrIndex+1);

  g_arrvStartPoint[g_arrIndex].x := -1.0; g_arrvStartPoint[g_arrIndex].y := 1.0; g_arrvStartPoint[g_arrIndex].z := 0.0;    // This is the starting point of the curve
  g_arrvControlPoint1[g_arrIndex].x := -0.5;  g_arrvControlPoint1[g_arrIndex].y := 1.0;  g_arrvControlPoint1[g_arrIndex].z := 0.0;				// This is the first control point of the curve
  g_arrvControlPoint2[g_arrIndex].x := 0.5;  g_arrvControlPoint2[g_arrIndex].y := 1.0;  g_arrvControlPoint2[g_arrIndex].z := 0.0;				// This is the second control point of the curve
  g_arrvEndPoint[g_arrIndex].x := 1.0;  g_arrvEndPoint[g_arrIndex].y := 1.0;  g_arrvEndPoint[g_arrIndex].z := 0.0;				// This is the end point of the curve

  UpdateTextValues();

end;

procedure TForm1.About1Click(Sender: TObject);
begin
   Form2.Show;
end;

end.
