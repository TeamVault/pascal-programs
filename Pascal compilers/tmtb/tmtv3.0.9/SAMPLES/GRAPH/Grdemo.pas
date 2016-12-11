(***********************************************)
(*                                             *)
(* Graph Unit Demo                             *)
(* Copyright (c) 1999 by TMT Development Corp. *)
(* Author: Vadim Bodrov, TMT Development Corp. *)
(*                                             *)
(* Targets:                                    *)
(*   MS-DOS 32-bit protected mode              *)
(*   Win32 Console                             *)
(***********************************************)

{$ifndef __CON__}
  This program must be compiled as MS-DOS or Win32 console application
{$endif}

 uses Graph, ZenTimer, CRT;

 const
   LineStyles : array[0..4] of string[9] =
    ('SolidLn', 'DottedLn', 'CenterLn', 'DashedLn', 'UserBitLn');

 var MaxX,MaxY: DWord;
     VST,HST:   Boolean:=false;
     GraphMode: Word:=0;

 function LongToStr (L: LongInt): String;
 var S: String;
 begin
  Str(L,S);
  LongToStr:= S;
 end;

 function RConv(R: LongInt): String;
 begin
  RConv:=LongToStr(R div 10)+'.'+LongToStr(R mod 10);
 end;

 function AddSpace (D: DWord): String;
 var S: String;
 begin
  S:=LongToStr(D);
  if Length(S)=3 then Result:=' '+S else Result:=S;
 end;

 function DWordToHex (D: DWord): String;
 const HexTable: array [0..15] of Char=('0','1','2','3','4','5','6','7',
                                        '8','9','A','B','C','D','E','F');
 var HexStr: String:='00000000';
     i:      DWord;
     s:      DWord:=24;
 begin
  s:=24;
  for i:=0 to 3 do begin
   HexStr[i*2+1]:=HexTable[(D shr s) and $F0 div 16];
   HexStr[i*2+2]:=HexTable[(D shr s) and $0F];
   Dec(s,8);
  end;
  Result:=HexStr;
 end;

 function GetChar (D: DWord): Char;
 begin
  if D<10 then
   Result:=Char(D+DWord('0'))
  else
   Result:=Char(D+55);
 end;

 function GetByte (C: Char): Byte;
 begin
  if C<'0' then begin
   Result:=0;
   exit;
  end;
  if C<'A' then
   Result:=Byte(C)-Byte('0')
  else
   Result:=Byte(C)-55;
 end;

 procedure MainFrame;
 begin
  ClrScr;
  Writeln;
  Writeln;
  Writeln;
{$ifdef __DOS__}
  Write('  VBE OEM string        : ');
  if GetOemString<>'' then
   Writeln(GetOemString)
  else
   Writeln('Unknown');
  if GetVbeVersion>0 then begin
   Write('  VBE version           : '+LongToStr(Hi(GetVbeVersion))+'.'+
    LongToStr(Lo(GetVbeVersion)));
   Writeln(' with '+LongToStr(TotalVbeMemory div 1024)+' Kb memory');
   if GetVbeVersion>=$200 then begin
    Writeln('  OEM vendor name       : '+GetOemVendorName);
    Writeln('  OEM product name      : '+GetOemProductName);
    Writeln('  OEM product revision  : '+GetOemProductRev);
    if GetLfbAddress<>0 then
     Writeln('  LFB located at        : $'+DWordToHex(GetLfbAddress));
   end else begin
    Writeln;
    Writeln('  Hint: Use UniVBE v5.1 or higher by SciTech Soft to gain access to');
    Writeln('        additional video modes and linear framebuffer.');
   end;
  end;
  Writeln;
{$endif}
 end;

 procedure TextBorder (Header: String);
 var i: DWord;
 begin
  GotoXY(Lo(WindMax) div 2 - Length(Header) div 2,1);
  Writeln(Header);
  for i:=2 to Lo(WindMax)-1 do begin
   GotoXY(i,2); Write('Ä');
   GotoXY(i,Hi(WindMax)); Write('Ä');
  end;
  GotoXY(1,2); Write('Ú');
  GotoXY(Lo(WindMax),2); Write('¿');
  GotoXY(1,Hi(WindMax)); Write('À');
  GotoXY(Lo(WindMax),Hi(WindMax)); Write('Ù');
  for i:=3 to Hi(WindMax)-1 do begin
   GotoXY(1,i); Write('³');
   GotoXY(Lo(WindMax),i); Write('³');
  end;
 end;

 function ModeSelect: DWord;
 var ModesList: array [0..70] of GraphModeType;
     Modes: array [0..70] of Word;
     Ch:  Char;
     Bpp,i,MaxMode: DWord;
 begin
  GetVbeModesList(ModesList);
  repeat
   repeat
    HideCursor;
    TextColor(White);
    MainFrame;
    Writeln('  [0]   - MCGA/VGA (13h BIOS) mode');
    Writeln('  [1]   - SVGA 08 bits per pixel modes');
    Writeln('  [2]   - SVGA 15 bits per pixel modes');
    Writeln('  [3]   - SVGA 16 bits per pixel modes');
    Writeln('  [4]   - SVGA 24 bits per pixel modes');
    Writeln('  [5]   - SVGA 32 bits per pixel modes');
    Writeln;
    Writeln('  [Esc] - exit');
    Writeln;
{$ifdef __DOS__}
    Write('  Demo options: [H]orizontal scrolling test : ');
    TextColor(LightGray);
    if HST then Writeln('Yes') else Writeln ('No ');
    TextColor(White);
    Write('                [V]ertical scrolling test   : ');
    TextColor(LightGray);
    if VST then Writeln('Yes') else Writeln ('No ');
    Writeln;
{$endif}
    TextColor(White);
    TextBorder('Graph unit demo program by TMT Corp., 1998');
    repeat
     Ch:=ReadKey;
     Ch:=UpCase(Ch)
    until ((Ch>='0') and (Ch<'6')) or (Ch='V') or (Ch='H') or (Ch=#27);
    if Ch='V' then VST:=not VST;
    if Ch='H' then HST:=not HST;
   until (Ch<>'V') and (Ch<>'H');
   if Ch=#27 then begin
    ShowCursor;
    NormVideo;
    ClrScr;
    Writeln(' GRDEMO terminated.');
    Halt(0);
   end;
   case Ch of
    '0': begin
          Result:=$13;
          exit;
         end;
    '1': Bpp:=8;
    '2': Bpp:=15;
    '3': Bpp:=16;
    '4': Bpp:=24;
    '5': Bpp:=32;
   end;
   ClrScr;
   Writeln;
   Writeln;
   MaxMode:=1;
   Writeln;
   for i:=0 to TotalVbeModes do begin
    if (ModesList[i].BitsPerPixel=Bpp) and (ModesList[i].VideoMode <> $FFFF) then
    begin
     Modes[MaxMode]:=i;
     Write('  [',GetChar(MaxMode),']   - ',AddSpace(ModesList[i].XResolution),
           ' x ',AddSpace(ModesList[i].YResolution),' ',AddSpace(ModesList[i].VideoMode));
     if ModesList[i].HaveLFB then
      Writeln(' (Banked and Linear)')
     else
      Writeln(' (Banked Only)');
     inc(MaxMode);
    end;
   end;
   if MaxMode=1 then Writeln('  Those modes are not supported');
   Writeln;
   Writeln('  [Esc] - return to main menu');
   TextBorder('Select mode resolution to test');
   repeat
    if Ch<>#27 then Ch:=UpCase(Readkey);
   until ((GetByte(Ch)>=1) and (GetByte(Ch)<MaxMode)) or (Ch=#27);
  until GetByte(Ch)>0;
  Result:=ModesList[Modes[GetByte(Ch)]].VideoMode;
{$ifndef __WIN32__}
  if ModesList[Modes[GetByte(Ch)]].HaveLfb then
  begin
   ClrScr;
   Writeln;
   Writeln;
   Writeln;
   Writeln('  [0] - Banked framebuffer mode');
   Writeln('  [1] - Linear framebuffer mode');
   TextBorder('Choose framebuffer mode');
   repeat
    Ch:=ReadKey;
   until (Ch>='0') and (Ch<='1');
   if Ch='1' then Result+$4000;
  end;
{$endif}
 end;

 procedure SetDefaults;
 begin
  MaxX:=GetMaxX;
  MaxY:=GetMaxY;
  SetColor(clWhite);
  SetLineStyle(SolidLn,0,NormWidth);
  SetTextJustify(LeftText,TopText);
 end;

 procedure DrawBorder;
 var
  ViewPort : ViewPortType;
 begin
  SetLineStyle(SolidLn,0,NormWidth);
  GetViewSettings(ViewPort);
  with ViewPort do Rectangle(0,0,X2-X1,Y2-Y1);
 end;

 procedure FullPort;
 begin
  SetViewPort(0,0,MaxX,MaxY,ClipOn);
 end;

 procedure MainWindow (Header: String);
 begin
  SetDefaults;
  ClearDevice;
  SetTextStyle(DefaultFont, HorizDir);
  SetTextJustify(CenterText, TopText);
  FullPort;
  OutTextXY(MaxX div 2,2,Header);
  SetViewPort(0,TextHeight('M')+4,MaxX,MaxY-(TextHeight('M')+4),ClipOn);
  DrawBorder;
  SetViewPort(1,TextHeight('M')+5,MaxX-1,MaxY-(TextHeight('M')+5),ClipOn);
 end;

 procedure GetMode (var ModeStr: String);
 begin
  if GraphMode=$13 then ModeStr:='MCGA/VGA' else begin
   case GetBitsPerPixel of
    8:  ModeStr:='SVGA (8 bpp)';
    15: ModeStr:='SVGA (15 bpp)';
    16: ModeStr:='SVGA (16 bpp)';
    24: ModeStr:='SVGA (24 bpp)';
    32: ModeStr:='SVGA (32 bpp)';
   end;
  end;
 end;

 procedure StatusLine(Msg: String);
 begin
  FullPort;
  SetTextStyle(DefaultFont,HorizDir);
  SetTextJustify(CenterText,TopText);
  SetLineStyle(SolidLn,0,NormWidth);
  SetFillStyle(SolidFill,clBlack);
  Bar(0,MaxY-(TextHeight('M')+4),MaxX,MaxY);
  Rectangle(0,MaxY-(TextHeight('M')+4), MaxX, MaxY);
  OutTextXY(MaxX div 2,MaxY-(TextHeight('M')+2), Msg);
  SetViewPort(1,TextHeight('M')+5,MaxX-1,MaxY-(TextHeight('M')+5),ClipOn);
 end;

 function WaitAKey: Boolean;
 var
  Ch : char;
 begin
  repeat until KeyPressed;
  Ch:=ReadKey;
  if Ch=#0 then Ch:=ReadKey;
  Result:=Ch=#27;
  ClearDevice;
 end;

 procedure ReportStatus;
 const X = 10;
 var ViewInfo   : ViewPortType;
     LineInfo   : LineSettingsType;
     TextInfo   : TextSettingsType;
     Palette    : PaletteType;
     ModeStr    : String;
     Y          : DWord;

 procedure WriteOut(S : string);
 begin
  OutTextXY(X,Y,S);
  Inc(Y,TextHeight('M')+2);
 end;

 begin
  GetMode(ModeStr);
  GetViewSettings(ViewInfo);
  GetLineSettings(LineInfo);
  GetTextSettings(TextInfo);
  GetPalette(Palette);
  Y:=4;
  MainWindow('Status report after SetGraphMode');
  SetTextJustify(LeftText, TopText);
  WriteOut('Graphics mode     : '+ModeStr);
  WriteOut('Screen resolution : (0, 0, '+LongToStr(GetMaxX)+', '+LongToStr(GetMaxY)+')');
  if isLfbUsed then
   WriteOut('LFB               : Enabled')
  else
   WriteOut('LFB               : Disabled');
  with ViewInfo do
  begin
    WriteOut('Current view port : ('+LongToStr(x1)+', '+LongToStr(y1)+', '+LongToStr(x2)+', '+LongToStr(y2)+')');
    if ClipOn then
      WriteOut('Clipping          : ON')
    else
      WriteOut('Clipping          : OFF');
  end;
  WriteOut('Max pages         : '+LongToStr(GetMaxPage+1));
  if GetMaxColor <= 255 then
    WriteOut('Palette entries   : '+LongToStr(Palette.Size));
  WriteOut('Max Color         : '+LongToStr(GetMaxColor));
  WriteOut('Current color     : '+LongToStr(GetColor));
  with LineInfo do
  begin
    WriteOut('Line style        : '+LineStyles[LineStyle]);
    WriteOut('Line thickness    : '+LongToStr(Thickness));
  end;
  if WaitAKey then exit;
 end;

 function RandColor : DWord;
 begin
  Result:=Random($FFFF)+DWord(Random($FFFF)) shl 16;
  case GetBitsPerPixel of
   8:     Result:=Result and $FF;
   15,16: Result:=Result and $FFFF;
   24,32: Result:=Result and $FFFFFF;
  end;
 end;

 procedure CircleDemo;
 var MaxRadius: DWord;
 begin
  MainWindow('Circle demonstration');
  StatusLine('Esc aborts or press a key');
  MaxRadius:=MaxY div 10;
  repeat
   SetColor(RandColor);
   Circle(Random(MaxX),Random(MaxY),Random(MaxRadius));
  until KeyPressed;
 end;

 procedure FillEllipseDemo;
 var FillColor,MaxRadius: DWord;
 begin
  MainWindow('FillEllipse demonstration');
  StatusLine('Esc aborts or press a key');
  MaxRadius:=MaxY div 10;
  repeat
   FillColor:=RandColor;
   SetColor(not FillColor);
   SetFillStyle(Random(12),FillColor);
   FillEllipse(Random(MaxX),Random(MaxY),Random(MaxRadius),Random(MaxRadius));
  until KeyPressed;
 end;

 procedure RandBarDemo;
 var MaxWidth: DWord;
     MaxHeight: DWord;
     ViewInfo: ViewPortType;
     Color: DWord;
 begin
  MainWindow('Random Bars');
  StatusLine('Esc aborts or press a key');
  GetViewSettings(ViewInfo);
  with ViewInfo do begin
    MaxWidth:=X2-X1;
    MaxHeight:=Y2-Y1;
  end;
  repeat
   Color:=RandColor;
   SetColor(Color);
   SetFillStyle(Random(12), not Color);
   Bar3D(Random(MaxWidth),Random(MaxHeight),Random(MaxWidth),Random(MaxHeight),0,TopOff);
  until KeyPressed;
 end;

 procedure PutImageDemo;
 var R: DWord:=20;
     CurPort : ViewPortType;
     StartX,StartY: LongInt;
     XDir,YDir: LongInt;

 procedure MoveSaucer (var X, Y: LongInt; Width, Height: DWord);
 begin
  inc(X,XDir);
  inc(Y,YDir);
  if Random(100)>95 then XDir:=XDir+1;
  if Random(100)>95 then YDir:=YDir+1;
  if Random(100)>95 then XDir:=XDir-1;
  if Random(100)>95 then YDir:=YDir-1;
  with CurPort do begin
   if X1+X > X2 then
    XDir:=-Random(5)-1
   else
    if X<-2*R then XDir:=Random(5)+1;
    if Y1+Y > Y2 then YDir:=-Random(5)-1
    else
     if Y<-R then YDir:=Random(5)+1;
   end;
 end;

 var
  Asp       : Real;
  Saucer    : Pointer;
  BackGndr  : Pointer;
  X, Y      : LongInt;
  ulx, uly  : DWord;
  lrx, lry  : DWord;
  sx,sy     : DWord;
  Size      : DWord;
  i         : Dword;
 begin
  GetAspectRatio(Asp);
  FullPort;
  XDir:=Random(5)+1;
  YDir:=Random(5)+1;
  StartX:=MaxX div 2;
  StartY:=MaxY div 2;
  MainWindow('GetImage / Transparent PutImage Demo');
  StatusLine('Esc aborts or press a key...');
  GetViewSettings(CurPort);
  DrawEllipse(StartX,StartY,R,(R div 3)+2);
  DrawEllipse(StartX,StartY-4,R,R div 3);
  Line(StartX+7,StartY-6,StartX+10,StartY-12);
  Circle(StartX+10,StartY-12,2);
  Line(StartX-7,StartY-6,StartX-10,StartY-12);
  Circle(StartX-10,StartY-12,2);
  SetFillStyle(SolidFill,clWhite);
  FloodFill(StartX+1,StartY+4,GetColor);
  SetFillStyle(SolidFill,clRed);
  ExpandFill(StartX+1,StartY-4);

  ulx:=StartX-(R+1);
  uly:=StartY-14;
  lrx:=StartX+(R+1);
  lry:=StartY+(R*2);
  sx:=lrx-ulx+1;
  sy:=lry-uly+1;

  Size:=ImageSize(ulx,uly,ulx+SX,uly+SY);
  GetMem(Saucer,Size);
  if Saucer=nil then exit;
  GetMem(BackGndr,Size);
  if BackGndr=nil then begin
   FreeMem(Saucer,Size);
   exit;
  end;
  GetImage(ulx,uly,ulx+SX,uly+sy,Saucer^);

  { Plot some "stars" }
  for i:=1 to 1000 do PutPixel(Random(MaxX),Random(MaxY),RandColor);
  SetFillStyle(SolidFill,clBlue);
  X:=MaxX div 2;
  Y:=MaxY div 2;

  { Dwar planet }
  SetFillStyle(SolidFill,clLightBlue);
  FillCircle(StartX,StartY,Round(MaxY div 4 /Asp));

  { Move the saucer around }
  repeat
    GetImage(X,Y,X+SX,Y+SY,BackGndr^);
    SetTranspMode(True,clBlack);
    PutImage(X,Y,Saucer^);                -- draw image
    Delay(20); Retrace;
    SetTranspMode(False,0);
    PutImage(X,Y,BackGndr^);              -- restore background
    MoveSaucer(X,Y,lrx-ulx+1,lry-uly+1);  -- width/height
  until KeyPressed;
  SetTranspMode(False,0);
  FreeMem(Saucer,Size);
  FreeMem(BackGndr,Size);
 end;

 procedure AspectRatioDemo;
 var ViewInfo: ViewPortType;
     CenterX: LongInt;
     CenterY: LongInt;
     Radius: DWord;
     i: LongInt;
     AspInc,Asp,A: Real;
     RadiusStep: DWord;
 begin
  MainWindow('Aspect Ratio demonstration');
  GetViewSettings(ViewInfo);
  GetAspectRatio(Asp);
  with ViewInfo do begin
   CenterX:=(x2-x1) div 2;
   CenterY:=(y2-y1) div 2;
   Radius:=Round((y2-y1)/Asp/2);

  end;
  RadiusStep:=(Radius div 30);
  Circle(CenterX,CenterY,Radius);
  AspInc:=Asp/30;
  A:=Asp;
  for i:=1 to 30 do begin
   A:=A-AspInc;
   SetAspectRatio(A);
   Circle(CenterX,CenterY,Radius);
   Dec(Radius,RadiusStep);
  end;
  Inc(Radius,RadiusStep*30);
  A:=Asp;
  for i:=1 to 30 do begin
   A:=A+AspInc;
   SetAspectRatio(A);
   if Radius>RadiusStep then Dec(Radius,RadiusStep);
   Circle(CenterX,CenterY,Radius);
  end;
  SetAspectRatio(Asp);
 end;

 procedure FillTriangleDemo;
 const MaxPts= 4;
 var Color: DWord;
 begin
  MainWindow('FillTriangle demonstration');
  StatusLine('Esc aborts or press a key...');
  repeat
   Color:=RandColor;
   SetFillStyle(Random(12), Color);
   SetColor(not Color);
   FillTriangle(Random(MaxX),Random(MaxY),Random(MaxX),Random(MaxY),
            Random(MaxX),Random(MaxY));
  until KeyPressed;
 end;

 procedure BarDemo;
 const
  NumBars   = 7;
  BarHeight : array[1..NumBars] of DWord = (1, 3, 5, 2, 4, 3, 1);
 var
  ViewInfo  : ViewPortType;
  BarNum    : DWord;
  H         : DWord;
  XStep     : Real;
  YStep     : Real;
  i,j       : LongInt;
  Color     : DWord;
 begin
  MainWindow('Bar / Rectangle demonstration');
  H:=3*TextHeight('M');
  GetViewSettings(ViewInfo);
  SetTextJustify(CenterText,TopText);
  SetTextStyle(DefaultFont,HorizDir);
  OutTextXY(MaxX div 2,6,'These are 2D bars');
  SetTextStyle(DefaultFont,HorizDir);
  with ViewInfo do
    SetViewPort(x1+50,y1+30,x2-50,y2-10,ClipOn);
  GetViewSettings(ViewInfo);
  with ViewInfo do begin
   Line(H,H,H,(y2-y1)-H);
   Line(H,(y2-y1)-H,(x2-x1)-H,(y2-y1)-H);
   YStep:=((y2-y1)-(2*H))/NumBars;
   XStep:=((x2-x1)-(2*H))/NumBars;
   J:=(y2-y1)-H;
   SetTextJustify(LeftText,CenterText);
   for i:=0 to NumBars do
   begin
    Line(H div 2,j,H,j);
    OutTextXY(0,j,LongToStr(i));
    J:=Round(j-Ystep);
   end;
   j:=H;
   SetTextJustify(CenterText,TopText);
   for i:=1 to Succ(NumBars) do begin
    SetColor(clWhite);
    Line(j,(y2-y1)-H,j,(y2-y1-3)-(H div 2));
    OutTextXY(j,(y2-y1)-(H div 2),LongToStr(i));
    if i<>Succ(NumBars) then begin
     SetFillColor(RandColor);
     Bar(j,Round((y2-y1-H)-(BarHeight[i]*Ystep)),Round(j+Xstep),(y2-y1)-H-1);
     Rectangle(j,Round((y2-y1-H)-(BarHeight[i]*Ystep)),Round(j+Xstep),(y2-y1)-H-1);
    end;
    j:=Round(j+Xstep);
   end;
  end;
 end;

 procedure Bar3DDemo;
 const
  NumBars   = 9;
  BarHeight : array[1..NumBars] of DWord = (1, 3, 2, 5, 4, 2, 1, 2, 5);
  YTicks    = 5;
 var
  ViewInfo : ViewPortType;
  H        : DWord;
  XStep    : Real;
  YStep    : Real;
  i,j      : LongInt;
  Depth    : DWord;
  Color    : DWord;
 begin
  MainWindow('Bar3D / Rectangle demonstration');
  H:=3*TextHeight('M');
  GetViewSettings(ViewInfo);
  SetTextJustify(CenterText,TopText);
  SetTextStyle(DefaultFont,HorizDir);
  OutTextXY(MaxX div 2,6,'These are 3D bars');
  SetTextStyle(DefaultFont,HorizDir);
  with ViewInfo do SetViewPort(x1+50,y1+40,x2-50,y2-10,ClipOn);
  GetViewSettings(ViewInfo);
  with ViewInfo do begin
   Line(H,H,H,(y2-y1)-H);
   Line(H,(y2-y1)-H,(x2-x1)-H,(y2-y1)-H);
   YStep:=((y2-y1)-(2*H))/YTicks;
   XStep:=((x2-x1)-(2*H))/NumBars;
   j:=(y2-y1)-H;
   SetTextJustify(LeftText,CenterText);
   for i:=0 to Yticks do begin
    Line(H div 2,j,H,j);
    OutTextXY(0,j,LongToStr(i));
    j:=Round(j-Ystep);
   end;
   Depth:=Trunc(0.25*XStep);
   SetTextJustify(CenterText,TopText);
   j:=H;
   for i:=1 to Succ(NumBars) do begin
    SetColor(clWhite);
    Line(j,(y2-y1)-H,j,(y2-y1-3)-(H div 2));
    OutTextXY(j,(y2-y1)-(H div 2),LongToStr(i-1));
    if i<>Succ(NumBars) then begin
     SetFillStyle(i, RandColor);
     Bar3D(j,Round((y2-y1-H)-(BarHeight[i]*Ystep)),
     Round(j+Xstep-Depth),Round((y2-y1)-H-1),Depth,TopOn);
     j:=Round(j+Xstep);
    end;
   end;
  end;
 end;

 procedure LineStyleDemo;
 var Style    : Word;
     Step     : DWord;
     X,Y      : DWord;
     ViewInfo : ViewPortType;
 begin
  ClearDevice;
  SetDefaults;
  MainWindow('Pre-defined line styles');
  GetViewSettings(ViewInfo);
  with ViewInfo do begin
   X:=35;
   Y:=10;
   Step:=(x2-x1) div 11;
   SetTextJustify(LeftText,TopText);
   OutTextXY(X,Y,'NormWidth');
   SetTextJustify(CenterText,TopText);
   for Style:=0 to 3 do begin
    SetLineStyle(Style,0,NormWidth);
    Line(X,Y+20,X,Y2-40);
    OutTextXY(X,Y2-35,LongToStr(Style));
    Inc(X,Step);
   end;
   Inc(X,2*Step);
   SetTextJustify(LeftText,TopText);
   OutTextXY(X,Y,'ThickWidth');
   SetTextJustify(CenterText,TopText);
   for Style:=0 to 3 do begin
    SetLineStyle(Style,0,ThickWidth);
    Line(X,Y+20,X,Y2-40);
    OutTextXY(X,Y2-35,LongToStr(Style));
    Inc(X,Step);
   end;
   end;
   SetTextJustify(LeftText,TopText);
 end;

 procedure UserLineStyleDemo;
 var Style    : Word:=0;
     X,Y      : DWord;
     i        : Word:=0;
     ViewInfo : ViewPortType;
 begin
  MainWindow('User defined line styles');
  GetViewSettings(ViewInfo);
  with ViewInfo do begin
   X:=4;
   Y:=10;
   while X<X2-4 do begin
    Style:=Style or (1 shl (i mod 16));
    SetLineStyle(UserBitLn,Style,NormWidth);
    Line(X,Y,X,(y2-y1)-Y);
    Inc(X,5);
    Inc(i);
    if Style=$FFFF then begin
     i:=0;
     Style:=0;
    end;
   end;
  end;
 end;

 procedure CrtModeDemo;
 var ViewInfo : ViewPortType;
     Ch       : Char;
 begin
  MainWindow('SetGraphMode / RestoreCrtMode demo');
  GetViewSettings(ViewInfo);
  SetTextJustify(CenterText, CenterText);
  with ViewInfo do begin
   OutTextXY((x2-x1) div 2,(y2-y1) div 2,'Now you are in graphics mode');
   StatusLine('Press any key for text mode...');
  repeat until KeyPressed;
  Ch:=ReadKey;
  if Ch=#0 then Ch:=Readkey;
  RestoreCrtMode;
  ClrScr;
  Writeln;
  Writeln;
  Writeln('  Now you are in text mode');
  Writeln('  Press any key to go back to graphics...');
  TextBorder('SetGraphMode / RestoreCrtMode demo');
  repeat until KeyPressed;
   Ch:=ReadKey;
   if Ch=#0 then Ch:=Readkey;
   SetGraphMode(GraphMode);
   MainWindow('SetGraphMode / RestoreCrtMode demo');
   SetTextJustify(CenterText,CenterText);
   OutTextXY((x2-x1) div 2,(y2-y1) div 2,'Back in graphics mode...');
  end;
 end;

 procedure PolyDemo;
 const MaxPts= 4;
 var Poly: array[1..MaxPts] of PointType;
     i,Color: DWord;
 begin
  MainWindow('FillPoly demonstration');
  StatusLine('Esc aborts or press a key...');
  repeat
   Color:=RandColor;
   SetFillStyle(Random(12),Color);
   SetColor(Color);
   for i:=1 to MaxPts do
    with Poly[I] do begin
     X:=Random(MaxX);
     Y:=Random(MaxY);
    end;
   FillPoly(MaxPts,Poly);
  until KeyPressed;
 end;

 procedure LineToDemo;
 const MaxPoints= 15;
 var
  Points     : array[0..MaxPoints] of PointType;
  ViewInfo   : ViewPortType;
  Asp        : Real;
  i,j        : LongInt;
  CenterX    : LongInt;
  CenterY    : LongInt;
  Radius     : DWord;
  StepAngle  : DWord;
  Xasp,Yasp  : DWord;
  Radians    : Real;

 begin
  MainWindow('MoveTo, LineTo demonstration');
  GetAspectRatio(Asp);
  GetViewSettings(ViewInfo);
  with ViewInfo do begin
   CenterX:=(x2-x1) div 2;
   CenterY:=(y2-y1) div 2;
   Radius:=Round((y2-y1) div 3 / Asp);
   while Round(CenterY+Asp*(Radius))<(y2-y1)-20 do Inc(Radius);
  end;
  StepAngle:=360 div MaxPoints;
  for i:=0 to MaxPoints-1 do begin
   Radians:=(StepAngle*i)*Pi/180;
   Points[I].X:=CenterX+Round(Cos(Radians)*Radius);
   Points[I].Y:=CenterY-Round(Asp*(Sin(Radians)*Radius));
  end;
  Circle(CenterX,CenterY,Radius);
  for j:=0 to MaxPoints-1 do begin
   for i:=j to MaxPoints-1 do begin
    MoveTo(Points[I].X,Points[I].Y);
    LineTo(Points[J].X,Points[J].Y);
   end;
 end;
 end;

 procedure DrawPattern;
 var i: DWord;
     Value: Byte;
     ViewInfo: ViewPortType;
     Height: DWord;
 begin
  GetViewSettings(ViewInfo);
  Height:=ViewInfo.Y2-ViewInfo.Y1;
  if GetBitsPerPixel>8 then begin
   for i:=0 to ViewInfo.X2 do begin
    SetColor(RGBColor(i*255 div ViewInfo.X2,0,0));
    Line(ViewInfo.X2 shr 1,Height shr 1,i,0);
    SetColor(RGBColor(0,i*255 div ViewInfo.X2,0));
    Line(ViewInfo.X2 shr 1,Height shr 1,i,Height);
   end;
   for i:=0 to Height do begin
    value:=Byte(i*255 div Height);
    SetColor(RGBColor(value,0,255-value));
    Line(ViewInfo.X2 shr 1,Height shr 1,0,i);
    SetColor(RGBColor(0,255-value,value));
    Line(ViewInfo.X2 shr 1,Height shr 1,ViewInfo.X2,i);
   end;
  end else begin
   i:=0;
   repeat
    SetColor(i mod 255);
    Line(ViewInfo.X2 shr 1,Height shr 1,i,0);
    SetColor((i+1) mod 255);
    Line(ViewInfo.X2 shr 1,Height shr 1,i,Height);
    inc(i,4);
   until (i>ViewInfo.X2);
   i:=0;
   repeat
    SetColor((i+2) mod 255);
    Line(ViewInfo.X2 shr 1,Height shr 1,0,i);
    SetColor((i+3) mod 255);
    Line(ViewInfo.X2 shr 1,Height shr 1,ViewInfo.X2,i);
    inc(i,4);
   until (i>Height);
  end;
 end;

 procedure ColorDemo;
 begin
  MainWindow('Color demonstration');
  DrawPattern;
 end;

 procedure ScrollTest;
 var MY,MX,i: Word;
 begin
{$ifdef __DOS__}
  if VST then begin
   ClearDevice;
   SetScreenStart(10,0,false);
   if GraphResult<>grOk then exit;
   SetScreenStart(0,0,false);
   MY:=MaxY;
   MX:=MaxX;
   i:=TotalVbeMemory div (GetScreenHeight+1) div ((GetBitsPerPixel+1) div 8);
   repeat
    SetLogicalPage(i,my);
    GetLogicalPage(mx,my);
    dec(i);
   until (mx>GetScreenWidth) or (i<GetScreenWidth);
   if (GetScreenWidth<mx) and (GetScreenWidth<i) then begin
    MainWindow('Horizontal scrolling demo');
    StatusLine('Esc aborts or press a key...');
    DrawPattern;
    ReadKey;
    for i:=0 to (MX-GetScreenWidth) do begin
     SetScreenStart(i,0,false);
     Delay(1);
     if KeyPressed then exit;
    end;
    ReadKey;
    for i:=(MX-GetScreenWidth) downto 0 do begin
     SetScreenStart(i,0,false);
     Delay(1);
     if KeyPressed then exit;
    end;
   end;
   ReadKey;
  end;
  if HST then begin
   ClearDevice;
   if GraphResult<>grOk then exit;
   SetScreenStart(0,0,false);
   my:=TotalVbeMemory div GetScreenWidth div ((GetBitsPerPixel+1) div 8);
   SetLogicalPage(GetScreenWidth,my);
   GetLogicalPage(mx,my);
   if GetScreenHeight<my then begin
   MainWindow('Vertical scrolling demo');
   StatusLine('Esc aborts or press a key...');
   DrawPattern;
   ReadKey;
   for i:=0 to (MY-GetScreenHeight) do begin
    SetScreenStart(0,i,false);
    Delay(2);
    if KeyPressed then exit;
   end;
   ReadKey;
   for i:=(MY-GetScreenHeight) downto 0 do begin
    SetScreenStart(0,i,false);
    Delay(2);
    if KeyPressed then exit;
   end;
  end;
  end;
{$endif}
 end;

 procedure PaletteDemo;
 var Pal,DPal: PaletteType;
     i,j: DWord;
 begin
  MainWindow('Palette demonstartion');
  StatusLine('Esc aborts or press a key...');
  DrawPattern;
  ReadKey;
  GetPalette(DPal);
  GetPalette(Pal);
  for j:=0 to 63 do begin
   for i:=0 to 256 do begin
    if RGBType(Pal.Colors[i]).Red>0 then Dec(RGBType(Pal.Colors[i]).Red);
    if RGBType(Pal.Colors[i]).Green>0 then Dec(RGBType(Pal.Colors[i]).Green);
    if RGBType(Pal.Colors[i]).Blue>0 then Dec(RGBType(Pal.Colors[i]).Blue);
   end;
   if KeyPressed then begin
    SetAllPalette(DPal);
    exit;
   end;
   Retrace;
   Retrace;
   SetAllPalette(Pal);
  end;
  Delay(100);
  for j:=0 to 63 do begin
   for i:=0 to 256 do begin
    if RGBType(Pal.Colors[i]).Red<RGBType(DPal.Colors[i]).Red
     then Inc(RGBType(Pal.Colors[i]).Red);
    if RGBType(Pal.Colors[i]).Green<RGBType(DPal.Colors[i]).Green
     then Inc(RGBType(Pal.Colors[i]).Green);
    if RGBType(Pal.Colors[i]).Blue<RGBType(DPal.Colors[i]).Blue
     then Inc(RGBType(Pal.Colors[i]).Blue);
   end;
   if KeyPressed then begin
    SetAllPalette(DPal);
    exit;
   end;
   Retrace;
   Retrace;
   SetAllPalette(Pal);
  end;
 end;

 function FlipDemo: Boolean;
 var i,j,iStep,jStep,APage,Vpage: LongInt;
     fpsRate,midRate: LongInt;
     lastCount,newCount: LongInt;
     S1,S2,S3: String;
 begin
  fpsRate:=0;
  if GetMaxPage>0 then begin
   VPage:=0;
   APage:=1;
   SetActivePage(APage);
   SetVisualPage(VPage,true);
   SetDefaults;
   FullPort;
   i:=0;
   j:=MaxX;
   iStep:=2;
   jStep:=-2;
   S3:='0';
   Str(GetMaxPage+1,S2);
   LastCount:=0;
   midRate:=0;
   LZTimerOn;
   repeat
    SetActivePage(APage);
    ClearPage;
    OutTextXY(10,10,'Pages flipping');
    OutTextXY(10,26,'FPS rate '+RConv(fpsRate)+' FPS, Page '+
     LongToStr(APage+1)+' of '+S2);
    Line(i,0,MaxX-i,MaxY);
    Line(0,MaxY-j,MaxX,j);
    Rectangle(0,0,GetMaxX,GetMaxY);
    VPage:=(VPage+1) mod (GetMaxPage+1);
    SetVisualPage(VPage,true);
    if APage=0 then begin
      newCount:=LZTimerLap;
      fpsRate:=Word(10000000 div (newCount-lastCount))*(GetMaxPage+1);
      if midRate=0 then
       midRate:=fpsRate
      else midRate:=(midRate+fpsRate) shr 1;
      lastCount:=newCount;
    end;
    APage:=(APage+1) mod (GetMaxPage+1);
    inc(i,iStep);
    if i>MaxX then begin
     i:=MaxX-2;
     iStep:=-2;
    end;
    if i<0 then begin
     i:=2;
     iStep:=2;
    end;
    inc(j,jStep);
    if j>MaxY then begin
     j:=MaxY-2;
     jStep:=-2;
    end;
    if j<0 then begin
     j:=2;
     jStep:=2;
    end;
  until (KeyPressed);
  LZTimerOff;
  SetActivePage(0);
  SetVisualPage(0,true);
  Result:=true;
  end else Result:=false;
 end;

 procedure XorDemo;
 var r,s,i: DWord;
     Asp: Real;
 begin
  MainWindow('XorPut demonstartion');
  StatusLine('Esc aborts or press a key...');
  SetWriteMode(XorPut);
  GetAspectRatio(Asp);
  r:=(Round(GetMaxY/Asp) div 2)-32;
  repeat
   i:=0;
   s:=r div 15;
   repeat
    Circle(MaxX div 2,MaxY div 2 - 16,i);
    Retrace;
    Circle(MaxX div 2,MaxY div 2 - 16,(r-i));
    Retrace;
    inc(i,s);
   until i>=r;
  until KeyPressed;
  SetWriteMode(NormalPut);
 end;

 procedure DoTest;
 begin
  ReportStatus;
  if GetBitsPerPixel>8 then
   ColorDemo
  else
   PaletteDemo;
   if WaitAKey then exit;
  if (VST) or (HST) then begin
   ScrollTest;
   if WaitAKey then exit;
   SetGraphMode(GraphMode);
  end;
  CircleDemo;
  if WaitAKey then exit;
  FillEllipseDemo;
  if WaitAKey then exit;
  RandBarDemo;
  if WaitAKey then exit;
  XorDemo;
  if WaitAKey then exit;
  PutImageDemo;
  if WaitAKey then exit;
  AspectRatioDemo;
  if WaitAKey then exit;
  FillTriangleDemo;
  if WaitAKey then exit;
  BarDemo;
  if WaitAKey then exit;
  Bar3DDemo;
  if WaitAKey then exit;
  LineStyleDemo;
  if WaitAKey then exit;
  UserLineStyleDemo;
  if WaitAKey then exit;
  if FlipDemo then if WaitAKey then exit;
  CrtModeDemo;
  if WaitAKey then exit;
  PolyDemo;
  if WaitAKey then exit;
  LineToDemo;
  if WaitAKey then exit;
 end;

{$ifdef __WIN32__}
function SetConsoleTitle conv arg_stdcall (lpConsoleTitle: PChar): Boolean;
external 'kernel32.dll' name 'SetConsoleTitleA';
{$endif}

begin
{$ifdef __WIN32__}
  SetConsoleTitle('Graph unit Demo for Win32');
{$endif};
  TextMode(CO80);
  ClrScr;
  repeat
   GraphMode:=ModeSelect;
   SetGraphMode(GraphMode);
   if GraphResult=grOk then begin
    DoTest;
    CloseGraph;
   end else begin
    CloseGraph;
    Writeln;
    Writeln;
    Writeln('  Selected mode is not supported.');
    Writeln('  Press any key...');
    TextBorder('');
    ReadKey;
   end;
  until false;
end.