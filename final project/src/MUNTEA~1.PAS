
         Program atestat;
uses  dos,ATES,
 {$ifdef __WIN32__} Windows, MMsystem,GRAPH    {$endif}  crt;
type
      mor=record
           cod:string;
           carac:char;
           end;
      natural=0..maxlongint;
   var v1:array[1..46] of mor;
       s4:string;
       st:array[1..100] of integer;
       opt1,opt:integer;
       f:text;
       g,k:integer;
       val:integer;
       x,y,z,w,r,p:integer;
       h3,m3,s3,s1003,h,m,s,s100,h2,h1,m2,m1,s1,s2,s1002,s1001,a,c,d:word;
       j:integer;

begin
 textbackground(blue); clrscr; TEXTCOLOR(YELLOW);gotoxy(7,12);hidecursor;  MouseInit;
Write('*MENIURILE SE POT ACCESA PRIN CLICK PE NUMARUL DIN FATA FIECARUI MENIU');
gotoxy(7,13);Write('*YOU CAN ACCES THE MENUES BY PRESSING THE NUMBER IN FRONT OF THEM');
gotoxy(7,14);Write('*JEDES MENU IST EREICHBAR DURCH EINEN CLICK AUF DER BEVORSTEHENDE NUMMER'); DELAY(10000); clrscr;mousehide;
repeat
 textbackground(blue);  clrscr;

   {a:=h;b:=m;c:=s;d:=s100; }
   textcolor(white);gotoxy(62,23);writeln('Start   ',h1,':',m1,':',s1,':',s1001);
{ a:=h;b:=m;c:=s;d:=s100;} gotoxy(62,24);writeln('Sfarsit ',h2,':',m2,':',s2,':',s1002);

GOTOXY(2,2); mousedata(mouse,x,y);  MouseInit;
write('Paul-Ioan Muntean alias MASTERCODE&CO');

gotoxy(25,7);textcolor(yellow);
writeln('1.');textbackground(blue);gotoxy(27,7);write('Meniul grafic');gotoxy(25,8);
writeln('2.');textbackground(blue);gotoxy(27,8);write('Meniul cu altgoritmi matematici ');gotoxy(25,9);
writeln('3.');textbackground(blue);gotoxy(27,9);write('Meniul cu fisiere');gotoxy(25,10);
writeln('4.');textbackground(blue);gotoxy(27,10);write('Meniul cu grafuri');gotoxy(25,11);
writeln('5.');textbackground(blue);gotoxy(27,11);write('Meniul BKTR');gotoxy(25,12);
writeln('6.');textbackground(blue);gotoxy(27,12);write('Meniul Divide et Impera');gotoxy(25,13);
writeln('7.');textbackground(blue);gotoxy(27,13);write('Meniul cu altgoritmi speciali');gotoxy(25,14);
writeln('8.');textbackground(blue);gotoxy(27,14);write('Meniul cu stringuri'); gotoxy(33,17);textbackground(green);
writeln('EXIT');gotoxy(29,6);  textbackground(blue);
 textcolor(white);write('*OPTIUNEA TA ESTE*'); textcolor(yellow); gotoxy(27,14);write('Meniul cu stringuri');
                      repeat
                    gotoxy(25,7);textcolor(yellow);writeln('1.');


{ in repeatul acesta ii easul din stnga sus integrat si functinea mouseului}
mousedata(mouse,x,y);  gettime(h3,m3,s3,s1003);textcolor(white);gotoxy(62,2);textbackground(red);write('Time ',h3,':',m3,':',s3,':',s1003);textcolor(yellow);gotoxy(44,16);
hidecursor;   mousedata(mouse,x,y);   MouseShow;textbackground(blue);   gotoxy(34,14);write('cu s'); textbackground(cyan);


