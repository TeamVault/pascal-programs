(***********************************************)
(*                                             *)
(* The Snake Demonstration Game                *)
(* Copyright (c) 1998 by TMT Development Corp. *)
(* Author: Vadim Bodrov, TMT Development Corp. *)
(*                                             *)
(* Targets:                                    *)
(*   MS-DOS 32-bit protected mode              *)
(*   OS/2 console application                  *)
(*   WIN32 console application                 *)
(*                                             *)
(***********************************************)

program Snake;

{$ifndef __CON__}
  This program must be compiled for MS-DOS, OS/2 or Win32 console mode
{$endif}

uses {$ifdef __WIN32__} Windows, MMsystem, {$endif} Crt;

{$ifdef __WIN32__}
{$r snake.res}
{$endif}

const
  MaxSections = 255;
  ScrDX       = 80;
  ScrDY       = 50;

var
  HeadX, HeadY: LongInt;
  SnakeX      : array [0..MaxSections] of Longint;
  SnakeY      : array [0..MaxSections] of Longint;
  Position    : LongInt;
  Sections    : LongInt;
  Direction   : LongInt;
  Screen      : array [1..ScrDX, 1..ScrDY] of Char;
  Score       : LongInt;

  isExit      : Boolean;
  Answer      : Char;
  DelayVal,i  : LongInt;
  SS, SE      : String := '';

  ScrHeight   : LongInt;
  ScrWidth    : LongInt;

  Key         : Char;
  OrigMode    : Word;

procedure PlayWave(SndNo, Flags: DWord);
begin
{$ifdef __WIN32__}
  MMSystem.PlaySound(MAKEINTRESOURCE(SndNo), HInstance, flags or SND_RESOURCE);
{$endif}
end;

procedure DrawWindow(X, Y, DX, DY: LongInt);
var
  i: LongInt;
begin
  GotoXY(X, Y); Write('É', Copy(SE, 1, DX-1), '»');
  GotoXY(X, Y + DY); Write('È', Copy(SE, 1, DX-1), '¼');
  for i := Y + 1 to Y + DY-1 do
  begin
    GotoXY(X,i);
    Write('º');
    Write(Copy(SS, 1, DX - 1));
    Write('º');
  end;
end;

procedure PutSymbol(X, Y: Longint; Symbol: Char);
begin
  if (X in [1..ScrDX]) and (Y in [1..ScrDY]) then
  begin
    GotoXY(X, Y);
    Write(Symbol);
    Screen[X, Y] := Symbol;
  end;
end;

procedure DrawArea;
var
  i: Longint;
begin
  TextBackGround(Blue);
  ClrScr;
  FillChar(Screen, SizeOf(Screen), ' ');
  TextColor(White);
  for i := 2 to ScrWidth-1 do
  begin
    PutSymbol(i, 2, 'Í');
    PutSymbol(i, ScrHeight - 1, 'Í');
  end;
  for i := 3 to ScrHeight-1 do
  begin
    PutSymbol(1, i, 'º');
    PutSymbol(ScrWidth, i, 'º');
  end;
   PutSymbol(1, 2, 'É');
   PutSymbol(ScrWidth, 2, '»');
   PutSymbol(1, ScrHeight - 1, 'È');
   PutSymbol(ScrWidth, ScrHeight - 1, '¼');
   TextBackGround(White);
   TextColor(Black);
   GotoXY(1, 1); Write(Copy(SS, 1, ScrWidth));
  if ScrWidth > 40 then
  begin
    GotoXY(ScrWidth div 2 - 24,1);
    TextColor(Red);
    Write(' The Snake Game, ');
    TextColor(Black);
    Write('Copyright (c) 1998 by TMT Corp.');
  end else
  begin
    GotoXY(ScrWidth div 2 - 7,1);
    TextColor(Red);
    Write('The Snake Game');
  end;
end;

procedure InitSnake(X, Y: LongInt);
var
  i: LongInt;
begin
  TextBackGround(Blue);
  TextColor(Yellow);
  for i := 0 to Sections - 1 do
  begin
    SnakeX[i] := i + X;
    SnakeY[i] := Y;
    PutSymbol(X + i, Y, '');
  end;
  HeadX := X;
  HeadY := Y;
end;

procedure InitBonus(num: LongInt);
var
  i, x, y: LongInt;
begin
  TextColor(White); TextBackGround(Blue);
  for i := 1 to num do
  begin
    repeat
      x := Random(ScrWidth - 3) + 2;
      y := Random(ScrHeight - 3) + 3;
    until Screen[x, y] = ' ';
    TextColor(Random(5) + 10);
    case Random (4) of
      1: PutSymbol(x, y, '');
      2: PutSymbol(x, y, '');
      3: PutSymbol(x, y, '');
    else
      PutSymbol(x, y, '');
    end;
  end;
  TextColor(Yellow);
end;

procedure ViewScore;
begin
  GotoXY(ScrWidth div 2 - 14, ScrHeight);
  Write('[Score: ', Score:4, '   Sections: ', Sections:4, ']');
end;

procedure KillSnake;
const
  cr: array [0..5] of Char = ('X', 'x', '%', ':', '.' ,' ');
var
  i, j: LongInt;
