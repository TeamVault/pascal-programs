{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ Simple four function calculator }

program Calc;

{$B-}
{$R CALC.RES}

uses WinTypes, WinProcs, Strings, OWindows, ODialogs;

const

{ Application name }

  AppName: PChar = 'Calc';

{ Number of digits in calculator display }

  DisplayDigits = 15;

{ Control ID of display static text }

  id_Display = 400;

{ Color constants }

  rgb_Yellow = $0000FFFF;
  rgb_Blue   = $00FF0000;
  rgb_Red    = $000000FF;

type

{ Calculator state }

  TCalcState = (cs_First, cs_Valid, cs_Error);

{ Calculator dialog window object }

  PCalc = ^TCalc;
  TCalc = object(TDlgWindow)
    CalcStatus: TCalcState;
    Number: array[0..DisplayDigits] of Char;
    Negative: Boolean;
    Operator: Char;
    Operand: Real;
    BlueBrush: HBrush;
    constructor Init;
    destructor Done; virtual;
    function GetClassName: PChar; virtual;
    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
    procedure WMControlColor(var Msg: TMessage);
      virtual wm_First + wm_CtlColor;
    procedure WMPaint(var Msg: TMessage);
      virtual wm_First + wm_Paint;
    procedure DefChildProc(var Msg: TMessage); virtual;
    procedure DefCommandProc(var Msg: TMessage); virtual;
    procedure FlashButton(Key: Char);
    procedure CalcKey(Key: Char);
    procedure Clear;
    procedure UpdateDisplay; virtual;
  end;

{ Calculator application object }

  TCalcApp = object(TApplication)
    procedure InitMainWindow; virtual;
    procedure InitInstance; virtual;
    function ProcessAppMsg(var Message: TMsg) : Boolean; virtual;
  end;

var

{ Application instance }

  CalcApp: TCalcApp;

{ Calculator constructor.  Create blue brush for calculator background,
  and do a clear command. }

constructor TCalc.Init;
begin
  TDlgWindow.Init(nil, AppName);
  BlueBrush := CreateSolidBrush(rgb_Blue);
  Clear;
end;

{ Calculator destructor.  Dispose the background brush. }

destructor TCalc.Done;
begin
  DeleteObject(BlueBrush);
  TDlgWindow.Done;
end;