{1}if ((mouse=1)and((x=25)or(x=26))) and( y=7 ) then opt:=1;
{2}if(mouse=1)and((x=25)or(x=26))and( y=8 ) then opt:=2;
   if(mouse=1)and (x=25) and( y=9 ) then opt:=3;
   if(mouse=1)and (x=25) and( y=10 )then opt:=4;
    if(mouse=1)and (x=25) and( y=11 ) then opt:=5;
     if(mouse=1)and (x=25) and( y=12 ) then opt:=6;
      if (mouse=1)and(x=25) and( y=13 ) then opt:=7;
      if(mouse=1)and (x=25) and( y=14 ) then opt:=8;
       if (mouse=1)and((x=33) or (x=34) or (x=35)or (x=36)) and( y=17 ) then exit
                                          else
                                           begin
                                          if(((x=25)or(x=26)) and(y=7))  then  Begin   gotoxy(25,7);textbackground(red); end;
                                          if not((x=25)or(x=26)) and (y=7) then begin gotoxy(25,7);  textbackground(cyan);      end;
                                          end;
until (mouse=1) and ((x in [25..30])and (y in[7..17]))  ;
 mousehide;
clrscr;nosound;
case opt of
1:begin
   repeat
             textbackground(blue); clrscr;    mousehide;   mouseinit;   MOUSESHOW;
                gotoxy(30,7);     mousedata(mouse,x,y);
      write('1.');textbackground(blue);gotoxy(32,7);write('Ferestre aleatoare');gotoxy(30,8);
      write('2.');textbackground(blue);gotoxy(32,8);write('Afisarea aleatoare a caracterelor ASCII');gotoxy(30,9);
      write('3.');textbackground(blue);gotoxy(32,9);write('Afisarea  creatorului programului');gotoxy(30,10);
      write('4.');textbackground(blue);gotoxy(32,10);write('Matrix Revolution& Machine cod');gotoxy(30,11);
      write('5.');textbackground(blue);gotoxy(32,11);write('Triunghi de numere  sonorizat de note muzicale');
      gotoxy(34,14);  textbackground(green);
         writeln('EXIT');
     textbackground(blue);
        repeat           gotoxy(30,7);
      write('1.');  mousedata(mouse,x,y);
            if ((mouse=1)and((x=30)or(x=31)) and( y=7 )) then opt1:=1;
              if(mouse=1)and((x=30)or(x=31))and( y=8 ) then opt1:=2;
                if(mouse=1)and ((x=30)or(x=31)) and( y=9 ) then opt1:=3;
                   if(mouse=1)and ((x=30)or(x=31)) and( y=10 )then opt1:=4;
                      if(mouse=1)and ((x=30)or(x=31)) and( y=11 ) then opt1:=5;
                      if (mouse=1)and((x=34) or (x=35) or (x=36)or (x=37)) and( y=14 ) then  opt1:=0
                                                   else
                                          begin
                                          if(((x=30)or(x=31)) and(y=7))  then  Begin   gotoxy(30,7);textbackground(red); end;
                                          if ((x<>30)or(x<>31)) and (y<>7) then begin gotoxy(30,7);  textbackground(cyan);      end;

                                          end;
    until (mouse=1 )and (x in[30..37])and (y in [7..17])    ;
       case opt1 of
       1:begin
     gettime(h1,m1,s1,s1001);
    CrtDemo;                                     {MERGE FARA ERORI DACA SUNT INCAPSULATE}
      gettime(h2,m2,s2,s1002);
       end;
     2:begin
         gettime(h1,m1,s1,s1001);clrscr;
          gr1;
         gettime(h2,m2,s2,s1002);
       end;
 3:begin
  gettime(h1,m1,s1,s1001);clrscr;
          gr2;
         gettime(h2,m2,s2,s1002);
end;
 4:begin
   gettime(h1,m1,s1,s1001);clrscr;
          gr3;
         gettime(h2,m2,s2,s1002);
end;
    5:begin
    gettime(h1,m1,s1,s1001);clrscr;
          gr4;
         gettime(h2,m2,s2,s1002);
      end;

    end;
   until opt1=0; clrscr;  textbackground(blue); clrscr;
   end;
