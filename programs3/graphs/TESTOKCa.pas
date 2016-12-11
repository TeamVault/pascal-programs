 program caseaa;
uses crt;
    var opt,i:integer;
    procedure casee;
Begin
        repeat
                  writeln ('Daca apesi tasta 1 se va continua in sase-ul imbricat');TextColor (15);
                  writeln ('Daca tastati tasta 2 se va executa produsul!');textcolor (red);
                  writeln ('Daca apasati tasra 4 se iasa din program!');textcolor (brown+182);

  case opt of
   1:begin;
                       repeat
                  writeln ('Daca apesi tasta 5 se va executa suma!');TextColor (15);
                  writeln ('Daca apasati tasra 11 se iasa din program!');textcolor (brown+182);
                  writeln ('Daca  alegeti un nr. va rog!');readln (opt);textcolor (02); clrscr;
               case opt of
                     5:write('om');
                     end;
                     until opt=11;
     end;

    2:write('oooooooooooooooooooooo');

  end;
        until opt=4;
 End;

    begin
    clrscr;
        for i:=0  to 300 do
         begin
   write (i,'=',chr(i));
         end;
     casee;
     end.