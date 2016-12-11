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
        function ajutor:integer;
       begin
       write ('dati puterean=');readln (n);
       ajutor:=n; calcul;
       end;
       begin
       write ('dati nr care doriti sa-l ridicati la putere!=');readln (a);       P:=1;
       ajutor;   writeln ('rezultatul este =',P);delay(2000);
       end.