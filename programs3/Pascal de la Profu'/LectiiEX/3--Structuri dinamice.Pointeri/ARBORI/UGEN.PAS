Unit UGen;

Interface
Type
  Elem = Integer;

Function StrI(w: Elem): String;
Function StrL(w: LongInt): String;
Function StrR(w: Real; l,d:Byte): String;
Function StrToW(S: String): Elem;
Function ToNumStr(S: String): String;
Procedure MemoDisp(M:String);
Function FileExists(fn: String): Boolean;
Procedure FileErase(fn: String);

Implementation

Function StrI(w: Elem): String;
  var s: String;
  begin
    Str(W:5, S);
    StrI := S
  end; { StrW }

Function StrL(w: LongInt): String;
  var s: String;
  begin
    Str(W:10, S);
    StrL := S
  end; { StrL }

Function StrR(w: Real; l,d:Byte): String;
  var s: String;
  begin
    Str(W:l:d, S);
    StrR := S
  end; { StrR }

Function StrToW(S: String): Elem;
  var v: Elem;
      c: Integer;
  begin
    val(S, v, c);
    if c = 0
      then StrToW := v
      else StrToW := MaxInt;
  end; { StrToW }

Function ToNumStr(S: String): String;
  var c: String;
      i: Integer;
  const Permise: set of char = [',', '0'..'9'];
  begin
    c := '';
    for i := 1 to length(S) do
      if S[i] in Permise then c := c + S[i];
    ToNumStr := c
  end; { ToNumStr }

Procedure MemoDisp(M:String);
  begin
    writeln(M + ': memorie disponibila ' + strL(MaxAvail));
    readln
  end;

Function FileExists(fn: String): Boolean;
  var
   F: file;
  begin
   {$I-}
   Assign(F, FN);
   FileMode := 0;  { Set file access to read only }
   Reset(F);
   Close(F);
   {$I+}
   FileExists := (IOResult = 0) and (FN <> '');
  end;  { FileExists }

Procedure FileErase(fn: String);
  var
   F: file;
  begin
   {$I-}
   Assign(F, FN);
   FileMode := 0;  { Set file access to read only }
   Reset(F);
   {$I+}
   If IOResult <> 0 then Exit;
   Close(F);
   Erase(F);
  end;  { FileErase }

End.