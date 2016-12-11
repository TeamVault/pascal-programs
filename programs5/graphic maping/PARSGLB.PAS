unit Parsglb;
{$O+,F+}
{$IFDEF WIN32}
{$H-}
{$ENDIF}
interface
type rpointer=^extended;

     onestep=procedure;

     operationpointer=^operation;

     operation=record
             arg1,arg2:rpointer;
             dest:rpointer;
             next:operationpointer;
             op:onestep;
             opnum:word;
            end;

     TVarString=String[3];
     TParString=String[6];
     TVarPoints=array[1..3] of rpointer;
     TParPoints=array[1..6] of rpointer;
     TParValues=array[1..6] of extended;
var randomsize,randomresult:word;
    randomiterates,contrand:boolean;
implementation

end.