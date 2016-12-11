{***************************************************}
{                                                   }
{   Windows 3.1 MCI API Sound Support               }
{   Demonstration Program                           }
{   Copyright (c) 1992 by Borland International     }
{                                                   }
{***************************************************}

program MCISound;

{ This example demonstrates the use of MCI APIs in Windows 3.1 in an
  OWL application.  You must have a sound board and its device driver
  properly installed under Windows 3.1.

  You may copy one of the .WAV files from the WINDOW subdirectory in
  your system to this example's subdirectory.

  Run the .EXE choose Open from the File menu and select a .WAV file.
  Choose Play from the Options menu and control of the sound is done
  via the Options menu and the scroll bar. The Options menu lets you
  stop/play/pause and resume.  The scrollbar allows random access
  through the waveform while it is playing.

  This example demostrates the use MCI API and use of a callback
}

uses Strings, WinTypes, WinProcs, OWindows, ODialogs, WinDOS, Win31,
  ShellAPI, MMSystem, CommDlg, BWCC;

{$R MCISOUND}

const

{ Resource IDs }

  id_Menu  = 100;
  id_About = 100;
  id_Instr = 101;   { Instructions }
  id_Icon  = 100;

{ Menu command IDs }

  cm_FileOpen   = 201;
  cm_HelpAbout  = 300;
  cm_SoundPlay  = 301;
  cm_SoundPause = 302;

  id_Scroll = 150;  { Scroll bar }
  Timer_Id  = 264;  { Unique timer ID. }

type

{ Filename string }

  TFilename = array[0..255] of Char;

{ Sound Control Scroll Bar }

  PSoundBar = ^TSoundBar;
  TSoundBar = object(TScrollBar)
    WaveRatio  : Integer;
    WaveLength : Longint;
    ElementName: TFilename;

    procedure RePosAndPlay(NewPos: Longint); virtual;

    procedure ScrollSetInfo(WRatio: Integer; WLength: Longint); virtual;
    procedure ScrollSetName(EName: PChar); virtual;

    procedure SBLineUp(var Msg: TMessage);
      virtual nf_First + sb_LineUp;
    procedure SBLineDown(var Msg: TMessage);
      virtual nf_First + sb_LineDown;
    procedure SBPageUp(var Msg: TMessage);
      virtual nf_First + sb_PageUp;
    procedure SBPageDown(var Msg: TMessage);
      virtual nf_First + sb_PageDown;
    procedure SBThumbPosition(var Msg: TMessage);
      virtual nf_First + sb_ThumbPosition;
    procedure SBTop(var Msg: TMessage);
      virtual nf_First + sb_Top;
    procedure SBBottom(var Msg: TMessage);
      virtual nf_First + sb_Bottom;
  end;

{ Application main window }

  PSoundWindow = ^TSoundWindow;
  TSoundWindow = object(TWindow)
    ElementName: TFilename;
    IsRunning  : Boolean;
    Paused     : Boolean;
    TimerGoing : Boolean;
    WaveRatio  : Integer;
    WaveLength : Longint;
    SoundBar   : PSoundBar;

    MciGenParm   : TMCI_Generic_Parms;
    MciOpenParm  : TMCI_Open_Parms;
    MciPlayParm  : TMCI_Play_Parms;
    MciStatusParm: TMCI_Status_Parms;
    MciSetParm   : TMCI_Set_Parms;

    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    destructor  Done; virtual;

    procedure GetDeviceInfo;     virtual;
    procedure StopWave;          virtual;
    procedure UpdateSoundWindow; virtual;

    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
    function  GetClassName: PChar; virtual;
    procedure SetupWindow; virtual;

    procedure MciNotify(var Msg: TMessage);
      virtual wm_First + mm_MCINotify;

    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;

    procedure CMFileOpen(var Msg: TMessage);
      virtual cm_First + cm_FileOpen;
    procedure CMSoundPlay(var Msg: TMessage);
      virtual cm_First + cm_SoundPlay;
    procedure CMSoundPause(var Msg: TMessage);
      virtual cm_First + cm_SoundPause;
    procedure CMHelpAbout(var Msg: TMessage);
      virtual cm_First + cm_HelpAbout;

    procedure WMIdleStuff(var Msg: TMessage);
      virtual wm_First + wm_Timer;
  end;

{ Application object }

  TSoundApp = object(TApplication)
    procedure InitInstance;   virtual;
    procedure InitMainWindow; virtual;
  end;

{ Initialized globals }

const
  DemoTitle  : PChar   = 'MCI Sound Demo Program';
  DeviceID   : Word    = 0;
  FlushNotify: Boolean = FALSE;

