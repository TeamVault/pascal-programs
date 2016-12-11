     {program care imi scrie pe ecran numele in tot felul de caractere}
  program paul_muntean_virtual_3d;
  uses crt;
  var x,p,i,s,l,e,r,d,c:integer;
  begin
gotoxy(12,12);  writeln ('ecranul va fi coplesit!!!!!!!!'); delay(2000);
clrscr;

repeat
randomize;

x:=random(256);
p:=random(256);
s:=random(256);
l:=random(256);
e:=random(256);
r:=random(256);
d:=random(256);
c:=random(256);
textbackground(x);
TEXTcolor(l);
TEXTcolor(r);
TEXTcolor(d);
TEXTcolor(c);
TEXTcolor(s);
TEXTcolor(e);
TEXTcolor(s);
textcolor(p);
gotoxy(6,2);write(char(p));   {P}
gotoxy(6,3);write(char(s));
gotoxy(6,4);write(char(l));
gotoxy(6,5);write(char(e));
gotoxy(6,6);write(char(r));
gotoxy(6,7);write(char(d));
gotoxy(6,8);write(char(c));
gotoxy(6,9);write(char(p));
gotoxy(7,2);write(char(p));
gotoxy(7,6);write(char(p));
gotoxy(8,2);write(char(p));
gotoxy(8,6);write(char(p));
gotoxy(9,3);write(char(l));
gotoxy(9,4);write(char(e));
gotoxy(9,5);write(char(r));
gotoxy(9,2);write(char(d));
gotoxy(9,6);write(char(s));

gotoxy(11,3);write(char(l));   {A}
gotoxy(11,4);write(char(e));
gotoxy(11,5);write(char(r));
gotoxy(11,6);write(char(d));
gotoxy(11,7);write(char(s));
gotoxy(11,8);write(char(c));
gotoxy(11,9);write(char(p));
gotoxy(12,2);write(char(p));
gotoxy(13,2);write(char(l));
gotoxy(14,3);write(char(s));
gotoxy(14,4);write(char(r));
gotoxy(14,5);write(char(p));
gotoxy(14,6);write(char(p));
gotoxy(14,7);write(char(p));
gotoxy(14,8);write(char(p));
gotoxy(14,9);write(char(d));
gotoxy(12,5);write(char(c));
gotoxy(13,5);write(char(p));
     TEXTcolor(e);
gotoxy(16,2);write(char(p));   {U}
gotoxy(16,3);write(char(x));
gotoxy(16,4);write(char(p));
gotoxy(16,5);write(char(s));
gotoxy(16,6);write(char(c));
gotoxy(16,7);write(char(d));
gotoxy(16,8);write(char(l));
gotoxy(19,2);write(char(d));
gotoxy(19,3);write(char(p));
gotoxy(19,4);write(char(p));
gotoxy(19,5);write(char(s));
gotoxy(19,6);write(char(l));
gotoxy(19,7);write(char(r));
gotoxy(19,8);write(char(d));
gotoxy(17,9);write(char(x));
gotoxy(18,9);write(char(p));
  TEXTcolor(r);
gotoxy(21,2);write(char(s));   {L}
gotoxy(21,3);write(char(l));
gotoxy(21,4);write(char(d));
gotoxy(21,5);write(char(c));
gotoxy(21,6);write(char(p));
gotoxy(21,7);write(char(p));
gotoxy(21,8);write(char(p));
gotoxy(21,9);write(char(c));
gotoxy(22,9);write(char(e));
gotoxy(23,9);write(char(p));
gotoxy(24,9);write(char(p));
  TEXTcolor(c);

gotoxy(27,2);write(char(p));   {M}
gotoxy(27,3);write(char(p));
gotoxy(27,4);write(char(p));
gotoxy(27,5);write(char(p));
gotoxy(27,6);write(char(s));
gotoxy(27,7);write(char(l));
gotoxy(27,8);write(char(p));
gotoxy(27,9);write(char(p));
gotoxy(28,3);write(char(p));
gotoxy(29,4);write(char(r));
gotoxy(30,3);write(char(d));
gotoxy(31,3);write(char(p));
gotoxy(31,2);write(char(c));
gotoxy(31,3);write(char(p));
gotoxy(31,4);write(char(p));
gotoxy(31,5);write(char(p));
gotoxy(31,6);write(char(p));
gotoxy(31,7);write(char(s));
gotoxy(31,8);write(char(l));
gotoxy(31,9);write(char(p));

