Program Stiva3M;
{ program de lucru cu stiva, varianta modulara
  stiva este implementata ca tablou de pointeri la element }

uses UStiva3M;

{$I operatp.pas}

{$I stivap.run}

Begin
  WriteLn('Stiva3M - Stiva modulara, tablou de pointeri la element, variabila globala');
  {S.Virf := 3;}    { S nu este accesibila, deoarece este declarata
                      in partea de implementare a unit-ului UStiva3M
                      ascunderea informatiei:
                        - S nu este vizibil in programul apelant
                        - S este accesibil numai prin operatii
                    }
  Run
End. { Stiva3M }

