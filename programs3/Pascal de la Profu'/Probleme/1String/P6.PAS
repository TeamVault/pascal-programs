{Pentru codificarea mesajelor transmite intre 2 terminale,se inlocuieste orice
succesiune de mai multe caractere de acelasi fel cu un caracter de control #
urmat de caracterul respectiv si nr lui de repetari succesive.Sa se scrie
programul de codificare.
      EX:abbbbxyyybbbzttt     0#b4x#y3#b3z#t3}
program p6;
var a,b,s,cr:string;
    i,j,nr:byte;
    c:integer;

begin
readln(a);
i:=1;b:=' ';
repeat
   cr:=a[1];
   nr:=0;
   while pos(cr,a)<>0 do
         begin
         inc(nr);
         delete(a,pos(cr,a),1);
         end;
   str(nr,s);
   b:=b+'#'+cr+s;
until length(a)=0;
writeln(b);
end.
