xprogram min;

var     a:array[1..50] of longint;
        i:byte;
        n,n1:longint;
begin
      write(' nr. elem sir:');readln(n);
      write('introduceti un numar ');
      readln(a[1]);
      n1:=a[1];
      i:=2;
     repeat
           begin
           write('introduceti un numar ');
           readln(a[i]);
           if a[i]<n1 then
              n1:=a[i];
           end;
           i:=i+1;
     until i>n;
     write('numarul minim este ',n1);
     readln;
end.

