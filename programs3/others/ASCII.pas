



      program Afisarea_tuturor_semnelor_cumSunt_memorate_inASCII;
      uses crt;
      type vec=array[1..400] of char;
      var v:vec;
          i,n:integer;
          f:text;
      procedure cautare;
       begin
              for i:= 1 to 256 do
                begin
       v[i]:=chr(i);
                end;
              for i:=0 to 256 do
        begin
        writeln(i,' ',v[i]);
        end;  textcolor(green);
             write('Aici sunt corect afisate datele,Pascal are in componenta lui aceste semne !'); WRITELN;
             write('COMPARELE CU CE DA ascii.txt SI VEI VEDEA DIFERENTA SI DIFERENTA DINTRE ELE  !');
       end;
       begin
       assign(f,'ascii.doc');rewrite(f);
       cautare;
       writeln(f,'La rularea programului apar alte valori la unele nr. dar corect afiseaza ascii.exe,notepad');
       writeln(f,'nu poate sa redea acele semne unele sunt  inlocuite de program dupa grila lui de semne pe car');
       writeln(f,'e le poate reda,!!!nu pe toate semnele le poate afisa de ex: zerourile de la inceput sunt semne ca smily,figurina');
       writeln(f,'COMPARELE CU CE DA ASCII.EXE SI VEI VEDEA DIFERENTA DESCHIDEL FISIERUL TEXT CU NOTEPAD SAU WORDPAD');
       writeln(f,'CE APARE SUB FORMA DE BUL NU ESTE AFISAT CORECT!!!!!!!!!!!!!!!!!!!!!!!');
       for i:=1 to 256 do
          begin
         textcolor(red); writeln(f,i,'-',v[i]);
          end;readln;
        close(f);delay(3000);exit;

       end.