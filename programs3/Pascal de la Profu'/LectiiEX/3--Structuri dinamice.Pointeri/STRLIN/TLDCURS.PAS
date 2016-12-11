Program TLDCurs;
{ program de test pentru unit-urile ULDCursD si ULDCursA
}
Uses
 Crt, UFile, ULDCursD;
{ Crt, UFile, ULDCursA; }

  var
    L: Lista;
    i: Integer;
    Info: TInfo;
    Esec: Boolean;
    Ch: Char;

  begin
    Creeaza(L);            { creeaza o lista vida }
    Repeat
      ClrScr;
      WriteLn('TLDCurs - program de test pentru lista dublu inlantuita');
      WriteLn('Memoria dinamica disponibila este: ', MemAvail, ' byte');
      WriteLn('Operatiile posibile sunt');
      WriteLn('A. Actualizeaza elementul curent din lista');
      WriteLn('F. Insereaza un nod nou in capul listei');
      WriteLn('I. Insereaza un nod nou dupa nodul curent');
      WriteLn('S. Insereaza un nod nou in coada listei');
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
                 Extrage(L, I);
                 WriteLn('Elementul curent are informatia: ', I:4);
                 Write('Noua valoare este: ');
                 ReadLn(I);
                 Modifica(L, I)
               end;
        'F': begin
               L.Cursor := Zero;
               Write('Informatia de inserat in cap este: ');
               ReadLn(I);
               Insereaza(L, I)
             end;
        'I': begin
               Write('Informatia de inserat dupa elementul curent este: ');
               ReadLn(I);
               Insereaza(L, I)
             end;
        'S': begin
               Ultimul(L);
               Write('Informatia de inserat in coada este: ');
               ReadLn(I);
               Insereaza(L, I)
             end;
        'C': begin
               Write('Informatia care se cauta este: ');
               ReadLn(I);
               If Cauta(L, I)
                 then WriteLn('Succes')
                 else WriteLn('Insucces');
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
                 Extrage(L, I);
                 WriteLn('Nodul curent contine informatia: ', I);
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
  end. { TLDCurs }
