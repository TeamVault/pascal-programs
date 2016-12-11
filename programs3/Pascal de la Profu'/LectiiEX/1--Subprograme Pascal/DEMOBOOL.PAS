Program DemoBool;
{ program demonstrativ pentru tipul Boolean }

Uses
  Crt;
var
  B1, B2: Boolean;
  B3: Boolean;

Procedure WriteBool(M: String; var B: Boolean);
  begin
    Write(M,': ');
    Write(B);
    Write(' Ordinal ');
    WriteLn(Ord(B))
  End; { WriteBool }

begin
  ClrScr;
  WriteLn('DEMOBOOL - program demonstrativ pentru tipul boolean');
  B1 := True;
  WriteBool('B1', B1);
  B2 := False;
  WriteBool('B2', B2);
  B3 := B1 < B2;
  WriteBool('B1<B2', B3);
  B3 := B2 < B1;
  WriteBool('B2<B1', B3);
  B3 := Pred(B1);
  WriteBool('Pred(B1)', B3);
  B3 := Succ(B2);
  WriteBool('Succ(B2)', B3);
  B3 := High(B1);
  WriteBool('High(B1)', B3);
  B3 := Low(B1);
  WriteBool('Low(B1)', B3);
  B3 := 3 < 5;
  WriteBool('3 < 5', B3);
  B3 := 5 > 12;
  WriteBool('5 > 12', B3);
  B3 := 'a' > 'A';
  WriteBool('''a'' > ''A''', B3);
  B3 := ord('a') > ord('A');
  WriteBool('ord(''a'') > ord(''A'')', B3);
  B3 := 'a' > 'c';
  WriteBool('''a'' > ''c''', B3);
  B3 := ord('a') > ord('c');
  WriteBool('ord(''a'') > ord(''c'')', B3);
  B3 := 'alfa' > 'Alfa';
  WriteBool('''alfa'' > ''Alfa''', B3);
  B3 := 'Alfa' > 'Alfa2';
  WriteBool('''Alfa'' > ''Alfa2''', B3);
  ReadLn
end. { DemoBool }