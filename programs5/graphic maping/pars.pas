unit Pars;
{$F+}
{$IFDEF WIN32}
{$H-}
{$ENDIF}
interface

uses build,parsglb,sysutils;

type

PParse = ^OParse;

OParse = object
  fstring:string;
  vars:tVarPoints;
  params:tParPoints;
  numop:integer;
  fop:operationpointer;
  constructor init(s:string; varstring:tvarstring; parstring:tparstring;
                   var error:boolean);
  procedure setparams(parameters:Tparvalues);
  procedure f(x,y,z:extended;var r:extended);
  destructor done;
end;

implementation

var lastop:operationpointer;


procedure mynothing;
begin
end;

procedure mysum;
begin
  lastop^.dest^:=lastop^.arg1^+lastop^.arg2^;
end;

procedure mydiff;
begin
  with lastop^ do
     dest^:=arg1^-arg2^;
end;

procedure myprod;
begin
  with lastop^ do
     dest^:=arg1^*arg2^;
end;

procedure mydivis;
begin
  with lastop^ do
  if arg2^<>0 then
   dest^:=arg1^/arg2^ else dest^:=0;
end;

procedure myminus;
begin
  with lastop^ do
     dest^:=-arg1^;
end;

procedure myintpower;
var n,i:longint;
begin
  with lastop^ do
  begin
    n:=trunc(abs(arg2^))-1;
    case n of
    -1: dest^:=1;
     0: dest^:=arg1^;
    else
    begin
      dest^:=arg1^;
      for i:=1 to n do
       dest^:=dest^*arg1^;
    end;
   end;
  if arg2^<0 then if dest^<>0 then dest^:=1/dest^;
 end;
end;

procedure mysquare;
begin
  with lastop^ do
    dest^:=arg1^*arg1^;
end;

procedure mythird;
begin
  with lastop^ do
    dest^:=arg1^*arg1^*arg1^;
end;

procedure myforth;
begin
  with lastop^ do
    dest^:=arg1^*arg1^*arg1^*arg1^;
end;

procedure myrealpower;
begin;
  with lastop^ do
  if arg1^>0 then dest^:=exp(arg2^*ln(arg1^)) else dest^:=0;;
end;

procedure mycos;
begin
  with lastop^ do
    dest^:=cos(arg1^);
end;

procedure mysin;
begin
  with lastop^ do
    dest^:=sin(arg1^);
end;

procedure myexp;
begin
  with lastop^ do
    dest^:=exp(arg1^);
end;

procedure myln;
begin
  with lastop^ do
    if arg1^>0 then
    dest^:=ln(arg1^) else dest^:=0;
end;

procedure mysqrt;
begin
  with lastop^ do
  if arg1^>0 then
  dest^:=sqrt(arg1^) else dest^:=0;
end;

procedure myarctan;
begin
  with lastop^ do
    dest^:=arctan(arg1^);
end;

procedure myabs;
begin
  with lastop^ do
    dest^:=abs(arg1^);
end;

procedure mymin;
begin
  with lastop^ do
  begin
    dest^:=arg1^;
    if arg2^<arg1^ then dest^:=arg2^;
  end;
end;

procedure mymax;
begin
  with lastop^ do
  begin
    dest^:=arg2^;
    if arg1^>arg2^ then dest^:=arg1^;
  end;
end;

procedure myheavi;
begin
  with lastop^ do
    if arg1^<0 then dest^:=0 else dest^:=1;
end;


procedure myphase;
var a:extended;
begin
  with lastop^ do
  begin
    a:=arg1^/2/pi;
    dest^:=2*pi*(a-round(a));
  end;
end;

procedure myrand;
var j,k:word;
begin
  with lastop^ do
  begin
  j:=round(arg2^);
  k:=round(arg1^);
  if j=random(k) then dest^:=1 else dest^:=0;
  end;
end;

procedure myarg;
begin
  with lastop^ do
  if arg1^=0 then dest^:=pi/2 else
  if arg1^>0 then dest^:=arctan(arg2^/arg1^) else
  if arg2^>0 then dest^:=arctan(arg2^/arg1^)+pi else
   dest^:=arctan(arg2^/arg1^)-pi;
end;

procedure mycosh;
begin
  with lastop^ do
    dest^:=(exp(arg1^)+exp(-arg1^))/2;
end;

procedure mysinh;
begin
  with lastop^ do
    dest^:=(exp(arg1^)-exp(-arg1^))/2;
end;

procedure myradius;
begin
  with lastop^ do
    dest^:=sqrt(sqr(arg1^)+sqr(arg2^));
end;

procedure myrandrand;
var c:extended;
begin
  c:=random;
  if c<1.e-20 then c:=1.e-20;
  c:=sqrt(-2*ln(c))*cos(2*pi*random);
  with lastop^ do
  dest^:=arg1^+arg2^*c;
end;

procedure myfrac;
begin
  with lastop^ do
  dest^:=frac(arg1^);
end;

procedure myless;
begin
  with lastop^ do
    if arg1^<arg2^ then dest^:=1 else dest^:=0;
end;

procedure mylessequal;
begin
  with lastop^ do
    if arg1^<=arg2^ then dest^:=1 else dest^:=0;
end;

procedure myequal;
begin
  with lastop^ do
    if arg1^=arg2^ then dest^:=1 else dest^:=0;
end;

