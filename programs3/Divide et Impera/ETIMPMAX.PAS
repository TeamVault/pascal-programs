Program maxDINsirPrinMETODAdivetIMPERA;
uses crt;
type vec=array[1..100] of integer;
 var v:vec;n,i:integer;
 function div_max (p,q:integer):integer;
   var mij:integer;max1,max2:integer;
     begin
     if p=q then div_max:=v[p]
            else
            begin{imparte subvectorul(v[p]..v[q])in alti subvectori prin poz. dinmijloc apoi det max1,2}
             mij:=(p+q)div 2;
             max1:=div_max(p,mij);
             max2:=div_max(mij+1,q);
             {daca max1 > max2 atunci va cauta in subvectorul max1 else in max2}
             if max1>max2 then div_max:=max1{cauta max din subsir.1 si din subsir.2apoi ii comp si-l afiseaza pe cel mai mare}
                          else div_max:=max2;
             end;
       end;
      begin
      clrscr;
      textcolor(red);
      write('Dati nr. de elemente dorit! n=');readln(n);
        for i:=1 to n do
         begin
         write ('v[',i,']=');readln(v[i]);
         end;
         writeln ('Maximul din sir este:',div_max(1,n));
         readln;
         end.
{sirul nutrebuie sa fie crescator sau descrescator este implicata stiva sistemului}