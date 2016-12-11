Program Coada2M;
{ program de lucru cu coada, varianta modulara
  stiva este implementata ca lista inlantuita }

uses UCoada2m;

{$I operatp.pas}

{$I coadap.run}

Begin
  WriteLn('Coada2M - Coada varianta modulara, lista inlantuita, variabila globala');
  {C.Inceput:= 3;}  { C nu este accesibila, deoarece este declarata
                      in partea de implementare a unit-ului UCoada2M
                      ascunderea informatiei:
                        - C nu este vizibil in programul apelant
                        - C este accesibil numai prin operatii
                    }
  Run
End. { Coada2M }