procedure mynotequal;
begin
  with lastop^ do
    if arg1^=arg2^ then dest^:=0 else dest^:=1;
end;

procedure mytan;
var x:extended;
begin
  with lastop^ do
  begin
    x:=cos(arg1^);
    if x<>0 then
   dest^:=sin(arg1^)/x else dest^:=0;
  end;
end;

procedure mytanh;
begin
  with lastop^ do
  dest^:=(exp(arg1^)-exp(-arg1^))/(exp(arg1^)+exp(-arg1^));
end;

procedure myarcsin;
begin
  with lastop^ do
  if abs(arg1^)<1 then dest^:=arctan(arg1^/sqrt(1-sqr(arg1^))) else
   if arg1^=1 then dest^:=pi/2 else if arg1^=-1 then dest^:=-pi/2 else dest^:=0;
end;

procedure myarccos;
begin
  with lastop^ do
  if arg1^>0 then if arg1^<=1 then dest^:=arctan(sqrt(1-sqr(arg1^))/arg1^)
  else dest^:=0 else if arg1^<0 then if arg1^>=-1 then
  dest^:=arctan(sqrt(1-sqr(arg1^))/arg1^)+pi else dest^:=0 else dest^:=pi/2;
end;




{OParse}

constructor OParse.init(s:string;varstring:tvarstring;
                   parstring:tparstring;var error:boolean);
var  lop:operationpointer;
const p:tparvalues = (1,1,1,1,1,1);
begin
    fstring:=s;
    fop:=nil;
    parsefunction(s,varstring,parstring,fop,vars,params,numop,error);
    lop:=fop;
    while lop<>nil do
    begin
      with lop^ do
      begin
        case opnum of
          0,1,2,3: op:=mynothing;
          4: op:=myminus;
          5: op:=mysum;
          6: op:=mydiff;
          7: op:=myprod;
          8: op:=mydivis;
          9: op:=myintpower;
          10: op:=myrealpower;
          11:op:=mycos;
          12:op:=mysin;
          13:op:=myexp;
          14:op:=myln;
          15:op:=mysqrt;
          16:op:=myarctan;
          17:op:=mysquare;
          18:op:=mythird;
          19:op:=myforth;
          20:op:=myabs;
          21:op:=mymax;
          22:op:=mymin;
          23:op:=myheavi;
          24:op:=myphase;
          25:op:=myrand;
          26:op:=myarg;
          27:op:=mysinh;
          28:op:=mycosh;
          29:op:=myradius;
          30:op:=myrandrand;
          31:op:=myfrac;
          32:op:=myless;
          33:op:=myequal;
          34:op:=mylessequal;
          35:op:=mynotequal;
          36:op:=mytan;
          37:op:=mytanh;
          38:op:=myarcsin;
          39:op:=myarccos;
        end; {case}
      end; {with lop^}
      lop:=lop^.next
    end; {while lop<>nil}
    if lop<>nil then
    setparams(p);
end;

procedure OParse.setparams;
var i:integer;
begin
  for i:=1 to 6 do
  params[i]^:=parameters[i];
end;


procedure OParse.f;
begin
    vars[1]^:=x; vars[2]^:=y; vars[3]^:=z;
    lastop:=fop;
    while lastop^.next<>nil do
    begin
      lastop^.op;
      lastop:=lastop^.next;
    end;
    lastop^.op;
    r:=lastop^.dest^;
end;

destructor OParse.done;
var i:integer; lastop,nextop:operationpointer;
begin
  lastop:=fop;
  while lastop<>nil do
  begin
    nextop:=lastop^.next;
    while nextop<>nil do
    begin
          if nextop^.arg1 = lastop^.arg1 then nextop^.arg1:=nil;
          if nextop^.arg2 = lastop^.arg1 then nextop^.arg2:=nil;
          if nextop^.dest = lastop^.arg1 then nextop^.dest:=nil;
          if nextop^.arg1 = lastop^.arg2 then nextop^.arg1:=nil;
          if nextop^.arg2 = lastop^.arg2 then nextop^.arg2:=nil;
          if nextop^.dest = lastop^.arg2 then nextop^.dest:=nil;
          if nextop^.arg1 = lastop^.dest then nextop^.arg1:=nil;
          if nextop^.arg2 = lastop^.dest then nextop^.arg2:=nil;
          if nextop^.dest = lastop^.dest then nextop^.dest:=nil;
          nextop:=nextop^.next;
    end;
    with lastop^ do
    begin
      for i:=1 to 3 do
      if arg1=vars[i] then arg1:=nil;
      for i:=1 to 6 do
      if arg1=params[i] then arg1:=nil;
      for i:=1 to 3 do
      if arg2=vars[i] then arg2:=nil;
      for i:=1 to 6 do
      if arg2=params[i] then arg2:=nil;
      for i:=1 to 3 do
      if dest=vars[i] then dest:=nil;
      for i:=1 to 6 do
      if dest=params[i] then dest:=nil;
      if (dest=arg1) or (dest=arg2) then dest:=nil;
      if arg1<>nil then dispose(arg1);
      if arg2<>nil then dispose(arg2);
      if dest<>nil then dispose(dest);
    end;
    nextop:=lastop^.next;
    dispose(lastop);
    lastop:=nextop;
  end;
  for i:=1 to 3 do
  if vars[i]<>nil then dispose(vars[i]);
  for i:=1 to 6 do
  if params[i]<>nil then dispose(params[i]);
end;



end.