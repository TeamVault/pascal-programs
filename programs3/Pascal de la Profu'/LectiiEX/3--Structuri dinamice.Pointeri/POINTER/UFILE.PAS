Unit UFile;
{ contine rutine de lucru cu fisiere }
Interface
  function Exista(NumeFisier: String): Boolean;
  procedure Asteapta;
  function Continua(M: String): Boolean;

Implementation
  Uses
    Crt;

  function Exista(NumeFisier: String): Boolean;
  { intoarce
      True  daca fisierul extern reprezentat de NumeFisier exista
      False altfel
  }
    var
      f: File;
    begin
      {$I-}                  { comuta pe off indicatorul $I }
      Assign(f, NumeFisier);
      Reset(f);
      Close(f);
      {$I+}                  { comuta pe on indicatorul $I }
      Exista := (IOResult = 0) and (NumeFisier <> '')
    end; { Exista }

  procedure Asteapta;
    { afiseaza mesajul "Apasati o tasta..." si apoi asteapta apasarea
      unei taste
    }
    var
      ch: Char;
    begin
      Write('Apasati o tasta...');
      ch := ReadKey;
      WriteLn
    end; { Asteapta }

  function Continua(M: String): Boolean;
    { afiseaza mesajul M si apoi asteapta apasarea
      unei taste
      intoarce
        True  daca tasta = 'D', 'd'
        False altfel
    }
    var
      ch: Char;
    begin
      Write(M, '(D=Da): ');
      ch := ReadKey;
      Continua := ch in ['d', 'D']
    end; { Continua }

  procedure Fictiva; { locala in modul; invizibila in afara }
    begin
    end; { Fictiva }

begin { cod de initializare vid }
end. { UFile }