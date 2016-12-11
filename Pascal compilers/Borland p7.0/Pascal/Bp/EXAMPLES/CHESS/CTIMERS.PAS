{************************************************}
{                                                }
{   Chess Demo                                   }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit CTimers;

interface

uses Objects;

type
  TTimerStatus = (tsStopped, tsRunning);

  PChessTimer = ^TChessTimer;
  TChessTimer = object(TObject)
    Status: TTimerStatus;
    TotalTime: Longint;
    constructor Init;
    constructor Load(var S: TStream);
    function AddTo(ATimer: PChessTimer): Longint;
    procedure Clear;
    function GetCurrentTicks: Longint;
    function GetMarkTime: Longint;
    procedure Mark;
    procedure Start;
    procedure Stop;
    procedure Store(var S: TStream);
  private
    MarkTime: Longint;
    TimeAtStart: Longint;
    function TicksSinceStart: Longint;
  end;

const
  RChessTimer: TStreamRec = (
    ObjType: 5005;
    VmtLink: Ofs(TypeOf(TChessTimer)^);
    Load:    @TChessTimer.Load;
    Store:   @TChessTimer.Store);

procedure ConvertTicks(TotalTicks: Longint; var Hours, Minutes, Seconds, Ticks: Word);
procedure Wait(Ticks: Longint);

implementation

const
  TotalDayTime = $0017FE7F;

{$IFDEF WINDOWS}
procedure __0040H;  far; external 'Kernel' index 193;
const
  Seg0040: Word = Ofs(__0040H);
{$ENDIF}

function CurrentTicks: Longint;
begin
  CurrentTicks := MemL[Seg0040:$6C];
end;

function PastMidnight: Boolean;
begin
  PastMidnight := Mem[Seg0040:$70] <> 0;
end;

constructor TChessTimer.Init;
begin
  Status := tsStopped;
  TimeAtStart := 0;
  TotalTime := 0;
  MarkTime := 0;
end;

constructor TChessTimer.Load(var S: TStream);
begin
  S.Read(Status, SizeOf(Status) + SizeOf(Longint));
  S.Read(MarkTime, SizeOf(Longint));
end;

function TChessTimer.AddTo(ATimer: PChessTimer): Longint;
begin
  AddTo := GetCurrentTicks + ATimer^.GetCurrentTicks;
end;

procedure TChessTimer.Clear;
begin
  Stop;
  TotalTime := 0;
end;

function TChessTimer.GetCurrentTicks: Longint;
begin
  if Status = tsRunning then
    GetCurrentTicks := TotalTime + TicksSinceStart
  else GetCurrentTicks := TotalTime;
end;

function TChessTimer.GetMarkTime: Longint;
begin
  if (Status = tsRunning) then
    GetMarkTime := MarkTime + TicksSinceStart
  else GetMarkTime := MarkTime;
end;

procedure TChessTimer.Mark;
begin
  MarkTime := 0;
end;

procedure TChessTimer.Start;
begin
  if Status = tsStopped then
  begin
    Status := tsRunning;
    TimeAtStart := CurrentTicks;
  end;
end;

procedure TChessTimer.Stop;
begin
  if Status = tsRunning then
  begin
    Status := tsStopped;
    TotalTime := TotalTime + TicksSinceStart;
    MarkTime := MarkTime + TicksSinceStart;
  end;
end;

procedure TChessTimer.Store(var S: TStream);
begin
  S.Write(Status, SizeOf(Status) + SizeOf(Longint));
  S.Write(MarkTime, SizeOf(Longint));
end;

function TChessTimer.TicksSinceStart: Longint;
var
  Ticks, TickDif: Longint;
begin
  Ticks := CurrentTicks;
  if PastMidnight then
    TickDif := TotalDayTime - TimeAtStart + Ticks
  else TickDif := Ticks - TimeAtStart;
  TicksSinceStart := TickDif;
end;

procedure ConvertTicks(TotalTicks: Longint; var Hours, Minutes, Seconds, Ticks: Word);
var
  Temp: Longint;
begin
  Hours := TotalTicks div 65520;
  Temp := TotalTicks mod 65520;
  Minutes := Temp div 1092;
  Temp := Temp mod 1092;
  Seconds := Temp div 91 * 5;
  Temp := Temp mod 91;
  Seconds := Seconds + Temp div 18;
  Ticks := ((Temp mod 18) * 18) mod 100;
end;

procedure Wait(Ticks: LongInt);
var
  StartTime, StopTime: Longint;
begin
  StartTime := CurrentTicks;
  StopTime := StartTime + Ticks;
  if StopTime > TotalDayTime then
    StopTime := TotalDayTime;
  repeat
  until CurrentTicks >= StopTime;
end;

end.
