program turnurileDinHanoi;
uses crt;
var A,B,C,n:integer;
  procedure Hanoi(n:integer;A,B,C:integer);
     begin
     if n=1 then{daca avem un singur disc il mutam de  pe A pe B}
       write('A,B')
            else
            begin
              Hanoi(n-1,A,C,B);{mutam n-1 dicuride pe A pe C,folosind B ca tija de manevra}
              writeln (A,B);  {dicul ramas pe tija A,ilmutam pe tija B}
              Hanoi(n-1,C,B,A); {mutam n-1 dicuri de pe C pe B,folosind A ca tija de manevra}
            end;
     end;
     begin
     clrscr;{n reprezinta nr de dicuri}
     write('n='); readln(n);{pt. a putea afisa tijele li se asociaza acestora numerele 1,2,3}
     Hanoi(n,1,2,3);
     readln;
     End.

