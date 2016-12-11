//------------------------------------------------------------------------
//
// Original Author     : Sami Hamlaoui's / NeHe
// Author              : Jan Horn
// Email               : jhorn@global.co.za
// Author Website      : http://nehe.gamedev.net
// Website             : http://www.sulaco.co.za
// Date                : 16 October 2001
// Version             : 1.0
// TMT Pascal version  : Vadim Bodrov (http://www.tmt.com)
// Description         : Conversion of NeHe's Tutorial 38 on Cell Shading
//     Note: The original article for this code can be found at:
//     http://www.gamedev.net/reference/programming/features/celshading
//
//------------------------------------------------------------------------
program CellShad;

uses
  Windows,
  Messages,
  Strings,
  OpenGL;

procedure glBindTexture conv arg_stdcall (target: GLenum; texture: GLuint);
  external opengl32dll;
procedure glGenTextures conv arg_stdcall (n: GLsizei; var textures: GLuint);
  external opengl32dll;

const
  WND_TITLE = 'Cell Shading';
  FPS_TIMER = 1;                        // Timer to calculate FPS
  FPS_INTERVAL = 1000;                  // Calculate FPS every 1000 ms

type TMatrix = Record                   // A Structure To Hold An OpenGL Matrix
       Data : Array[0..15] of glFloat;
     end;
     TVector = Record                   // A Structure To Hold A Single Vector
       X, Y, Z : glFloat;               // The Components Of The Vector
     end;
     TVertex = Record                   // A Structure To Hold A Single Vertex
       Nor : TVector;                   // Vertex Normal
       Pos : TVector;                   // Vertex Position
     end;
     PPolygon = ^TPolygon;
     TPolygon = Record                  // A Structure To Hold A Single Polygon
       Verts : Array[0..2] of TVertex;  // Array Of 3 VERTEX Structures
     end;

var
  h_Wnd  : HWND;                        // Global window handle
  h_DC   : HDC;                         // Global device context
  h_RC   : HGLRC;                       // OpenGL rendering context
  keys : Array[0..255] of Boolean;      // Holds keystrokes
  FPSCount : Integer = 0;               // Counter for FPS
  ElapsedTime : Integer;                // Elapsed time between frames
  LastUpdate : Integer;

  // Textures
  shaderTexture : glUint;

  // User vaiables
  outlineDraw : Boolean = true;         // Flag To Draw The Outline
  outlineSmooth : Boolean = false;      // Flag To Anti-Alias The Lines
  outlineWidth : Integer = 3;           // Width Of The Lines
  lightAngle   : TVector;               // The Direction Of The Light
  lightRotate  : Boolean = false;       // Flag To See If We Rotate The Light
  modelAngle   : glFloat = 0.0;         // Y-Axis Angle Of The Model
  modelRotate  : Boolean = false;       // Flag To Rotate The Model
  polyData     : Pointer;               // Polygon Data
  polyNum      : Integer;

const
  outlineColor : Array[0..2] of glFloat = (0.0, 0.0, 0.0);  // Color Of The Lines


// Reads The Contents Of The "model.txt" File
function ReadMesh : Boolean;
var F : File;
BytesRead : Integer;
begin
  result :=FALSE;
  Assign(F, 'Data\model.txt');
{$I-}
  Reset(F, 1);
{$I+}
  if IOResult <> 0 then
    exit;

  // read header
  BlockRead(F, PolyNum, Sizeof(Integer));
  GetMem(PolyData, polyNum*sizeof(TPolygon));
  BlockRead(F, PolyData^, polyNum*sizeof(TPolygon), BytesRead);   //*sizeof(TPolygon)
  Close(F);
  Result :=TRUE;
end;


// Calculate The Angle Between The 2 Vectors
function DotProduct (const v1, v2 : TVector) : glFloat;
begin
  result :=V1.X * V2.X + V1.Y * V2.Y + V1.Z * V2.Z;
end;


// Creates A Vector With A Unit Length Of 1
procedure Normalize(var V : TVector);
var L : glFloat;
begin
  L := sqrt(V.X*V.X + V.Y*V.Y + V.Z*V.Z);
  if L = 0 then
    L :=1;

  v.X :=v.X / L;
  v.Y :=v.Y / L;
  v.Z :=v.Z / L;
end;


