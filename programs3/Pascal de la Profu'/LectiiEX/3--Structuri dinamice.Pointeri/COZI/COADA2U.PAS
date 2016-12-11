Program Coada2U;
{ program de lucru cu stiva, varianta modulara
  coada este implementata ca lista inlantuita }

uses UCoada2;

{$I operatm.pas}

{$I coadam.run}

Begin
  WriteLn('Coada2U - Coada varianta modulara, lista inlantuita, parametru');
  {C.Inceput:= 3;}  { C nu este accesibila, deoarece este declarata
                      locala in procedura Run din fisierul
                      coadam.run
                    }
  Run
End. { Coada2U }