{ Global variables }

var
  App: TSoundApp;


{ TSoundBar Methods }

procedure TSoundBar.RePosAndPlay(NewPos: Longint);
var
  MciSeekParm  : TMCI_Seek_Parms;
  MciGenParm   : TMCI_Generic_Parms;
  MciOpenParm  : TMCI_Open_Parms;
  MciPlayParm  : TMCI_Play_Parms;
  MciStatusParm: TMCI_Status_Parms;
  MciSetParm   : TMCI_Set_Parms;
begin
{ Only allow SEEK if playing. }

  if DeviceID = 0 then
    Exit;

{ Close the currently playing wave.
}
  FlushNotify := True;
  MciGenParm.dwCallback := 0;
  mciSendCommand(DeviceID, mci_Stop,  mci_Wait, Longint(@MciGenParm));
  mciSendCommand(DeviceID, mci_Close, mci_Wait, Longint(@MciGenParm));

{ Open the wave again and seek to new position.
}
  MciOpenParm.dwCallback := 0;
  MciOpenParm.wDeviceID  := DeviceID;
  MciOpenParm.wReserved0 := 0;
  MciOpenParm.lpstrDeviceType := nil;
  MciOpenParm.lpstrElementName:= ElementName;
  MciOpenParm.lpstrAlias      := nil;
 
  if mciSendCommand(DeviceID, mci_Open, mci_Wait or mci_Open_Element,
      Longint(@MciOpenParm)) <> 0 then
    MessageBox(HWindow, 'Open Error', DemoTitle, mb_OK)
  else
  begin
    DeviceID := MciOpenParm.wDeviceID;

{ Our time scale is in SAMPLES.
}
    MciSetParm.dwTimeFormat := mci_Format_Samples;
    if mciSendCommand(DeviceID, mci_Set, mci_Set_Time_Format,
        Longint(@MciSetParm)) <> 0 then
      MessageBox(HWindow, 'Set Time Error', DemoTitle, mb_OK)
    else
    begin
{ Compute new position, remember the scrollbar range has been scaled based
  on waveRatio.
}
      MciSeekParm.dwCallback:= 0;
      if (NewPos * WaveRatio) > WaveLength then
        MciSeekParm.dwTo := WaveLength
      else
        MciSeekParm.dwTo := NewPos * WaveRatio;
      
      if mciSendCommand(DeviceID, mci_Seek, mci_To,
          Longint(@MciSeekParm)) <> 0 then
        MessageBox(HWindow, 'Seek Error', DemoTitle, mb_OK)
      else
      begin
	MciPlayParm.dwCallback:= HWindow;
	MciPlayParm.dwFrom    := 0;
	MciPlayParm.dwTo      := 0;
	if mciSendCommand(DeviceID, mci_Play, mci_Notify,
	    Longint(@MciPlayParm)) <> 0 then
          MessageBox(HWindow, 'Play Error', DemoTitle, mb_OK);
      end;
    end;
  end;  { Playing }
end;

{ Sets the given ratio and length as the current WaveRatio and WaveLength
  of the Sound Bar.
}
procedure TSoundBar.ScrollSetInfo(WRatio: Integer; WLength: Longint);
begin
  WaveRatio  := WRatio;
  WaveLength := WLength;
end;

{ Sets the given string as the name of the SoundBar.
}
procedure TSoundBar.ScrollSetName(EName: PChar);
begin
  StrCopy(ElementName, EName);
end;

{ Responds to a click on the Scroll Bar's up-arrow by stepping
  the wave.  Calls on the inherited SBLineUp to do the actual
  update of the scroll bar, then uses the new position for the
  sound.
}
procedure TSoundBar.SBLineUp(var Msg: TMessage);
begin
  TScrollBar.SBLineUp(Msg);
  RePosAndPlay(GetPosition);
end;

{ Responds to a click on the Scroll Bar's down-arrow as above.
}
procedure TSoundBar.SBLineDown(var Msg: TMessage);
begin
  TScrollBar.SBLineDown(Msg);
  RePosAndPlay(GetPosition);
end;

{ Responds to a click on the Scroll Bar's page-up area as above.
}
procedure TSoundBar.SBPageUp(var Msg: TMessage);
begin
  TScrollBar.SBPageUp(Msg);
  RePosAndPlay(GetPosition);
end;

{ Responds to a click on the Scroll Bar's page-down area as above.
}
procedure TSoundBar.SBPageDown(var Msg: TMessage);
begin
  TScrollBar.SBPageDown(Msg);
  RePosAndPlay(GetPosition);
end;

