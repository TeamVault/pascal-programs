unit Build;
{$F+}
{$IFDEF WIN32}
{$H-}
{$ENDIF}
interface
uses sysutils,parsglb;

procedure parsefunction(ss:string;varstring:TVarString;parstring:TParString;
            var fop:operationpointer;
            var point:TVarPoints;
            var par:TParPoints;
            var numop:integer;
            var error:boolean);
implementation

type
     TtermKind=(variab,constant,param,brack,minus,sum,diff,prod,divis,
                    intpower,realpower,cosine,sine,expo,logar,sqroot,
                    arctang,square,third,forth,
                    abso,maxim,minim,heavi,
                    phase,randfunc,argu,hypersine,hypercosine,radius,
                    randrand,fraction,less,equal,lessequal,notequal,
                    tangent,hypertangent,arcsine,arccosine);

var TheString:string; TheVar:TVarstring; ThePar:TParstring;

procedure checksyntax(i0,j0:byte; var i1,j1,i2,j2:byte;
                      var kind:ttermkind; var num:extended;
                      var varsort,parsort:word; var numvar:byte;
                      var checks:boolean); forward;

procedure chopblanks(var s:string);  forward;
{deletes all blanks in s}

{i0, j0 in the following are used to denote a part of TheString.
 under investigation is the string s=copy(TheString,i0,j0). i1, j1 (, i2, j2)
 return the delimiter(s) of the substring(s) corresponding to the operand(s).}
