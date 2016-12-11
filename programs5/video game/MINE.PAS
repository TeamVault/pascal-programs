Program MINE_GAME;

Uses GraphPro,Crt,ADVHSC;

Const
  FileName               = 'DEFAULT.PIC';
  PicNumber              = 22;
  SizeX                  = 10;
  SizeY                  = 10;
 {known   Numer          = 0..9  }
 {Unknown Number         = 10..19}
  Flag                   = 200;
  Mine                   = 50;
  MinesNumber            = 12;
  StartX                 = 160-8*SizeX;
  StartY                 = 100-8*SizeY;
  BackColor              = 20;
  Unknown                = 10;
  Dly                    = 10;

  Countersize            = 4;

Type
  TBox      = Array [0..15,0..15]            Of Byte;
  TPic      = Array [0..PicNumber-1]         Of Tbox;
  TTable    = Array [0..SizeX-1, 0..SizeY-1] Of Byte;
  Sounds    = (WinSound, LooseSound, TurnCardSound);

Var
  Pics     : TPic;
  Table    : TTable;
  Bombs    : Integer;

Procedure MakeSound( hz, msec: word );
Begin
  Sound( hz );
  Delay( msec );
  NoSound;
End;

Procedure Play_Sound( Wich: Sounds );
Var
  i: Word;
Begin
  Case Wich of
    WinSound: For i:= 0 to 300 do MakeSound( i*10+i, 2 );
    LooseSound: Begin
                  For i:= 1 to 25 do
                    Begin MakeSound(   i*i, 3 ); MakeSound( $FFFF div  i, 5 ); End;
                  For i:= 1 to 10 do
                    Begin MakeSound( 27*27, 3 ); MakeSound( $FFFF div 27, 5 ); End;
                  For i:= 20 DownTo 1 do
                    Begin MakeSound(   i*i, 6 ); MakeSound( $FFFF div  i, 8 ); End;
                End;
    TurnCardSound: For i:= 0 to 10 do MakeSound( 10*i*i + i*2 + 10 , 3 );
  End;
End;

Procedure Error( Str : String);
Begin
  WriteLn;
  WriteLn(Str);
  WriteLn;
  Halt;
End;

Procedure LoadPics;
Var
  F : File Of TPic;
Begin
  Assign(F,FileName);
  {$I-}Reset(F);{$I+}
  If IOResult > 0 Then Error('File '+FileName+' Not Found');
  Read(F,Pics);
  Close(F);
End;

(*컴 Mouse 컴컴컴컴컴컴컴컴컴컴컴컴 *)
Procedure ShowMouse;
Inline( $B8/$01/$00/              { MOV   AX,0001h                 }
        $CD/$33);                 { INT   33h                      }
Procedure HideMouse;
Inline( $B8/$02/$00/              { MOV   AX,0002h                 }
        $CD/$33);                 { INT   33h                      }
Function GetButton:Word;
InLine( $B8/$03/$00/              { MOV   AX,0003h                 }
        $CD/$33/                  { INT   33h                      }
        $89/$D8);                 { MOV   AX,BX     ; result in BX }
Function GetMouseX:Word;
InLine( $B8/$03/$00/              { MOV   AX,0003h                 }
        $CD/$33/                  { INT   33                       }
        $89/$C8);                 { MOV   AX,CX     ; result in CX }
Function GetMouseY:Word;
InLine( $B8/$03/$00/              { MOV   AX,0003h                 }
        $CD/$33/                  { INT   33                       }
        $89/$D0);                 { MOV   AX,DX     ; result in DX }

Function  MouseX : Word;
Begin
  MouseX := GetMouseX shr 1;
End;

Function  MouseY : Word;
Begin
  MouseY := GetMouseY;
End;
{-------- end of mouse porcs -------------}

Procedure DrawTable;
Var
  Xc,Yc : Byte;
Begin
  For Xc:=0 To SizeX-1 Do
    For Yc:=0 To SizeY-1 Do
      Case Table[Xc,Yc] Of
        Mine, 10..19 : DrawPic(VGA, StartX+Xc*16, StartY+Yc*16, 16, 17, @Pics[0]);
        0..9         : DrawPic(VGA, StartX+Xc*16, StartY+Yc*16, 16, 17, @Pics[Table[Xc,Yc]+1]);
        Flag-1..$FF    : DrawPic(VGA, StartX+Xc*16, StartY+Yc*16, 16, 17, @Pics[10]);
      End;
