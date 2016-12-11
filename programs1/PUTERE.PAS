{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+}
{$M 16384,0,655360}
program putere;
uses crt;
var a,n,i:integer;
    P:real;
BEGIN
 clrscr;
 Write('Dati numarul: ');
 Readln(a);
 Write('Dati puterea: ');
 Readln(n);
 P:=1;
 For i:=1 to n do
  P:=P*a;
 Write(a,' la puterea ',n,' este: ',P);
 Readln;
END.