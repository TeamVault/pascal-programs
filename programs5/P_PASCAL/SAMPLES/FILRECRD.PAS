{$c+}
program record_file(fp);
type  node = record
     message1 : packed array [1 ..27] of char;
     index : integer;
     message2 : packed array [1 .. 25] of char;
     r_index : real
    end;
  file_record = file of node;
var fp : file_record;
 n_buf : node;
    i  : integer;
 break : boolean;
begin
 rewrite(fp);
 for i := 1 to 3 do
  begin
   with n_buf do
    begin
     message1 := 'This is read from record # ';
     index := i;
     message2 := '; real value of index is ';
     r_index := i
    end;
   write(fp, n_buf)
  end;
 page; writeln;
 writeln('First test; use of file WRITEs and READs:');
 reset(fp);
 i := 1; break := true;
 while break and not eof(fp) do
  if i > 3 then
   begin
    writeln; writeln;
    writeln('File error: index i is ', i : 1);
    break := false
   end
  else
   begin
    read(fp, n_buf);
    with n_buf do
     writeln(message1, index : 1, message2, r_index : 1 : 1, ' .');
    i := succ(i)
   end;
 writeln; writeln;
 writeln('Second test; the system PUTs, then GETs, records:');
 rewrite(fp);
 for i := 1 to 3 do
  begin
   with fp^ do
    begin
     message1 := 'This is read from record # ';
     index := i;
     message2 := '; real value of index is ';
     r_index := i
    end;
   put(fp)
  end;
 reset(fp);
 i := 1; break := true;
 while break and not eof(fp) do
  if i > 3 then
   begin
    writeln; writeln;
    writeln('File error: index i is ', i : 1);
    break := false
   end
  else
   begin
    with fp^ do
     writeln(message1, index : 1, message2, r_index : 1 : 1, ' .');
    get(fp);
    i := succ(i)
   end
end.