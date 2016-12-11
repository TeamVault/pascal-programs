{***********************************************************************
 *  Copyright (c) 1991,92 - Borland International.
 *
 *  File: TDODEMO.PAS
 *
 *  Turbo Pascal demonstration program to show how to use TDW
 *  to debug an Object Windows application.
 *
 *  The Color Scribble program lets the user draw on the screen in
 *  any of four colors: red, green, blue, and black.
 ***********************************************************************}

program CScribble;

{$R TDODEMO.RES} {Include resource file having menu definition. }

uses WinTypes, WinProcs, OWindows, ODialogs;

const
  PenWidth   = 1;          { Width of Scribble line.      }
  MenuID     = 100;        { ID of menu in resource file. }
  IconID     = 100;        { ID of Icon in resource file. }
  RedMenu    = 101;        { Value of Pen|Red menu.       }
  GreenMenu  = 102;        { Value of Pen|Green menu.     }
  BlueMenu   = 103;        { Value of Pen|Blue menu.      }
  BlackMenu  = 204;        { Value of Pen|Black menu.     }

type
{ --------------------------------------------------------
  CScribbleApplication type.
  -------------------------------------------------------- }
 CScribbleApplication = object(TApplication)
   procedure InitMainWindow; virtual; { Creates main window }
 end;


type
{ --------------------------------------------------------
  ScribbleWindow type.
  -------------------------------------------------------- }

  PScribbleWindow = ^ScribbleWindow;
  ScribbleWindow = object(TWindow)
    HandleDC: HDC;        { Display context for drawing.            }
			  { Preserves value while dragging mouse.   }
    ButtonDown: Boolean;  { left-button-down flag }

    constructor Init(aParent: PWindowsObject; aTitle: PChar);

      { Virtual method that gets called when the left mouse     }
      { button is clicked in the window.  This method sets up   }
      { the window for scribbling by creating a display context.}
    procedure WMLButtonDown(var Msg: TMessage); virtual WM_LBUTTONDOWN;

      { Virtual method that gets called when the left mouse     }
      { button is released in the window.  This method releases }
      { the display context that is used for drawing.           }
    procedure WMLButtonUp(var Msg: TMessage); virtual WM_LBUTTONUP;

      { Virtual method that gets called when the mouse is   }
      { moved anywhere in the window.  If the left mouse    }
      { button is pressed, the window will be scribbled in. }
    procedure WMMouseMove(var Msg: TMessage); virtual WM_MOUSEMOVE;

      { Virtual method that gets called when the right mouse button }
      { is clicked in the window.  It clears the window by invali-  }
      { dating the window, causing a WM_PAINT message to be sent.   }
    procedure WMRButtonDown(var Msg: TMessage); virtual WM_RBUTTONDOWN;

  end;


{ --------------------------------------------------------
  CScribbleWindow type.
  -------------------------------------------------------- }
  PCScribbleWindow = ^CScribbleWindow;
  CScribbleWindow  = object(ScribbleWindow)
    thePen: HPen;  { Pen that is used for drawing in color }

      { Adds a menu to the window and }
      { initializes the pen to black. }
    constructor Init(aParent: PWindowsObject; ATitle: PChar);

    destructor Done; virtual;   { Disposes of the pen. }

      { Virtual method that gets called when user      }
      { selects Pen.Red from the menu bar. Disposes    }
      { of the current pen and creates a red pen.      }
    procedure SelectRedPen(var Msg: TMessage);
      virtual cm_First + RedMenu;

      { Virtual method that gets called when user      }
      { selects Pen.Green from the menu bar. Disposes  }
      { of the current pen and creates a green pen.    }
    procedure SelectGreenPen(var Msg: TMessage);
      virtual cm_First + GreenMenu;

      { Virtual method that gets called when user      }
      { selects Pen.Blue from the menu bar. Disposes   }
      { of the current pen and creates a blue pen.     }
    procedure SelectBluePen(var Msg: TMessage);
      virtual cm_First + BlueMenu;

      { Virtual method that gets called when user       }
      { selects Pen.Black from the menu bar. Disposes   }
      { of the current pen and creates a black pen.     }
    procedure SelectBlackPen(var Msg: TMessage);
      virtual cm_First + BlackMenu;

      { Method that gets called when the user presses the         }
      { left mouse button.  Selects pen into the display context. }
    procedure WMLButtonDown(var Msg: TMessage);
      virtual WM_LBUTTONDOWN;

      { Method to change the window class of the Scribble Window. }
      {	Allows program to have an Icon associated with the        }
      {	main window                                               }
    procedure GetWindowClass(var AWndClass: TWndClass);virtual;

      { Returns a unique name for this class of window.  Needed }
      {	because this class has a unique icon associated through }
      {	GetWindowClass method                                   }
    function GetClassName: PChar;virtual;
  end;