2:begin
  repeat
             textbackground(blue);clrscr;     MOUSESHOW;
               gotoxy(30,7);     mousedata(mouse,x,y);hidecursor;
      write('1.');textbackground(blue);gotoxy(32,7);write('Ec. de grad 2 rezolvata in C ');gotoxy(30,8);
      write('2.');textbackground(blue);gotoxy(32,8);write('Bordarea unei matrici cu 1 coloana si 1 linie');gotoxy(30,9);
      write('3.');textbackground(blue);gotoxy(32,9);write('Transormarea unui nr. in orice baza');gotoxy(30,10);
      write('4.');textbackground(blue);gotoxy(32,10);write('Inmultirea a 2 matrici');gotoxy(30,11);
      write('5.');textbackground(blue);gotoxy(32,11);write('Ackerman');gotoxy(30,12);
      write('6.');textbackground(blue);gotoxy(32,12);write('Mana_Pnuelli; '); gotoxy(34,14);
     textbackground(green); write('EXIT');
        repeat            gotoxy(30,7);     mousedata(mouse,x,y);
      write('1.');  mousedata(mouse,x,y);
            if ((mouse=1)and((x=30)or(x=31))) and( y=7 ) then opt1:=1;
              if(mouse=1)and((x=30)or(x=31))and( y=8 ) then opt1:=2;
                if(mouse=1)and ((x=30)or(x=31)) and( y=9 ) then opt1:=3;
                   if(mouse=1)and ((x=30)or(x=31)) and( y=10 )then opt1:=4;
                      if(mouse=1)and ((x=30)or(x=31)) and( y=11 ) then opt1:=5;
                          if(mouse=1)and ((x=30)or(x=31)) and( y=12 )then opt1:=6;
                      if (mouse=1)and((x=34) or (x=35) or (x=36)or (x=37)) and( y=14 ) then  opt1:=0
                                                             else
                                          begin
                                          if(((x=30)or(x=31)) and(y=7))  then  Begin   gotoxy(30,7);textbackground(red); end;
                                          if ((x<>30)or(x<>31)) and (y<>7) then begin gotoxy(30,7);  textbackground(cyan);      end;
                                          end;
    until (mouse=1 )and (x in[30..37])and (y in [7..14])    ;
       case opt1 of
       1:begin
 gettime(h1,m1,s1,s1001);
         mat1;
   gettime(h2,m2,s2,s1002);
        end;
       2:begin
       gettime(h1,m1,s1,s1001);
       mat2;
         gettime(h2,m2,s2,s1002);
       end;
         3:begin
          gettime(h1,m1,s1,s1001);
       mat3;
         gettime(h2,m2,s2,s1002);
       end;
       4:begin
           gettime(h1,m1,s1,s1001);
       mat4;
         gettime(h2,m2,s2,s1002);
     end
        5:begin
         gettime(h1,m1,s1,s1001);
          functia_Ackerman;clrscr;
         gettime(h2,m2,s2,s1002);
        end;
        6:begin
         gettime(h1,m1,s1,s1001);
           Mana_Pnuelli; clrscr;
         gettime(h2,m2,s2,s1002);
        end;
       end;
       until opt1=0;
