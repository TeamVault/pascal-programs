(*$c+*)
program print(com1);
const x =
 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
var i, j : integer;
   com1 : text;
begin
{ PROGRAM FOR WRITING TO THE com1 PORT OF A PC; THE }
{ SAME METHOD CAN BE USED TO READ FROM A COM PORT OR }
{ TO WRITE TO DEVICES LIKE lpt1, WHICH CAN BE OPENED }
{ AS FILES. SEE YOUR OPERATING SYSTEM MANUAL FOR THE }
{ DETAILS. }
 write('Type in the number of repetitions: ');
{ NOTE THAT READLN READS IN THE INTEGER AND THEN CONSUMES }
{ THE END OF LINE THAT YOUR PRESSING OF THE 'ENTER' KEY }
{ PRODUCES: }
 readln(i);
 for j := 1 to i do
  begin
   writeln(x);
   writeln(com1, x)
  end
end.
