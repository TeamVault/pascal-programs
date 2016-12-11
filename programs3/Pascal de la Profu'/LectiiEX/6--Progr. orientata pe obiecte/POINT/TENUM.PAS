Program tenum;
  type
    enum = (unu, doi, trei, patru, cinci, sase);
    subd = trei..cinci;
  var
    e:enum;
    s:subd;
  begin
    e := trei;
    s := patru;
    readln;
  end.