gotoxy(33,2);write(char(p));   {U}
gotoxy(33,3);write(char(p));
gotoxy(33,4);write(char(p));
gotoxy(33,5);write(char(r));
gotoxy(33,6);write(char(p));
gotoxy(33,7);write(char(d));
gotoxy(33,8);write(char(l));
gotoxy(36,2);write(char(s));
gotoxy(36,3);write(char(p));
gotoxy(36,4);write(char(x));
gotoxy(36,5);write(char(p));
gotoxy(36,6);write(char(x));
gotoxy(36,7);write(char(p));
gotoxy(36,8);write(char(p));
gotoxy(34,9);write(char(p));
gotoxy(35,9);write(char(p));

gotoxy(38,2);write(char(s));   {N}
gotoxy(38,3);write(char(p));
gotoxy(38,4);write(char(p));
gotoxy(38,5);write(char(r));
gotoxy(38,6);write(char(p));
gotoxy(38,7);write(char(x));
gotoxy(38,8);write(char(p));
gotoxy(38,9);write(char(p));
gotoxy(39,3);write(char(p));
gotoxy(40,4);write(char(p));
gotoxy(41,2);write(char(p));
gotoxy(41,3);write(char(p));
gotoxy(41,4);write(char(p));
gotoxy(41,5);write(char(l));
gotoxy(41,6);write(char(p));
gotoxy(41,7);write(char(p));
gotoxy(41,8);write(char(p));
gotoxy(41,9);write(char(p));
      TEXTcolor(d);
gotoxy(45,2);write(char(p));   {T}
gotoxy(45,3);write(char(p));
gotoxy(45,4);write(char(p));
gotoxy(45,5);write(char(p));
gotoxy(45,6);write(char(p));
gotoxy(45,7);write(char(s));
gotoxy(45,8);write(char(l));
gotoxy(45,9);write(char(r));
gotoxy(43,2);write(char(d));
gotoxy(44,2);write(char(c));
gotoxy(46,2);write(char(x));
gotoxy(47,2);write(char(p));

gotoxy(49,2);write(char(p));   {E}
gotoxy(49,3);write(char(p));
gotoxy(49,4);write(char(p));
gotoxy(49,5);write(char(l));
gotoxy(49,6);write(char(p));
gotoxy(49,7);write(char(r));
gotoxy(49,8);write(char(d));
gotoxy(49,9);write(char(c));
gotoxy(50,2);write(char(s));
gotoxy(51,2);write(char(x));
gotoxy(52,2);write(char(x));
gotoxy(50,5);write(char(x));
gotoxy(51,5);write(char(p));
gotoxy(50,5);write(char(p));
gotoxy(50,9);write(char(p));
gotoxy(51,9);write(char(p));
gotoxy(52,9);write(char(l));
     TEXTcolor(x);
gotoxy(54,3);write(char(p));   {A}
gotoxy(54,4);write(char(p));
gotoxy(54,5);write(char(p));
gotoxy(54,6);write(char(p));
gotoxy(54,7);write(char(x));
gotoxy(54,8);write(char(p));
gotoxy(54,9);write(char(p));
gotoxy(55,2);write(char(l));
gotoxy(56,2);write(char(l));
gotoxy(57,3);write(char(e));
gotoxy(57,4);write(char(p));
gotoxy(57,5);write(char(r));
gotoxy(57,6);write(char(d));
gotoxy(57,7);write(char(c));
gotoxy(57,8);write(char(x));
gotoxy(57,9);write(char(e));
gotoxy(55,5);write(char(l));
gotoxy(56,5);write(char(p));

