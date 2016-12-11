{sa se scrie un numar mai mic decat 100000, sub forma literala}
uses crt;
type cifre=array[0..9] of string;
     nr_11_19=array[0..9] of string;
     nr_zeci=array[1..9] of string;
     sute=array[2..9] of string;
const s:cifre=(' ','unu','doi','trei','patru','cinci','sase','sapte','opt','noua');
      t:nr_11_19=('zece','unszpe','doiszpe','treiszpe','paiszpe','cinciszpe','saiszpe','sapteszpe','optszpe','nouaszpe');
      u:nr_zeci=(' ','douazeci','treizeci','patruzeci','cincizeci','saizeci','saptezeci','optzeci','nouazeci');
      v:sute=('doua','trei','patru','cinci','sase','sapte','opt','noua');
var x,d,c,e,b,f,g,h,j,k,i,l,m:longint;
begin
clrscr;
write('Introdu un numar de 4 cifre ');readln(x);

d:=x;
c:=d mod 100;
e:=d mod 10;
b:=d div 10;
f:=b mod 10;
g:=b div 10;
h:=g mod 10;
j:=d mod 1000;
k:=g div 10;
l:=k mod 10;
m:=d mod 10000;
if (j<100) and (l=0) then begin
   if c=0 then write('zero');
   if (c>0) and (c<10) then write(' ',s[e]);
   if (c>9) and (c<20) then write(' ',t[e]);
   if (c>19) and (c<100) then
      if e<>0 then write(' ',u[f],' szi',' ',s[e])
              else write(' ',u[f]);
   end;
if (j>99) and (j<1000) and (l=0) then begin
   if h=1 then begin
      if (c>=0) and (c<10) then write('o suta',' ',s[e]);
      if (c>9) and (c<20) then write('o suta',' ',t[e]);
      if (c>19) and (c<100) then
         if e<>0 then write('o suta',' ',u[f],' szi',' ',s[e])
                 else write('o suta',' ',u[f]);
      end;
   if (h<>1) then begin
      if (c>=0) and (c<10) then write(' ',v[h],' sute',' ',s[e]);
      if (c>9) and (c<20) then write(' ',v[h],' sute',' ',t[e]);
      if (c>19) and (c<100) then
         if e<>0 then write(' ',v[h],' sute',' ',u[f],' szi',' ',s[e])
                 else write(' ',v[h],' sute',' ',u[f]);
      end;
   end;
if (m>999) and (m<10000) then begin
   if (l=1) and (h=1) then begin
      if (c>=0) and (c<10) then write('o mie',' o suta',' ',s[e]);
      if (c>9) and (c<20) then write('o mie',' o suta',' ',t[e]);
      if (c>19) and (c<100) then
         if e<>0 then write('o mie',' o suta',' ',u[f],' szi',' ',s[e])
                 else write('o mie',' o suta',' ',u[f]);
      end;
   if (l=1) and (h>1) then begin
      if (c>=0) and (c<10) then write('o mie',' ',v[h],' sute',' ',s[e]);
      if (c>9) and (c<20) then write('o mie',' ',v[h],' sute',' ',t[e]);
      if (c>19) and (c<100) then
         if e<>0 then write('o mie',' ',v[h],' sute',' ',u[f],' szi',' ',s[e])
                 else write('o mie',' ',v[h],' sute',' ',u[f]);
      end;
   if (l>1) and (h=1) then begin
      if (c>=0) and (c<10) then write(' ',v[l],' mii',' o suta',' ',s[e]);
      if (c>9) and (c<20) then write(' ',v[l],' mii',' o suta',' ',t[e]);
      if (c>19) and (c<100) then
         if e<>0 then write(' ',v[l],' mii',' o suta',' ',u[f],' szi',' ',s[e])
                 else write(' ',v[l],' mii',' o suta',' ',u[f]);
      end;
   if (l>1) and (h>1) then begin
      if (c>=0) and (c<10) then write(' ',v[l],' mii',' ',v[h],' sute',' ',s[e]);
      if (c>9) and (c<20) then write(' ',v[l],' mii',' ',v[h],' sute',' ',t[e]);
      if (c>19) and (c<100) then
         if e<>0 then write(' ',v[l],' mii',' ',v[h],' sute',' ',u[f],' szi',' ',s[e])
                 else write(' ',v[l],' mii',' ',v[h],' sute',' ',u[f]);
      end;
   if (l=1) and (h=0) then begin
      if (c>=0) and (c<10) then write('o mie',' ',s[e]);
      if (c>9) and (c<20) then write('o mie',' ',t[e]);
      if (c>19) and (c<100) then
         if e<>0 then write('o mie',' ',u[f],' szi',' ',s[e])
                 else write('o mie',' ',u[f]);
   end;
end;
   readln;
end.