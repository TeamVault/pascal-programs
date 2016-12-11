//------------------------------------------------------------------------
//
// Author      : Maarten Kronberger
// Email       : Maartenk@tinderbox.co.za
// Website     : http://www.sulaco.co.za
//               http://www.tinderbox.co.za
// Date        : 6 October 2002
// Version     : 1.0
// Description : Bezier Curve Generator/Creator
//
// Special thanks to Digiben and the guys at www.gametutorials.com for the
// bezier curve source. :D
//------------------------------------------------------------------------
unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm2 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Button1: TButton;
    Label18: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
begin
  Close;
end;

end.
