
program eger;
uses dos, crt;
type
    wordptr = ^word;
var
   but, xp, yp : word;

function initMouse : word;
var
   regs : Registers;
begin
     regs.AX := 0;
     intr($33, regs);
     initMouse := 0;
     if (regs.AX <> 0) then
     begin
          initMouse := regs.BX;
     end;
end;

procedure onMouse;
var
   regs : Registers;
begin
     regs.AX := 1;
     intr($33, regs);
end;


procedure offMouse;
var
   regs : Registers;
begin
     regs.AX := 2;
     intr($33, regs);
end;

procedure getMouse(buttons, xpos, ypos : wordptr);
var
   regs : Registers;
begin
     regs.AX := 3;
     intr($33, regs);
buttons^ := regs.BX;
xpos^ := regs.CX;
ypos^ := regs.DX;
end;

procedure setMouse(xpos, ypos : word);
var
   regs : Registers;
begin
     regs.AX := 3;
     regs.CX := xpos;
     regs.DX := ypos;
     intr($33, regs);
end;


begin
writeln('Egergombok szama: ', initMouse);
onMouse;
repeat
gotoXY(1,1);
getMouse(@but, @xp, @yp);
write(but,' ',xp,' ',yp);
until keypressed;
offMouse;
end.