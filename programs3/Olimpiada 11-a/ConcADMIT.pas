{program foloseste case avand optinunea de a aranja o in ordine alfabetica, in
 ordine medilor, afisare lor toate acestea dupa ce datele au fost introduse; fireste}

 program Concurs_de_admitere;
 uses crt;
 type date=record
      n1,n2,med:integer;
      nume:string;
      end;
    vec=array[1..200] of date;
   var v:vec;  n,m,i,j,opt,aux:integer; gata:boolean;num:string;

      procedure media;
     begin
     write('ordonarea dupa medie a celor',n,'este');
      repeat
     gata:=true;
      for i:=1 to n-1 do
           if (v[i+1].med< v[i].med) then
          begin
         gata:=false;
         aux:=v[i].med;
         v[i].med:=v[i+1].med;
         v[i+1].med:=aux;
          end
         until gata;
         writeln ('vectorul sortat  arata asa :');
         for i:=1 to n do
         writeln ('pe pozitia=' ,i, 'este elevul cu media:',v[(n+1)-i].med);
         readln;
      end;
      procedure ORDalfabetica;
      var s:string;
       begin
       writeln('se executa ordalfabetica');
         for i:=1to n do
          for j:=i+1 to n-1 do
           if (v[j].nume< v[i].nume) then
           begin
           s:=v[i].nume;
           v[i].nume:=v[j].nume;
           v[j].nume:=s;
           end;
           writeln('ordalfabetica este:');
           for i:=1 to n do
              begin
              writeln('pe pozitia',i,'este elevul:',v[i].nume);
              end;
       end;
      procedure Cautarea;
      begin
   writeln  ('dati numele cautat');readln(num);
      for i:=1  to n do
        begin
       if v[i].nume=num then
       writeln('elevul:',v[i].nume );
       writeln('ocupa pozitia ',i,'din lista, are:');
       writeln('nota 1:',v[i].n1 );
       writeln('nota 2:,',v[i].n2);
       writeln('media',v[i].med);delay(2000);exit;
        end;
      end;
      begin
       writeln('dati nr de elevi');readln(n);
           for i:=1 to n do
             with  v[i] do
                begin
          repeat
              writeln ('dati not 1 si nota 2 a elelvului',i);readln(n1,n2);
          until (n1>=5) and (n2>=5);
            writeln('Dati numele elevului',i);readln(nume);
          v[i].med:=((v[i].n1+v[i].n2)div 2);
                end; clrscr;
       repeat
    writeln ('1:media:Ordonarea dupa mediea elevilor');
    writeln ('2:ORDalfabetica:ordonarea alfabetica');
    writeln ('3:Cautarea: elevului dorit prin introducerea numelui sau');
    writeln ('4:parasirea programului');readln(opt);clrscr;
        case opt of
     1:media;
     2:ORDalfabetica;
     3:Cautarea;

       else write('dati un nr in [1,3]');
       end;
       until opt=4;writeln('multumim!!!');
 end.