end;
 3:begin
   repeat
       textbackground(blue); clrscr;MouseInit;   MOUSESHOW;
              gotoxy(30,7);    mousedata(mouse,x,y); textcolor(yellow);hidecursor;
      write('1.');textbackground(blue);gotoxy(32,7);write('Ordonarea alfabetica a unei liste din fisier');gotoxy(30,8);
      write('2.');textbackground(blue);gotoxy(32,8);write('Simulare click 2');gotoxy(30,9);
      write('3.');textbackground(blue);gotoxy(32,9);write('Se genereaza parola in Parola.doc');gotoxy(30,10);
      write('4.');textbackground(blue);gotoxy(32,10);write('Umplere fisier cu caractere');gotoxy(30,11);
      write('5.');textbackground(blue);gotoxy(32,11);write('ARNOLD SCHWARZENEGER');gotoxy(30,12);
      write('');textbackground(blue);gotoxy(32,12);write(' '); gotoxy(34,14);
     textbackground(green); write('EXIT');   textbackground(blue);
        repeat            gotoxy(30,7);     mousedata(mouse,x,y);
      write('1.');  mousedata(mouse,x,y);   mousedata(mouse,x,y);
            if ((mouse=1)and((x=30)or(x=31))) and( y=7 ) then opt1:=1;
              if(mouse=1)and((x=30)or(x=31))and( y=8 ) then opt1:=2;
                if(mouse=1)and ((x=30)or(x=31)) and( y=9 ) then opt1:=3;
                   if(mouse=1)and ((x=30)or(x=31)) and( y=10 )then opt1:=4;
                      if(mouse=1)and ((x=30)or(x=31)) and( y=11 ) then opt1:=5;
                          if(mouse=1)and ((x=30)or(x=31)) and( y=12 )then opt1:=6;
                      if (mouse=1)and((x=34) or (x=35) or (x=36)or (x=37)) and( y=14 ) then  opt1:=0
                                                               else
                                          begin
                                          if(((x=30)or(x=31)) and(y=7))  then  Begin   gotoxy(30,7);textbackground(red); end;
                                          if ((x<>30)or(x<>31)) and (y<>7) then begin gotoxy(30,7);  textbackground(cyan);      end;
                                          end;
    until (mouse=1 )and (x in[30..37])and (y in [7..14])    ;
       case opt1 of
       1:begin
           gettime(h1,m1,s1,s1001);CLRSCR;
         write('Se prelucreaza');   readln;textcolor(yellow);   Ara;
           gettime(h2,m2,s2,s1002);
         end;
       2:begin
           gettime(h1,m1,s1,s1001);CLRSCR;
            click2;textcolor(yellow);
           gettime(h2,m2,s2,s1002);
        end;
       3:begin
            gettime(h1,m1,s1,s1001);CLRSCR;
             genParola;
           gettime(h2,m2,s2,s1002);
       end;
       4:begin
            gettime(h1,m1,s1,s1001);CLRSCR;
            umplere_fisier_text;
           gettime(h2,m2,s2,s1002);
         end;
       5:begin
            gettime(h1,m1,s1,s1001);CLRSCR;
           arnold;
           gettime(h2,m2,s2,s1002);
         end;
       0:begin
          gettime(h1,m1,s1,s1001);CLRSCR;
           gettime(h2,m2,s2,s1002);
         end
         else
           begin
         write('Dati o optiune din 1..5 sau 0');
           end;
       end;
       until opt1=0;
       end;
