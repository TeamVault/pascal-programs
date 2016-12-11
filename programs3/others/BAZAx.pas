{Program care calculeaza un nr. intro anumita baza, baza trebuie data,oricare}
 program BazaX;
 uses crt;
  type vec=array[1..100] of integer;
       var v:vec;
       n2,n,i,b:integer;
     procedure calculare;
      begin
      write('Dati baza dorita!');readln(b);
      write('Dati nr la care ii doriti sa-i aflati baza!');readln(n);
        i:=1;
      while n>0 do
         begin
         v[i]:=n mod b;
         inc(i);
         n:=n div b;
         end;
       n2:=i-1;
       end;
       begin
       clrscr;
       calculare;
     for i:=n2 downto 1 do
        begin
       write(v[i]);
        end;readln;
       end.