gotoxy(59,2);write(char(s));   {N}
gotoxy(59,3);write(char(l));
gotoxy(59,4);write(char(r));
gotoxy(59,5);write(char(e));
gotoxy(59,6);write(char(e));
gotoxy(59,7);write(char(d));
gotoxy(59,8);write(char(c));
gotoxy(59,9);write(char(s));
gotoxy(60,3);write(char(l));
gotoxy(61,4);write(char(p));
gotoxy(62,2);write(char(p));
gotoxy(62,3);write(char(p));
gotoxy(62,4);write(char(p));
gotoxy(62,5);write(char(p));
gotoxy(62,6);write(char(p));
gotoxy(62,7);write(char(s));
gotoxy(62,8);write(char(x));
gotoxy(62,9);write(char(p));

gotoxy(12,13);write(char(s));   {I}
gotoxy(12,14);write(char(e));
gotoxy(12,15);write(char(r));
gotoxy(12,16);write(char(d));
gotoxy(12,17);write(char(c));
gotoxy(12,18);write(char(p));
gotoxy(12,19);write(char(d));
gotoxy(12,20);write(char(x));
gotoxy(12,11);write(char(p));

gotoxy(14,14);write(char(p));   {O}
gotoxy(14,15);write(char(d));
gotoxy(14,16);write(char(p));
gotoxy(14,17);write(char(s));
gotoxy(14,18);write(char(p));
gotoxy(14,19);write(char(p));
gotoxy(17,14);write(char(p));
gotoxy(17,15);write(char(p));
gotoxy(17,16);write(char(d));
gotoxy(17,17);write(char(p));
gotoxy(17,18);write(char(r));
gotoxy(17,19);write(char(e));
gotoxy(15,13);write(char(d));
gotoxy(16,13);write(char(x));
gotoxy(15,20);write(char(s));
gotoxy(16,20);write(char(l));

gotoxy(19,14);write(char(p));   {A}
gotoxy(19,15);write(char(p));
gotoxy(19,16);write(char(r));
gotoxy(19,17);write(char(e));
gotoxy(19,18);write(char(d));
gotoxy(19,19);write(char(c));
gotoxy(19,20);write(char(l));
gotoxy(22,14);write(char(s));
gotoxy(22,15);write(char(r));
gotoxy(22,16);write(char(c));
gotoxy(22,17);write(char(p));
gotoxy(22,18);write(char(p));
gotoxy(22,19);write(char(p));
gotoxy(22,20);write(char(p));
gotoxy(20,16);write(char(p));
gotoxy(21,16);write(char(x));
gotoxy(20,13);write(char(p));
gotoxy(21,13);write(char(p));

gotoxy(24,13);write(char(p));   {N}
gotoxy(24,14);write(char(p));
gotoxy(24,15);write(char(r));
gotoxy(24,16);write(char(e));
gotoxy(24,17);write(char(d));
gotoxy(24,18);write(char(c));
gotoxy(24,19);write(char(s));
gotoxy(24,20);write(char(l));
gotoxy(27,13);write(char(r));
gotoxy(27,14);write(char(x));
gotoxy(27,15);write(char(l));
gotoxy(27,16);write(char(p));
gotoxy(27,17);write(char(d));
gotoxy(27,18);write(char(p));
gotoxy(27,19);write(char(p));
gotoxy(27,20);write(char(p));
gotoxy(25,14);write(char(x));
gotoxy(26,15);write(char(p));

gotoxy(30,14);write(char(22));   {love-symbol}
gotoxy(30,15);write(char(2));
gotoxy(30,16);write(char(p));
gotoxy(31,13);write(char(p));
gotoxy(31,17);write(char(5));
gotoxy(32,12);write(char(6));
gotoxy(32,18);write(char(66));
gotoxy(33,12);write(char(63));
gotoxy(33,19);write(char(32));
gotoxy(34,13);write(char(2));
gotoxy(34,20);write(char(0));
gotoxy(35,19);write(char(p));
gotoxy(35,12);write(char(32));
gotoxy(36,18);write(char(45));
gotoxy(36,12);write(char(65));
gotoxy(37,13);write(char(52));
gotoxy(37,17);write(char(12));
gotoxy(38,14);write(char(2));
gotoxy(38,15);write(char(0));
gotoxy(38,16);write(char(p));