4:begin
   repeat
     textbackground(blue); clrscr; MouseInit;   MOUSESHOW;
           gotoxy(30,7);    mousedata(mouse,x,y); textcolor(yellow);  hidecursor;
      write('1.');textbackground(blue);gotoxy(32,7);write('Verifica daca un graf este sau nu hamiltonian');gotoxy(30,8);
      write('2.');textbackground(blue);gotoxy(32,8);write('Componenta tare conexa');gotoxy(30,9);
      write('3.');textbackground(blue);gotoxy(32,9);write('Eliminarea unui varf a.i. graful sa fie conex');gotoxy(30,10);
      write('4.');textbackground(blue);gotoxy(32,10);write('Verifica daca un graf este eulerian si conex');gotoxy(30,11);
      write('5.');textbackground(blue);gotoxy(32,11);write('Afisare arborelui partial de cost minim');gotoxy(30,12);
      write('');textbackground(blue);gotoxy(32,12);write(' '); gotoxy(34,14);
     textbackground(green); write('EXIT');   textbackground(blue);
         repeat            gotoxy(30,7);     mousedata(mouse,x,y);
      write('1.');  mousedata(mouse,x,y);  mousedata(mouse,x,y);
            if ((mouse=1)and((x=30)or(x=31))) and( y=7 ) then opt1:=1;
              if(mouse=1)and((x=30)or(x=31))and( y=8 ) then opt1:=2;
                if(mouse=1)and ((x=30)or(x=31)) and( y=9 ) then opt1:=3;
                   if(mouse=1)and ((x=30)or(x=31)) and( y=10 )then opt1:=4;
                      if(mouse=1)and ((x=30)or(x=31)) and( y=11 ) then opt1:=5;
                          if(mouse=1)and ((x=30)or(x=31)) and( y=12 )then opt1:=6;
                      if (mouse=1)and((x=34) or (x=35) or (x=36)or (x=37)) and( y=14 ) then  opt1:=0
                                                            else
                                          begin
                                          if(((x=30)or(x=31)) and(y=7))  then  Begin   gotoxy(30,7);textbackground(red); end;
                                          if ((x<>30)or(x<>31)) and (y<>7) then begin gotoxy(30,7);  textbackground(cyan);      end;
                                          end;
    until (mouse=1 )and (x in[30..37])and (y in [7..14])    ;
         case opt1 of
       1:begin
           gettime(h1,m1,s1,s1001);CLRSCR;
             graf_hamiltonian;readln;
           gettime(h2,m2,s2,s1002);
         end;
       2:begin
           gettime(h1,m1,s1,s1001);CLRSCR;
            componenta_tareconex;
           gettime(h2,m2,s2,s1002);
        end;
       3:begin
            gettime(h1,m1,s1,s1001);CLRSCR;
              subGrafConex;
           gettime(h2,m2,s2,s1002);
       end;
       4:begin
            gettime(h1,m1,s1,s1001);CLRSCR;
            grafEulerian;
           gettime(h2,m2,s2,s1002);
         end;
       5:begin
            gettime(h1,m1,s1,s1001);CLRSCR;
             arb_partial_de_cost_minim;
           gettime(h2,m2,s2,s1002);
         end;
       0:begin
          gettime(h1,m1,s1,s1001);CLRSCR;
           gettime(h2,m2,s2,s1002);
         end
         else
           begin
         write('Dati o optiune din 1..5 sau 0');
           end;
       end;
       until opt1=0;
       end;
5:begin
  repeat
    textbackground(blue); clrscr;  MouseInit;   MOUSESHOW;
             gotoxy(30,7);   mousedata(mouse,x,y); textcolor(yellow);    hidecursor;
      write('1.');textbackground(blue);gotoxy(32,7);write('Afisarea permutarilor de n elemente');gotoxy(30,8);
      write('2.');textbackground(blue);gotoxy(32,8);write('Afisarea combinarilor de n,k elemente');gotoxy(30,9);
      write('3.');textbackground(blue);gotoxy(32,9);write('Afisare produs cartezian de n multimi');gotoxy(30,10);
      write('4.');textbackground(blue);gotoxy(32,10);write('Generarea nr. prime din n cifre');gotoxy(30,11);
      write('5.');textbackground(blue);gotoxy(32,11);write('Comis voiajor');gotoxy(30,12);
      write('');textbackground(blue);gotoxy(32,12);write(' '); gotoxy(34,14);
     textbackground(green); write('EXIT');   textbackground(blue);
        repeat            gotoxy(30,7);     mousedata(mouse,x,y);
      write('1.');  mousedata(mouse,x,y);   mousedata(mouse,x,y);
            if ((mouse=1)and((x=30)or(x=31))) and( y=7 ) then opt1:=1;
              if(mouse=1)and((x=30)or(x=31))and( y=8 ) then opt1:=2;
                if(mouse=1)and ((x=30)or(x=31)) and( y=9 ) then opt1:=3;
                   if(mouse=1)and ((x=30)or(x=31)) and( y=10 )then opt1:=4;
                      if(mouse=1)and ((x=30)or(x=31)) and( y=11 ) then opt1:=5;
                          if(mouse=1)and ((x=30)or(x=31)) and( y=12 )then opt1:=6;
                      if (mouse=1)and((x=34) or (x=35) or (x=36)or (x=37)) and( y=14 ) then  opt1:=0
                                                          else
                                          begin
                                          if(((x=30)or(x=31)) and(y=7))  then  Begin   gotoxy(30,7);textbackground(red); end;
                                          if ((x<>30)or(x<>31)) and (y<>7) then begin gotoxy(30,7);  textbackground(cyan);      end;
                                          end;
    until (mouse=1 )and (x in[30..37])and (y in [7..14])    ;
       case opt1 of
       1:begin
           gettime(h1,m1,s1,s1001);CLRSCR;
             bktr_nerecursiv_permutari;
           gettime(h2,m2,s2,s1002);
         end;
       2:begin
           gettime(h1,m1,s1,s1001);CLRSCR;
           bktr_combinari;
           gettime(h2,m2,s2,s1002);
        end;
       3:begin
            gettime(h1,m1,s1,s1001);CLRSCR;
          bktr_prodCartezian;
           gettime(h2,m2,s2,s1002);
       end;
       4:begin
            gettime(h1,m1,s1,s1001);CLRSCR;
             bktr_Nrprime;
           gettime(h2,m2,s2,s1002);
         end;
       5:begin
            gettime(h1,m1,s1,s1001);CLRSCR;
             bktr_comisVOIAJOR;
           gettime(h2,m2,s2,s1002);
         end;
       0:begin
          gettime(h1,m1,s1,s1001); CLRSCR;
           gettime(h2,m2,s2,s1002);
         end
         else
           begin
         write('Dati o optiune din 1..5 sau 0');
           end;
       end;
       until opt1=0;
       end;
