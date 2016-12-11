{*******************************************************}
{                                                       }
{       Keyboard Unit demo program                      }
{                                                       }
{       Copyright (C) 1997    T M T   Corporation       }
{                                                       }
{*******************************************************}

 program TestKeys;

 uses Keyboard,CRT;

 var X: Word := 40;
     Y: Word := 12;

 procedure SetCursor(Cursor: Word); assembler;
      asm
        mov     ax,$0100
        xor     bx,bx
        mov     cx,[Cursor]
        int     $10
 end;

 procedure HideCursor;
 begin
  SetCursor($2000);
 end;

 procedure ShowCursor;
 begin
  SetCursor($0607);
 end;

 begin
  CLRSCR;
  HideCursor;
  Writeln(' Tastele sageti: move & erase(deplasare)');
  Writeln(' Space     : drawing(desenare)');
  Writeln(' Ecs       : exit');
  MultiKeysInit;
  repeat
   GotoXY(X,Y);
   if TestKey(Space_Scan) then Write('*') else Write(' ');
   if (TestKey(Right_Scan)) and (X<79) then inc(X);
   if (TestKey(Left_Scan)) and (X>1) then dec(X);
   if (TestKey(Down_Scan)) and (Y<24) then inc(Y);
   if (TestKey(Up_Scan)) and (Y>4) then dec(Y);
   GotoXY(X,Y);
   Write('Û');
   Delay(75);
  until TestKey(ESC_Scan);
  ShowCursor;
  MultiKeysDone;
 end.