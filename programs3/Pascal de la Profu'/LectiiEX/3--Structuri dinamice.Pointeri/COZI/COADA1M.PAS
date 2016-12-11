Program Coada1M;
{ program de lucru cu coada, varianta modulara
  coada este implementata ca tablou circular }

uses UCoada1m;

{$I operatp.pas}

{$I coadap.run}

Begin
  WriteLn('Coada1M - Coada varianta modulara, tablou circular, variabila globala');
  {C.Inceput:= 3;}  { C nu este accesibila, deoarece este declarata
                      in partea de implementare a unit-ului UCoada1M
                      ascunderea informatiei:
                        - C nu este vizibil in programul apelant
                        - C este accesibil numai prin operatii
                    }
  Run
End. { Coada1M }

