{************************************************}
{                                                }
{   ObjectWindows Paint demo                     }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit PaintDef;

{ This unit supplies the basic definitions used by all modules of the
  paint program, as well as a few utility routines dealing mainly
  with common dialogs.
}

interface

uses ResDef, OStdDlgs, WinTypes, WinProcs, Objects;

var 
  DashedPen: HPen;

type

  PPaintTool = ^TPaintTool;

  { The state object is used for communication among modules of the
    paint program. It records the state of drawing, i.e., what has
    been drawn, what colors, pen, brush, etc. are selected, what the
    current screen selection is, etc. Only one state object should
    exist for each paint screen.
  }

  PState = ^TState;
  TState = record
    PaintTool: PPaintTool;      { Tool currently in use }
    MemDC: HDC;			{ Display contex with the offscreen Bitmap }
    Offset: TPoint;		{ Offset of Bitmap origin relative to screen }
    BitmapSize: TPoint;	        { Size of current bitmap }
    IsDirtyBitmap: Boolean;  	{ Records when the Bitmap has been modified }
    Selection: TRect;           { Coordinates of current screen selection }
    SelectionBM: HBitmap;       { Contents of current screen selection }
    PenSize: Integer;           { Current line width selected }
    PenColor: TColorRef;        { Current line color selected }
    BrushColor: TColorRef;      { Current fill color selected }
  end;


  { Paint tools are the basic entities that cause painting to be done
    in the paint program. PaintTool defines the interface required by
    all PaintTools, but no implementation (save initialization).
  }

  TPaintTool = object(TObject)
    Icon: HIcon;                { Icon associated with tool }
    Cursor: HCursor;            { Cursor to be displayed when tool is
                                  in use }
    State: PState;              { Current state of drawing }
    Window: HWnd;               { Window tool is operating on }
    DC: HDC;                    { Screen display context to be operated on }

    { Creation and activation }
    constructor Init(AState: PState; IconName, CursorName: PChar);
    procedure Select; virtual;
    procedure Deselect; virtual;

    { Actions initiated by mouse action }
    procedure MouseDown(AWindow: HWnd; X, Y: Integer;
      AState: PState); virtual;
    procedure MouseMove(X, Y: Integer); virtual;
    procedure MouseUp; virtual;
    procedure DrawBegin(X, Y: Integer); virtual;
    procedure DrawTo(X, Y: Integer); virtual;
    procedure DrawEnd; virtual;

    { Utility routines used by mouse actions }
    procedure PickUpSelection(aDC: HDC; Left, Top, aWidth, aHeight: Integer);
      virtual;
    procedure ReleaseSelection; virtual;
    procedure DropSelection; virtual;

    { Actions initiated by keyboard }
    procedure Char(Key, Count, lParamHi: Word); virtual;
  end;

{ Utility routines }

{ Dialog Interactions }

{ Display a message in a dialog with certain standard buttons.
}
function Ask(Quest: PChar): Boolean;            { Yes/No }
function AskCancel(Quest: PChar): Integer;      { Yes/No/Cancel }
function Confirm(Msg: PChar): Boolean;          { Ok/Cancel }
procedure Tell(Msg: PChar);                     { Ok }

{ 
  Display standard file dialogs. Path may contain a mask (e.g.,
  '*.pas') and contains full path name on return. Function return
  value is True if file was selected, False on Cancel. 
}
function FileOpenDialog(Path: PChar): Boolean;  { File open }
function FileSaveDialog(Path: PChar): Boolean;  { Filename selection }

{ Other }
function CreateCompatibleDCW(HWindow: Hwnd): HDC;

implementation

uses OWindows;

{ TPaintTool }

{ Default initialization of a Paint Tool.
}
constructor TPaintTool.Init(AState: PState; IconName, CursorName: PChar);
begin
  TObject.Init;
  State := AState;
  Icon := LoadIcon(HInstance, IconName);
  Cursor := LoadCursor(HInstance, CursorName);
end;

{ Set up the paint tool to be the currently used tool.
}
procedure TPaintTool.Select;
begin
  State^.PaintTool := @Self;
end;

{
  Prepare the paint tool to no longer be the currently used tool.
}
procedure TPaintTool.Deselect;
begin
end;

{ Actions initiated by mouse actions. }

