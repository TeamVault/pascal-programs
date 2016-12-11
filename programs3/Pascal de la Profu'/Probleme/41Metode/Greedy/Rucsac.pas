Program Problema_Rucsacului;
Uses Crt;
Type
 vector=array[1..255] of integer;
 vector1=array[1..255] of set of byte;
Var
 go,co,cid,cid1   :vector;
 n,i,j,g,max,poz,k:integer;
 stare,stare1     :vector1;
Begin
 Write('n= '); Readln(n);
 Write('g= '); Readln(g);
 For i:=1 to n do
                 Begin
                  Clrscr;
                  Write('Greutatea obiectului ',i,' : ');
                  Readln(go[i]);
                  Write('Castig obtinut la transportul ob. ',i,' : ');
                  Readln(co[i]);
                 End;
 For j:=1 to g do
                 Begin
                  stare[j]:=[];
                  cid[j]:=0;
                 End;
 cid[go[1]]:=co[1];
 stare[go[1]]:=[1];
 For i:=2 to n do
                 Begin
                  cid1:=cid;
                  stare1:=stare;
                  if cid1[go[i]]<co[i] then
                                           Begin
                                            cid[go[i]]:=co[i];
                                            stare[go[i]]:=[i];
                                           End;
                  For j:=1 to g-go[i] do
                     If cid1[j]<>0 then
                       If cid1[j+go[i]]<cid1[j]+co[i] then
                        Begin
                         cid[j+go[i]]:=cid1[j]+co[i];
                         stare[j+go[i]]:=stare1[j]+[i];
                        End;
                 End;
 max:=cid[1];
 poz:=1;
 For i:=2 to g do
      If cid[i]>max then
                        Begin
                         poz:=i;
                         max:=cid[i];
                        End;
 Writeln('Se transporta ',poz,' unitati de greutate ');
 Writeln('Castig maxim este ',max);
 Writeln('Se transporta obiectele: ');
 For i:=1 to 255 do
  If i in stare[poz] then writeln(i);
  Readln;
End.