{************************************************}
{                                                }
{   Chess - Shared DLL Example                   }
{   CHESS.DLL Game timers.                       }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit LTimer;

{$R-,Q-,S-,W-}

interface

uses Objects;

{ The Clock procedures provides a module for measuring Time.
  Think of the module as a Stop watch. InitTime resets a
  Clock completely. StartTime starts the Clock Running,
  StopTime stops it again, and TotalTime then contains the
  elapsed Time in seconds. You can use StartTime and StopTime
  again and have the elapsed Time added to the TotalTime, and
  you can use StopTime to get an intervening Time without
  stoping the Clock itself }

type

  TStopWatch = object(TObject)
    StartTime: Longint;
    ElapsedTime : Longint;    { base unit is bios tics }
    constructor Init;
    procedure Start;
    procedure Resume;
    procedure Stop;
    procedure Reset;
    function  GetString: String;
    function  GetElapsedTime: Longint;
    procedure Update;
    function  Running: Boolean;
  end;

  PTaskTimer = ^TTaskTimer;
  TTaskTimer = object(TStopWatch)
    TimeLimit: Longint;
    procedure SetLimit( A: Longint);
    function  TimeExpired: Boolean;
    function  TimeRemaining: Longint;
  end;


implementation

{$IFDEF WINDOWS}
procedure __0040H;  far; external 'Kernel' index 193;
const
  Seg0040: Word = Ofs(__0040H);
{$ENDIF}

constructor TStopWatch.Init;
begin
  Reset;
end;

procedure TStopWatch.Reset;
begin
  StartTime := 0;
  ElapsedTime := 0;
end;

procedure TStopWatch.Start;
begin
  StartTime := MemL[Seg0040:$6C];
end;

procedure TStopWatch.Resume;
begin
  StartTime:= MemL[Seg0040:$6C];
end;

procedure TStopWatch.Stop;
begin
  Update;
  StartTime := 0;
end;

procedure TStopWatch.Update;
begin
  if LongBool(StartTime) then
  begin
    ElapsedTime := ElapsedTime + MemL[Seg0040:$6C] - StartTime;
    Resume;
  end;
end;

function TStopWatch.GetString: String;
var
  Temp : String[20];
begin
  Update;
  Str(ElapsedTime, Temp);
  GetString := Temp;
end;

function TStopWatch.GetElapsedTime: Longint;
begin
  Update;
  GetElapsedTime := ElapsedTime;
end;

function TStopWatch.Running: Boolean;
begin
  Running := StartTime <> 0;
end;


procedure TTaskTimer.SetLimit(A: Longint);
begin
  TimeLimit := A;
end;

function TTaskTimer.TimeExpired: boolean;
begin
  Update;
  TimeExpired := ElapsedTime >= TimeLimit;
end;

function TTaskTimer.TimeRemaining: Longint;
begin
  Update;
  TimeRemaining := TimeLimit - ElapsedTime;
end;


end.