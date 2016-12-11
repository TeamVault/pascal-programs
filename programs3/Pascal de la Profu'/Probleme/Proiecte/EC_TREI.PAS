{Program care rezolva ecuatii de gradul III cu coeficientii introdusi de la tastatura}

{metoda de rezolvare se bazeaza pe teorema lui Rolle; o radacina a
unei ecuatii se afla intre doua radacini ale derivatei functiei, daca  pentru aceste
radacini functia ia valori de semne contrare, dar si intre -   si radacina minima
si intre radacina maxima a derivatei si +  , in aceleasi conditii; problema consta
in determinarea acestor "intervale" si determinarea radacinii ecuatiei de gradul III poate
avea una sau doua radacini reale.}
program ec_grad_trei;
var x,e,f,g,xd,xd1,xd2,j,m,s:real;
{notam cu x radacina cautata, cu xd1 si xd2 radacinile derivatei;
e,f,g,j,s,m,s1,s2,ss sunt variabile auxiliare care se folosesc la calcule
a,b,c,d coeficienti}
var a,b,c,d,s1,s2,ss:integer;
function z(x:real):real;
begin
  z:=a*x*x*x+b*x*x+c*x+d
end;
{procedura aprox, calculeaza radacina x intr-un interval j..s, m este o valoare medie
in cadrul intervalului,iar una dintre limitele intervalului este mutata in functie de semnele
functiei pe interval }
procedure aprox;
begin
     repeat
     m:=j+(s-j)/2;
     if z(m)*z(j)>0 then j:=m
                    else if z(m)*z(j)<0 then s:=m
                                        else if z(m)=0 then x:=m;
     until abs(z(m))<0.001;
     x:=m;
end;
begin
     writeln ('Dati ecuatia de gradul trei');
     writeln ('Rezultate');
     write('a=');readln(a);
     write('b=');readln(b);
     write('c=');readln(c);
     write('d=');readln(d);
     writeln (' ecuatia  ',a,'x^3+',b,'x^2+',c,'x+',d,'=0');
     e:=3*a; f:=2*b; g:=sqr(abs(f))-4*e*c;
     writeln(' discriminantul derivatei functiei g=',g:2:3 );
{discriminantul derivatei g=0 inseamna o radacina a dublei derivate,
xd, are o singura radacihna a ecuatiei intr-un interval care depinde de semnul
 functiei z(xd) pentru x=xd; am luat intervalul -100, +100}
     if g=0 then
     begin
      xd:=-f/(2*e);
      if z(xd)<0 then
      begin
        j:=xd;
        s:=100;
        aprox;
      end
      else if z(xd)>0 then
      begin
        j:=-100;
        s:=xd;
        aprox;
      end
      else if z(xd)=0 then x:=xd;
      writeln (' radacina derivatei xd= ',xd:2:3,' z(xd)= ',z(xd):2:3);
      writeln (' o singura solutie x= ',x:2:3,'pentru care z(x)=',z(x):2:3);
      end;
{ daca avem discriminantul negativ inseamna ca radacinile imaginare ale derivatei
sitrebuie cautate in spatiul -  ,+  }
      if g<0 then
      begin
        j:=-98; s:=100;
        aprox;
        writeln ('o singura solutie reala x=',x:2:3,'pentru care z(x)=',z(x):2:3);
      end;
{discriminantul pozitiv inseamna doua radacini reale ale derivatei, xd1 si xd2}
      if g>0 then
      begin
        xd1:=(-f-sqrt(g))/(2*e);
        xd2:=(-f+sqrt(g))/(2*e);
        writeln ('radacinile derivatei xd1 si xd2:',xd1:2:3,' ',xd2:2:3);
        writeln ('z(xd1)=',z(xd1):2:3,'z(xd2)=',z(xd2):2:3);
{ introducem variabilele s1 si s2, care reprezinta semnele functiilor}
        if z(xd1)>0 then s1:=1
                    else if z(xd1)<0 then s1:=-1
                                     else s1:=0;
        if z(xd2)>0 then s2:=1
                    else if z(xd2)<0 then s2:=-1
                                     else s2:=0;
                                     ss:=s1-s2;
{ambele valori ale functiei sunt negative inseamna ca are o radacina reala }
        if (s1+s2)=-2 then
        begin
          j:=0.5*((ss+1)*xd1+(-ss+1)*xd2); s:=100;
          aprox;
          writeln ('o solutie reala x=',x,' pentru care z(x)=',z(x));
        end
{ambele valori ale funtiei pozitive deci avem o radacina reala}
        else if (s1+s2)=2 then
        begin
          j:=-100; s:=0.5*((ss+1)*xd1);
          aprox;
          writeln('o solutie reala x= ',x:2:3,' pentru care z(x)=',z(x):2:3);
        end
{valorile functiei sunt de semn contrar insemna ca avem 3 radacini reale pe intervalele}

        else if s1+s2=0 then
        begin
          writeln(  'trei solutii reale');
          j:=-100; s:=xd1;
          aprox;
          writeln('x=',x:2:3,    'pentru care z(x)=',z(x):2:3);
          j:=xd1; s:=xd2;
          aprox;
          writeln('x= ',x:2:3,     'pentru care z(x)=',z(x):2:3);
          j:=xd2; s:=10;
          aprox;
          writeln ('x=',x:2:3,      'pentru care z(x)=',z(x):2:3);
       end
       else if s1=0 then
       begin
         writeln('o solutie dubla x= ', xd1:2:3,' pentru care z(x) =',z(x):2:3);
         j:=xd2;   s:= 100;
         aprox;
         writeln(' o solutie x=',x:2:3, 'pentru care z(x)=',z(x):2:3);
       end
{o valoare a functiei =0 o radacina dubla si una simpla}
       else if s2=0 then
       begin
         x:=xd2;
         writeln ('o solutie dubla x = ',xd2:2:3,'pentru care z(x) =',z(x):2:3);
         j:=-100;  s:=xd1;
         aprox;
         writeln ('o solutie x=',x:2:3,'  pentru care z(x)=',z(x):2:3);
        end;
       end;
      end.