6:begin
  repeat
     textbackground(blue); clrscr;MouseInit;   MOUSESHOW;
          gotoxy(30,7);     mousedata(mouse,x,y); textcolor(yellow);  hidecursor;
      write('1.');textbackground(blue);gotoxy(32,7);write('Cautare binara intr-un sir');gotoxy(30,8);
      write('2.');textbackground(blue);gotoxy(32,8);write('TURNURILE DIN HANOI');gotoxy(30,9);
      write('3.');textbackground(blue);gotoxy(32,9);write('CMMDC de N elemente mai mari decat "0"');gotoxy(30,10);
      write('4.');textbackground(blue);gotoxy(32,10);write('Aria maxima dintr-o foaie de tabla');gotoxy(30,11);
      write('5.');textbackground(blue);gotoxy(32,11);write('Quick sort de n elemente');gotoxy(30,12);
      write('');textbackground(blue);gotoxy(32,12);write(' '); gotoxy(34,14);
     textbackground(green); write('EXIT');   textbackground(blue);
         repeat            gotoxy(30,7);     mousedata(mouse,x,y);
      write('1.');  mousedata(mouse,x,y); mousedata(mouse,x,y);
            if ((mouse=1)and((x=30)or(x=31))) and( y=7 ) then opt1:=1;
              if(mouse=1)and((x=30)or(x=31))and( y=8 ) then opt1:=2;
                if(mouse=1)and ((x=30)or(x=31)) and( y=9 ) then opt1:=3;
                   if(mouse=1)and ((x=30)or(x=31)) and( y=10 )then opt1:=4;
                      if(mouse=1)and ((x=30)or(x=31)) and( y=11 ) then opt1:=5;
                          if(mouse=1)and ((x=30)or(x=31)) and( y=12 )then opt1:=6;
                      if (mouse=1)and((x=34) or (x=35) or (x=36)or (x=37)) and( y=14 ) then  opt1:=0
                                                            else
                                          begin
                                          if(((x=30)or(x=31)) and(y=7))  then  Begin   gotoxy(30,7);textbackground(red); end;
                                          if ((x<>30)or(x<>31)) and (y<>7) then begin gotoxy(30,7);  textbackground(cyan);      end;
                                          end;
    until (mouse=1 )and (x in[30..37])and (y in [7..14])    ;
         case opt1 of
       1:begin
           gettime(h1,m1,s1,s1001); CLRSCR;
               cautare_binara;
           gettime(h2,m2,s2,s1002);
         end;
       2:begin
           gettime(h1,m1,s1,s1001); CLRSCR;
           turnurile_hanoi;
           gettime(h2,m2,s2,s1002);
        end;
       3:begin
            gettime(h1,m1,s1,s1001);CLRSCR;
              CmmdcDEnNR;
           gettime(h2,m2,s2,s1002);
       end;
       4:begin
            gettime(h1,m1,s1,s1001); CLRSCR;
           foaiatabla;
           gettime(h2,m2,s2,s1002);
         end;
       5:begin
            gettime(h1,m1,s1,s1001);CLRSCR;
           quick_sort;
           gettime(h2,m2,s2,s1002);
         end;
       0:begin
          gettime(h1,m1,s1,s1001); CLRSCR;
           gettime(h2,m2,s2,s1002);
         end
         else
           begin
         write('Dati o optiune din 1..5 sau 0');
           end;
       end;
       until opt1=0;
       end;
