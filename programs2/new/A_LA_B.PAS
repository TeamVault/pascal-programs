       Program alaputb;
       uses crt;
       var a,n,P,i:integer;

       procedure calcul;
       begin
       for i:=1 to n do
       begin
       P:=P*a;
       end;
       end;
       begin
       write ('Dati numarul pe care doriti sa-l ridicati la oputere');readln(a);
       write('Dati puterea dorita');readln(n);P:=1;  clrscr;
       calcul;
       write('rezultatul este:'); gotoxy(15,12);textcolor(red);write(P:2);delay(2000);
       end.