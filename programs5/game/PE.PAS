Program Picture_Editor;

Uses GamePro,Crt;

Const
  (* Colors *)
  Back                   = 25;
  Shadow                 = 20;
  Normal                 = 23;
  Light                  = 27;
  TextColor              = 1;
  BackColor     : Byte   = 7;
  BoxColor               = 0;
  CursorColor            = 10;
  (* Position *)
  Bx                     = 201;
  By                     = 120;
  Cy                     = 70; {Colors}
  Cx                     = 150;
  Mx                     = 5;
  My                     = 5;
  Px                     = 180;
  Py                     = 210;

  PicNumber              = 22;
  FntName                = 'DIGGER.FNT';
  PicName       : String = 'DEFAULT.PIC';
  CurX          : Byte   = 0;
  CurY          : Byte   = 0;
  Active        : Byte   = 0;
  CurrColor     : Byte   = 0;
  Clr                    = '**************************************';

Type
  TBox  = Array [0..15,0..15]          Of Byte;
  Tpic  = Array [0..PicNumber-1]       Of Tbox;
  Ppic  = ^Tpic;

  TFont = Array [#40..#90, 0..7] Of Byte;
  PFont = ^TFont;

Var
  Pic           : PPic;
  Font          : PFont;
  KeyPressed    : Char;
  CurPal,PPAl,
  ExtraPal      : PalType;
  CopyedBox     : Byte;
  SvdColor      : Array [ 0..9 ] Of Byte;
  drawmode      : boolean;


{ Graphics }
Procedure Frame(X1,Y1,X2,Y2 : Word; On : Boolean);
Var
  C : Word;
Begin
  If On
  Then
    Begin
      For C := X1 To X2 Do
        Begin
          Pixel (C,Y1,Light);
          Pixel (C,Y2,Shadow);
        End;
      For C := Y1 To Y2 Do
        Begin
          Pixel (X1,C,Light);
          Pixel (X2,C,Shadow);
        End;
    End
  Else
    Begin
      For C := X1 To X2 Do
        Begin
          Pixel (C,Y1,Shadow);
          Pixel (C,Y2,Light);
        End;
      For C := Y1 To Y2 Do
        Begin
          Pixel (X1,C,Shadow);
          Pixel (X2,C,Light);
        End;
    End;
End;

Procedure Box (X1,Y1,X2,Y2 : Word ; C : Byte);
Var Xc,Yc : Word;
Begin
  For Xc := X1 To X2 Do
    For Yc := Y1 To Y2 Do
      Pixel (Xc,Yc,C);
End;

{-----Disk-----}

{Font}
Function Exist(Name : String) : Boolean;
Var
  F  : File;
Begin
  Assign(F,name);
  {$I-}
  Reset(F);
  Close(F);
  {$I+}
  Exist:= IOResult=0;
End;

Procedure LoadFont;
Var
  Xc    : Char;
  Yc    : Byte;
  F     : File Of Byte;
  xx,yy : Word;
Begin
  Assign (F,FntName);
  Reset(F);
  For Xc:=#40 To #90 Do
    For Yc := 0 To 7 Do
      Read(F,Font^[Xc,Yc]);
  Close(F);
End;

Function GetBit( Number, BitNum : Byte) : Boolean;
Begin
  GetBit := Number And (1 Shl BitNum)<>0;
End;

Procedure DrawChar(X,Y : Word; WithBack : Boolean; Chr : Char);
Var
  Xc,Yc : Word;
Begin
  For Xc:=0 To 7 Do
    For Yc:=0 To 7 Do
      If (GetBit(Font^[Chr,Yc],Xc)) And (Chr<>#32) Then Pixel(X+Xc,Y+Yc,TextColor) Else
                                       If WithBack Then Pixel(X+Xc,Y+Yc,BackColor);
End;

Procedure WriteStr(X,Y : Word; WithBack : Boolean; Str:String);
Var
  Xc : Byte;
Begin
  For Xc:=1 To Ord(Str[0]) Do
    DrawChar(X+(Xc-1)*8,Y,WithBack, Str[Xc])
End;

Procedure GetKey( Var Ch : Char);
Begin
  Ch:=ReadKey;
  If Ch In [#97..#122] Then Ch:=Chr(Ord(Ch)-32) Else
End;

Procedure ReadStr(X,Y : Word; Var Str : String);
Var
  Xc,Yc : Word  ;
  Key   : Char  ;
  StrC  : String;
Begin
  StrC[0]:=Chr(0);
  Repeat
    For Yc:=0 To 7 Do Pixel(Ord(StrC[0])*8+X,Y+Yc,TextColor);
    GetKey(Key);
    If Key=#32 Then Key:=#64;
    Case Key Of
      #40..#90 : Begin
                   StrC:=StrC+Key;
                   DrawChar(X+(Ord(StrC[0])-1)*8,Y,True,Key);
                 End;
      #8       : If StrC[0]>#0 Then Begin
                   For Yc:=0 To 7 Do Pixel(Ord(StrC[0])*8+X,Y+Yc,BackColor);
                   DrawChar(X+(Ord(StrC[0])-1)*8,Y,True,#64);
                   StrC[0]:=Chr(Ord(StrC[0])-1);
                 End;
      #0       : Key:=ReadKey;
    End;
  Until Key In [#13,#27];
  If Key=#13 Then Str:=StrC;
End;

{Pics}
Procedure MSG(Message : String);
Begin
  WriteStr(Mx+3,My+15,True,Clr);
  WriteStr(Mx+3,My+15,True,Message);
End;

Procedure DrawScreen;
Var
  Xc,Yc : Byte;
Begin
  For Xc:=0 To 15 Do
    For Yc:=0 To 15 Do
      Pixel(Xc+PX,Yc+Py,Pic^[Active,Xc,Yc]);
End;

Procedure DrawInBox(X,Y,C : Byte);
Var
  Xc,Yc : Byte;
Begin
  For Xc:=1 To 5 Do
    For Yc:=1 To 5 Do
      Pixel(Bx+10+X*6+Xc,By+12+Y*6+Yc,C);
  Pic^[Active,X,Y]:=C;
End;

Procedure SetActive;
Var
  Xc,Yc : Byte;
Begin
  For Xc:=0 To 15 Do
    For Yc:=0 To 15 Do
      DrawInBox(Xc,Yc,Pic^[Active,Xc,Yc]);
  DrawScreen;
End;

Procedure LoadPic(On : Boolean);
Var
  Xc,Yc : Byte;
  F     : File;
Begin
  If Exist(PicName) Or (Not On) Then Begin
    Assign (F,PicName);
    If On Then Reset(F,1) Else ReWrite(F,1);
    If On Then BlockRead(F,Pic^,FileSize(F)) Else
               BlockWrite(F,Pic^,PicNumber*16*16);
    Close(F);
    If On Then SetActive;
  End Else Begin
    MSG('FILE NOT FOUND. PRESS ANY KEY.');
    If ReadKey=#0 Then ReadKey;
    MSG(Clr);
  End;
End;

{-----Init-----}
Procedure InitHelp;
Begin
  WritePage(2);
  WriteStr(30,15,True,   '<>     : PIC NUM               ');
  WriteStr(30,24,True,  'DEL    : DELETE                ');
  WriteStr(30,33,True,  'F1     : HELP                  ');
  WriteStr(30,42,True,  'F2     : SAVE                  ');
  WriteStr(30,51,True,  'F3     : LOAD                  ');
  WriteStr(30,60,True,  'F4     : NEW NAME              ');
  WriteStr(30,69,True,  'F5     : NUMBER                ');
  WriteStr(30,78,True,  'F6     : NEW                   ');
  WriteStr(30,87,True,  'F7     : SAVE CURRENT COLOR    ');
  WriteStr(30,96,True,  'F8     : CHOSSE PICTURE        ');
  WriteStr(30,105,True, 'ESC    : EXIT                  ');
  WriteStr(30,114,True, '0..9   : GET SAVED COLOR       ');
  WriteStr(30,123,True, '(C)    : COPY PICTURE          ');
  WriteStr(30,132,True, '(P)    : PASTE                 ');
  WriteStr(30,141,True, 'HOME   : TURN PICTURE LEFT     ');
  WriteStr(30,150,True, 'PGUP   : TURN PICTURE RIGHT    ');
  WriteStr(30,159,True, 'END    : GET LAST PICTURE      ');
  WriteStr(30,168,True, 'PGDOWN : GET FIRST PICTURE     ');
  WriteStr(30,177,True, '(ENTER): DRAW A POINT          ');
  WriteStr(30,186,True, '(TAB)  : GET COLOR             ');
  WriteStr(13,210,False,'PRESS ANY KEY TO RETURN TO THE EDITOR');
  WritePage(1);
End;

Procedure InitAbout;
Begin
  WritePage(0);
  WriteStr(10,30,False,'ABOUT  :');
  WriteStr(10+8*8,40,False,     'PICTURE EDITOR');
  WriteStr(10+8*8,50,False,     'MADE BY THE = TEAM, 1996 (C)');
  WriteStr(10+8*8,60,False,     'VER 2.05');
  WriteStr(13,210,False,'PRESS ANY KEY TO RETURN TO THE EDITOR');
  WritePage(1);
End;


Procedure InitBox;
Var
  Xc,Yc : Byte;
Begin
  For Xc:=0 To 16 Do
    For Yc:=0 To 16 Do
     Pixel(Bx+10+Xc*6,By+12+Yc*6,BoxColor);
  Pixel(Bx+10+CurX*6,By+12+CurY*6,CursorColor);
  Pixel(Bx+10+(CurX+1)*6,By+12+CurY*6,CursorColor);
  Pixel(Bx+10+CurX*6,By+12+(CurY+1)*6,CursorColor);
  Pixel(Bx+10+(CurX+1)*6,By+12+(CurY+1)*6,CursorColor);
End;

Function Strng (b :byte) : String;
var S : string;
begin
  Str (b,s);
  Strng := S;
End;

Procedure RefreshColor;
var c : byte;
begin
  box (Cx,Cy,Cx+20,Cy+20,CurrColor);
  for c := 1 to 10 do
    begin
      box (Cx-(c+1)*10,Cy+5,Cx-c*10,Cy+15,currcolor-c);
      box (Cx+20+c*10,Cy+5,Cx+20+(c+1)*10,Cy+15,currcolor+c);
    end;
  BackColor := Back;
  WriteStr (Cx-14,Cy+24,True,'  '+Strng(currcolor)+'  ');
  backcolor := light;
end;

Procedure InitScreen;
Var
  Xc : Word;
  Pc : Byte;
Begin
  FillChar(Mem[$A000:000],80*240*3,Back);
  WritePage(1);
  Box(Bx+1,BY+1,Bx+115,By+115,Normal);
  Frame (Bx,By,Bx+116,By+116,true);
  Box(Mx+1,My+1,Mx+309,My+27,Normal);
  Frame (Mx,My,Mx+310,My+28,true);
  Frame (Mx+2,My+14,Mx+38*8+3,My+8+15,False);
  WriteStr(Mx+125,My+5,False,'MESSAGE:');
  MSG(Clr);
  Frame (9 ,203,199,236,True);
  Box (10,204,198,235,normal);
  For Xc:=10 To 200 Do
    If (Xc Mod 10 = 0) And (Xc<110) Then
      DrawChar(10+Xc-3,193,False,Chr((Xc Div 10) + 47));

  WriteStr(10,40,True,'PICTURE NUMBER :');
  WriteStr(10,50,True,'PICTURE COPYED :');
 {WriteStr(203,5 ,False,'PICTURE EDITOR                 ');}
  refreshColor;
  frame (Cx-1,Cy-1,Cx+21,Cy+21,true);
  frame (Cx-111,Cy+4,Cx-9,Cy+16,true);
  frame (Cx+29,Cy+4,Cx+131,Cy+16,true);
  DrawChar (Cx-121,Cy+6,False,'-');
  DrawChar (Cx+134,Cy+6,False,'+');
End;

Procedure InitFont;
Begin
  New(Font);
  LoadFont;
End;

Procedure InitPics;
Var
  Xc,Yc,Pc : Byte;
Begin
  New(Pic);
  For Pc:=0 To PicNumber-1 Do
    For Xc:=0 To 15 Do
      For Yc:=0 TO 15 Do
        Pic^[Pc,Xc,Yc]:=0;
End;

Procedure DeInitFont;
Begin
  Dispose(Font);
End;

Procedure DeInitPics;
Begin
  Dispose(Pic);
End;

{-----General-----}
Procedure READMSG(Message : String; Var Answer : String);
Var
  Xc,Yc : Word;
Begin
  WriteStr(5+3,20,True,Clr);
  WriteStr(5+3,20,True,Message);
  ReadStr (5+3+Ord(Message[0])*8,20,Answer);
  WriteStr(5+3,20,True,Clr);
End;

Procedure SaveColor;
Var
  K     : Char;
  Xc,Yc : Byte;
Begin
  Msg('ENTER THE COLOR NUMBER:');
  K:=ReadKey;
  If K In ['0'..'9'] Then
    Begin
      For Xc:=15+10*(Ord(K)-48) To 15+10*(Ord(K)-48)+10 Do
        For Yc:=206 To 216 Do
          Pixel(Xc,Yc,CurrColor);
      SvdColor[Ord(K)-48]:=CurrColor;
    End;
End;

Procedure SetNew;
Begin
  DeInitPics;
  InitPics;
  SetActive;
End;

Procedure Help(Hlp : Boolean);
Var
  Xc : Word;
Begin
  If Hlp Then For Xc:=80 To 160 Do
    Begin
      SetShowFrom(Xc*240);
      Delay(5);
    End Else For Xc:=80 DownTo 0 Do
      Begin
        SetShowFrom(Xc*240);
        Delay(5);
      End;
  If ReadKey=#0 Then ReadKey;
  If Hlp Then For Xc:=160 DownTo 80 Do
    Begin
      SetShowFrom(Xc*240);
      Delay(5);
    End Else For Xc:=0 To 80 Do
      Begin
        SetShowFrom(Xc*240);
        Delay(5);
      End;
End;


Procedure DelActive;
Begin
  FillChar(Pic^[Active],256,CurrColor);
  SetActive;
End;

Procedure Current;
Begin
  Box (74,60,8*18+10,68,back);
  WriteStr(10,60,True,'NAME   :');
  WriteStr(10+8*5,60,True,Picname);
End;

Procedure SetName;
Begin
  ReadMSG('ENTER NEW FILE NAME:',PICNAME);
  Current;
End;

Procedure PicNum;
Var
  Num : String;
Begin
  Str(Active,Num);
  DrawChar(10+8+8*15,40,True,'(');
  WriteStr(10+8*2+8*15,40,True,Num);
  DrawChar(10+8*2+8*15+8*Ord(Num[0]),40,True,')');
  If Active<10  Then WriteStr(10+8*3+8*15+8*Ord(Num[0]),40,True,'  ') Else
  If Active<100 Then WriteStr(10+8*3+8*15+8*Ord(Num[0]),40,True,' ');
End;

Procedure CopyNew;
Var
  Num :String;
Begin
  Str(Active,Num);
  DrawChar(10+8+8*15,50,True,'(');
  WriteStr(10+8*2+8*15,50,True,Num);
  DrawChar(10+8*2+8*15+8*Ord(Num[0]),50,True,')');
  If Active<10  Then WriteStr(10+8*3+8*15+8*Ord(Num[0]),50,True,'  ') Else
  If Active<100 Then WriteStr(10+8*3+8*15+8*Ord(Num[0]),50,True,' ');
  CopyedBox:=Active;
End;

Procedure CopyIt;
Var
  Xc,Yc : Byte;
Begin
  For Xc:=0 To 15 Do
    For Yc:=0 To 15 Do
      Pic^[Active,Xc,Yc]:=Pic^[CopyedBox,Xc,Yc];
  SetActive;
End;

Procedure ChkBounds;
Begin
  If CurX=16            Then CurX:= 0;
  If CurX=255           Then CurX:=15;
  If CurY=16            Then CurY:= 0;
  If CurY=255           Then CurY:=15;
  If Active=PicNumber   Then Active:=0;
  If Active>PicNumber-1 Then Active:=PicNumber-1;
End;

Procedure SetNumber;
Var
  Xc,Yc : Word;
  Num   : String;
  Err   : Integer;
Begin
  READMSG('NEW PIC NUMBER :',NUM);
  Val(Num,Active,Err);
  ChkBounds;
  PicNum;
  SetActive;
End;

Procedure TurnLeft(Left : Boolean);
Var
  Xc,Yc : Byte;
  Box1  : Tbox;
Begin
  For Xc:=0 TO 15 Do
    For Yc:=0 To 15 Do
      Box1[Xc,Yc]:=Pic^[Active,Yc,Xc];
  For Xc:=0 TO 15 Do
    For Yc:=0 To 15 Do
      If Left Then Pic^[Active,Xc,15-Yc]:=Box1[Xc,Yc] Else
                   Pic^[Active,15-Xc,Yc]:=Box1[Xc,Yc];
  SetActive;
End;

Procedure Shift(d : byte);
var xc,yc : byte;
    box1  : tbox;
Begin
      Box1:=pic^[active];
  case d of
   1 : begin {Up}
         for Yc := 0 to 14 do
           for Xc := 0 to 15 do
             pic^[Active,xc,yc]:=Box1[xc,yc+1];
         for xc:=0 to 15 do
           pic^[active,xc,15]:=box1[xc,0];
       end;
   2 : begin {Down}
         for Yc := 1 to 15 do
           for Xc := 0 to 15 do
             pic^[Active,xc,yc]:=Box1[xc,yc-1];
         for xc:=0 to 15 do
           pic^[active,xc,0]:=box1[xc,15];
       end;
   3 : begin {Left}
         for Xc := 0 to 14 do
           for Yc := 0 to 15 do
             pic^[Active,xc,yc]:=Box1[xc+1,yc];
         for Yc:=0 to 15 do
           pic^[active,15,yc]:=box1[0,yc];
       End;
   4 : begin {Right}
         for Xc := 1 to 15 do
           for Yc := 0 to 15 do
             pic^[Active,xc,yc]:=Box1[xc-1,yc];
         for Yc:=0 to 15 do
           pic^[active,0,yc]:=box1[15,yc];
       End;
  End;
  SetActive;
End;

Procedure XsideY(updown : boolean);
var xc,yc : byte;
    Box1  : Tbox;
Begin
  for xc:=0 to 15 do
    for yc:=0 to 15 do
      Box1[xc,yc]:=pic^[active,xc,yc];
  if updown then
    for xc:=0 to 15 do
      for Yc:=0 to 15 do
        pic^[active,xc,yc]:=box1[xc,15-yc]
  else
    for xc:=0 to 15 do
      for yc:=0 to 15 do
        pic^[active,xc,yc]:=box1[15-xc,yc];
  SetActive;
End;

Procedure HandleSpecial;
Begin
  KeyPressed:=ReadKey;
  Case KeyPressed Of
    {Arrows}
    #80 : CurY:=CurY+1;
    #72 : CurY:=CurY-1;
    #77 : CurX:=CurX+1;
    #75 : CurX:=CurX-1;

    {F ...}
    #59 : Help(True);
    #60 : LoadPic(False);
    #61 : LoadPic(True);
    #62 : SetName;
    #63 : SetNumber;
    #64 : SetNew;
    #65 : SaveColor;
    #66 : Help(False);

    #83 : DelActive;        {Del}

    #71 : TurnLeft(True );  {Home}
    #73 : TurnLeft(False);  {PGup}
    #79 : Begin Active:=PicNumber-1; SetActive; PicNum; End; {END}
    #81 : Begin Active:=0;           SetActive; PicNum; End;
  End;
  ChkBounds;
  if drawmode then Begin DrawInBox(CurX,CurY,CurrColor); DrawScreen; End;
  InitBox;
End;

Procedure HandleFuncs;
Begin
  Case KeyPressed Of
    #0       : HandleSpecial;
    #13      : Begin DrawInBox(CurX,CurY,CurrColor); DrawScreen; End;
    '+'      : Begin CurrColor:=CurrColor+1; RefreshColor; End;
    '-'      : Begin CurrColor:=CurrColor-1; RefreshColor; End;
    #44      : Begin Active:=Active-1; ChkBounds; SetActive; PicNum; End;
    #46      : Begin Active:=Active+1; ChkBounds; SetActive; PicNum; End;
    'C'      : CopyNew;
    'P'      : CopyIt;
    #9       : Begin CurrColor:=Pic^[Active,CurX,CurY]; RefreshColor; End;
    '0'..'9' : Begin CurrColor:=SvdColor[Ord(KeyPressed)-48]; RefreshColor; End;
    'w','W'  : Shift(1);
    'x','X'  : Shift(2);
    'a','A'  : Shift(3);
    'd','D'  : Shift(4);
    'e','E'  : XsideY(True);
    'e','R'  : XsideY(false);
    ^D       : drawmode:= not drawmode;
  End;
End;

Procedure Init;
Begin
  GetAllPal(CurPal);
  FillPalType(ExtraPal,0,0,0);
  Fade2Pal(ExtraPal,0,255,10);
  ClrScr;
  InitFont;
  SetXmode;
  GetAllPal(PPal);
  SetAllPal(ExtraPal);
  InitScreen;
  InitPics;
  InitBox;
  LoadPic(True);
  SetActive;
  Current;
  PicNum;
  InitHelp;
  InitAbout;
  ShowPage(1);
  Fade2Pal(PPal,0,255,10);
End;

Procedure DeInit;
Begin
  Fade2Pal(ExtraPal,0,255,10);
  DeInitPics;
  DeInitFont;
  SetTextMode;
  WriteLn;
  WriteLn('Bye...');
  WriteLn;
  SetAllPal(ExtraPal);
  Fade2Pal(CurPal,0,255,10);
End;

Begin
  If Exist(FntName) Then Begin
    Init;
    Repeat
      GetKey(KeyPressed);
      HandleFuncs;
    Until KeyPressed=#27;
    DeInit;
  End Else WriteLn(#10,#13,FNTNAME+'Not Found. (Could Not Initalize Font).',#10,#13);
End.