procedure checkbracketnum(i0,j0:byte; var checks:boolean); forward;
{checks whether there's a ')' for any '('}

procedure checknum(i0,j0:byte;var num:extended;var checks:boolean); forward;
{checks whether s is a number}

procedure checkvar(i0,j0:byte; var varsort:word;var checks:boolean); forward;
{checks whether s is a variable character}

procedure checkparam(i0,j0:byte; var parsort:word;var checks:boolean); forward;
{checks whether s is a parameter character}

procedure checkbrack(i0,j0:byte; var i1,j1,i2,j2:byte; var kind:TTermKind; var num:extended;
    var varsort,parsort:word; var numvar:byte; var checks:boolean); forward;
{checks whether s =(...(s1)...) and s1 is a valid term}

procedure checkmin(i0,j0:byte;
      var i1,j1:byte;var checks:boolean); forward;
{checks whether s denotes the negative value of a valid operation}

procedure checkoperation(i0,j0:byte;
  var i1,j1,i2,j2:byte; var priority:byte;
  var kind:TTermkind; var checks:boolean); forward;
{Checks whether s is a valid expression for an operation +, -, *, /, or ^}

procedure check2varfunct(i0,j0:byte;
   var i1,j1,i2,j2:byte;var fsort:
    Ttermkind;var checks:boolean);  forward;
{checks whether s=f(s1,s2); s1,s2 being valid terms}

procedure checkfunct(i0,j0:byte;
          var i1,j1:byte;var fsort:TTermKind; var checks:boolean); forward;
{checks whether s denotes the evaluation of a function f(s1)}

procedure chopblanks(var s:string);
var i:byte;
begin
  while pos(' ',s)>0 do
  begin
    i:=pos(' ',s);
    delete(s,i,1);
  end;
end;

procedure checkbracketnum(i0,j0:byte; var checks:boolean);
var lauf,lzu,i:integer;
begin
  lauf:=0;lzu:=0;i:=i0-1;
  checks:=false;
  repeat
    inc(i);
    if TheString[i]='(' then
      inc(lauf);
    if TheString[i]=')' then
      inc(lzu);
    if lzu>lauf then exit;
  until i>=i0+j0-1;
  if lauf=lzu then
    checks:=true;
end;

procedure checksyntax(i0,j0:byte; var i1,j1,i2,j2:byte;
              var kind:ttermkind; var num:extended;
              var varsort,parsort:word; var numvar:byte;
                var checks:boolean);
var priority:byte;
begin
  checks:=false;
  checkbracketnum(i0,j0,checks);
  if not checks then exit;
  checkbrack(i0,j0,i1,j1,i2,j2,kind,num,varsort,parsort,numvar,checks);
  if checks then exit;
  kind:=constant; numvar:=0;
  checknum(i0,j0,num,checks); if checks then exit;
  kind:=variab;
  checkvar(i0,j0,varsort,checks); if checks then exit;
  kind:=param;
  checkparam(i0,j0,parsort,checks); if checks then exit;
  numvar:=2;
  checkoperation(i0,j0,i1,j1,i2,j2,priority,kind,checks);
  if checks then exit;
  numvar:=1; kind:=minus;
  checkmin(i0,j0,i1,j1,checks); if checks then exit;
  checkfunct(i0,j0,i1,j1,kind,checks); if checks then exit;
  numvar:=2;
  check2varfunct(i0,j0,i1,j1,i2,j2,kind,checks); if checks then exit;
end;

procedure checknum(i0,j0:byte;var num:extended;var checks:boolean);
var s:string;
begin
  checks:=false;
  if (copy(thestring,i0,j0)='Pi') or (copy(thestring,i0,j0)='pi') then
  begin
    checks:=true;
    num:=Pi;
    exit;
  end
  else
  begin
    s:=copy(thestring,i0,j0)+#0;
    {$IFDEF WIN32}
    checks:=TextToFloat(@s[1],num,fvExtended);
    {$ELSE}
    checks:=TextToFloat(@s[1],num);
    {$ENDIF}
  end;
end;

procedure checkparam(i0,j0:byte; var parsort:word; var checks:boolean);
var i:byte;
begin
  checks:=false;
  if j0<>1 then exit else
  begin
    for i:=1 to 6 do
    if thestring[i0]=thepar[i] then begin
      checks:=true; parsort:=i; exit; end;
  end;
end;


procedure checkvar(i0,j0:byte;var varsort:word;var checks:boolean);
var i:byte;
begin
  checks:=false;
  if j0<>1 then exit else
  begin
    for i:=1 to 3 do
    if thestring[i0]=thevar[i] then
    begin
      checks:=true;
      varsort:=i;
      exit;
    end;
  end;
end;

procedure checkbrack(i0,j0:byte; var i1,j1,i2,j2:byte;
            var kind:ttermkind; var num:extended;
              var varsort,parsort:word; var numvar:byte; var checks:boolean);
begin
  checks:=false;
  if thestring[i0]='(' then
  if thestring[i0+j0-1]=')' then
  begin
    checksyntax(i0+1,j0-2,i1,j1,i2,j2,kind,num,varsort,parsort,numvar,checks);
  end;
end;

procedure checkmin(i0,j0:byte;
             var i1,j1:byte; var checks:boolean);
var num:extended;   fsort:tTermKind; i2,j2,i3,j3:byte;
    varsort,parsort:word; numvar,priority:byte;
begin
  checks:=false;
  if thestring[i0]='-' then
  begin
    i1:=i0+1; j1:=j0-1;
    checkbrack(i1,j1,i2,j2,i3,j3,fsort,num,varsort,parsort,numvar,checks);
    if checks then begin
       i1:=i1+1; j1:=j1-2; exit; end;
    checkvar(i1,j1,varsort,checks); if checks then exit;
    checkparam(i1,j1,varsort,checks); if checks then exit;
    checkfunct(i1,j1,i2,j2,fsort,checks); if checks then exit;
    check2varfunct(i1,j1,i2,j2,i3,j3,fsort,checks); if checks then exit;
    checknum(i1,j1,num,checks); if checks then exit;
    checkoperation(i1,j1,i2,j2,i3,j3,priority,fsort,checks);
    checks:=checks and (priority>=2);
  end;
end;

procedure checkoperation(i0,j0:byte;
                         var i1,j1,i2,j2:byte; var priority:byte;
                              var kind:TTermKind; var checks:boolean);
var i3,j3,i4,j4,i,j:byte; num:extended; fsort:ttermkind;varsort,parsort:word;
    prior:byte;op:char; che:boolean; numvar:byte;
begin
  checks:=false;
  i:=i0-1; 
  repeat
    j:=i;
    repeat
      inc(j);
    until (thestring[j] in ['+','-','*','/','^']) or (j>i0+j0-1);
    if j>i0+j0-1 then exit;
    i:=j;
    op:=thestring[i];
    case op of
      '+','-': priority:=1;
      '*','/': priority:=2;
      '^':priority:=3;
    end;
    i1:=i0; j1:=i-i0; i2:=i+1; j2:=i0+j0-1-i;
    if j1>0 then if j2>0 then
    begin
      checkbracketnum(i1,j1,checks); if checks then
      checkbracketnum(i2,j2,checks); if checks then
      begin
        checkvar(i1,j1,varsort,checks);
        if not checks then
           checknum(i1,j1,num,checks);
        if not checks then
          checkparam(i1,j1,parsort,checks);
        if not checks then
          checkbrack(i1,j1,i3,j3,i4,j4,kind,num,varsort,parsort,numvar,checks);
        if not checks then
        begin
          checkmin(i1,j1,i3,j3,checks);
          checks:=checks and (priority < 3);
        end;
        if not checks then
        begin
          checkoperation(i1,j1,
            i3,j3,i4,j4,prior,fsort,checks);
          checks:=checks and (prior >=priority);
        end;
        if not checks then
         check2varfunct(i1,j1,
         i3,j3,i4,j4,fsort,checks);
        if not checks then
         checkfunct(i1,j1,i3,j3,fsort,checks);
        if checks then
        begin
          checkvar(i2,j2,varsort,checks); if checks then break;
          checknum(i2,j2,num,checks);if checks then break;
          checkparam(i2,j2,parsort,checks); if checks then break;
          checkbrack(i2,j2,i3,j3,i4,j4,kind,num,varsort,parsort,numvar,checks);
          if checks then
          begin
            break;
          end;
          checkoperation(i2,j2,
            i3,j3,i4,j4,prior,fsort,checks);
          checks:=checks and (prior>priority);
          if checks then break;
          checkfunct(i2,j2,
            i3,j3,fsort,checks);if checks then break;
          check2varfunct(i2,j2,
            i3,j3,i4,j4,fsort,checks);if checks then break;
        end;
      end;
    end;
  until checks or (i>=i0+j0-1) or (j=i0-1);
  if checks then
  case op of
    '+':kind:=sum;
    '-':kind:=diff;
    '*':kind:=prod;
    '/':kind:=divis;
    '^':begin
          kind:=realpower;
          checknum(i2,j2,num,che);
          if che then
          if trunc(num)=num then
          begin
            case trunc(num) of
              2:kind:=square;
              3:kind:=third;
              4:kind:=forth;
            else
              kind:=intpower;
            end;
          end
          else begin
            checkbrack(i2,j2,i3,j3,i4,j4,kind,num,varsort,parsort,numvar,che);
            if che then
            begin
              checknum(i2+1,j2-2,num,che);
              if che then if trunc(num)=num then
              begin
                case trunc(num) of
                  2: kind:=square;
                  3: kind:=third;
                  4: kind:=forth;
                else  kind:=intpower; end;
              end;
            end;
          end;
        end;
  end; {case}
end;

procedure check2varfunct(i0,j0:byte;
       var i1,j1,i2,j2:byte;var fsort:ttermkind;var checks:boolean);
var num:extended; parsort,varsort:word; numvar:byte;
  procedure checkcomma(i0,j0:byte; var i1,j1,i2,j2:byte; var checks:boolean);
  var i3,j3,i4,j4:byte; i,j:integer;
  begin
    checks:=false;
    i:=i0-1;
    repeat
      j:=pos(',',copy(thestring,i+1,j0-(i-i0+1)));
      if j>0 then
      begin
        i:=i+j;
        if (i<i0+j0-1) and (i>i0) then
        begin
          i1:=i0; j1:=i-i0; i2:=i+1; j2:=i0+j0-1-i;
          checksyntax(i1,j1,i3,j3,i4,j4,fsort,num,varsort,parsort,numvar,checks);
          if checks then
          checksyntax(i2,j2,i3,j3,i4,j4,fsort,num,varsort,parsort,numvar,checks);
        end;
      end;
    until checks or (i>=i0+j0-1) or (j=0);
  end;
begin
  checks:=false;
  if copy(thestring,i0,3)='min' then
  begin
    if (thestring[i0+3]='(') and (thestring[i0+j0-1]=')') then
    begin
      checkcomma(i0+4,j0-5,i1,j1,i2,j2,checks);
    end;
    if checks then begin fsort:=minim; exit; end;
  end;
  if copy(thestring,i0,3)='max' then
  begin
    if (thestring[i0+3]='(') and (thestring[i0+j0-1]=')') then
    begin
      checkcomma(i0+4,j0-5,i1,i2,j1,j2,checks);
    end;
    if checks then begin fsort:=maxim; exit; end;
  end;
  if copy(thestring,i0,2)='rn' then
  begin
    if (thestring[i0+2]='(') and (thestring[i0+j0-1]=')') then
    begin
      checkcomma(i0+3,j0-4,i1,j1,i2,j2,checks);
    end;
    if checks then begin fsort:=randfunc; exit; end;
  end;
  if copy(thestring,i0,3)='arg' then
  begin
    if (thestring[i0+3]='(') and (thestring[i0+j0-1]=')') then
    begin
      checkcomma(i0+4,j0-5,i1,j1,i2,j2,checks);
    end;
    if checks then begin fsort:=argu; exit; end;
  end;
  if copy(thestring,i0,1)='r' then
  begin
    if (thestring[i0+1]='(') and (thestring[i0+j0-1]=')') then
    begin
      checkcomma(i0+2,j0-3,i1,j1,i2,j2,checks);
    end;
    if checks then begin fsort:=radius;exit; end;
  end;
  if copy(thestring,i0,2)='rm' then
  begin
    if (thestring[i0+2]='(') and (thestring[i0+j0-1]=')') then
    begin
      checkcomma(i0+3,j0-4,i1,j1,i2,j2,checks);
    end;
    if checks then begin fsort:=randrand; exit; end;
  end;
  if copy(thestring,i0,2)='lt' then
  begin
    if (thestring[i0+2]='(') and (thestring[i0+j0-1]=')') then
    begin
      checkcomma(i0+3,j0-4,i1,j1,i2,j2,checks);
    end;
    if checks then begin fsort:=less; exit; end;
  end;
  if copy(thestring,i0,2)='le' then
  begin
    if (thestring[i0+2]='(') and (thestring[i0+j0-1]=')') then
    begin
      checkcomma(i0+3,j0-4,i1,j1,i2,j2,checks);
      if checks then begin fsort:=lessequal; exit; end;
    end;
  end;
  if copy(thestring,i0,2)='eq' then
  begin
    if (thestring[i0+2]='(') and (thestring[i0+j0-1]=')') then
    begin
      checkcomma(i0+3,j0-4,i1,j1,i2,j2,checks);
      if checks then begin fsort:=equal; exit; end;
    end;
  end;
  if copy(thestring,i0,2)='ne' then
  begin
    if (thestring[i0+2]='(') and (thestring[i0+j0-1]=')') then
    begin
      checkcomma(i0+3,j0-4,i1,j1,i2,j2,checks);
      if checks then begin fsort:=notequal; exit; end;
    end;
  end;
end;


procedure checkfunct(i0,j0:byte;
   var i1,j1:byte;var fsort:ttermkind;var checks:boolean);
var num:extended; varsort,parsort:word;  numvar:byte;

 procedure checkArgument(i0,j0:byte; var i1,j1:byte);
 var i2,j2,i3,j3:byte;
 begin
   checkbrack(i0,j0,i2,j2,i3,j3,fsort,num,varsort,parsort,numvar,checks);
   if checks then begin i1:=i0+1; j1:=j0-2; end;
 end;

begin
  checks:=false;
  if copy(thestring,i0,3)='cos' then
  begin
    checkArgument(i0+3,j0-3,i1,j1);
    if checks then
      begin fsort:=cosine; exit; end;
  end;
  if copy(thestring,i0,3)='sin' then
  begin
    checkargument(i0+3,j0-3,i1,j1);
    if checks then
      begin fsort:=sine; exit; end;
  end;
  if copy(thestring,i0,3)='exp' then
  begin
    checkArgument(i0+3,j0-3,i1,j1);
    if checks then
      begin fsort:=expo; exit; end;
  end;
  if copy(thestring,i0,2)='ln' then
  begin
    checkArgument(i0+2,j0-2,i1,j1);
    if checks then
      begin fsort:=logar; exit; end;
  end;
  if copy(thestring,i0,6)='arctan' then
  begin
    checkArgument(i0+6,j0-6,i1,j1);
    if checks then
      begin fsort:=arctang; exit; end;
  end;
  if copy(thestring,i0,4)='sqrt' then
  begin
    checkArgument(i0+4,j0-4,i1,j1);
    if checks then
      begin fsort:=sqroot; exit; end;
  end;
  if copy(thestring,i0,3)='abs' then
  begin
    checkArgument(i0+3,j0-3,i1,j1);
    if checks then
      begin fsort:=abso; exit; end;
  end;
  if copy(thestring,i0,4)='heav' then
  begin
    checkArgument(i0+4,j0-4,i1,j1);
    if checks then
      begin fsort:=heavi; exit; end;
  end;
  if copy(thestring,i0,2)='ph' then
  begin
    checkArgument(i0+2,j0-2,i1,j1);
    if checks then begin fsort:=phase; exit; end;
  end;
  if copy(thestring,i0,4)='sinh' then
  begin
    checkArgument(i0+4,j0-4,i1,j1);
    if checks then begin fsort:=hypersine; exit; end;
  end;
  if copy(thestring,i0,4)='cosh' then
  begin
    checkArgument(i0+4,j0-4,i1,j1);
    if checks then begin fsort:=hypercosine; exit; end;
  end;
  if copy(thestring,i0,2)='fr' then
  begin
    checkArgument(i0+2,j0-2,i1,j1);
    if checks then begin fsort:=fraction; exit; end;
  end;
  if copy(thestring,i0,3)='tan' then
  begin
    checkArgument(i0+3,j0-3,i1,j1);
    if checks then begin fsort:=tangent; exit; end;
  end;
  if copy(thestring,i0,4)='tanh' then
  begin
    checkArgument(i0+4,j0-4,i1,j1);
    if checks then begin fsort:=hypertangent; exit; end;
  end;
  if copy(thestring,i0,6)='arcsin' then
  begin
    checkArgument(i0+6,j0-6,i1,j1);
    if checks then begin fsort:=arcsine; exit; end;
  end;
  if copy(thestring,i0,6)='arccos' then
  begin
    checkArgument(i0+6,j0-6,i1,j1);
    if checks then begin fsort:=arccosine; exit; end;
  end;
end;


const maxlevels=30;  maxlevelsize=50;




type

         termpointer=^termrec;

         termrec=record
                 i0,j0,i1,j1,i2,j2:byte;
                 termkind:ttermkind;
                 numvar:byte;
                 posit:array[1..3] of integer;
                 next1,next2,prev:termpointer
                 end;


         levelsizearray=array[0..maxlevels] of integer;

procedure ini(var theop:operationpointer;term:ttermkind);
begin
  new(theop);
  with theop^ do
  begin
    arg1:=nil; arg2:=nil; dest:=nil; next:=nil;
    opnum:=ord(term);
  end;
end;

procedure parsefunction(ss:string; varstring:Tvarstring; parstring:tparstring;
            var fop:operationpointer;
            var point:tVarpoints;
            var par:tParpoints;
            var numop:integer;
           var error:boolean);

var checks,done,predone,found:boolean; l,i,levels,p,code:integer;
      ab,levelsize:levelsizearray;
    i3,j3,i4,j4:byte;
    firstterm,next1term,next2term,lastterm:termpointer; kind:ttermkind;
    matrix:array[0..maxlevels,1..maxlevelsize] of operationpointer;
    lastop:operationpointer;
    num:extended; varsort,parsort:word; numv:byte;



begin
  lastop:=nil;
  for i:=1 to 3 do
  point[i]:=nil;
  for i:=1 to 6 do
  par[i]:=nil;
  fop:=nil;
  error:=false;
  thestring:=ss;
  thevar:=varstring; thepar:=parstring;
  chopblanks(thestring);
  checksyntax(1,length(thestring),i3,j3,i4,j4,kind,num,varsort,parsort,numv,checks);
  if not checks then
  begin
    error:=true; exit;
  end;
  for i:=1 to 3 do
  new(point[i]);
  for i:=1 to 6 do
  new(par[i]);
  done:=false;
  levels:=0;
  levelsize[0]:=1;
  for l:=0 to maxlevels do
    ab[l]:=0;
  new(firstterm);
  firstterm^.i0:=1; firstterm^.j0:=length(thestring);
  with firstterm^ do
  begin
    i1:=1; j1:=1; i2:=1; j2:=1; termkind:=variab; numvar:=0;
    next1:=nil; next2:=nil; prev:=nil;
    new(matrix[0,1]);
    with matrix[0,1]^ do
    begin
      arg1:=nil; arg2:=nil; dest:=nil;
      opnum:=ord(variab); next:=nil;
    end;
  end;
  lastterm:=firstterm;
  lastterm^.posit[1]:=0;
  lastterm^.posit[2]:=1;
  lastterm^.posit[3]:=1;
  repeat
    predone:=false;
    repeat
      l:=lastterm^.posit[1];
      i:=lastterm^.posit[2];
      if lastterm^.next1=nil then
      with lastterm^ do
      begin
        checksyntax(i0,j0,i1,j1,i2,j2,termkind,num,varsort,parsort,numvar,checks);
        if checks then
        begin
          case termkind of
            variab: begin
                      if posit[3]=1 then matrix[l,i]^.arg1:=point[varsort]
                      else matrix[l,i]^.arg2:=point[varsort];
                    end;
             param: begin
                      if posit[3]=1 then matrix[l,i]^.arg1:=par[parsort]
                      else matrix[l,i]^.arg2:=par[parsort];
                    end;
           constant:begin
                      if posit[3]=1 then
                      begin
                        new(matrix[l,i]^.arg1);
                        matrix[l,i]^.arg1^:=num;
                      end else
                      begin
                        new(matrix[l,i]^.arg2);
                        matrix[l,i]^.arg2^:=num;
                      end;
                    end;
          randfunc: begin
                      val(copy(thestring,i1,j1),num,code);
                      randomsize:=round(num);
                      randomiterates:=true;
                      randomize;
                    end;
          randrand: begin
                      contrand:=true;
                      randomize;
                    end;
          end; {case}
        end; {if checks}
      end; {with lastterm^}
      if lastterm^.numvar=1 then
      begin
        new(next1term);
        l:=l+1;
        if l>maxlevels then
        begin
          error:=true; exit;
        end;
        if levels<l then levels:=l;
        i:=ab[l]+1;
        if i>maxlevelsize then
        begin
          error:=true; exit;
        end;
        with next1term^ do
        begin
          i0:=lastterm^.i1;
          j0:=lastterm^.j1;
          prev:=lastterm;
          posit[1]:=l;  posit[2]:=i; posit[3]:=1;
          termkind:=variab;
          j1:=1; i1:=1; j2:=1; i2:=1; num:=0;
          next1:=nil; next2:=nil;
          ini(matrix[l,i],lastterm^.termkind);
          p:=lastterm^.posit[3];
          new(matrix[l,i]^.dest);
          matrix[l,i]^.dest^:=0;
          if p=1 then
          matrix[lastterm^.posit[1],lastterm^.posit[2]]^.arg1:=
                       matrix[l,i]^.dest else
          matrix[lastterm^.posit[1],lastterm^.posit[2]]^.arg2:=
                       matrix[l,i]^.dest;
        end; {with next1term^}
        lastterm^.next1:=next1term;
        ab[l]:=ab[l]+1;
      end;
      if lastterm^.numvar=2 then
      begin
        if lastterm^.next1=nil then
        begin
          new(next1term);
          l:=l+1;
          if l>maxlevels then
          begin
            error:=true; exit;
          end;
          if levels<l then levels:=l;
          i:=ab[l]+1;
          if i>maxlevelsize then
          begin
            error:=true; exit;
          end;
          with next1term^ do
          begin
            i0:=lastterm^.i1;
            j0:=lastterm^.j1;
            prev:=lastterm;
            posit[1]:=l;
            posit[2]:=i; posit[3]:=1;
            num:=0;
            j1:=1; i1:=1; j2:=1; i2:=1; termkind:=variab;
            next1:=nil; next2:=nil;
            ini(matrix[l,i],lastterm^.termkind);
            p:=lastterm^.posit[3];
            new(matrix[l,i]^.dest);
            matrix[l,i]^.dest^:=0;
            if p=1 then
            matrix[lastterm^.posit[1],lastterm^.posit[2]]^.arg1:=
                           matrix[l,i]^.dest else
            matrix[lastterm^.posit[1],lastterm^.posit[2]]^.arg2:=
                           matrix[l,i]^.dest;
          end;
          lastterm^.next1:=next1term;
        end {if lastterm.next1=nil}
        else
        begin
          new(next2term);
          l:=l+1;
          if l>maxlevels then
          begin
            error:=true; exit;
          end;
          if levels<l then
          levels:=l;
          i:=ab[l]+1;
          if i>maxlevelsize then
          begin
            error:=true; exit;
          end;
          with next2term^ do
          begin
            i0:=lastterm^.i2;
            j0:=lastterm^.j2;
            prev:=lastterm;
            posit[1]:=l; posit[2]:=i; posit[3]:=2;
            num:=0;
            j1:=1; i1:=1; j2:=1; i2:=1; termkind:=variab;
            next1:=nil; next2:=nil;
          end;
          lastterm^.next2:=next2term;
          ab[l]:=ab[l]+1;
        end;
      end; {if lastterm.numvar=2}
      if lastterm^.next1=nil then
      predone:=true
      else
      if lastterm^.next2=nil then
      lastterm:=lastterm^.next1
      else
      lastterm:=lastterm^.next2;
    until predone;
    if lastterm=firstterm then
    begin
      done:=true;
      dispose(lastterm);
      firstterm:=nil;
    end
    else
    begin
      repeat
        if lastterm^.next1<>nil then
        dispose(lastterm^.next1);
        if lastterm^.next2<>nil then
        dispose(lastterm^.next2);
        lastterm:=lastterm^.prev;
      until ((lastterm^.numvar=2) and
            (lastterm^.next2=nil)) or (lastterm=firstterm);
      if (lastterm=firstterm) and ((firstterm^.numvar=1)
               or ((firstterm^.numvar=2) and (firstterm^.next2<>nil))) then
      done:=true;
    end;
  until done;
  if firstterm<>nil then
  begin
    if firstterm^.next1<>nil then dispose(firstterm^.next1);
    if firstterm^.next2<>nil then dispose(firstterm^.next2);
    dispose(firstterm);
  end;
  for l:=1 to levels do
    levelsize[l]:=ab[l];
  if levels=0 then
  begin
    fop:=matrix[0,1];
    fop^.dest:=fop^.arg1; fop^.next:=nil;
    numop:=0;
  end
  else
  begin
    for l:=levels downto 1 do
    for i:=1 to levelsize[l] do
    begin
      if (l=levels) and (i=1) then
      begin
        numop:=1;
        fop:=matrix[l,i];
        lastop:=fop;
      end
      else
      begin
        inc(numop);
        lastop^.next:=matrix[l,i];
        lastop:=lastop^.next;
      end;
    end; {for l,i}
    with matrix[0,1]^ do
    begin
      arg1:=nil; arg2:=nil; dest:=nil;
    end;
    dispose(matrix[0,1]);
  end; {if levels>0}
end;

end.