{primul program. despre grafuri,Citire acestuia de tastatura si afisarea lui!!}
program Citirea_unui_graf_Neorientat_de_latast_si_afisarea_lui;
uses crt;
type mat=array[1..100,1..100]of integer;
 var    m,n,i,j:byte;
        a:mat;
  procedure citire;
  var i,j,k,x,y:integer;
   begin
    writeln ('Dati nr. de varfuri:');readln(n);
    writeln ('Dati nr. de muchii:');readln(m);
    {initializam toata matricea cu zero pe toate pozitiile}
    for i:=1 to n do
    for j:=1 to n do
    a[i,j]:=0;
     {citim de latastatura muchile formate ,se cer arfurile intre care s-a format fiecare din cele ',m,'muchii};
      for k:=1 to m do
         begin
       writeln ('Dati varfurile intre care sa format muchia',k:2 );
          repeat
            readln(x,y);{prin repeat ...until se asigura ca x si y sa apartina de 1..n si sa fie diferite ca valori}
          until  (x>=1) and (x<=n)and  (y>=1) and (y<=n)   and(y<>x);
            a[x,y]:=1;  {matricea grafului neorintat este simetrica fata de diag. principala}
            a[y,x]:=1;
          end;
     end;
    procedure afisarea;
    begin
 clrscr;
     for i:=1 to n do
       begin
            if i= (n div 2) then
        write ('A:');
         for j:=1 to n do
          begin
          gotoxy (4+j,14+i);
          write(a[i,j]);
              if (j=n) then writeln;{-asigura ca sa apara frumos sub forma de matrice ex: 12333
                                                                                           111..
                                                                                           .....
                                                                                           22222}
           end;
        end;
      end;
      begin
      clrscr;
      citire;
      afisarea;delay(2222);
      end.