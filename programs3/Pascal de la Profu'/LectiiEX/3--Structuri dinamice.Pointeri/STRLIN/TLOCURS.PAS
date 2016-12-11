Program TLOCurs;
{ program de test pentru unit-urile ULOCursD si ULOCursA
  implementari de liste ordonate
}
Uses
{ Crt, UFile, ULOCursD; }
 Crt, UFile, ULOCursA;

  var
    L: Lista;
    i: Integer;
    Info: TInfo;
    Esec: Boolean;
    Ch: Char;

  Procedure AfiseazaInfo(M: String; var I: TInfo);
    begin
      WriteLn(M, ':', InfoToString(I))
    end; { AfiseazaInfo }

  Procedure CitesteInfo(M: String; var I: TInfo);
    begin
      WriteLn(M);
      Write('Cheia: ');
      ReadLn(Info.Cheie);
      Write('Rest: ');
      ReadLn(Info.Rest)
    end; { CitesteInfo }

  begin
    Creeaza(L);            { creeaza o lista vida }
    Repeat
      ClrScr;
      WriteLn('TLOCurs - program de test pentru lista ordonata');
      WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
      WriteLn('Operatiile posibile sunt');
      WriteLn('A. Actualizeaza elementul curent din lista');
      WriteLn('I. Insereaza un nod nou in lista');
      WriteLn('C. Cauta un element cu informatia cunoscuta');
      WriteLn('P. Pozitionare pe primul nod');
      WriteLn('U. Pozitionare pe nodul urmator');
      WriteLn('R. Pozitionare pe nodul precedent');
      WriteLn('L. Pozitionare pe ultimul nod');
      WriteLn('E. Extrage informatia din nodul curent');
      WriteLn('V. Testeaza daca lista este vida');
      WriteLn('T. Tipareste elementele listei');
      WriteLn('G. Sterge nodul curent');
      WriteLn('D. Sterge toate nodurile listei');
      WriteLn('M. Afiseaza memoria disponibila');
      WriteLn('X. Termina executia programului');
      Write('Dati codul operatiei dorite: ');
      ReadLn(Ch);
      Ch := UpCase(Ch);
      Case Ch of
        'A': if Vida(L)
               then WriteLn('Eroare: Lista este vida!')
               else begin
                 Extrage(L, Info);
                 AfiseazaInfo('Elementul curent are informatia', Info);
                 CitesteInfo('Introduceti noua valoare', Info);
                 Modifica(L, Info)
               end;
        'I': begin
               CitesteInfo('Informatia de inserat este:', Info);
               Insereaza(L, Info)
             end;
        'C': begin
               Write('Cheia care se cauta este: ');
               ReadLn(Info.Cheie);
               If Cauta(L, Info.Cheie)
                 then begin
                   Urmatorul(L, esec);
                   Extrage(L, Info);
                   AfiseazaInfo('Elementul cautat are informatia', Info)
                 end else WriteLn('Insucces');
             end;
        'P': if Vida(L)
               then WriteLn('Eroare! Lista este vida!')
               else Primul(L);
        'U': if Vida(L)
               then WriteLn('Eroare! Lista este vida!')
               else begin
                 Urmatorul(L, Esec);
                 If Esec
                   then WriteLn('Suntem pe ultimul element!')
               end;
        'R': if Vida(L)
               then WriteLn('Eroare! Lista este vida!')
               else begin
                 Precedentul(L, Esec);
                 If Esec
                   then WriteLn('Suntem pe primul element!')
               end;
        'L': if Vida(L)
               then WriteLn('Eroare! Lista este vida!')
               else Ultimul(L);
        'E': if Vida(L)
               then WriteLn('Eroare! Lista este vida!')
               else begin
                 Extrage(L, Info);
                 AfiseazaInfo('Nodul curent contine informatia', Info);
               end;
        'V': if Vida(L)
               then WriteLn('Lista este vida')
               else WriteLn('Lista nu este vida');
        'T': Traverseaza(L);
        'G': If Vida(L)
               then WriteLn('Lista este vida')
               else If L.Cursor = Zero
                      then WriteLn('Cursorul nu este pozitionat')
                      else Sterge(L);
        'D': Elibereaza(L);
        'M': WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
      End;
      Asteapta
    Until Ch = 'X';
    Elibereaza(L)
  end. { TLOCurs }
