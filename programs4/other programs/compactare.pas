                          program compactareTXT;
                          var bs,b,a :string;j,i:integer;
                          begin
                          write('dati textul dorit');readln(a);
                          bs:='';
                          i:=1;
                          while i <length(a) do
                          begin
                         if a[i]=a[i+1] then
                            begin
                           j:=1;
                            repeat
                             inc(j);inc(i);
                             until a[i]<>a[i+1];
                           inc(i); str(j,b);
                          bs:=bs+'#'+a[i-1]+b
                            end
                          else          begin
                         bs:=bs+'#'+a[i]+'1'; inc(i);
                                         end;
                           end;
                         writeln(bs);readln;
                         end.