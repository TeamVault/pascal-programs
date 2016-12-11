Program Stiva1M;
{ program de lucru cu stiva, varianta modulara
  stiva este implementata ca tablou }

uses UStiva1M;

{$I operatp.pas}

{$I stivap.run}

Begin
  WriteLn('Stiva1M - Stiva varianta modulara, tablou, variabila globala');
  {S.Virf := 3;}    { S nu este accesibila, deoarece este declarata
                      in partea de implementare a unit-ului UStiva1M
                      ascunderea informatiei:
                        - S nu este vizibil in programul apelant
                        - S este accesibil numai prin operatii
                    }
  Run
End. { Stiva1M }