gotoxy(40,15);write(char(56));   {peace-symbol}
gotoxy(40,16);write(char(5));
gotoxy(40,17);write(char(222));
gotoxy(41,13);write(char(32));
gotoxy(41,19);write(char(44));
gotoxy(40,14);write(char(p));
gotoxy(40,18);write(char(p));
gotoxy(42,19);write(char(3));
gotoxy(42,12);write(char(p));
gotoxy(46,20);write(char(p));
gotoxy(46,12);write(char(3));
gotoxy(47,13);write(char(p));
gotoxy(47,19);write(char(2));
gotoxy(48,14);write(char(p));
gotoxy(48,18);write(char(p));
gotoxy(42,20);write(char(7));
gotoxy(43,12);write(char(77));
gotoxy(43,20);write(char(8));
gotoxy(44,12);write(char(3));
gotoxy(44,20);write(char(p));
gotoxy(45,12);write(char(p));
gotoxy(45,20);write(char(98));
gotoxy(46,19);write(char(65));
gotoxy(47,18);write(char(p));
gotoxy(48,15);write(char(111));
gotoxy(48,16);write(char(22));
gotoxy(48,17);write(char(p));

TEXTcolor(s);
gotoxy(44,12);write(char(4));
gotoxy(44,13);write(char(34));
gotoxy(44,14);write(char(p));
gotoxy(44,15);write(char(s));
gotoxy(44,16);write(char(l));
gotoxy(44,17);write(char(d));
gotoxy(43,18);write(char(e));
gotoxy(45,18);write(char(r));

gotoxy(54,12);write(char(s));   {cruce,cros}
gotoxy(54,13);write(char(l));
gotoxy(54,14);write(char(r));
gotoxy(54,15);write(char(d));
gotoxy(54,16);write(char(c));
gotoxy(54,17);write(char(p));
gotoxy(54,18);write(char(p));
gotoxy(54,19);write(char(32));
gotoxy(54,20);write(char(123));
gotoxy(53,20);write(char(38));
gotoxy(55,20);write(char(d));
gotoxy(50,12);write(char(e));
gotoxy(51,12);write(char(l));
gotoxy(52,12);write(char(s));
gotoxy(53,12);write(char(c));
gotoxy(55,12);write(char(p));
gotoxy(56,12);write(char(84));
gotoxy(57,12);write(char(p));
gotoxy(58,12);write(char(p));
gotoxy(54,11);write(char(22));
gotoxy(54,10);write(char(p));
gotoxy(45,20);write(char(33));
gotoxy(46,19);write(char(p));     gotoxy(58,17);write('by paul ioan muntean');
gotoxy(47,18);write(char(p));     gotoxy(58,18);write('2005 code_masters&CO ');
gotoxy(48,15);write(char(67));
gotoxy(48,16);write(char(45));
gotoxy(48,17);write(char(p));
gotoxy(43,20);write(char(188));
gotoxy(42,20);write(char(144));
until keypressed;
      clrscr;
   gotoxy(23,14);
   write('what are you thinking now?');delay(3000);
    delay(1100);clrscr;
      textbackground(red+181);
  for i:= 1 to 25 do
   begin
gotoxy(i,i);write('$ PM $');
   end;p:=0;
    for i:= 25 downto 1 do
       begin
       inc(p);
gotoxy(i,p);write('$ PM $');
       end;
gotoxy(23,12);write(' /////---------------------------------------------\\\\\');
gotoxy(23,13);write('~~~~~created by the smartest boy alias MASTERCODS PM ~~~~~');
gotoxy(23,14);write(' \\\\\---------------------------------------------/////');
gotoxy(30,16);write('"tyu@linuxtimes.net"-e-mail addres paul muntean');
 gotoxy(30,16);write('creata in 6.5.2005'); delay(5000);
     end.