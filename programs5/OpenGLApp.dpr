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
program OpenGLApp;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
