Program Stiva3U;
{ program de lucru cu stiva, varianta modulara
  stiva este implementata ca tablou de pointeri la element }

uses UStiva3;

{$I operatm.pas}

{$I stivam.run}

Begin
  WriteLn('Stiva3U - Stiva modulara, tablou de pointeri la element, parametru');
  {S.Virf := 3;}    { S nu este accesibila, deoarece este declarata
                      locala in procedura Run (inclusa in fisierul
                      stivam.run)
                    }
  Run
End. { Stiva3U }

