	program cautare_binara;
	type sir=array[1..10] of integer;
	var a:sir;
	    i,n:byte;
	    x:integer;
	procedure   cautare(st,dr:byte);
	var mijloc:byte;
	begin
	if st>dr then  begin
	write('el nu apartine sirului');exit;
	end;
	mijloc:=(st+dr) div 2;
	if a[mijloc]=x then 
	write('valoarea ',x,' se afla pe pozitia  ',mijloc)
	               else 
	if a[mijloc]>x then 
	cautare(st,mijloc-1)
	                                else 
	cautare(mijloc+1,dr);
	end;
	begin
	write('dati nr de valori ');read(n);
	write('dati sirul ordonat');
	for i:=1 to n do
	begin
	write('a[',i,']= ');
	read(a[i]);
	end;
	write('dati valoarea ');read(x);
	cautare(1,n);
	readln;
	readln;
	end.