{ Action to be taken when the mouse button is pressed down (and the
  tool is the currently used tool).
}
procedure TPaintTool.MouseDown(AWindow: HWnd; X, Y: Integer;
  AState: PState);
begin
end;

{ Action to be taken when the mouse button is down and the mouse is moved.
}
procedure TPaintTool.MouseMove(X, Y: Integer);
begin
end;

{ Action to be taken when the mouse button is released.
}
procedure TPaintTool.MouseUp;
begin
end;

{ Prepare the tool to begin drawing. Used by tools whose actions are
  in response to mouse clicks. Their drawing actions are divided into
  three phases: 1) DrawBegin on mouse down, 2) DrawTo when the mouse
  is moved, and 3) DrawEnd when the mouse is released.
}
procedure TPaintTool.DrawBegin(X, Y: Integer);
begin
end;

{ Perform the tool drawing action.
}
procedure TPaintTool.DrawTo(X, Y: Integer);
begin
end;

{ Prepare the tool to stop drawing.
}
procedure TPaintTool.DrawEnd;
begin
end;


{ Utility routines used by mouse action routines.

{ Prepare the rectangle selected on the screen to be treated as
  a distinct entity. E.g., for dragging or cutting.
}
procedure TPaintTool.PickUpSelection(aDC: HDC; Left, Top, 
                                               aWidth, aHeight: Integer);
begin
end;

{ Release the current selection without modifying the current Bitmap.
}
procedure TPaintTool.ReleaseSelection;
begin
end;

{ Copy the current selection onto the current Bitmap and release the
  selection. 
}
procedure TPaintTool.DropSelection;
begin
end;

{ Action initiated by the keyboard.

{ Action to be taken when a non-system key is pressed. That is, not an
  "alt" or other specially interpreted key-stroke.
}
procedure TPaintTool.Char(Key, Count, lParamHi: Word);
begin
end;

{ Utility routines }

{ Display a message in a dialog box with certain common buttons.
}
{ Yes/No }
function Ask(Quest: PChar): Boolean;
begin
  Ask := MessageBox(0, Quest, '', mb_YesNo) = id_Yes;
end;

{ Yes/No/Cancel }
function AskCancel(Quest: PChar): Integer;
begin
  AskCancel := MessageBox(0, Quest, '', mb_YesNoCancel);
end;

{ Ok/Cancel }
function Confirm(Msg: PChar): Boolean;
begin
  Confirm := MessageBox(0, Msg, '', mb_OkCancel) = id_OK;
end;

{ Ok }
procedure Tell(Msg: PChar);
begin
  MessageBox(0, Msg, '', mb_Ok);
end;


{ File Dialogs }

{ Display a standard file dialog. Path will be filled in with the
  selected filename (full path). Which is a "sd_" constant specifying
  which file dialog to display.
}
function FileDialog(var Path: PChar; Which: PChar): Boolean;
begin
  FileDialog := 
  Application^.ExecDialog(new(PFileDialog, Init(Application^.MainWindow,
    Which, Path))) = id_OK;
end;

{ Standard file open. (Select an existing file.) }
function FileOpenDialog(Path: PChar): Boolean;
begin
  FileOpenDialog := FileDialog(Path, PChar(sd_FileOpen));
end;

{ Standard file save. (Select a new or existing file.) }
function FileSaveDialog(Path: PChar): Boolean;
begin
  FileSaveDialog := FileDialog(Path, PChar(sd_FileSave));
end;

{ Other }

{ Given a window, return a drawing context that is compatible with
  that window.
}
function CreateCompatibleDCW(HWindow: Hwnd): HDC;
var
  DC: HDC;
begin
  DC := GetDC(HWindow);
  CreateCompatibleDCW :=  CreateCompatibleDC(DC);
  ReleaseDC(HWindow, DC);
end;

{ Deal with deinitialization of unit. }
var
  SaveExit: Pointer;

procedure PaintDefExit;
far;
begin
  DeleteObject(DashedPen);
  ExitProc := SaveExit;
end;

{ initialization }
begin
  { A pen that draws a dashed line. }
  DashedPen := CreatePen(ps_Dot, 1, $000000);

  { Set up unit de-initialization }
  SaveExit := ExitProc;
  ExitProc := @PaintDefExit;
end.