// Rotate A Vector Using The Supplied Matrix
procedure RotateVector(const M : TMatrix; const V : TVector; var D : TVector);
begin
  D.X := (M.Data[0] * V.X) + (M.Data[4] * V.Y) + (M.Data[8]  * V.Z);    // Rotate Around The X Axis
  D.Y := (M.Data[1] * V.X) + (M.Data[5] * V.Y) + (M.Data[9]  * V.Z);    // Rotate Around The Y Axis
  D.Z := (M.Data[2] * V.X) + (M.Data[6] * V.Y) + (M.Data[10] * V.Z);    // Rotate Around The Z Axis
end;


{------------------------------------------------------------------}
{  Function to draw the actual scene                               }
{------------------------------------------------------------------}
procedure glDraw;
var I, J : Integer;
    TmpShade : glFloat;                         // Temporary Shader Value
    TmpMatrix : TMatrix;                        // Temporary MATRIX Structure
    TmpVector, TmpNormal : TVector;             // Temporary VECTOR Structures
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);    // Clear The Screen And The Depth Buffer
  glLoadIdentity();                                       // Reset The View

  if outlineSmooth then                         // Check To See If We Want Anti-Aliased Lines
  begin
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);     // Use The Good Calculations
    glEnable(GL_LINE_SMOOTH);                   // Enable Anti-Aliasing
  end
  else                                          // We Don't Want Smooth Lines
    glDisable(GL_LINE_SMOOTH);                  // Disable Anti-Aliasing

  glTranslatef(0.0, 0.0, -2.0);                 // Move 2 Units Away From The Screen
  glRotatef(modelAngle, 0.0, 1.0, 0.0);         // Rotate The Model On It's Y-Axis

  glGetFloatv(GL_MODELVIEW_MATRIX, @TmpMatrix.Data);    // Get The Generated Matrix

  // Cel-Shading Code //
  glEnable(GL_TEXTURE_1D);                                                                      // Enable 1D Texturing
  glBindTexture(GL_TEXTURE_1D, shaderTexture);          // Bind Our Texture

  glColor3f(1.0, 1.0, 1.0);                             // Set The Color Of The Model
  glBegin(GL_TRIANGLES);                                // Tell OpenGL That We're Drawing Triangles
    for I :=0 to polyNum-1 do
    begin
      For J :=0 to 2 do
      begin
        TmpNormal.X := PPolygon(polyData+i*sizeof(TPolygon))^.Verts[j].Nor.X;      // Fill Up The TmpNormal Structure With
        TmpNormal.Y := PPolygon(polyData+i*sizeof(TPolygon))^.Verts[j].Nor.Y;      // The Current Vertices' Normal Values
        TmpNormal.Z := PPolygon(polyData+i*sizeof(TPolygon))^.Verts[j].Nor.Z;

        RotateVector(TmpMatrix, TmpNormal, TmpVector);  // Rotate This By The Matrix
        Normalize(TmpVector);                                                   // Normalize The New Normal
        TmpShade := DotProduct(TmpVector, lightAngle);  // Calculate The Shade Value

        if TmpShade < 0.0 then
           TmpShade := 0.0;                             // Clamp The Value to 0 If Negative

        glTexCoord1f(TmpShade);                         // Set The Texture Co-ordinate As The Shade Value
        glVertex3fv(@PPolygon(polyData+i*sizeof(TPolygon))^.Verts[j].Pos);         // Send The Vertex Position
      end;
    end;
  glEnd();                                                                                                      // Tell OpenGL To Finish Drawing

  glDisable(GL_TEXTURE_1D);                     // Disable 1D Textures

  // Outline Code //
  if outlineDraw then                           // Check To See If We Want To Draw The Outline
  begin
    glEnable(GL_BLEND);                         // Enable Blending
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);   // Set The Blend Mode

    glPolygonMode(GL_BACK, GL_LINE);            // Draw Backfacing Polygons As Wireframes
    glLineWidth(outlineWidth);                  // Set The Line Width
    glCullFace(GL_FRONT);                       // Don't Draw Any Front-Facing Polygons
    glDepthFunc(GL_LEQUAL);                     // Change The Depth Mode
    glColor3fv(@outlineColor);                  // Set The Outline Color

    glBegin(GL_TRIANGLES);                      // Tell OpenGL What We Want To Draw
      for I :=0 to polyNum-1 do                 // Loop Through Each Polygon
        for J :=0 to 2 do                       // Loop Through Each Vertex
         glVertex3fv(@PPolygon(polyData+i*sizeof(TPolygon))^.Verts[j].Pos);// Send The Vertex Position
    glEnd();                                                                                            // Tell OpenGL We've Finished

    glDepthFunc(GL_LESS);                       // Reset The Depth-Testing Mode
    glCullFace(GL_BACK);                        // Reset The Face To Be Culled
    glPolygonMode(GL_BACK, GL_FILL);            // Reset Back-Facing Polygon Drawing Mode
    glDisable(GL_BLEND);                        // Disable Blending
  end;

  if modelRotate then                           // Check To See If Rotation Is Enabled
    modelAngle := modelAngle + (ElapsedTime - LastUpdate)/10;  // Update Angle Based On The Clock
  LastUpdate :=ElapsedTime;
