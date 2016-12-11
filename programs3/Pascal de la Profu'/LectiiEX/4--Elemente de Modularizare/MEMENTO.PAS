Memento

5 martie 1999

1. Cum se calculeaza catul a doua numere complexe
   procedura Imparteste din UComplex

  a + b*i   (a + b*i)(c - d*i)   (a + b*i)(c - d*i)
  ------- = ------------------ = ------------------
  c + d*i   (c + d*i)(c - d*i)        c*c + d*d

2. Folosirea ferestrei Call Stack (CTRL+F3)
   - inspectarea stivei de apeluri
   - determinarea instructiunii care a provocat apelul
     pentru fiecare apel
   - inlantuirea apelurilor
   - vizualizarea parametrilor de apel (actuali, efectivi)

3. Folosirea ferestrei Watch (CTRL + F7)
   - semnificatia variabilelor locale si globale
   - domenii de vizibilitate
   - corespondenta dintre parametrii formali ai unui subprogram
     si parametrii efectivi (de apel)
   - parametrii transmisi prin valoare sunt tratati ca
     variabile locale
   - variabilele locale nu sunt initializate la declarare
   - variabilele globale sunt initializate la declarare

4. Conversia explicita (typecast)
   - exemplu: functia ZiDinSaptamana (unit-ul UDataC)
