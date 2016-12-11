Program Stiva5M;
{ program de lucru cu stiva, varianta modulara
  stiva este implementata ca tablou de pointeri la element
  alocat dinamic si flexibil }

uses UStiva5M;

{$I operatp.pas}

{$I stivap.run}

Begin
  WriteLn('Stiva5M - Stiva modulara, implementata ca tablou dinamic si flexibil');
  WriteLn('          de pointeri la element, variabila globala');
  Run
End.