{*****************************************************************
 * ScribbleWindow constructor.
 *****************************************************************}
constructor ScribbleWindow.Init(aParent: PWindowsObject; aTitle: PChar);
begin
  TWindow.Init(aParent, aTitle);
  ButtonDown := False;
end;

{*****************************************************************
 * procedure ScribbleWindow.WMLButtonDown
 *
 * Process WM_LBUTTONDOWN messages by creating a display context and
 * marking mouse as being pressed.  Also tell Windows to send
 * all mouse messages to window.
 *****************************************************************}
procedure ScribbleWindow.WMLButtonDown(var Msg: TMessage);
begin
  if not ButtonDown then
  begin
    ButtonDown := True;  { Mark mouse button as being     }
			 { pressed so when mouse movement }
			 { occurs, a line will be drawn.  }

    SetCapture(hWindow); { Tell Windows to send all mouse   }
			 { messages to window. WMLButtonUp  }
			 { method will release the capture. }

    HandleDC := GetDC(hWindow);    { Create display context for drawing. }

    MoveTo(HandleDC, Msg.LParamLo, { Move drawing point to location }
	   Msg.LParamHi);          { where mouse was pressed.       }

  end;
end;

{*****************************************************************
 * procedure ScribbleWindow.WM_Mousemove
 *
 * Process WM_MOUSEMOVE messages by drawing a line if the
 * mouse button is marked as being pressed.
 *****************************************************************}
procedure ScribbleWindow.WMMouseMove(var Msg: TMessage);
begin
  if ButtonDown then  { If the mouse button is currently down }
    LineTo(HandleDC, Msg.LParamLo, Msg.LParamHi);
		      { Draw a line to where the mouse is presently }
end;

{*****************************************************************
 * procedure ScribbleWindow.WM_LBUTTONUP
 *
 * Process WM_LBUTTONUP messages by allowing other applications
 * to receive mouse messages, releasing the display context, and
 * marking the mouse button as not being pressed.
 *****************************************************************}
procedure ScribbleWindow.WMLButtonUp(var Msg: TMessage);
begin
  if ButtonDown then
  begin
    ReleaseCapture; { Tell Windows to stop sending all mouse  }
                    { messages to this window.  Allow other   }
                    { applications to receive mouse messages. }
    ReleaseDC(hWindow,handleDC);
			 { Release display context created   }
                         { by WMLButtonDown method.          }
    ButtonDown := False; { Mark mouse button as not pressed. }
  end;
end;

{*****************************************************************
 * procedure ScribbleWindow.WMRButtonDown
 *
 * Process WM_RBUTTONDOWN messages by erasing the window.
 * Invalidate entire window by passing nil rectangle to
 * InvalidateRect.  Window is erased because third parameter
 * of InvalidateRect is true. Since a Paint method wasn't
 * defined, WM_PAINT messages call only BeginPaint and EndPaint.
 ***************************************************************** }
procedure ScribbleWindow.WMRButtonDown(var Msg: TMessage);
begin
  InvalidateRect(HWindow, nil, True);
  UpdateWindow(HWindow);
end;

{*****************************************************************
 * CScribbleWindow constructor.
 *****************************************************************}