7:begin
  repeat
      textbackground(blue); clrscr;MouseInit;   MOUSESHOW;;hidecursor;
              gotoxy(30,7);     mousedata(mouse,x,y); textcolor(yellow);   hidecursor;
      write('1.');textbackground(blue);gotoxy(32,7);write('Flame ,Flacara');gotoxy(30,8);
      write('2.');textbackground(blue);gotoxy(32,8);write('Desenare aleatoare');gotoxy(30,9);
      write('3.');textbackground(blue);gotoxy(32,9);write('Joc Snake');gotoxy(30,10);
      write('4.');textbackground(blue);gotoxy(32,10);write('Cod morse');gotoxy(30,11);
      write('5.');textbackground(blue);gotoxy(32,11);write('Hexagon');gotoxy(30,12);
      write('');textbackground(blue);gotoxy(32,12);write(' '); gotoxy(34,14);
     textbackground(green); write('EXIT');   textbackground(blue);
       repeat            gotoxy(30,7);     mousedata(mouse,x,y);
      write('1.');  mousedata(mouse,x,y);    mousedata(mouse,x,y);
            if ((mouse=1)and((x=30)or(x=31))) and( y=7 ) then opt1:=1;
              if(mouse=1)and((x=30)or(x=31))and( y=8 ) then opt1:=2;
                if(mouse=1)and ((x=30)or(x=31)) and( y=9 ) then opt1:=3;
                   if(mouse=1)and ((x=30)or(x=31)) and( y=10 )then opt1:=4;
                      if(mouse=1)and ((x=30)or(x=31)) and( y=11 ) then opt1:=5;
                          if(mouse=1)and ((x=30)or(x=31)) and( y=12 )then opt1:=6;
                      if (mouse=1)and((x=34) or (x=35) or (x=36)or (x=37)) and( y=14 ) then  opt1:=0
                                                            else
                                          begin
                                          if(((x=30)or(x=31)) and(y=7))  then  Begin   gotoxy(30,7);textbackground(red); end;
                                          if ((x<>30)or(x<>31)) and (y<>7) then begin gotoxy(30,7);  textbackground(cyan);      end;
                                          end;
    until (mouse=1 )and (x in[30..37])and (y in [7..14])    ;
          case opt1 of
       1:begin
           gettime(h1,m1,s1,s1001);CLRSCR;
           flame;
           gettime(h2,m2,s2,s1002);
         end;
       2:begin
           gettime(h1,m1,s1,s1001);CLRSCR;
           desenare;
           gettime(h2,m2,s2,s1002);
        end;
       3:begin
            gettime(h1,m1,s1,s1001);CLRSCR;
            snake;
           gettime(h2,m2,s2,s1002);
       end;
       4:begin
            gettime(h1,m1,s1,s1001); CLRSCR;
            morse;
           gettime(h2,m2,s2,s1002);
         end;
       5:begin
            gettime(h1,m1,s1,s1001); CLRSCR;
              hexagon3D;
           gettime(h2,m2,s2,s1002);
         end;
       0:begin
          gettime(h1,m1,s1,s1001); CLRSCR;
           gettime(h2,m2,s2,s1002);
         end
         else
           begin
         write('Dati o optiune din 1..5 sau 0');
           end;
       end;
       until opt1=0;
       end;
   8:begin
      repeat
             textbackground(blue); clrscr;MouseInit;   MOUSESHOW;
               gotoxy(30,7);     mousedata(mouse,x,y); textcolor(yellow);   hidecursor;
      write('1.');textbackground(blue);gotoxy(32,7);write('Eliminarea literelor ce se repeta inr-un cuvant');gotoxy(30,8);
      write('2.');textbackground(blue);gotoxy(32,8);write('Alcatuirea unei parole dintr-un cuvant dat');gotoxy(30,9);
      write('3.');textbackground(blue);gotoxy(32,9);write('Sortarea alfabetica a unei fraze');gotoxy(30,10);
      write('4.');textbackground(blue);gotoxy(32,10);write('Afisarea  inversa a cifrelor dintr-un cuvant');gotoxy(30,11);
      write('5.');textbackground(blue);gotoxy(32,11);write('Prefixurile unui cuvant');gotoxy(30,12);
      write('');textbackground(blue);gotoxy(32,12);write(' '); gotoxy(34,14);
     textbackground(green); write('EXIT');   textbackground(blue);
       repeat            gotoxy(30,7);     mousedata(mouse,x,y);
      write('1.');  mousedata(mouse,x,y);    mousedata(mouse,x,y);
            if ((mouse=1)and((x=30)or(x=31))) and( y=7 ) then opt1:=1;
              if(mouse=1)and((x=30)or(x=31))and( y=8 ) then opt1:=2;
                if(mouse=1)and ((x=30)or(x=31)) and( y=9 ) then opt1:=3;
                   if(mouse=1)and ((x=30)or(x=31)) and( y=10 )then opt1:=4;
                      if(mouse=1)and ((x=30)or(x=31)) and( y=11 ) then opt1:=5;
                          if(mouse=1)and ((x=30)or(x=31)) and( y=12 )then opt1:=6;
                      if (mouse=1)and((x=34) or (x=35) or (x=36)or (x=37)) and( y=14 ) then  opt1:=0
                                                                 else
                                          begin
                                          if(((x=30)or(x=31)) and(y=7))  then  Begin   gotoxy(30,7);textbackground(red); end;
                                          if ((x<>30)or(x<>31)) and (y<>7) then begin gotoxy(30,7);  textbackground(cyan);      end;
                                          end;
    until (mouse=1 )and (x in[30..37])and (y in [7..14])    ;
       case opt1 of
       1:begin
           gettime(h1,m1,s1,s1001);CLRSCR;
            eliminareLITrepetate;
           gettime(h2,m2,s2,s1002);
         end;
       2:begin
           gettime(h1,m1,s1,s1001);CLRSCR;
            parola;
           gettime(h2,m2,s2,s1002);
        end;
       3:begin
            gettime(h1,m1,s1,s1001);CLRSCR;
              p7;
           gettime(h2,m2,s2,s1002);
       end;
       4:begin
            gettime(h1,m1,s1,s1001);CLRSCR;
           cuvant;
           gettime(h2,m2,s2,s1002);
         end;
       5:begin
            gettime(h1,m1,s1,s1001);CLRSCR;
             prefix;
           gettime(h2,m2,s2,s1002);
         end;
       0:begin
          gettime(h1,m1,s1,s1001); CLRSCR;
           gettime(h2,m2,s2,s1002);
         end
         else
           begin
         write('Dati o optiune din 1..5 sau 0');
           end;
       end;
       until opt1=0;
       end;
0:begin
      gettime(h1,m1,s1,s1001);
  exit;
   gettime(h2,m2,s2,s1002);
  end
  else
    begin
       gettime(h1,m1,s1,s1001); MouseInit;   MOUSESHOW;
     writeln('Alegeti optiuni intre 1..8,0 exit');
  readln; gettime(h2,m2,s2,s1002);clrscr;
    end;
 end;
until opt=0; clrscr;
end.