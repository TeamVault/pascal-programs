Program Coada1U;
{ program de lucru cu coada, varianta modulara
  coada este implementata ca tablou }

uses UCoada1;

{$I operatm.pas}

{$I coadam.run}

Begin
  WriteLn('Coada1U - Coada varianta modulara, tablou circular, parametru');
  {C.Inceput:= 3;}  { C nu este accesibila, deoarece este declarata
                      locala in procedura Run din fisierul
                      coadam.run
                    }
  Run
End. { Coada1U }

