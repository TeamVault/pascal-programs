program testmouse;
uses crt;
var x,y,b:integer;
 procedure MouseInit;assembler;
  asm mov ax,0;int $33 end;
procedure MouseShow;assembler;
 asm mov ax,1; int $33 end;
procedure MouseData(var buton,x,y:integer);
var bb,xx,yy:integer;
  begin
  asm mov ax,3; int $33; mov bb,bx; mov xx,cx; mov yy,dx end;
  buton:=bb;x:=xx div 8 +1;y:=yy div 8+1;
  end;
procedure MouseHide;assembler;
asm mov ax,2; int $33 end;


begin
clrscr;mouseinit;mouseshow;
repeat
 mousedata(b,x,y);
 if (b=1) {and (x=25) and (y=7)} then {opt:=1;}
 mousehide; gotoxy(x,y);write('#178');mouseshow;  end;
 until b=2;
 end.

