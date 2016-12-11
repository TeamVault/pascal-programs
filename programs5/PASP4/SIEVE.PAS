program sieve;
const size=8190;
      loops= 1;
var
        flags:array[0..size] of boolean;
        i,prime,k,count,iter:integer;
begin
        writeln(loops, ' iterations');
        for iter:=1 to loops do begin
        count:=0;
        for i:=0 to size do
            flags[i]:=true;
        for i:=0 to size do
                if flags[i] then begin
                        prime:=i+i+3;
                        k:=i+prime;
                        while k<=size do begin
                                flags[k]:=false;
                                k:=k+prime
                        end;
                        count:=count+1;
                end;
       end;
       writeln(count,' primes');
end.
{$n-}