begin
  case Random(3) of
    1:   PlayWave(107, 1);
    2:   PlayWave(104, 1);
    else PlayWave(103, 1);
  end;
  for j := 0 to 5 do
  begin
    for i := 0 to Sections - 1 do
    begin
      GotoXY (SnakeX[i], SnakeY[i]);
      if ((SnakeX[i] <> HeadX) or (SnakeY[i] <> HeadY)) and
         (SnakeX[i] <> 0) then Write(cr[j]);
    end;
    Delay(50);
  end;
  Delay(200);
end;

procedure AddSection;
begin
  if Sections < MaxSections then
  begin
    inc(Sections);
    SnakeX[Sections] := 0;
  end;
  ViewScore;
end;

procedure MoveSnake;
begin
  PutSymbol(SnakeX[Position], SnakeY[Position], ' ');
  case Direction of
    1:  Dec(HeadX);
    2:  Inc(HeadX);
    3:  Dec(HeadY);
    4:  Inc(HeadY);
  end;
  SnakeX[Position] := HeadX;
  SnakeY[Position] := HeadY;
  if Screen[HeadX, HeadY] in ['', '', '', ''] then
  begin
    case Screen[HeadX, HeadY] of
      '': PlayWave(105, 1);
      '': PlayWave(106, 1);
      '': PlayWave(102, 1);
      '': PlayWave(108, 1);
    end;
    inc(Score);
    AddSection;
    InitBonus(1);
  end else
  if Screen[HeadX, HeadY] <> ' ' then
  begin
    KillSnake;
    isExit := TRUE;
    exit;
  end;
  PutSymbol(SnakeX[Position], SnakeY[Position], '');
  Dec(Position);
  if Position < 0 then Position := Sections - 1;
end;

begin
  FillChar(SnakeX, SizeOf(SnakeX), 0);
  FillChar(SnakeY, SizeOf(SnakeY), 0);
  DirectVideo := FALSE;
  CheckBreak := FALSE;

{$ifdef __WIN32__}
  SetConsoleTitle('The Snake - Win32 Console Application Demo');
{$endif}

  OrigMode := LastMode;
  TextMode(CO80 or Font8x8);

  HideCursor;

  ScrHeight := Hi(WindMax) + 1;
  ScrWidth  := Lo(WindMax) + 1;
  for i := 1 to 254 do
  begin
    SE := SE + 'Í';
    SS := SS + ' ';
  end;

  repeat
    DrawArea;

    TextColor(White);
    TextBackGround(Red);

    DrawWindow(ScrWidth div 2 - 16, ScrHeight div 2 - 2, 34, 8);
    GotoXY(ScrWidth div 2 - 8, ScrHeight div 2 - 2);
    Write(' Choose Game Level ');
    GotoXY(ScrWidth div 2 - 14, ScrHeight div 2);
    Write(' 1. Where are my diapers?');
    GotoXY(ScrWidth div 2 - 14, ScrHeight div 2 + 1);
    Write(' 2. Little fella');
    GotoXY(ScrWidth div 2 - 14, ScrHeight div 2 + 2);
    Write(' 3. Play the game!');
    GotoXY(ScrWidth div 2 - 14, ScrHeight div 2 + 3);
    Write(' 4. Die hard!');
    GotoXY(ScrWidth div 2 - 14, ScrHeight div 2 + 4);
    Write(' 5. Sanitarium!');

    PlayWave(101, 9);

    repeat
      Answer := ReadKey;
      if Answer = #27 then
      begin
        ShowCursor;
        NormVideo;
        ClrScr;
        TextMode(OrigMode);
        Halt(0);
      end;
    until Answer in ['1'..'5'];

    case Answer of
      '1': DelayVal := 100;
      '2': DelayVal := 80;
      '3': DelayVal := 60;
      '4': DelayVal := 40;
      '5': DelayVal := 20;
    end;

    Position  := 3;
    Sections  := 4;
    Direction := 1;
    isExit    := FALSE;
    isExit    := FALSE;
    Score     := 0;

    DrawArea;
    InitBonus(5);
    InitSnake(ScrWidth div 2 - 2, ScrHeight div 2);
    ViewScore;

    PlayWave(106, 1);

    repeat
      if KeyPressed then
      begin
        Key := ReadKey;
        if Key = #0 then
          case ReadKey of
           #72: if Direction <> 4 then Direction := 3;
           #80: if Direction <> 3 then Direction := 4;
           #75: if Direction <> 2 then Direction := 1;
           #77: if Direction <> 1 then Direction := 2;
          end;
        isExit := Key = #27;
      end;
      Delay(DelayVal);
      MoveSnake;

    until isExit;

    TextColor(White);
    TextBackGround(Black);
    DrawWindow(ScrWidth div 2 - 10, ScrHeight div 2 - 2, 20, 7);
    TextColor(LightCyan);
    GotoXY(ScrWidth div 2 - 4, ScrHeight div 2);
    Write('Game Over');
    TextColor(White);
    GotoXY(ScrWidth div 2 - 8, ScrHeight div 2 + 2);
    Write('Play again (Y/N)?');

    repeat
      Answer := UpCase(ReadKey);
    until (Answer = 'Y') or (Answer = 'N');

  until Answer = 'N';

  ShowCursor;

  NormVideo;
  ClrScr;
  TextMode(OrigMode);
end.