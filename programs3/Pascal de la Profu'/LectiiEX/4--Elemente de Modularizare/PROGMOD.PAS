Programare modulara - notite

Ce este un modul:
  - unitate sintactica (fisier sursa)
  - se compileaza separat
  - ofera servicii (subprograme, tipuri de date, variabile, etc)
    care se pot folosi de catre alte module

Terminologie
  - unit - numele modulului in Borland (Turbo) Pasca;
           incepand cu versiunea 4.0
  - modul client: un modul care foloseste serviciile altui modul
  - modul server: un modul care-si ofera serviciile altui modul
  - export: declararea serviciilor ca publice
      in partea Interface
  - import: folosirea serviciilor oferite de alte module
      uses NumeModul1, NumeModul2, ..., NumeModul_n

Partile unui modul
  - antet
  - interfata: specifica toate serviciile publice
  - implementare: implementeaza toate serviciile
  - cod de initializare (optional)

Tipuri de servicii implementate intr-un modul
  - servicii publice - sunt declarate in partea de interfata
  - servicii private (locale) - apar numai in partea de implementare

Principiul ascunderii informatiei (implementarii)
  - un modul client are acces numai la serviciile publice ale
    modulului server