constructor CScribbleWindow.Init(aParent: PWindowsObject; ATitle: PChar);
begin
  ScribbleWindow.Init(aParent, ATitle); { Call standard OWL constructor }
                                        { for a window.                 }
  Attr.Menu := LoadMenu(HInstance,          { Attach menu from resource }
		  MakeIntResource(MenuID)); { file to window.           }

  thePen := CreatePen(PS_SOLID,PenWidth,    {Initialize pen to black.   }
                      RGB(0, 0, 0));
end;

{*****************************************************************
 * CScribbleWindow destructor.
 *****************************************************************}
destructor CScribbleWindow.Done;
begin
  TWindow.Done;           { Call standard OWL destructor for a window. }
  DeleteObject(thePen);   { Dispose of pen. }
end;

{*****************************************************************
 * procedure CScribbleWindow.SelectRedPen
 *
 * Create a red pen in response to a "Red" selection from
 * Pen menu.
 *****************************************************************}
procedure CScribbleWindow.SelectRedPen(var Msg: TMessage);
begin
  DeleteObject(thePen);                { Dispose of the current pen }
  thePen := CreatePen(PS_SOLID,PenWidth, RGB(255, 0, 0));
end;

{*****************************************************************
 * procedure CScribbleWindow.SelectGreenPen
 *
 * Create a green pen in response to a "Green" selection from
 * Pen menu.
 *****************************************************************}
procedure CScribbleWindow.SelectGreenPen(var Msg: TMessage);
begin
  DeleteObject(thePen);                 { Dispose of the current pen }
  thePen := CreatePen(PS_SOLID,PenWidth, RGB(0, 255, 0));
end;

{*****************************************************************
 * procedure CScribbleWindow.SelectBluePen
 *
 * Create a blue pen in response to a "Blue" selection from
 * Pen menu.
 *****************************************************************}
procedure CScribbleWindow.SelectBluePen(var Msg: TMessage);
begin
  DeleteObject(thePen);                 { Dispose of the current pen }
  thePen := CreatePen(PS_SOLID,PenWidth, RGB(0, 0, 255));
end;

{*****************************************************************
 * procedure CScribbleWindow.SelectBlackPen
 *
 * Create a black pen in response to a "Black" selection from
 * Pen menu.
 *****************************************************************}
procedure CScribbleWindow.SelectBlackPen(var Msg: TMessage);
begin
  DeleteObject(thePen); { Dispose of the current pen }
  thePen := CreatePen(PS_SOLID,PenWidth, RGB(0, 0, 0));
end;

{*****************************************************************
 * procedure CScribbleWindow.WM_LButtonDown
 *
 * Select a colored pen into the display context.
 *****************************************************************}
procedure CScribbleWindow.WMLButtonDown(var Msg: TMessage);
begin
  ScribbleWindow.WMLButtonDown(Msg); { Call ScribbleWindow   }
				     { WMLButtonDown method. }
  SelectObject(handleDC, thePen);    { Select pen into display context. }
end;

{*****************************************************************
 * procedure CScribbleWindow.GetWindowClass
 *
 * Changes the window icon to a custom icon
 *****************************************************************}
procedure CScribbleWindow.GetWindowClass(var AWndClass: TWndClass);
begin
  ScribbleWindow.GetWindowClass(AWndClass); { Get the ScribbleWindow }
					    { class                  }
  AWndClass.hIcon := LoadIcon(HInstance,MakeIntResource(IconID));
					    { Attach a resource to }
					    {  the window          }
end;

{*****************************************************************
 * function CScribbleWindow.GetClassName: PChar;
 *
 * Returns a unique class name for the Color Scribble window class.
 *****************************************************************}
function CScribbleWindow.GetClassName: PChar;
begin
  GetClassName := 'ColorScribble';
end;

{*****************************************************************
 * procedure CScribbleApplication.InitMainWindow
 *
 * Initialize a Color Scribble window for the main window.
 *****************************************************************}
procedure CScribbleApplication.InitMainWindow;
begin
  MainWindow := New(PCScribbleWindow,Init(nil, 'Scribble With Color!'));
end;


{*** Program begins here. ***}

var
  CSApp: CScribbleApplication;

begin
  CSApp.Init('CScribble');
  CSApp.Run;
  CSApp.Done;
end.
