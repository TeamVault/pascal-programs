{  Programul prezentat realizeaza,in primul rand,clasificarile notelor
unor studenti la examenul de Algoritmica.Nota finala a examenului va fi
media aritmetica dintre notele a trei probe:test grila teoretic,un proiect
si examenul practic (cu specificatia ca se vor da doua teste grila ,iar
nota finala a probei teoretice va fi nota maxima dintre cele doua)
    Am utilizat doua variabile de control a executiei programului:una logica,
care spune daca datele(unei serii de studenti) au fost introduse sau nu,precum
si una intreaga (optiune),prin care se precizeaza ce operatie se va executa .
De asemenea,aceasta a doua variabila este folosita atunci cand,desi datele
despre elevi sunt introduse,dorim sa le reintroducem.
    Cand se realizeaza o ordonare a studentilor,indiferent de criteriu,are loc
o interschimbare intre studenti.Acest lucru se realizeaza cu ajutorul unei
variabile auxiliare,care va fi de acelasi tip,deci de tip student.


program Examenul_la_Algoritmica;
{uses crt;}
type student=record
     nume :string;
     nota1,nota2,nota3,nota4,media,max:real;
     end;
var studentul:array[1..20] of student;
    numele:string;{numele studentului curent,completat cu spatii}
    i,j,nrstudenti:integer;
    aux:student;
    optiune:integer;
    date_introduse:boolean;
    s:string;
begin
  date_introduse:=false;
  repeat
 { textbackground(blue);}
   { clrscr;}
     Writeln('     ***  Examen Algoritmica - 8 ian 2001  ***');
     writeln;
     writeln('0-oprire program');
     writeln('1-introducere date studenti  ');
     writeln('2-listare dupa mediile finale');
     writeln('3-listare alfabetica_1       ');
     writeln('4-listare alfabetica_2       ');
     writeln;
     write('   Optiunea dvs.=');
     readln(optiune);
       case optiune of
          1:begin
              if not date_introduse then optiune:=1
              else
                 begin
                   writeln('Atentie! Date deja introduse!');
                   writeln('Le reintroduceti? (1=da;2=nu) ');
                   readln(optiune);
                  end;
              if optiune=1 then
                 begin
                   write('Dati numarul de studenti:');
                   readln(nrstudenti);
                   for i:=1 to nrstudenti do
                      with studentul[i] do
                        begin
                          writeln('Dati numele si prenumele!');
                          readln(nume);
                          writeln('Dati notele!');
                          write(' * Nota la primul test grila   :');
                          readln(nota1);
                          write(' * Nota la al doilea test grila:');
                          readln(nota2);
                          write(' * Nota pe proiect             :');
                          readln(nota3);
                          write(' * Nota la examenul practic    :');
                          readln(nota4);
                           if nota1>nota2 then
                            begin
                              max:=nota1;
                              media:=(max+nota3+nota4)/3
                            end
                                          else
                            begin
                              max:=nota2;
                              media:=(max+nota3+nota4)/3;
                            end;
                        end;
                     date_introduse:=true;
                 end;
             end;

         2: if not date_introduse then
             begin
               write('Introduceti mai intai datele');
               writeln('  despre studenti!');
              end
                                  else
              begin
                 {Folosim metoda sortarii prin selectie}
                 for i:=1 to pred(nrstudenti) do
                 for j:=succ(i) to nrstudenti do
                   {comparatie dupa medii}
                   if studentul[i].media<studentul[j].media then
                     begin
                       aux:=studentul[i];
                       studentul[i]:=studentul[j];
                       studentul[j]:=aux
                     end;

                for i:=1 to nrstudenti do
                   with studentul[i] do
                    begin
                       {se completeaza numele cu spatii la dreapta}
                       numele:=nume;
                       for j:=1 to 30-length(nume) do
                           numele:=numele+' ';
                       {se afisaza daca studentul a luat sau nu examenul}
                       if media>=5 then
                          begin
                             s:='  admis';
                             writeln(i:2,'.',numele,':',max:6:2,nota3:6:2,nota4:6:2,media:6:2,s);
                          end
                                  else
                          begin
                             s:='  respins';
                             writeln(i:2,'.',numele,':',max:6:2,nota3:6:2,nota4:6:2,media:6:2,s);
                          end;

              end;
            end;
        3: if not date_introduse then
              begin
                write('Introduceti mai intai');
                writeln(' datele despre studenti !');
              end
                                 else
              begin
               {ordonarea prin selectie a numelor}
               for i:=1 to pred(nrstudenti) do
               for j:=succ(i) to nrstudenti do
                 if studentul[i].nume<studentul[j].nume then
                   begin
                     aux:=studentul[i];
                     studentul[i]:=studentul[j];
                     studentul[j]:=aux;
                   end;

               for i:=1 to nrstudenti do
                with studentul[i] do
                  begin
                    {se completeaza numele cu spatii la dreapta}
                    numele:=nume;
                    for j:=1 to 35-length(nume)do
                      numele:=numele+' ';
                      writeln(i:2,'.',numele,':',max:6:2,nota3:6:2,nota4:6:2,media:6:2);
                  end;
              end;
       4: if not date_introduse then
              begin
                write('Introduceti mai intai');
                writeln(' datele despre studenti !');
              end
                                else
              begin
               {ordonarea prin selectie a mediilor de la proba practica}
               for i:=1 to pred(nrstudenti) do
               for j:=succ(i) to nrstudenti do
                 if studentul[i].nota4<studentul[j].nota4 then
                   begin
                     aux:=studentul[i];
                     studentul[i]:=studentul[j];
                     studentul[j]:=aux;
                   end;

               for i:=1 to nrstudenti do
                with studentul[i] do
                  begin
                    {se completeaza numele cu spatii la dreapta}
                    numele:=nume;
                    for j:=1 to 35-length(nume)do
                      numele:=numele+' ';
                      writeln(i:2,'.',numele,':',nota4:6:2);
                  end;
              end;
 end;
 writeln;
 writeln('06 pentru continuare! ');
{ readln;}
 until(optiune=0);
 readln;
 readln;
 end.

 { *** Variabile folosite: studentul:array[1..20] of student;
                           numele:string-->numele studentului curent,completat cu spatii;
                           aux:student --> variabila auxiliara folosita la interschimbare;
                           s:string -->sir de caractere in care memoram doua
                                       cuvinte: admis/respins;

   *** Fireste,programul nu poate fi considerat decat din punct de vedere
 didactic,deoarece el lucreaza cu cel mult 20 de studenti.Acest numar poate
 fi marit,insa nu prea mult,caci se va afisa o eroare de depasire a memoriei.}


