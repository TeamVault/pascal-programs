Program data_calendaristica;
uses crt;
var L  :array[1..12] of byte;
     ziua,luna,anul:integer;
     i,ziuac:integer;
     bisect:boolean;
begin
clrscr;
         L[1]:=31;         L[5]:=31;               L[9]:=30;
         L[2]:=29;         L[6]:=30;               L[10]:=31;
         L[3]:=31;         L[7]:=31;               L[11]:=30;
         L[4]:=30;         L[8]:=31;               L[12]:=31;

     writeln('dati luna:');
     readln(luna);
     if luna>12 then halt;
                         writeln('dati ziua');
                         readln(ziua);
     if ziua>31 then  halt;
                         writeln ('dati anul');
                         readln (anul);
      bisect:=false;
      if (anul=1000)or (anul=2000) or(anul=3000) then bisect:=true
      else
      if(anul mod 4=0)and (anul mod 100<>0) then bisect:=true;
      if bisect then  L[2]:=28;
      i:=1;
      ziuac:=0;
      while   i<luna  do
            begin
               ziuac:=ziuac+L[i];
               i:=i+1;
               end;
      ziuac:=ziuac+ziua;
      write('ziua a',ziuac,'-a');
      readln;
end.