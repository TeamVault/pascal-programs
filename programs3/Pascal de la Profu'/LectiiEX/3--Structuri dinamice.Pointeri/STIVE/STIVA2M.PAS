Program Stiva2M;
{ program de lucru cu stiva, varianta modulara
  stiva este implementata ca lista inlantuita }

uses UStiva2m;

{$I operatp.pas}

{$I stivap.run}

Begin
  WriteLn('Stiva2M - Stiva varianta modulara, lista inlantuita, variabila globala');
  {S.Virf := 3;}    { S nu este accesibila, deoarece este declarata
                      in partea de implementare a unit-ului UStiva2M
                      ascunderea informatiei:
                        - S nu este vizibil in programul apelant
                        - S este accesibil numai prin operatii
                    }
  Run
End. { Stiva2M }

