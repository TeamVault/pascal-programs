program cmmdc_si_cmmmc;
uses crt;
var a,b,u,v,cmmmc:integer;
BEGIN
 clrscr;
 Write('Dati a: ');
 Readln(a);
 Write('Dati b: ');
 Readln(b);
 u:=a;v:=b;
 If (a>0) and (b>0) then
  While (a<>b) do
   Begin
    If (a>b) then a:=a-b
             else b:=b-a;
   End;textcolor (blue);
   Writeln('c.m.m.d.c este: ',a);
   cmmmc:=u*v div a;
   Writeln('c.m.m.m.c este: ',cmmmc);
 Readln;
END.