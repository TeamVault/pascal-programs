 program ceasContinu;
 uses crt,dos;
 var    h,m,s,s100,c:word;

 procedure ora;
   begin
 repeat
 gettime(h,m,s,s100);
  gotoxy(34,12);textcolor(2);
 write(h,':',m,':',s,':',s100);
 until keypressed;
 end;
 begin
 textbackground(blue);clrscr;
 ora;
 end.