end;


{------------------------------------------------------------------}
{  Initialise OpenGL                                               }
{------------------------------------------------------------------}
procedure glInit;
var F : Text;
    I : Integer;
    shaderData : Array[0..31, 0..2] of glFloat;
begin
  glClearColor(0.7, 0.7, 0.7, 0.0);     // Light Grey Background
  glShadeModel(GL_SMOOTH);              // Enables Smooth Color Shading
  glDisable(GL_LINE_SMOOTH);            // Initially Disable Line Smoothing
  glClearDepth(1.0);                    // Depth Buffer Setup
  glEnable(GL_DEPTH_TEST);              // Enable Depth Buffer
  glDepthFunc(GL_LESS);                 // The Type Of Depth Test To Do

  glEnable(GL_CULL_FACE);               // Enable OpenGL Face Culling
  glDisable(GL_LIGHTING);               // Disable OpenGL Lighting

  Assign(F, 'Data\shader.txt');
{$I-}
  Reset(F);
{$I+}
  if IOResult <> 0 then
    exit;

  for I :=0 to 31 do                    // Loop Though The 32 Greyscale Values
  begin
    if EOF(F) then                      // Check For The End Of The File
      Break;
    Readln(F, shaderData[i][0]);
    shaderData[i][1] :=shaderData[i][0];
    shaderData[i][2] :=shaderData[i][0];
  end;
  Close(F);

  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);    // Realy Nice perspective calculations

  glEnable(GL_TEXTURE_1D);                              // Enable Texture Mapping
  glGenTextures(1, shaderTexture);                      // Get A Free Texture ID
  glBindTexture(GL_TEXTURE_1D, shaderTexture);          // Bind This Texture. From Now On It Will Be 1D

  // For Crying Out Loud Don't Let OpenGL Use Bi/Trilinear Filtering!
  glTexParameteri (GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri (GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

  glTexImage1D(GL_TEXTURE_1D, 0, GL_RGB, 32, 0, GL_RGB , GL_FLOAT, @shaderData);        // Upload

  lightAngle.X := 0.0;                  // Set The X Direction
  lightAngle.Y := 0.0;                  // Set The Y Direction
  lightAngle.Z := 1.0;                  // Set The Z Direction
  Normalize(lightAngle);                // Normalize The Light Direction

  ReadMesh;                             // Return The Value Of ReadMesh
end;


{------------------------------------------------------------------}
{  Handle window resize                                            }
{------------------------------------------------------------------}
procedure glResizeWnd(Width, Height : Integer);
begin
  if (Height = 0) then                // prevent divide by zero exception
    Height := 1;
  glViewport(0, 0, Width, Height);    // Set the viewport for the OpenGL window
  glMatrixMode(GL_PROJECTION);        // Change Matrix Mode to Projection
  glLoadIdentity();                   // Reset View
  gluPerspective(45.0, Width/Height, 1.0, 100.0);  // Do the perspective calculations. Last value = max clipping depth

  glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
  glLoadIdentity();                   // Reset View
end;


{------------------------------------------------------------------}
{  Processes all the keystrokes                                    }
{------------------------------------------------------------------}
procedure ProcessKeys;
begin
  if (keys[VK_SPACE]) then
  begin
    modelRotate := NOT(modelRotate);    // Toggle Model Rotation On/Off
    keys[VK_SPACE] :=FALSE;
  end;

  if (keys[Ord('1')]) then
  begin
    outlineDraw := NOT(outlineDraw);    // Toggle Outline Drawing On/Off
    keys[Ord('1')] :=FALSE;
  end;

  if (keys[Ord('2')]) then
  begin
    outlineSmooth := NOT(outlineSmooth);// Toggle Outline Drawing On/Off
    keys[Ord('2')] :=FALSE;
  end;

  if (keys[VK_UP]) then
  begin
    Inc(outlineWidth);                  // Increase Line Width
    keys[VK_UP] :=FALSE;
  end;

  if (keys[VK_DOWN]) then
  begin
    Dec(outlineWidth);                  // Decrease Line Width
    keys[VK_DOWN] :=FALSE;
  end;

end;


{------------------------------------------------------------------}
{  Determines the application’s response to the messages received  }
{------------------------------------------------------------------}
function WndProc(hWnd: HWND; Msg: UINT;  wParam: WPARAM;  lParam: LPARAM): LRESULT; stdcall;
var
  Buff: array[0..MAX_PATH] of Char;
begin
  case (Msg) of
    WM_CREATE:
      begin
        // Insert stuff you want executed when the program starts
      end;
    WM_CLOSE:
      begin
        PostQuitMessage(0);
        Result := 0
      end;
    WM_KEYDOWN:       // Set the pressed key (wparam) to equal true so we can check if its pressed
      begin
        keys[wParam] := True;
        Result := 0;
      end;
    WM_KEYUP:         // Set the released key (wparam) to equal false so we can check if its pressed
      begin
        keys[wParam] := False;
        Result := 0;
      end;
    WM_SIZE:          // Resize the window with the new width and height
      begin
        glResizeWnd(LOWORD(lParam),HIWORD(lParam));
        Result := 0;
      end;
    WM_TIMER :                     // Add code here for all timers to be used.
      begin
        if wParam = FPS_TIMER then
        begin
          FPSCount :=Round(FPSCount * 1000/FPS_INTERVAL);   // calculate to get per Second incase intercal is less or greater than 1 second
          SetWindowText(h_Wnd, StrPCopy(Buff, WND_TITLE + '   [' + intToStr(FPSCount) + ' FPS]'));
          FPSCount := 0;
          Result := 0;
        end;
      end;
    else
      Result := DefWindowProc(hWnd, Msg, wParam, lParam);    // Default result if nothing happens
  end;
end;


{---------------------------------------------------------------------}
{  Properly destroys the window created at startup (no memory leaks)  }
{---------------------------------------------------------------------}
procedure glKillWnd(Fullscreen : Boolean);
begin
  if Fullscreen then             // Change back to non fullscreen
  begin
    ChangeDisplaySettings(TDeviceMode(nil^), 0);
    ShowCursor(True);
  end;

  // Makes current rendering context not current, and releases the device
  // context that is used by the rendering context.
  if (not wglMakeCurrent(h_DC, 0)) then
    MessageBox(0, 'Release of DC and RC failed!', 'Error', MB_OK or MB_ICONERROR);

  // Attempts to delete the rendering context
  if (not wglDeleteContext(h_RC)) then
  begin
    MessageBox(0, 'Release of rendering context failed!', 'Error', MB_OK or MB_ICONERROR);
    h_RC := 0;
  end;

  // Attemps to release the device context
  if ((h_DC = 1) and (ReleaseDC(h_Wnd, h_DC) <> 0)) then
  begin
    MessageBox(0, 'Release of device context failed!', 'Error', MB_OK or MB_ICONERROR);
    h_DC := 0;
  end;

  // Attempts to destroy the window
  if ((h_Wnd <> 0) and (not DestroyWindow(h_Wnd))) then
  begin
    MessageBox(0, 'Unable to destroy window!', 'Error', MB_OK or MB_ICONERROR);
    h_Wnd := 0;
  end;

  // Attempts to unregister the window class
  if (not UnRegisterClass('OpenGL', hInstance)) then
  begin
    MessageBox(0, 'Unable to unregister window class!', 'Error', MB_OK or MB_ICONERROR);
    hInstance := 0;
  end;
end;


{--------------------------------------------------------------------}
{  Creates the window and attaches a OpenGL rendering context to it  }
{--------------------------------------------------------------------}
function glCreateWnd(Width, Height : Integer; Fullscreen : Boolean; PixelDepth : Integer) : Boolean;
var
  wndClass : TWndClass;         // Window class
  dwStyle : DWORD;              // Window styles
  dwExStyle : DWORD;            // Extended window styles
  dmScreenSettings : TDeviceMode;   // Screen settings (fullscreen, etc...)
  PixelFormat : GLuint;         // Settings for the OpenGL rendering
  h_Instance : HINST;           // Current instance
  pfd : TPIXELFORMATDESCRIPTOR;  // Settings for the OpenGL window
begin
  h_Instance := GetModuleHandle(nil);       //Grab An Instance For Our Window
  ZeroMemory(@wndClass, SizeOf(wndClass));  // Clear the window class structure

  with wndClass do                    // Set up the window class
  begin
    style         := CS_HREDRAW or    // Redraws entire window if length changes
                     CS_VREDRAW or    // Redraws entire window if height changes
                     CS_OWNDC;        // Unique device context for the window
    lpfnWndProc   := @WndProc;        // Set the window procedure to our func WndProc
    hInstance     := h_Instance;
    hCursor       := LoadCursor(0, IDC_ARROW);
    lpszClassName := 'OpenGL';
  end;

  if (RegisterClass(wndClass) = 0) then  // Attemp to register the window class
  begin
    MessageBox(0, 'Failed to register the window class!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit
  end;

  // Change to fullscreen if so desired
  if Fullscreen then
  begin
    ZeroMemory(@dmScreenSettings, SizeOf(dmScreenSettings));
    with dmScreenSettings do begin              // Set parameters for the screen setting
      dmSize       := SizeOf(dmScreenSettings);
      dmPelsWidth  := Width;                    // Window width
      dmPelsHeight := Height;                   // Window height
      dmBitsPerPel := PixelDepth;               // Window color depth
      dmFields     := DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL;
    end;

    // Try to change screen mode to fullscreen
    if (ChangeDisplaySettings(dmScreenSettings, CDS_FULLSCREEN) = DISP_CHANGE_FAILED) then
    begin
      MessageBox(0, 'Unable to switch to fullscreen!', 'Error', MB_OK or MB_ICONERROR);
      Fullscreen := False;
    end;
  end;

  // If we are still in fullscreen then
  if (Fullscreen) then
  begin
    dwStyle := WS_POPUP or                // Creates a popup window
               WS_CLIPCHILDREN            // Doesn't draw within child windows
               or WS_CLIPSIBLINGS;        // Doesn't draw within sibling windows
    dwExStyle := WS_EX_APPWINDOW;         // Top level window
    ShowCursor(False);                    // Turn of the cursor (gets in the way)
  end
  else
  begin
    dwStyle := WS_OVERLAPPEDWINDOW or     // Creates an overlapping window
               WS_CLIPCHILDREN or         // Doesn't draw within child windows
               WS_CLIPSIBLINGS;           // Doesn't draw within sibling windows
    dwExStyle := WS_EX_APPWINDOW or       // Top level window
                 WS_EX_WINDOWEDGE;        // Border with a raised edge
  end;

  // Attempt to create the actual window
  h_Wnd := CreateWindowEx(dwExStyle,      // Extended window styles
                          'OpenGL',       // Class name
                          WND_TITLE,      // Window title (caption)
                          dwStyle,        // Window styles
                          0, 0,           // Window position
                          Width, Height,  // Size of window
                          0,              // No parent window
                          0,              // No menu
                          h_Instance,     // Instance
                          nil);           // Pass nothing to WM_CREATE
  if h_Wnd = 0 then
  begin
    glKillWnd(Fullscreen);                // Undo all the settings we've changed
    MessageBox(0, 'Unable to create window!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Try to get a device context
  h_DC := GetDC(h_Wnd);
  if (h_DC = 0) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to get a device context!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Settings for the OpenGL window
  with pfd do
  begin
    nSize           := SizeOf(TPIXELFORMATDESCRIPTOR); // Size Of This Pixel Format Descriptor
    nVersion        := 1;                    // The version of this data structure
    dwFlags         := PFD_DRAW_TO_WINDOW    // Buffer supports drawing to window
                       or PFD_SUPPORT_OPENGL // Buffer supports OpenGL drawing
                       or PFD_DOUBLEBUFFER;  // Supports double buffering
    iPixelType      := PFD_TYPE_RGBA;        // RGBA color format
    cColorBits      := PixelDepth;           // OpenGL color depth
    cRedBits        := 0;                    // Number of red bitplanes
    cRedShift       := 0;                    // Shift count for red bitplanes
    cGreenBits      := 0;                    // Number of green bitplanes
    cGreenShift     := 0;                    // Shift count for green bitplanes
    cBlueBits       := 0;                    // Number of blue bitplanes
    cBlueShift      := 0;                    // Shift count for blue bitplanes
    cAlphaBits      := 0;                    // Not supported
    cAlphaShift     := 0;                    // Not supported
    cAccumBits      := 0;                    // No accumulation buffer
    cAccumRedBits   := 0;                    // Number of red bits in a-buffer
    cAccumGreenBits := 0;                    // Number of green bits in a-buffer
    cAccumBlueBits  := 0;                    // Number of blue bits in a-buffer
    cAccumAlphaBits := 0;                    // Number of alpha bits in a-buffer
    cDepthBits      := 16;                   // Specifies the depth of the depth buffer
    cStencilBits    := 0;                    // Turn off stencil buffer
    cAuxBuffers     := 0;                    // Not supported
    iLayerType      := PFD_MAIN_PLANE;       // Ignored
    bReserved       := 0;                    // Number of overlay and underlay planes
    dwLayerMask     := 0;                    // Ignored
    dwVisibleMask   := 0;                    // Transparent color of underlay plane
    dwDamageMask    := 0;                     // Ignored
  end;

  // Attempts to find the pixel format supported by a device context that is the best match to a given pixel format specification.
  PixelFormat := ChoosePixelFormat(h_DC, @pfd);
  if (PixelFormat = 0) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to find a suitable pixel format', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Sets the specified device context's pixel format to the format specified by the PixelFormat.
  if (not SetPixelFormat(h_DC, PixelFormat, @pfd)) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to set the pixel format', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Create a OpenGL rendering context
  h_RC := wglCreateContext(h_DC);
  if (h_RC = 0) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to create an OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Makes the specified OpenGL rendering context the calling thread's current rendering context
  if (not wglMakeCurrent(h_DC, h_RC)) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to activate OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Initializes the timer used to calculate the FPS
  SetTimer(h_Wnd, FPS_TIMER, FPS_INTERVAL, nil);

  // Settings to ensure that the window is the topmost window
  ShowWindow(h_Wnd, SW_SHOW);
  SetForegroundWindow(h_Wnd);
  SetFocus(h_Wnd);

  // Ensure the OpenGL window is resized properly
  glResizeWnd(Width, Height);
  glInit();

  Result := True;
end;


{--------------------------------------------------------------------}
{  Main message loop for the application                             }
{--------------------------------------------------------------------}
function WinMain(hInstance : HINST; hPrevInstance : HINST;
                 lpCmdLine : PChar; nCmdShow : Integer) : Integer; stdcall;
var
  msg : TMsg;
  finished : Boolean;
  DemoStart, LastTime : DWord;
begin
  finished := False;

  // Perform application initialization:
  if not glCreateWnd(800, 600, FALSE, 32) then
  begin
    Result := 0;
    Exit;
  end;

  DemoStart := GetTickCount();            // Get Time when demo started

  // Main message loop:
  while not finished do
  begin
    if (PeekMessage(msg, 0, 0, 0, PM_REMOVE)) then // Check if there is a message for this window
    begin
      if (msg.message = WM_QUIT) then     // If WM_QUIT message received then we are done
        finished := True
      else
      begin                               // Else translate and dispatch the message to this window
        TranslateMessage(msg);
        DispatchMessage(msg);
      end;
    end
    else
    begin
      Inc(FPSCount);                      // Increment FPS Counter

      LastTime :=ElapsedTime;
      ElapsedTime :=GetTickCount() - DemoStart;     // Calculate Elapsed Time
      ElapsedTime :=(LastTime + ElapsedTime) DIV 2; // Average it out for smoother movement

      glDraw();                           // Draw the scene
      SwapBuffers(h_DC);                  // Display the scene

      if (keys[VK_ESCAPE]) then           // If user pressed ESC then set finised TRUE
        finished := True
      else
        ProcessKeys;                      // Check for any other key Pressed
    end;
  end;
  glKillWnd(FALSE);
  Result := msg.wParam;
end;


begin
  WinMain( hInstance, hPrevInst, CmdLine, CmdShow );
end.
