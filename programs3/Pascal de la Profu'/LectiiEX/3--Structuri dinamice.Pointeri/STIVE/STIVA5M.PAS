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
  {S.Virf := 3;}    { S nu este accesibila, deoarece este declarata
                      in partea de implementare a unit-ului UStiva5M
                      ascunderea informatiei:
                        - S nu este vizibil in programul apelant
                        - S este accesibil numai prin operatii
                    }
  Run
End. { Stiva5M }