{ Responds to a movement of the Scroll Bar's thumb as above.
}
procedure TSoundBar.SBThumbPosition(var Msg: TMessage);
begin
  TScrollBar.SBThumbPosition(Msg);
  RePosAndPlay(GetPosition);
end;

{ Responds to movement of the scroll bar to the Top as above.
}
procedure TSoundBar.SBTop(var Msg: TMessage);
begin
  TScrollBar.SBTop(Msg);
  RePosAndPlay(GetPosition);
end;

{ Responds to movement of the scroll bar to the Bottom as above.
}
procedure TSoundBar.SBBottom(var Msg: TMessage);
begin
  TScrollBar.SBBottom(Msg);
  RePosAndPlay(GetPosition);
end;


{ TSoundWindow Methods }

{ Constructs an instance of the TSoundWindow, positioning it and setting
  its data fields to their initial values.
}
constructor TSoundWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  TWindow.Init(AParent, ATitle);

  Attr.X := 50;
  Attr.Y := 100;
  Attr.W := 400;
  Attr.H := 150;

  IsRunning  := False;
  Paused     := False;
  WaveLength := 0;
  WaveRatio  := 0;
  StrCopy(ElementName, '');

  SoundBar := New(PSoundBar, Init(@Self, id_Scroll, 50, 50, 300, 0, True));
  SoundBar^.SetRange(0, 0);
end;

{ Destroys an instance of the Sound Window.  Before calling the ancestral
  destructor to remove the object, stops the current wave.
}
destructor TSoundWindow.Done;
begin
  StopWave;
  TWindow.Done;
end;


{ Repaints the window, posting information about the current sound.
}
procedure TSoundWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  Buffer: array [0..100] of Char;
begin
{ File Name }
  if StrLen(ElementName) > 0 then
    TextOut(PaintDC, 5, 5, ElementName, StrLen(ElementName))
  else
    TextOut(PaintDC, 5, 5, '<No WAVEFORM file loaded>', 25);

{ Beginning value }
  TextOut (PaintDC, 50, 30, '0', 1);

{ Ending number of samples }
  if WaveLength <> 0 then
    Str(WaveLength * WaveRatio, Buffer)
  else
    StrCopy(Buffer, 'Unknown');
  TextOut(PaintDC, 325, 30, Buffer, StrLen(Buffer));
end;

{ Redefines GetWindowClass to give this application an icon and a menu.
}
procedure TSoundWindow.GetWindowClass(var AWndClass: TWndClass);
begin
  TWindow.GetWindowClass(AWndClass);
  AWndClass.lpszMenuName := PChar(id_Menu);
end;

{ Returns the class name of this window.  This is necessary since we
  redefine the inherited GetWindowClass method, above.
}
function TSoundWindow.GetClassName: PChar;
begin
  GetClassName := 'SoundPlay';
end;

{ Completes the initialization of the Window, performing
  those functions which require a valid window handle. 
}
procedure TSoundWindow.SetupWindow;
begin
  TWindow.SetupWindow;
  if WaveOutGetNumDevs = 0 then
  begin
    MessageBox(HWindow, 'No Wave Output device is available', 'Sound Demo',
      mb_OK or mb_IconStop);
    PostQuitMessage(0);
  end;
end;

{ Obtains information about the system's sound generating capabilities.
}
procedure TSoundWindow.GetDeviceInfo;
var
  WOutCaps: TWaveOutCaps;
begin
  if WaveOutGetDevCaps(DeviceID, @WOutCaps, SizeOf(WOutCaps)) <> 0 then
    MessageBox(HWindow, 'GetDevCaps Error', 'Sound Demo', mb_OK);
end;


{ Plays the wave on request.
}
procedure TSoundWindow.CMSoundPlay(var Msg: TMessage);
var
  MyMenu : HMenu;
  Res    : Longint;
  ErrMsg : array [0..255] of Char;
begin
  if not IsRunning then
  begin
{ MCI APIs to open a device and play a .WAV file, using notification to close
}
    MciOpenParm.dwCallback := 0;
    MciOpenParm.wDeviceID  := 0;
    MciOpenParm.wReserved0 := 0;
    MciOpenParm.lpstrDeviceType  := nil;
    MciOpenParm.lpstrElementName := ElementName;
    MciOpenParm.lpstrAlias       := nil;

    if mciSendCommand(0, mci_Open, (mci_Wait or mci_Open_Element),
        Longint(@MciOpenParm)) <> 0 then
      MessageBox(HWindow, 'Open Error - A waveForm output device is ' +
          'necessary to use this demo.', 'Sound Demo', mb_OK)
    else
    begin
      DeviceID := MciOpenParm.wDeviceID;

