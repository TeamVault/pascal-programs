Program Stiva4U;
{ program de lucru cu stiva, varianta modulara
  stiva este implementata ca lista de pointeri la element }

uses UStiva4;

{$I operatm.pas}

{$I stivam.run}

Begin
  WriteLn('Stiva4U - Stiva modulara, lista de pointeri la element, parametru');
  {S.Virf := 3;}    { S nu este accesibila, deoarece este declarata
                      locala in procedura Run (inclusa in fisierul
                      stivam.run)
                    }
  Run
End. { Stiva4U }

