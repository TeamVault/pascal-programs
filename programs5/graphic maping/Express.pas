unit Express;
{$F+}
{$IFDEF WIN32}
{$H-}
{$ENDIF}


interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, pars, parsglb;

type

  TExpressEvaluator=function(x,y,z:extended):extended of object;

  EExpressError=class(Exception);
  {Is raised whenever the expression assigned is invalid.}

  TExpress = class(TComponent)
  private
    fparse:pparse;
    fparlist:TParString;
    fvarlist:TVarString;
    fparvalues:TParValues;
    fExpression:string;
    fTheFunction:TExpressEvaluator;
    ferror:boolean;
    procedure SetExpression(expr:string);
    function fdummy(x,y,z:extended):extended;
    function fTheRealThing(x,y,z:extended):extended;
    { Private declarations }
  protected
    { Protected declarations }
  public

    property Error:boolean read ferror;
    {read the value of Error to check whether the current expression has
    valid syntax}

    property TheFunction:TExpressEvaluator read fThefunction;

    constructor create(AOwner:TComponent); override;
    destructor destroy; override;

    {Call TheFunction to evaluate the current expression. Before you make
    any calls to TheFunction, check that the expression has valid syntax
    (->Error). If you call TheFunction for an invalid expression you get
    a GPF}

    procedure SetParameters(p1,p2,p3,p4,p5,p6:extended);
    {Set parameter values for the available 6 parameters -> SyntaxText property}

    { Public declarations }
  published
    property Expression:string read fexpression write SetExpression;
    {Expression is the string to be evaluated. For syntax -> SyntaxText property}

    property VariableList:TVarString read fvarlist write fvarlist;
    {String containing the characters for the 3 possible variables}

    property ParameterList:TParString read fparlist write fparlist;
    {String containing the characters for the 6 possible parameters}

    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TExpress]);
end;


constructor TExpress.Create;
var i:integer;
begin
  inherited create(aowner);
  fparse:=nil;
  fvarlist:='xyz';
  fparlist:='abcdef';
  for i:=1 to 6 do
  fparvalues[i]:=1;
  fExpression:='x';
  fThefunction:=fdummy;
end;

procedure TExpress.SetExpression(expr:string);
begin
  if fparse<>nil then dispose(fparse,done);
  fparse:=new(pparse,init(expr,fvarlist,fparlist,ferror));
  if ferror then
  begin
    dispose(fparse,done);
    fparse:=nil;
    fThefunction:=fdummy;
    raise EExpressError.Create('Error in Expression');
  end else
  begin
    fparse^.setparams(fparvalues);
    fExpression:=expr;
    fThefunction:=fTheRealThing;
  end;
end;

function TExpress.fdummy(x,y,z:extended):extended;
begin
  result:=1;
end;

function TExpress.fTheRealThing(x,y,z:extended):extended;
begin
  fparse^.f(x,y,z,result);
end;
  
procedure TExpress.setparameters;
begin
  if fparse<>nil then
  begin
    fparvalues[1]:=p1; fparvalues[2]:=p2; fparvalues[3]:=p3;
    fparvalues[4]:=p4; fparvalues[5]:=p5; fparvalues[6]:=p6;
    fparse^.setparams(fparvalues);
  end;
end;

Destructor TExpress.destroy;
begin
  if fparse<>nil then dispose(fparse,done);
  inherited destroy;
end;

end.

