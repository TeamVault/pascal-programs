Program Stiva1U;
{ program de lucru cu stiva, varianta modulara
  stiva este implementata ca tablou }

uses Ustiva1;

{$I operatm.pas}

{$I stivam.run}

Begin
  WriteLn('Stiva1U - Stiva varianta modulara, tablou, parametru');
  {S.Virf := 3;}    { S nu este accesibila, deoarece este declarata
                      locala in procedura Run (inclusa in fisierul
                      stivam.run)
                    }
  Run
End. { Stiva1U }