{ The time format in this demo is in Samples.
}
      MciSetParm.dwCallback   := 0;
      MciSetParm.dwTimeFormat := mci_Format_Samples;
      if mciSendCommand(DeviceID, mci_Set, mci_Set_Time_Format,
	  Longint(@MciSetParm)) <> 0 then
      begin
        StopWave;
	MessageBox(HWindow, 'SetTime Error', 'Sound Demo', mb_OK)
      end
      else
      begin
        MciPlayParm.dwCallback := HWindow;
        MciPlayParm.dwFrom     := 0;
        MciPlayParm.dwTo       := 0;

	Res := mciSendCommand(DeviceID, mci_Play, mci_Notify,
	  Longint(@MciPlayParm));
        if Res <> 0 then
        begin
          mciGetErrorString(Res, ErrMsg, SizeOf(ErrMsg));
	  MessageBox(HWindow, ErrMsg, 'Sound Demo', mb_OK or mb_IconStop);
          StopWave;
        end
        else
        begin
{ Modify the menu to toggle PLAY to STOP, and enable PAUSE.
}
          MyMenu := GetMenu(HWindow);
          ModifyMenu(MyMenu, cm_SoundPlay, mf_String, cm_SoundPlay, '&Stop');
	  EnableMenuItem(MyMenu, cm_SoundPause, mf_Enabled);

{ Make sure the Play/Stop toggle menu knows we're running.
}
	  IsRunning := True; 

{ Start a timer to show our progress through the waveform file.
}
          TimerGoing := (SetTimer(HWindow, Timer_Id, 500, nil) <> 0);

{ Give enough information to the scrollbar to monitor the progress and issue a re-mci_Open.
}
          SoundBar^.ScrollSetName(ElementName);
        end;
      end;
    end;
  end
  else
  begin
{ Stop menu is toggled so kill the timer and stop the wave.
}
    KillTimer(HWindow, Timer_Id);
    StopWave;
  end;
end;

{ Pauses or resumes the playback in response to requests to do so from
  the menu.  The File | Pause selection acts as a toggle.
}
procedure TSoundWindow.CMSoundPause(var Msg: TMessage);
var
  MyMenu: HMenu;
begin
  MyMenu := GetMenu(HWindow);

  if not Paused then
  begin       { Pause the playing. }
    MciGenParm.dwCallback := 0;
    mciSendCommand(DeviceID, mci_Pause, mci_Wait, Longint(@MciGenParm));

    ModifyMenu(MyMenu, cm_SoundPause, mf_String, cm_SoundPause,
      '&Resume'^I'Ctrl+P');
  end
  else
  begin       { Resume the playing. }
    MciGenParm.dwCallback := 0;
    mciSendCommand(DeviceID, mci_Resume, mci_Wait, Longint(@MciGenParm));

    ModifyMenu(MyMenu, cm_SoundPause, mf_String, cm_SoundPause,
      'P&ause'^I'Ctrl+P');
  end;

  Paused := not Paused;
end;

{ Posts the About Box for the Sound Demo.
}
procedure TSoundWindow.CMHelpAbout(var Msg: TMessage);
begin
  Application^.ExecDialog(New(PDialog, Init(@Self, PChar(id_About))));
end;

{ Stops the playing waveform file, and closes the waveform device.
}
procedure TSoundWindow.StopWave;
var
  MyMenu: HMenu;
begin
  if DeviceID <> 0 then
  begin
    MciGenParm.dwCallback := 0;
    mciSendCommand(DeviceID, mci_Stop,  mci_Wait, Longint(@MciGenParm));
    mciSendCommand(DeviceID, mci_Close, mci_Wait, Longint(@MciGenParm));

{ Reset the menus to Play menu and gray the Pause menu.
}
    MyMenu := GetMenu(HWindow);
    ModifyMenu(MyMenu, cm_SoundPlay,  mf_String, cm_SoundPlay,
      '&Play'^I'Ctrl+P');
    ModifyMenu(MyMenu, cm_SoundPause, mf_String or mf_Grayed, cm_SoundPause,
      'P&ause'^I'Ctrl+A');

    IsRunning := FALSE;
    DeviceID  := 0;
  end;
end;

{ Posts the file open dialog, gets a wave file name, and updates the sound
  window to use it.
}
procedure TSoundWindow.CMFileOpen(var Msg: TMessage);
const
  DefExt = 'wav';
var
  OpenFN   : TOpenFileName;
  Filter   : array [0..100] of Char;
  FileName : TFilename;
  WinDir   : array [0..145] of Char;
  MyMenu   : HMenu;