End;

Procedure Box2(x1,y1, x2,y2 : integer; col : byte);
var
  xc,yc : word;
Begin
  for xc:=x1 to x2 do
    for yc:=y1 to y2 do
      pixel(xc,yc,col,vga);
End;

Procedure equal;
  var a,b:byte;
  Begin;
    GetPlayerState;
    For a:=1 to 9 do
    Begin;
      b:=playerstate.equalizer[a];
      If b>30 then b:=0;
      box2(a*6+5,100  ,a*6+9,119-b,20);
      box2(a*6+5,120-b,a*6+9,120 ,10);
    End;
  End;


Procedure FillVirTable(X, Y : Byte);
Var
  Xc, Yc, LookFor : Byte;
  Done            : Boolean;
  VirTable,virtable2 : TTable;
Begin
  For Xc:=0 To SizeX-1 Do
    For Yc:=0 To SizeY-1 Do
      If (Table[Xc,Yc]=0) or (Table[Xc,Yc]=10) Then VirTable[Xc,Yc]:=0
      Else VirTable[Xc,Yc]:=$FF;
  virtable[x,y]:=1;
  if (table[x,y]<>10) and (table[x,y]>0) then begin
    If (X>0) then VirTable[X-1,Y]:=255;
    If (X<SizeX-1) then VirTable[X+1,Y]:=255;
    If (Y>0) then VirTable[X,Y-1]:=255;
    If (Y<sizeY-1) then VirTable[X,Y+1]:=255;
  End;
  LookFor:=1;
  Repeat
    Done := True;
    For Xc:=0 To SizeX-1 Do
      For Yc:=0 To SizeY-1 Do
        If VirTable[Xc,Yc]=LookFor Then Begin
          If (Xc>0) And (VirTable[Xc-1,Yc]=0) Then Begin
            VirTable[Xc-1,Yc]:=LookFor+1;
            Done:=False;
          End;
          If (Xc<SizeX-1) And (VirTable[Xc+1,Yc]=0) Then Begin
            VirTable[Xc+1,Yc]:=LookFor+1;
            Done:=False;
          End;
          If (Yc>0) And (VirTable[Xc,Yc-1]=0) Then Begin
            VirTable[Xc,Yc-1]:=LookFor+1;
            Done:=False;
          End;
          If (Yc<SizeY-1) And (VirTable[Xc,Yc+1]=0) And (VirTable[Xc,Yc+1]=0) Then Begin
            VirTable[Xc,Yc+1]:=LookFor+1;
            Done:=False;
          End;
    End;
    Inc( LookFor );
    Delay(dly);
    For Xc:=0 To SizeX-1 Do
      For Yc:=0 To SizeY-1 Do
        If (virTable[xc,yc]>0) and (VirTable[xc,yc]<255) And
         (Table[Xc,Yc]>=Unknown)  then dec(Table[xc,yc],Unknown);
    DrawTable;
  Until Done;
  virtable2:=virtable;
  For Xc:=0 To SizeX-1 Do
    For Yc:=0 To SizeY-1 Do
      If (VirTable2[Xc,Yc]<255) and (VirTable2[Xc,Yc]>1) Then Begin
          If (Xc>0) Then VirTable[Xc-1,Yc]:=1;
          If (Xc<SizeX-1) Then VirTable[Xc+1,Yc]:=1;
          If (Yc>0) Then VirTable[Xc,Yc-1]:=1;
          If (Yc<SizeY-1) Then VirTable[Xc,Yc+1]:=1;

          If (Xc>0) and (Yc<SizeY-1) Then VirTable[Xc-1,Yc+1]:=1;
          If (Xc<SizeX-1) and (Yc<SizeY-1)Then VirTable[Xc+1,Yc+1]:=1;
          If (Yc>0) and (Xc>0)Then VirTable[Xc-1,Yc-1]:=1;
          If (Xc<SizeX-1) and (Yc>0) Then VirTable[Xc+1,Yc-1]:=1;
        End;

  For Xc:=0 To SizeX-1 Do
    For Yc:=0 To SizeY-1 Do
      If (virTable[Xc,Yc]>0) and (VirTable[xc,yc]<255) And
         (Table[Xc,Yc]>Unknown) then dec(Table[xc,yc],Unknown);
  DrawTable;
End;

Procedure WriteNumber(X,Y : Byte; Num : Integer);
Var
  S  :  String;
  Xc :  Byte;
