Program Stiva4M;
{ program de lucru cu stiva, varianta modulara
  stiva este implementata ca lista de pointeri la element }

uses UStiva4M;

{$I operatp.pas}

{$I stivap.run}

Begin
  WriteLn('Stiva4M - Stiva modulara, lista de pointeri la element, variabila globala');
  {S.Virf := 3;}    { S nu este accesibila, deoarece este declarata
                      in partea de implementare a unit-ului UStiva4M
                      ascunderea informatiei:
                        - S nu este vizibil in programul apelant
                        - S este accesibil numai prin operatii
                    }
  Run
End. { Stiva4M }

