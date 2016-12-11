Program Stiva2U;
{ program de lucru cu stiva, varianta modulara
  stiva este implementata ca lista inlantuita }

uses UStiva2;

{$I operatm.pas}

{$I stivam.run}

Begin
  WriteLn('Stiva2U - Stiva varianta modulara, lista inlantuita, parametru');
  {S.Virf := 3;}    { S nu este accesibila, deoarece este declarata
                      locala in procedura Run (inclusa in fisierul
                      stivam.run)
                    }
  Run
End. { Stiva2U }

