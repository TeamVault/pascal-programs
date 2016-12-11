{************************************************}
{                                                }
{   ObjectWindows Paint demo                     }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit ToolBar;

{ This unit defines a tool bar window for the paint program.
  The toolbar is responsible for the management of the available tools
  and displays the icons for the available tools. Selection of the current
  tool is handled here.
}

interface

uses PaintDef, Tools, WinTypes, WinProcs, OWindows;

type
  { All available tools }
  ToolName = (PenTool, LineTool,
              FillTool,	                { ordering defines the layout of }
              ORectTool, FRectTool,     { the display of icons }
              OEllipseTool, FEllipseTool,
              EraserTool, SelectTool);

const
  MinTool = PenTool;
  MaxTool = SelectTool;

type
  PToolBar = ^TToolBar;
  TToolBar = object(TWindow)
    State: PState;			{ communication among modules }
    Tools: array[ToolName] of PPaintTool; { tools available }

    { Creation and destruction }
    constructor Init(AParent: PWindowsObject; AState: PState);
    destructor Done; virtual;

    { Utility }
    procedure ToolSelect(Tool: ToolName);

    { Display } 
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;

    { Window manager responses }
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
  end;

implementation

{ Create the actual toolbar and a new instance of each tool it is to contain.
}
constructor TToolBar.Init(AParent: PWindowsObject; AState: PState);
begin
  TWindow.Init(AParent, nil);
  Attr.Style := ws_Child or ws_Visible;
  State := AState;
  Tools[PenTool] := New(PPenTool, Init(AState, 'PenTool', 'PenCursor'));
  Tools[LineTool] := New(PLineTool, Init(AState, 'LineTool', 'PenCursor', False));
  Tools[FillTool] := New(PFillTool, Init(AState, 'FillTool', 'FillCursor'));
  Tools[ORectTool] := New(PRectTool, Init(AState, 'RectTool', 'CrossCursor', False));
  Tools[FRectTool] := New(PRectTool, Init(AState, 'FillRectTool', 'CrossCursor', True));
  Tools[OEllipseTool] := New(PEllipseTool, Init(AState, 'EllipseTool', 'CrossCursor', False));
  Tools[FEllipseTool] := New(PEllipseTool, Init(AState, 'FillEllipseTool', 'CrossCursor', True));
  Tools[EraserTool] := New(PEraserTool, Init(AState, 'EraserTool', 'EraserCursor'));
  Tools[SelectTool] := New(PSelectTool, Init(AState, 'SelectTool', 'CrossCursor', False));
  Tools[PenTool]^.Select;
end;

{ Destroy each tool instance befory dying.
}
destructor TToolBar.Done;
var
  Tool: ToolName;
begin
  for Tool := MinTool to MaxTool do Dispose(Tools[Tool], Done);
  TWindow.Done;
end;

{ Deselect the current tool and select the new tool and update the display.
}
procedure TToolBar.ToolSelect(Tool: ToolName);
begin
  State^.PaintTool^.Deselect;
  Tools[Tool]^.Select;
  InvalidateRect(HWindow, nil, False);
end;

{ Paint the toolbar by painting the icon for each tool horizontally. The icon
  for the currently selected tool is highlighted. Note that icons are 32x32,
  but overlap by one pixel.
}
procedure TToolBar.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  I: Integer;		{ Position of tool in row of icons }
  Tool: ToolName;	{ Current tool being drawn }
  R: TRect;		{ Coordinates of icon }
begin
  for Tool := MinTool to MaxTool do
  begin
    I := Ord(Tool);
    DrawIcon(PaintDC, I * 31, 0, Tools[Tool]^.Icon);
    
    { Highlight currently selected tool }
    if Tools[Tool] = State^.PaintTool then
    begin
      R.top := 1;
      R.left := I * 31 + 1;
      R.bottom := R.top + 30;
      R.right := r.left + 30;
      InvertRect(PaintDC, R);
    end;
  end;
end;

{ Select the tool whose icon is pressed.
}
procedure TToolBar.WMLButtonDown(var Msg: TMessage);
var
  Tool: ToolName;
begin
  Tool := ToolName(Msg.LParamLo div 31);
  if Tool <= MaxTool then ToolSelect(Tool);
end;

end.