Begin
  Str ( Num:4, S);
  For Xc:=1 To 4 Do
    if s[xc]='-' then drawpic(VGA,x+Xc*16-16,Y,16,17,@Pics[11]) else
    if s[xc] in ['0'..'9'] then DrawPic(VGA,x+Xc*16-16,Y,16,17,@Pics[Ord(S[xc])-48+12]) else
    DrawPic(VGA,x+Xc*16-16,Y,16,17,@Pics[12]);
end;

Procedure Init;
Var
  Xc, Yc, Zc : Byte;
Begin
  Bombs:=MinesNumber;
  For Xc:=0 To SizeX-1 Do
    For Yc:=0 To SizeY-1 Do Table[Xc,Yc]:=0;
  For Xc:=0 To MinesNumber-1 Do Begin
    Repeat
      Yc:=Random(SizeX);
      Zc:=Random(SizeY);
    Until Table[Yc,Zc]<>Mine;
    Table[Yc,Zc]:=Mine;
  End;
  For Xc:=0 To SizeX-1 Do
    For Yc:=0 To SizeY-1 Do If Table[Xc,Yc]<>Mine Then Begin
      Zc := 0;
      If (Table[Xc-1,Yc-1]=Mine) And (Xc>0)       And (Yc>0)       Then Inc(Zc);
      If (Table[Xc  ,Yc-1]=Mine)                  And (Yc>0)       Then Inc(Zc);
      If (Table[Xc+1,Yc-1]=Mine) And (Xc<SizeX-1) And (Yc>0)       Then Inc(Zc);
      If (Table[Xc-1,Yc  ]=Mine) And (Xc>0)                        Then Inc(Zc);
      If (Table[Xc+1,Yc  ]=Mine) And (Xc<SizeX-1)                  Then Inc(Zc);
      If (Table[Xc-1,Yc+1]=Mine) And (Xc>0)       And (Yc<SizeY-1) Then Inc(Zc);
      If (Table[Xc  ,Yc+1]=Mine)                  And (Yc<SizeY-1) Then Inc(Zc);
      If (Table[Xc+1,Yc+1]=Mine) And (Xc<SizeX-1) And (Yc<SizeY-1) Then Inc(Zc);
      Table[Xc,Yc]:=Unknown+Zc;
  End;
  SetMCGA;
  FillScr(BackColor);
{  GotoXY(1,1);
  WriteLn('  ',Bombs,'  ');}
  writenumber(10,5,bombs);
  DrawTable;
  ShowMouse;
End;

Procedure Done;
Begin
  FADESONG;
  Delay(2000);
  STOPSONG;
  HideMouse;
  SetTEXT;
End;

Begin
  WriteLn('Please Wait While Loading....');
  Randomize;
  LoadPics;
  textcolor(14);
  DirectVideo:=False;
  Init;
  If LoadSong('MUSIC.HSC') Then PlaySong;
  Repeat
    delay(1);
     If (mousex>startx) and (mousex<startx+16*(sizex))
     and (mousey>starty) and (mousey<starty+16*(sizey)) then
       Case GetButton Of
         1 : If Table[(mousex-startx) div 16,(mousey-starty)div 16]=Mine Then Begin
                 Play_Sound( LooseSound );
                 Init;
             End Else If (Table[(mousex-startx) div 16,(mousey-starty)div 16]>=Unknown) And
                         (Table[(mousex-startx) div 16,(mousey-starty)div 16]<Flag) Then Begin
               Play_SOund(TurnCardSound);
               hidemouse;
               fillvirtable((mousex-startx) div 16,(mousey-starty)div 16);
               showmouse;
               repeat until getbutton=0;
             End;
         2 : If Table[(mousex-startx) div 16,(mousey-starty)div 16]>=Unknown Then Begin
               Play_Sound(TurnCardSound);
               If Table[(MouseX-StartX) Div 16,(MouseY-StartY) DIv 16]<Flag Then Begin
                 Inc(Table[(MouseX-StartX) Div 16,(MouseY-StartY) DIv 16],Flag);
                 Dec(Bombs); End Else Begin
                   Dec(Table[(MouseX-StartX) Div 16,(MouseY-StartY) DIv 16],Flag);
                   Inc(Bombs);
                 End;
               HideMouse;
               DrawTable;
               ShowMouse;
               writenumber(10,5,bombs);
               repeat until getbutton=0;
             End;
       End;
    Equal;
  Until Port[$60]=01;
  Done;
End.
