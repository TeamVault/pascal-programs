Program Stiva5U;
{ program de lucru cu stiva, varianta modulara
  stiva este implementata ca tablou de pointeri la element
  alocat dinamic si flexibil }

uses UStiva5;

{$I operatm.pas}

{$I stivam.run}

Begin
  WriteLn('Stiva5U - Stiva modulara, implementata ca tablou dinamic si flexibil');
  WriteLn('          de pointeri la element, parametru');
  {S.Virf := 3;}    { S nu este accesibila, deoarece este declarata
                      locala in procedura Run (inclusa in fisierul
                      stivam.run)
                    }
  Run
End. { Stiva5U }

