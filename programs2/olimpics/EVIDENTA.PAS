program  evidenta;
uses crt;
    type info=record
    nume,prenume:string;
    nota1,nota2:real;
    end;
    var v:array [1..50] of info;
        G,F:text;
        n,i,opt:integer;

    begin
    assign (F,'intrari.txt');reset(F);
    assign (G,'iesire.txt');rewrite(G);
    if not eof(F) then
     reset(F);
    for i:=1 to n do
       begin
    read (F,'nume:);readln (v[i].nume);
    read (F,'prenume:);readln (v[i].prenume);
    end;
     for i:=1 to n do
    read (F',nota1:);readln(v[i].nota1);
    read (F'nota2:);readln (v[i].nota2);
       end;

    begin
    writeln ('dati val lui n:');readln (n);
    writeln ('daca tastati val "1" se va executa media notelor:');readln (opt);
    writeln ( 'daca tastati val "2"se va executa media geometrica:')readln (opt);
    writeln ( 'daca tastati val "3"se va executa afisarea lor in fisierul G:');(opt);
    end;
    case opt of
    1:begin
      for i:= 1 to n do
      writeln ('elevul cu numele',v[i].nume,v[i].prenume,'are media notelor:',(v[i].nota1*v[i].nota2)/2:3);
      readln;
      end;
    2:begin
      for i:= 1 to n do
      writeln ('elevul cu numele',v[i].nume,v[i].prenume,'are media geometrica:',sqrt(v[i].nota1*v[i].nota2));
      readln;
      end;
    3:begin
    rewrite (G);
      for i:= 1 to n do
      while not eof (G) do
      writeln(G,'Elevul cu numele', v[i].nume',:,' v[i].prenume',v[i].nota1 ,v[i].nota2);
      readln;
     end;
   end;close (G);close(F);
   end.