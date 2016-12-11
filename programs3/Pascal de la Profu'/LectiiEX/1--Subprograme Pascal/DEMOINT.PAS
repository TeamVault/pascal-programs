Program DemoInt;
{ program demonstrativ pentru tipurile intregi }

{$Q+}   { overflow checking - verifica depasirile }

Uses
  Crt;

Procedure DemoByte(a, b: Byte);
  begin
    WriteLn('Tipul Byte');
    WriteLn(a:3, '+', b:3, '=', Byte(a+b):3);
    WriteLn(a:3, '-', b:3, '=', Byte(a-b):3);
    WriteLn(a:3, '*', b:3, '=', Byte(a*b):3);
    WriteLn('Catul impartirii lui ',a:3, ' la ', b:3, '=', a div b);
    WriteLn('Restul impartirii lui ',a:3, ' la ', b:3, '=', a mod b);
    WriteLn('Ord(',a:3,')=',Ord(a):3);
    WriteLn('Pred(',a:3,')=',Pred(a):3);
    WriteLn('Succ(',a:3,')=',Succ(a):3);
    WriteLn('Low(',a:3,')=',Low(a):3);
    WriteLn('High(',a:3,')=',High(a):3);
    ReadLn
  end; { DemoByte }

Procedure DemoShort(a, b: ShortInt);
  begin
    WriteLn('Tipul ShortInt');
    WriteLn(a:3, '+', b:3, '=', ShortInt(a+b):3);
    WriteLn(a:3, '-', b:3, '=', ShortInt(a-b):3);
    WriteLn(a:3, '*', b:3, '=', ShortInt(a*b):3);
    WriteLn('Catul impartirii lui ',a:3, ' la ', b:3, '=', a div b);
    WriteLn('Restul impartirii lui ',a:3, ' la ', b:3, '=', a mod b);
    WriteLn('Ord(',a:3,')=',Ord(a):3);
    WriteLn('Pred(',a:3,')=',Pred(a):3);
    WriteLn('Succ(',a:3,')=',Succ(a):3);
    WriteLn('Low(',a:3,')=',Low(a):3);
    WriteLn('High(',a:3,')=',High(a):3);
    ReadLn
  end; { DemoShort }

Procedure DemoInteger(a, b: Integer);
  begin
    WriteLn('Tipul IntegerInt');
    WriteLn(a:3, '+', b:3, '=', Integer(a+b):3);
    WriteLn(a:3, '-', b:3, '=', Integer(a-b):3);
    WriteLn(a:3, '*', b:3, '=', Integer(a*b):3);
    WriteLn('Catul impartirii lui ',a:3, ' la ', b:3, '=', a div b);
    WriteLn('Restul impartirii lui ',a:3, ' la ', b:3, '=', a mod b);
    WriteLn('Ord(',a:3,')=',Ord(a):3);
    WriteLn('Pred(',a:3,')=',Pred(a):3);
    WriteLn('Succ(',a:3,')=',Succ(a):3);
    WriteLn('Low(',a:3,')=',Low(a):3);
    WriteLn('High(',a:3,')=',High(a):3);
    ReadLn
  end; { DemoInteger }

Procedure DemoWord(a, b: Word);
  begin
    WriteLn('Tipul Word');
    WriteLn(a:3, '+', b:3, '=', Word(a+b):3);
    WriteLn(a:3, '-', b:3, '=', Word(a-b):3);
    WriteLn(a:3, '*', b:3, '=', Word(a*b):3);
    WriteLn('Catul impartirii lui ',a:3, ' la ', b:3, '=', a div b);
    WriteLn('Restul impartirii lui ',a:3, ' la ', b:3, '=', a mod b);
    WriteLn('Ord(',a:3,')=',Ord(a):3);
    WriteLn('Pred(',a:3,')=',Pred(a):3);
    WriteLn('Succ(',a:3,')=',Succ(a):3);
    WriteLn('Low(',a:3,')=',Low(a):3);
    WriteLn('High(',a:3,')=',High(a):3);
    ReadLn
  end; { DemoWord }

Procedure DemoLong(a, b: LongInt);
  begin
    WriteLn('Tipul LongInt');
    WriteLn(a:3, '+', b:3, '=', LongInt(a+b):3);
    WriteLn(a:3, '-', b:3, '=', LongInt(a-b):3);
    WriteLn(a:3, '*', b:3, '=', LongInt(a*b):3);
    WriteLn('Catul impartirii lui ',a:3, ' la ', b:3, '=', a div b);
    WriteLn('Restul impartirii lui ',a:3, ' la ', b:3, '=', a mod b);
    WriteLn('Ord(',a:3,')=',Ord(a):3);
    WriteLn('Pred(',a:3,')=',Pred(a):3);
    WriteLn('Succ(',a:3,')=',Succ(a):3);
    WriteLn('Low(',a:3,')=',Low(a):3);
    WriteLn('High(',a:3,')=',High(a):3);
    ReadLn
  end; { DemoLong }

var
  optiune: byte;
begin
  Repeat
    ClrScr;
    WriteLn('DEMOINT - program demonstrativ pentru tipurile intregi');
    WriteLn('1. Tipul Byte');
    WriteLn('2. Tipul ShortInt');
    WriteLn('3. Tipul Integer');
    WriteLn('4. Tipul Word');
    WriteLn('5. Tipul LongInt');
    WriteLn('0. Terminare');
    Write('Dati optiunea: ');
    ReadLn(optiune);
    Case optiune of
      1: DemoByte(23, 12);
      2: DemoShort(12, -23);
      3: DemoInteger(100, 200);
      4: DemoWord(200, 100);
      5: DemoLong(1000, 1000);
    end
  Until optiune = 0
end. { DemoInt }