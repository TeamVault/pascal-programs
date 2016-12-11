Program CMMDC;
uses crt;
var a,b,opt:integer;label sfarsit;
   procedure cmmdc1;
begin
if (a>0)and (b>0) then
begin
while (a<>b) do
if (a>b) then a:=a-b
         else b:=b-a;
         writeln ('rezultatul este',a)

 end;
 end;
   function cmmdc2:real;
   begin
if (a>0)and (b>0) then
begin
while (a<>b) do
if (a>b) then a:=a-b
         else b:=b-a;
         cmmdc2:=a;
 end;
 end;
 begin
      writeln ('apesi 1 face procedura');
      writeln ('apesi 2 face functia');
      writeln ('apesi 3 face sa iese' {mai pe moldoveneste});
 writeln ('dati opt dv.');readln (opt);
 case opt of
 1: begin
 write ('dati vlorile  a celor 2 nr:');read(a,b);cmmdc1;
 delay (3000); clrscr ;

 end;
 2: begin
  write ( 'dati vlorile  a celor 2 nr:');read (a,b);cmmdc2 ;
  write ('rezultatul la functie este :',a);
  delay (3000);clrscr;
 end;
 3:goto sfarsit ;  {sau 3:exit sau gotoxy si coordonatele lui end."final"}
 end;
 sfarsit:end.