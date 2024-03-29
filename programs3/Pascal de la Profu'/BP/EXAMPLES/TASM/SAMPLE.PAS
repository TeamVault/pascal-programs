unit Sample;
{ Sample unit that defines several pascal procedures that are
  called from an assembly language procedure. }
interface

procedure TestSample;

procedure PublicProc;         { Must be far since it is visible outside }

implementation

var
  A : word;

procedure AsmProc; external;
{$L CALLPROC.OBJ}

procedure PublicProc;
  begin { PublicProc }
    Writeln('In PublicProc');
  end;  { PublicProc }

procedure NearProc;           { Must be near }
  begin { NearProc }
    Writeln('In NearProc');
  end;  { NearProc }

{$F+}
procedure FarProc;            { Must be far due to compilerdirective }
  begin { FarProc }
    Writeln('In FarProc');
  end;  { FarProc }

{$F-}

procedure TestSample;
  begin { TestSample }
    Writeln('In TestSample');
    A := 10;
    Writeln('Value of A before ASMPROC = ',A);
    AsmProc;
    Writeln('Value of A after ASMPROC = ',A);
  end { TestSample };

end.