{ We're changing the window class so we must supply a new class name. }

function TCalc.GetClassName: PChar;
begin
  GetClassName := AppName;
end;

{ The calculator has its own icon which is installed here. }

procedure TCalc.GetWindowClass(var AWndClass: TWndClass);
begin
  TDlgWindow.GetWindowClass(AWndClass);
  AWndClass.hIcon := LoadIcon(HInstance, AppName);
end;

{ Colorize the calculator.  Allows background to show through corners of
  buttons, uses yellow text on black background in the display, and sets
  the dialog background to blue. }

procedure TCalc.WMControlColor(var Msg: TMessage);
begin
  case Msg.LParamHi of
    ctlColor_Btn:
      Msg.Result := GetStockObject(null_Brush);
    ctlColor_Static:
      begin
        SetTextColor(Msg.WParam, rgb_Yellow);
        SetBkMode(Msg.WParam, transparent);
        Msg.Result := GetStockObject(black_Brush);
      end;
    ctlcolor_Dlg:
      begin
        SetBkMode(Msg.WParam, Transparent);
        Msg.Result := BlueBrush;
      end;
  else
    DefWndProc(Msg);
  end;
end;

{ Even dialogs can have their background's painted on.  This creates
  a red ellipse over the blue background. }

procedure TCalc.WMPaint(var Msg: TMessage);
var
  OldBrush: HBrush;
  OldPen: HPen;
  R: TRect;
  PS: TPaintStruct;
begin
  BeginPaint(HWindow, PS);
  OldBrush := SelectObject(PS.hdc, CreateSolidBrush(rgb_Red));
  OldPen := SelectObject(PS.hdc, GetStockObject(null_Pen));
  GetClientRect(HWindow, R);
  R.bottom := R.right;
  OffsetRect(R, -R.right div 4, -R.right div 4);
  Ellipse(PS.hdc, R.left, R.top, R.right, R.bottom);
  SelectObject(PS.hdc, OldPen);
  DeleteObject(SelectObject(PS.hdc, OldBrush));
  EndPaint(HWindow, PS);
end;

{ Flash a button with the value of Key.  Looks exactly like a
  click of the button with the mouse. }

procedure TCalc.FlashButton(Key: Char);
var
  Button: HWnd;
  Delay: Word;
begin
  if Key = #13 then Key := '=';
  Button := GetDlgItem(HWindow, Integer(UpCase(Key)));
  if Button <> 0 then
  begin
    SendMessage(Button, bm_SetState, 1, 0);
    for Delay := 1 to 30000 do;
    SendMessage(Button, bm_SetState, 0, 0);
  end;
end;

{ Rather then handle each button individually with child ID
  response methods, it is possible to handle them all at
  once with the default child procedure. }

procedure TCalc.DefChildProc(var Msg: TMessage);
begin
  if (Msg.WParamHi = 0) and (Msg.LParamHi = bn_Clicked) then
    CalcKey(Char(Msg.WParamLo));
  TDlgWindow.DefChildProc(Msg);
end;

{ Rather then handle each accelerator individually with
  command ID response methods, it is possible to handle them
  all at once with the default command procedure. }

procedure TCalc.DefCommandProc(var Msg: TMessage);
begin
  if Msg.WParamHi = 0 then
  begin
    FlashButton(Char(Msg.WParamLo)); { flash button as if it were pushed }
    CalcKey(Char(Msg.WParamLo));
  end;
  TDlgWindow.DefCommandProc(Msg);
end;

{ Set Display text to the current value. }

procedure TCalc.UpdateDisplay;
var
  S: array[0..DisplayDigits + 1] of Char;
begin
  if Negative then StrCopy(S, '-') else S[0] := #0;
  SetWindowText(GetDlgItem(HWindow, id_Display), StrCat(S, Number));
end;

{ Clear the calculator. }

procedure TCalc.Clear;
begin
  CalcStatus := cs_First;
  StrCopy(Number, '0');
  Negative := False;
  Operator := '=';
end;

{ Process calculator key. }

procedure TCalc.CalcKey(Key: Char);
var
  R: Real;

  procedure Error;
  begin
    CalcStatus := cs_Error;
    StrCopy(Number, 'Error');
    Negative := False;
  end;

  procedure SetDisplay(R: Real);
  var
    First, Last: PChar;
    S: array[0..63] of Char;
  begin
    Str(R: 0: 10, S);
    First := S;
    Negative := False;
    if S[0] = '-' then
    begin
      Inc(First);
      Negative := True;
    end;
    if StrLen(First) > DisplayDigits + 1 + 10 then Error else
    begin
      Last := StrEnd(First);
      while Last[Word(-1)] = '0' do Dec(Last);
      if Last[Word(-1)] = '.' then Dec(Last);
      StrLCopy(Number, First, Last - First);
    end;
  end;

  procedure GetDisplay(var R: Real);
  var
    E: Integer;
  begin
    Val(Number, R, E);
    if Negative then R := -R;
  end;

  procedure CheckFirst;
  begin
    if CalcStatus = cs_First then
    begin
      CalcStatus := cs_Valid;
      StrCopy(Number, '0');
      Negative := False;
    end;
  end;

  procedure InsertKey;
  var
    L: Integer;
  begin
    L := StrLen(Number);
    if L < DisplayDigits then
    begin
      Number[L] := Key;
      Number[L + 1] := #0;
    end;
  end;

begin
  Key := UpCase(Key);
  if (CalcStatus = cs_Error) and (Key <> 'C') then Key := ' ';
  case Key of
    '0'..'9':
      begin
        CheckFirst;
        if StrComp(Number, '0') = 0 then Number[0] := #0;
        InsertKey;
      end;
    '.':
      begin
        CheckFirst;
        if StrPos(Number, '.') = nil then InsertKey;
      end;
    #8:
      begin
        CheckFirst;
        if StrLen(Number) = 1 then StrCopy(Number, '0')
        else Number[StrLen(Number) - 1] := #0;
      end;
    '_':
      Negative := not Negative;
    '+', '-', '*', '/', '=', '%', #13:
      begin
        if CalcStatus = cs_Valid then
        begin
          CalcStatus := cs_First;
          GetDisplay(R);
          if Key = '%' then
            case Operator of
              '+', '-': R := Operand * R / 100;
              '*', '/': R := R / 100;
            end;
          case Operator of
            '+': SetDisplay(Operand + R);
            '-': SetDisplay(Operand - R);
            '*': SetDisplay(Operand * R);
            '/': if R = 0 then Error else SetDisplay(Operand / R);
          end;
        end;
        Operator := Key;
        GetDisplay(Operand);
      end;
    'C':
      Clear;
  end;
  UpdateDisplay;
end;

{ Create calculator as the application's main window. }

procedure TCalcApp.InitMainWindow;
begin
  MainWindow := New(PCalc, Init);
end;

{ This application loads accelerators so that key input can be used. }

procedure TCalcApp.InitInstance;
begin
  TApplication.InitInstance;
  HAccTable := LoadAccelerators(HInstance, AppName);
end;

{ This is one of the few places where the order of processing of
  messages is important.  The usual order, ProcessDlgMsg,
  ProcessMDIAccels, ProcessAccels, allows an application to define
  accelerators which will not break the keyboard handling in
  child dialogs.  In this case, the dialog is the application.
  If we used the default ProcessAppMsg, then the keyboard
  handler, ProcessDlgMsg, would return true and accelerators
  would not be processed.  In this case, what we are doing is safe
  because we are not defining any accelerators which conflict
  with the Window's keyboard handling for dialogs.  Making this
  change allows us to use keyboard input of the calculator.  Also,
  because this is our app, we know that it is not an MDI app,
  therefore we do not need to call ProcessMDIAccels (although it
  would not hurt to do so). }

function TCalcApp.ProcessAppMsg(var Message: TMsg): Boolean;
begin
  ProcessAppMsg := ProcessAccels(Message) or ProcessDlgMsg(Message);
end;

begin
  CalcApp.Init(AppName);
  CalcApp.Run;
  CalcApp.Done;
end.
