  program Drum_de_cost_minim_si_maxim;
uses crt;
var  n,i,j:integer;
   a:array[1..100,1..100] of real;
    procedure citire_mat;
     var i,j,k:integer;
     begin
     writeln ('Dati nr. de varfuri');readln(n);
      for i:=1 to n do
        for j:=1 to n do
          begin
       writeln ('Dati costul format intre varful',i,'si',j);
       readln(a[i,j]);
          end;
     end;
      procedure afisareMAT;
     begin
       for i:=1 to n do
        begin
         for j:=1 to n do
           write(a[i,j]:2,'  ');readln;
        end;
     end;
     procedure generare;{altgoritmul Roy-Floyd}
         var i,j,k:integer;
      begin
        for i:=1 to n do
         for j:=1 to n do
           for k:=1 to n do
           if a[i,k]+a[k,j]<a[i,j] then a[i,j]:=a[i,k]+a[k,j];
           {la drumuri de cost maxim trebuie ">", programul nostru calculeaza drumul de cost minim}
      end;
      begin
      clrscr;
      citire_mat;textcolor(red);
      writeln('mat costurilor');
       afisareMAT;textcolor(red);
      writeln('mat drumurilor');
       generare;
       afisareMAT;
       end.