begin
  GetWindowsDirectory(WinDir, SizeOf(WinDir));
  SetCurDir(WinDir);
  StrCopy(FileName, '');

{ Set up a filter buffer to look for Wave files only.  Recall that filter
  buffer is a set of string pairs, with the last one terminated by a
  double-null.
}
  FillChar(Filter, SizeOf(Filter), #0);  { Set up for double null at end }
  StrCopy(Filter, 'Wave Files');
  StrCopy(@Filter[StrLen(Filter)+1], '*.wav');

  FillChar(OpenFN, SizeOf(TOpenFileName), #0);

  with OpenFN do
  begin
    hInstance     := HInstance;
    hwndOwner     := HWindow;
    lpstrDefExt   := DefExt;
    lpstrFile     := ElementName;
    lpstrFilter   := Filter;
    lpstrFileTitle:= nil;     {Title not needed right now ... use full path }
    flags         := ofn_FileMustExist;
    lStructSize   := SizeOf(TOpenFileName);
    nFilterIndex  := 1;       {Use first Filter String in lpstrFilter}
    nMaxFile      := SizeOf(FileName);
  end;
{ If a file is selected, turn the Play menu on, and update the sound
  window to show the new file name.
}
  if GetOpenFileName(OpenFN) then
  begin
    MyMenu := GetMenu(HWindow);
    EnableMenuItem(MyMenu, cm_SoundPlay, mf_Enabled);
 
    WaveLength := 0;
    WaveRatio  := 0;
    UpdateSoundWindow;
  end;
end;

{ Responds to mm_MCINotify messages when mci_Play is complete.  If the
  Stop/Close is from the thumb movement, then ignore it.  Otherwise,
  kill the timer and reset the scroller.
}
procedure TSoundWindow.MciNotify(var Msg: TMessage);
var
  LoVal, HiVal: Integer;
begin
  if not FlushNotify then
  begin               { Internal STOP/CLOSE, from thumb re-pos? }
    if TimerGoing then
    begin               { No, normal close. }
      KillTimer(HWindow, Timer_Id);
{ Make sure the thumb is at the end. There could be some wm_Timer
  messages on the queue when we kill it, thereby flushing wm_Timer's
  from the message queue.
}
      SoundBar^.GetRange(LoVal, HiVal);
      SoundBar^.SetPosition(HiVal);
    end;

    StopWave;
  end;
  FlushNotify := False;  { Yes, so ignore the close. }
end;

{ Invalidates the client area of the Sound Window so that the
  information display will get updated.
}
procedure TSoundWindow.UpdateSoundWindow;
begin
  InvalidateRect(HWindow, nil, True);
end;

{ Processes wm_Timer events.
}
procedure TSoundWindow.WMIdleStuff(var Msg: TMessage);
begin
  if not FlushNotify then
  begin            { Internal STOP/CLOSE, from thumb re-pos? }
    MciStatusParm.dwCallback := 0;	 { No, normal close. }
    MciStatusParm.dwItem     := mci_Status_Length;
    mciSendCommand(DeviceID, mci_Status, mci_Status_Item,
      Longint(@MciStatusParm));

{ If the wavelength has changed, update the scroll bar numbers.
}
    if WaveLength <> MciStatusParm.dwReturn then
    begin
      UpdateSoundWindow;
      WaveLength := MciStatusParm.dwReturn;
    end;

{ Compute the length and ratio and update SoundBar info.
}
    WaveRatio := Round((WaveLength / 32000) + 0.5);
    SoundBar^.ScrollSetInfo(WaveRatio, WaveLength);
    SoundBar^.SetRange(0, Round(WaveLength / WaveRatio));

{ Update the current position.
}
    MciStatusParm.dwCallback := 0;
    MciStatusParm.dwItem     := mci_Status_Position;
    mciSendCommand(DeviceID, mci_Status, mci_Status_Item,
      Longint(@MciStatusParm));

    SoundBar^.SetPosition(Round(MciStatusParm.dwReturn / WaveRatio));
  end;

  FlushNotify := False;   { Yes, ignore this close. }
end;


{ TDragApp Methods }

{ Creates the application's main window.
}
procedure TSoundApp.InitMainWindow;
begin
  MainWindow := New(PSoundWindow, Init(nil, Application^.Name));
end;

{ Initializes this instance of the Sound Application.  Redefined
  to load the accelerators.
}
procedure TSoundApp.InitInstance;
begin
  TApplication.InitInstance;
  HAccTable := LoadAccelerators(HInstance, 'ACCELERATORS_1');
end;


{ Main Program }

begin
  App.Init(DemoTitle);
  App.Run;
  App.Done;
end.

