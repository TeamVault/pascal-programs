 program dd;
uses crt;
var b,x,y:integer;

procedure MouseInit;
begin
asm
mov ax,0;
int $33;
end;
end;

procedure MouseShow;
begin
asm
mov ax,1;
int $33;
end;
end;

procedure MouseHide;
begin
asm
mov ax,2;
int $33;
end;

procedure MouseData(var button,x,y:integer);
var bb,xx,yy:integer;
begin
asm
mov ax,3;int $33;
mov bb,bx; mov xx,cx; mov yy,dx;
end;
button:=bb;x:=xx div 8 + 1;y:=yy div 8 +1;
end;

begin
MouseInit;
MouseData(b,x,y);
MouseShow;
readln;
MouseHide;
end.