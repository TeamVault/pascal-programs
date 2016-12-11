unit about;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TForm2 = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Button1: TButton;
    procedure Label5Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses ShellAPI;

{$R *.DFM}

procedure TForm2.Label5Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'http://www.sulaco.co.za', '', '', SW_SHOW);
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  Close;
end;

end.
