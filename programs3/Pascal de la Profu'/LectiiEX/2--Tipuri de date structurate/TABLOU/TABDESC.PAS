Program TabDesc;

 Function Min(var A: array of Real): Real;
   {A este parametru tablou deschis }
   Var
     I: integer;
     M: real;
   begin
     M := 10e20;
     for I := Low(A) to High(A) do
       if A[I] < M then M := A[I];
     Min := M
   end;

 const   { constante tablou cu tip }

   CA1: array[5..20] of real =(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16);
   CA2: array[-5..7] of real =(-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7);

 Begin
   WriteLn(Min(CA1):10:2);
   WriteLn(Min(CA2):10:2);
   ReadLn
 End. { TabDesc }